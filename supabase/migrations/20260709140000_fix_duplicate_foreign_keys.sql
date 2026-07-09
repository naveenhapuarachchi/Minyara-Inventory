-- Fix duplicate foreign keys that break Supabase embed joins
-- Run in Supabase SQL Editor if products/bills still show relationship errors

ALTER TABLE products DROP CONSTRAINT IF EXISTS fk_products_category;
ALTER TABLE bill_items DROP CONSTRAINT IF EXISTS fk_bill_items_product;
ALTER TABLE bill_items DROP CONSTRAINT IF EXISTS fk_bill_items_bill;
ALTER TABLE bills DROP CONSTRAINT IF EXISTS fk_bills_customer;
ALTER TABLE stock_adjustments DROP CONSTRAINT IF EXISTS fk_stock_adjustments_product;

-- Verify: each table should have only ONE foreign key per relationship
-- products.category_id -> categories.id  (products_category_id_fkey)
-- bill_items.product_id -> products.id     (bill_items_product_id_fkey)
-- bill_items.bill_id -> bills.id           (bill_items_bill_id_fkey)
-- bills.customer_id -> customers.id        (bills_customer_id_fkey)
-- stock_adjustments.product_id -> products.id (stock_adjustments_product_id_fkey)
