-- Membuat Temporary Table yang akan menyimpan agregasi penjualan bulanan berdasarkan produk
CREATE OR REPLACE TEMPORARY TABLE report_monthly_orders_product_agg AS
SELECT
  EXTRACT(YEAR FROM o.created_at) AS year,
  EXTRACT(MONTH FROM o.created_at) AS month,
  p.product_id,
  p.product_name,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.sale_price * oi.quantity) AS total_sales
FROM
  `bigquery-public-data.thelook_ecommerce.orders` o
JOIN
  `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON o.order_id = oi.order_id
JOIN
  `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.product_id
GROUP BY
  year,
  month,
  p.product_id,
  p.product_name;

-- Menampilkan produk dengan penjualan tertinggi setiap bulan
WITH monthly_top_products AS (
  SELECT
    year,
    month,
    product_id,
    product_name,
    total_sales,
    ROW_NUMBER() OVER (PARTITION BY year, month ORDER BY total_sales DESC) AS rank
  FROM
    report_monthly_orders_product_agg
)
SELECT
  year,
  month,
  product_id,
  product_name,
  total_sales
FROM
  monthly_top_products
WHERE
  rank = 1
ORDER BY
  year,
  month;
