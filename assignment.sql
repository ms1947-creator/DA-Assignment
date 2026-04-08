SECTION A: SQL – Hotel Management System

Q1. For every user, get the user_id and last booked room_no

SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
   SELECT user_id, MAX(booking_date) AS last_booking
   FROM bookings
   GROUP BY user_id
) latest
ON b.user_id = latest.user_id
AND b.booking_date = latest.last_booking;

Q2. Get booking_id and total billing amount (November 2021)

SELECT bc.booking_id,
      SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;

Q3. Get bill_id and bill amount (October 2021, >1000)

SELECT bc.bill_id,
      SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-10'
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

Q4. Most ordered and least ordered item of each month (2021)

WITH item_orders AS (
   SELECT
       DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
       bc.item_id,
       SUM(bc.item_quantity) AS total_qty
   FROM booking_commercials bc
   WHERE YEAR(bc.bill_date) = 2021
   GROUP BY month, bc.item_id
),
ranked AS (
   SELECT *,
          RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
          RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
   FROM item_orders
)
SELECT month, item_id, total_qty,
      CASE
          WHEN most_rank = 1 THEN 'Most Ordered'
          WHEN least_rank = 1 THEN 'Least Ordered'
      END AS category
FROM ranked
WHERE most_rank = 1 OR least_rank = 1;

Q5. Customers with second highest bill value each month (2021)

WITH monthly_bills AS (
   SELECT
       DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
       b.user_id,
       SUM(bc.item_quantity * i.item_rate) AS total_bill
   FROM booking_commercials bc
   JOIN bookings b ON bc.booking_id = b.booking_id
   JOIN items i ON bc.item_id = i.item_id
   WHERE YEAR(bc.bill_date) = 2021
   GROUP BY month, b.user_id
),
ranked AS (
   SELECT *,
          DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
   FROM monthly_bills
)
SELECT month, user_id, total_bill
FROM ranked
WHERE rnk = 2;

SECTION B: SQL – Clinic Management System

Q1. Revenue from each sales channel (2021)

SELECT sales_channel,
      SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

Q2. Top 10 most valuable customers

SELECT uid,
      SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

Q3. Month-wise revenue, expense, profit, status

WITH revenue AS (
   SELECT
       DATE_FORMAT(datetime, '%Y-%m') AS month,
       SUM(amount) AS total_revenue
   FROM clinic_sales
   WHERE YEAR(datetime) = 2021
   GROUP BY month
),
expense AS (
   SELECT
       DATE_FORMAT(datetime, '%Y-%m') AS month,
       SUM(amount) AS total_expense
   FROM expenses
   WHERE YEAR(datetime) = 2021
   GROUP BY month
)
SELECT r.month,
      r.total_revenue,
      e.total_expense,
      (r.total_revenue - e.total_expense) AS profit,
      CASE
          WHEN (r.total_revenue - e.total_expense) > 0 THEN 'Profitable'
          ELSE 'Not Profitable'
      END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;

Q4. Most profitable clinic per city (October 2021)

WITH clinic_profit AS (
   SELECT
       c.city,
       cs.cid,
       SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
   FROM clinic_sales cs
   JOIN clinics c ON cs.cid = c.cid
   LEFT JOIN expenses e ON cs.cid = e.cid
       AND MONTH(cs.datetime) = MONTH(e.datetime)
   WHERE MONTH(cs.datetime) = 10 AND YEAR(cs.datetime)=2021
   GROUP BY c.city, cs.cid
),
ranked AS (
   SELECT *,
          RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
   FROM clinic_profit
)
SELECT * FROM ranked WHERE rnk = 1;

Q5. Second least profitable clinic per state (October 2021)

WITH clinic_profit AS (
   SELECT
       c.state,
       cs.cid,
       SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
   FROM clinic_sales cs
   JOIN clinics c ON cs.cid = c.cid
   LEFT JOIN expenses e ON cs.cid = e.cid
       AND MONTH(cs.datetime) = MONTH(e.datetime)
   WHERE MONTH(cs.datetime)=10 AND YEAR(cs.datetime)=2021
   GROUP BY c.state, cs.cid
),
ranked AS (
   SELECT *,
          DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
   FROM clinic_profit
)
SELECT * FROM ranked WHERE rnk = 2;

SECTION C: Spreadsheet Proficiency

Q1. Populate 'ticket_created_at'
Used INDEX-MATCH to fetch ticket creation time:
=INDEX(ticket!B:B, MATCH(A2, ticket!A:A, 0))

Q2. Outlet-wise ticket counts
Same Day:
Created helper column:
=DATE(created_at)=DATE(closed_at)
Used Pivot Table:
Rows → outlet_id
Values → count
Same Hour:
Created helper column:
=HOUR(created_at)=HOUR(closed_at)
Used Pivot Table for aggregation
