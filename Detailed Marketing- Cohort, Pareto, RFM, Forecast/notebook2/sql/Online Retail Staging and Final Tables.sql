CREATE TABLE online_retail (
  "InvoiceNo" TEXT,
  "StockCode" TEXT,
  "Description" TEXT,
  "Quantity" INTEGER,
  "InvoiceDate" TEXT,
  "UnitPrice" NUMERIC,
  "CustomerID" TEXT,
  "Country" TEXT
);

CREATE TABLE online_retail_final (
  "InvoiceNo" TEXT,
  "StockCode" TEXT,
  "Description" TEXT,
  "Quantity" INTEGER,
  "InvoiceDate" TEXT,
  "UnitPrice" NUMERIC,
  "CustomerID" TEXT,
  "Country" TEXT,
  "TotalPrice" NUMERIC
);
