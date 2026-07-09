-- ============================================================
-- MINYARA — Supabase Database Fix Script
-- Run this in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

-- 1. Remove duplicate foreign keys (causes "more than one relationship" errors)
ALTER TABLE products DROP CONSTRAINT IF EXISTS fk_products_category;
ALTER TABLE bill_items DROP CONSTRAINT IF EXISTS fk_bill_items_product;
ALTER TABLE bill_items DROP CONSTRAINT IF EXISTS fk_bill_items_bill;
ALTER TABLE bills DROP CONSTRAINT IF EXISTS fk_bills_customer;
ALTER TABLE stock_adjustments DROP CONSTRAINT IF EXISTS fk_stock_adjustments_product;

-- 2. Ensure bill_items uses correct column names for Supabase
-- (quantity and total_price — not qty/total)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bill_items' AND column_name = 'qty'
  ) THEN
    ALTER TABLE bill_items RENAME COLUMN qty TO quantity;
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bill_items' AND column_name = 'total'
  ) THEN
    ALTER TABLE bill_items RENAME COLUMN total TO total_price;
  END IF;
END $$;

-- 3. Ensure products.is_active is boolean (not int)
ALTER TABLE products
  ALTER COLUMN is_active TYPE boolean
  USING CASE WHEN is_active::text IN ('1','true','t') THEN true ELSE false END;

ALTER TABLE products ALTER COLUMN is_active SET DEFAULT true;

-- 4. RLS policies (allow app access via anon key)
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['categories','products','customers','bills','bill_items','stock_adjustments','app_settings']
  LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('DROP POLICY IF EXISTS "Allow all access on %I" ON %I', t, t);
    EXECUTE format('CREATE POLICY "Allow all access on %I" ON %I FOR ALL USING (true) WITH CHECK (true)', t, t);
  END LOOP;
END $$;

-- 5. App settings table (for shop name, address, etc.)
CREATE TABLE IF NOT EXISTS app_settings (
  id integer PRIMARY KEY DEFAULT 1,
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT app_settings_single_row CHECK (id = 1)
);

INSERT INTO app_settings (id, settings)
VALUES (1, '{
  "shop_name": "MINYARA Printing",
  "shop_tagline": "A MOMENTS OF TECHNOLOGY",
  "shop_address": "143/7, Church rd, Welivita, Kaduwela",
  "shop_phone": "0786763999",
  "shop_email": "minyara.team.lk@gmail.com",
  "currency": "Rs.",
  "bill_prefix": "MIN-",
  "invoice_footer": ""
}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- 6. Product images storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('products', 'products', true)
ON CONFLICT (id) DO NOTHING;

-- 7. Bill + stock helper functions (used by the app)
CREATE OR REPLACE FUNCTION create_bill_with_items(
  p_bill_no text, p_customer_name text, p_customer_phone text,
  p_subtotal numeric, p_discount numeric, p_tax numeric, p_total numeric,
  p_paid_amount numeric, p_change_amount numeric, p_payment_method text,
  p_status text, p_notes text, p_items jsonb
) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
  v_bill_id integer; v_item jsonb; v_prod_id integer;
  v_qty integer; v_unit_price numeric; v_line_total numeric;
BEGIN
  INSERT INTO bills (bill_no, customer_name, customer_phone, subtotal, discount, tax, total,
                     paid_amount, change_amount, payment_method, status, notes)
  VALUES (p_bill_no, p_customer_name, p_customer_phone, p_subtotal, p_discount, p_tax, p_total,
          p_paid_amount, p_change_amount, p_payment_method, p_status, p_notes)
  RETURNING id INTO v_bill_id;
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
    v_prod_id := NULLIF(v_item->>'product_id', '')::integer;
    v_qty := (v_item->>'qty')::integer;
    v_unit_price := (v_item->>'unit_price')::numeric;
    v_line_total := v_qty * v_unit_price;
    INSERT INTO bill_items (bill_id, product_id, product_name, unit, quantity, unit_price, total_price)
    VALUES (v_bill_id, v_prod_id, v_item->>'product_name', COALESCE(v_item->>'unit', 'pcs'), v_qty, v_unit_price, v_line_total);
    IF v_prod_id IS NOT NULL THEN
      UPDATE products SET stock_qty = GREATEST(0, stock_qty - v_qty) WHERE id = v_prod_id;
      INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (v_prod_id, 'sale', v_qty, 'Bill ' || p_bill_no);
    END IF;
  END LOOP;
  RETURN jsonb_build_object('id', v_bill_id, 'bill_no', p_bill_no, 'total', p_total, 'change', p_change_amount);
END; $$;

CREATE OR REPLACE FUNCTION delete_bill_restore_stock(p_bill_id integer)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE v_bill_no text; r record;
BEGIN
  SELECT bill_no INTO v_bill_no FROM bills WHERE id = p_bill_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Bill not found'; END IF;
  FOR r IN SELECT * FROM bill_items WHERE bill_id = p_bill_id LOOP
    IF r.product_id IS NOT NULL THEN
      UPDATE products SET stock_qty = stock_qty + r.quantity WHERE id = r.product_id;
      INSERT INTO stock_adjustments (product_id, type, quantity, note)
      VALUES (r.product_id, 'return', r.quantity, 'Cancelled Bill ' || v_bill_no);
    END IF;
  END LOOP;
  DELETE FROM bill_items WHERE bill_id = p_bill_id;
  DELETE FROM bills WHERE id = p_bill_id;
END; $$;

CREATE OR REPLACE FUNCTION adjust_product_stock(
  p_product_id integer, p_type text, p_quantity integer, p_note text DEFAULT ''
) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE v_stock integer; v_delta integer;
BEGIN
  SELECT stock_qty INTO v_stock FROM products WHERE id = p_product_id AND is_active = true;
  IF NOT FOUND THEN RAISE EXCEPTION 'Product not found'; END IF;
  IF p_type = 'out' AND v_stock < p_quantity THEN RAISE EXCEPTION 'Insufficient stock. Available: %', v_stock; END IF;
  v_delta := CASE WHEN p_type = 'in' THEN p_quantity ELSE -p_quantity END;
  UPDATE products SET stock_qty = stock_qty + v_delta WHERE id = p_product_id;
  INSERT INTO stock_adjustments (product_id, type, quantity, note) VALUES (p_product_id, p_type, p_quantity, p_note);
  RETURN jsonb_build_object('new_stock', v_stock + v_delta);
END; $$;

GRANT EXECUTE ON FUNCTION create_bill_with_items TO anon, authenticated;
GRANT EXECUTE ON FUNCTION delete_bill_restore_stock TO anon, authenticated;
GRANT EXECUTE ON FUNCTION adjust_product_stock TO anon, authenticated;
