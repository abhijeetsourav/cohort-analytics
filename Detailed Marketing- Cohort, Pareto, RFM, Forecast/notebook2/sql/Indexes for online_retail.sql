CREATE INDEX IF NOT EXISTS idx_invoice_no
ON online_retail (invoice_no);

CREATE INDEX IF NOT EXISTS idx_invoice_no_like
ON online_retail (invoice_no text_pattern_ops);

CREATE INDEX IF NOT EXISTS idx_customer_id
ON online_retail (customer_id);
