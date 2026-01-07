Question 1: Top 10 products by revenue and quantity sold
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        COUNT(oi.order_id) AS times_ordered,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.unit_price) AS total_revenue,
        AVG(oi.unit_price) AS avg_selling_price
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status != 'Cancelled' OR o.status IS NULL
    GROUP BY p.product_id, p.product_name, p.category, p.subcategory
)
SELECT 
    product_name,
    category,
    subcategory,
    times_ordered,
    total_quantity_sold,
    total_revenue,
    avg_selling_price,
    ROUND((total_revenue / SUM(total_revenue) OVER()) * 100, 2) AS revenue_percentage
FROM product_sales
ORDER BY total_revenue DESC
LIMIT 10;

Question 2: Monthly Revenue Trend
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month_year,
        COUNT(DISTINCT o.order_id) AS order_count,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue,
        AVG(oi.quantity * oi.unit_price) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status IN ('Delivered', 'Shipped')
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT 
    month_year,
    order_count,
    customer_count,
    monthly_revenue,
    avg_order_value,
    LAG(monthly_revenue) OVER (ORDER BY month_year) AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month_year)) * 100.0 / 
        LAG(monthly_revenue) OVER (ORDER BY month_year), 
        2
    ) AS revenue_growth_percentage,
    SUM(monthly_revenue) OVER (
        ORDER BY month_year 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY month_year;

Question 3: Top 5 Customers by Total Spending
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.city,
        c.country,
        c.customer_segment,
        c.registration_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS total_spent,
        AVG(oi.quantity * oi.unit_price) AS avg_order_value,
        MAX(o.order_date) AS last_order_date,
        MIN(o.order_date) AS first_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status IN ('Delivered', 'Shipped') OR o.status IS NULL
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city, c.country, c.customer_segment, c.registration_date
),
ranked_customers AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_spent DESC) AS spending_rank,
        PERCENT_RANK() OVER (ORDER BY total_spent) AS spending_percentile
    FROM customer_spending
)
SELECT 
    customer_name,
    city,
    country,
    customer_segment,
    total_orders,
    total_spent,
    avg_order_value,
    first_order_date,
    last_order_date,
    spending_rank,
    ROUND(spending_percentile * 100, 2) AS spending_percentile,
    CASE 
        WHEN total_spent > 2000 THEN 'VIP'
        WHEN total_spent > 1000 THEN 'Premium'
        WHEN total_spent > 500 THEN 'Regular'
        ELSE 'Standard'
    END AS value_tier
FROM ranked_customers
WHERE spending_rank <= 5
ORDER BY spending_rank;

Question 4: Running Total of Sales by Day
WITH daily_sales AS (
    SELECT 
        o.order_date,
        COUNT(DISTINCT o.order_id) AS daily_orders,
        COUNT(DISTINCT o.customer_id) AS daily_customers,
        SUM(oi.quantity) AS daily_units_sold,
        SUM(oi.quantity * oi.unit_price) AS daily_revenue,
        AVG(oi.quantity * oi.unit_price) AS avg_daily_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status IN ('Delivered', 'Shipped')
    GROUP BY o.order_date
)
SELECT 
    order_date,
    daily_orders,
    daily_customers,
    daily_units_sold,
    daily_revenue,
    avg_daily_order_value,
    -- Running totals
    SUM(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue,
    SUM(daily_orders) OVER (
        ORDER BY order_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_orders,
    -- Moving averages
    AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS weekly_moving_avg_revenue,
    -- Day-over-day growth
    LAG(daily_revenue) OVER (ORDER BY order_date) AS prev_day_revenue,
    ROUND(
        (daily_revenue - LAG(daily_revenue) OVER (ORDER BY order_date)) * 100.0 / 
        NULLIF(LAG(daily_revenue) OVER (ORDER BY order_date), 0), 
        2
    ) AS daily_growth_percentage
FROM daily_sales
ORDER BY order_date;

Question 5: Customers who Haven’t Purchased in the Last 30 Days
WITH customer_last_purchase AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        c.city,
        c.country,
        c.registration_date,
        c.customer_segment,
        MAX(o.order_date) AS last_purchase_date,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS lifetime_value,
        DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_purchase
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city, c.country, c.registration_date, c.customer_segment
)
SELECT 
    customer_id,
    customer_name,
    email,
    city,
    country,
    registration_date,
    customer_segment,
    last_purchase_date,
    total_orders,
    lifetime_value,
    days_since_last_purchase,
    CASE 
        WHEN days_since_last_purchase BETWEEN 30 AND 60 THEN 'At Risk'
        WHEN days_since_last_purchase BETWEEN 61 AND 90 THEN 'Dormant'
        WHEN days_since_last_purchase > 90 THEN 'Lost'
        ELSE 'Active'
    END AS customer_status
FROM customer_last_purchase
WHERE last_purchase_date IS NULL 
    OR last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY days_since_last_purchase DESC, lifetime_value DESC;