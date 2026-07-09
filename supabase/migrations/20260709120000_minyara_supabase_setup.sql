-- Minyara Inventory: Supabase setup migration
-- Run via: supabase db push (after supabase link)

-- RLS policies
CREATE POLICY IF NOT EXISTS "Allow all access on categories" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Allow all access on products" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Allow all access on customers" ON customers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Allow all access on bills" ON bills FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Allow all access on bill_items" ON bill_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Allow all access on stock_adjustments" ON stock_adjustments FOR ALL USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS app_settings (
  id integer PRIMARY KEY DEFAULT 1,
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT app_settings_single_row CHECK (id = 1)
);

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Allow all access on app_settings" ON app_settings FOR ALL USING (true) WITH CHECK (true);

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

INSERT INTO storage.buckets (id, name, public)
VALUES ('products', 'products', true)
ON CONFLICT (id) DO NOTHING;
