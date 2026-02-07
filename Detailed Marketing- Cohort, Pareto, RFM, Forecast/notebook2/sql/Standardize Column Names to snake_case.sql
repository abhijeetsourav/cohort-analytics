ALTER TABLE online_retail RENAME COLUMN "InvoiceNo"   TO invoice_no;
ALTER TABLE online_retail RENAME COLUMN "StockCode"   TO stock_code;
ALTER TABLE online_retail RENAME COLUMN "Description" TO description;
ALTER TABLE online_retail RENAME COLUMN "Quantity"    TO quantity;
ALTER TABLE online_retail RENAME COLUMN "InvoiceDate" TO invoice_date;
ALTER TABLE online_retail RENAME COLUMN "UnitPrice"   TO unit_price;
ALTER TABLE online_retail RENAME COLUMN "CustomerID"  TO customer_id;
ALTER TABLE online_retail RENAME COLUMN "Country"     TO country;



ALTER TABLE online_retail_final RENAME COLUMN "InvoiceNo"   TO invoice_no;
ALTER TABLE online_retail_final RENAME COLUMN "StockCode"   TO stock_code;
ALTER TABLE online_retail_final RENAME COLUMN "Description" TO description;
ALTER TABLE online_retail_final RENAME COLUMN "Quantity"    TO quantity;
ALTER TABLE online_retail_final RENAME COLUMN "InvoiceDate" TO invoice_date;
ALTER TABLE online_retail_final RENAME COLUMN "UnitPrice"   TO unit_price;
ALTER TABLE online_retail_final RENAME COLUMN "CustomerID"  TO customer_id;
ALTER TABLE online_retail_final RENAME COLUMN "Country"     TO country;
ALTER TABLE online_retail_final RENAME COLUMN "TotalPrice"  TO total_price;
