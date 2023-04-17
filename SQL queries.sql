/* Query 1 - query used for first insight

Looking at the family-friendly categories of Animation, Children, Classics, Comedy, Family and Music, create a query that lists each movie, the film category 
it is classified in (must be one of those 6), and the number of times it has been rented out. */

SELECT f.title AS film_title,
	   c.name AS category_name,
       COUNT(r.rental_ID) AS rental_count
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE (c.name = 'Animation') OR (c.name = 'Children') OR (c.name = 'Classics') OR (c.name = 'Comedy') OR (c.name = 'Family') OR (c.name = 'Music')
GROUP BY 1,2
ORDER BY 2,1



/* Query 2 - query used for second insight 
Looking at these family-friendly movies as defined in Query 1, how does the lengths of rental duration COMPARE to the duration that all movies are rented for? 
Provide a table that shows the distribution of movie rental durations in each category AMONGST the four quartiles
(where the quartiles are determined by movie rental durations across ALL categories).
*/

SELECT t1.name, t1.standard_quartile, COUNT(t1.standard_quartile)
FROM
        (SELECT f.title, c.name, f.rental_duration, NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
        FROM film f
        JOIN film_category fc
        ON f.film_id = fc.film_id
        JOIN category c
        ON fc.category_id = c.category_id
        GROUP BY 1,2,3	
        ORDER BY 4,1) AS t1
WHERE (name = 'Animation') OR (name = 'Children') OR (name = 'Classics') OR (name = 'Comedy') OR (name = 'Family') OR (name = 'Music')
GROUP BY 1,2
ORDER BY 1,2



/* Query 3 - query used for third insight 
How do the two stores compare in their count of rental orders (for every month for all the years we have data for)? 
Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. 
*/

SELECT 
	   DATE_PART('month', r.rental_date) AS Rental_month,
       DATE_PART('year', r.rental_date) AS Rental_year,
	   s.store_id,
       COUNT(r.rental_id) AS Count_rentals
FROM staff s
JOIN rental r
ON s.staff_id = r.staff_id
GROUP BY 2,1,3
ORDER BY 2,1,4 DESC


/* Query 4 - query used for fourth insight
For the TOP 10 paying customers: how many payments did they make on a monthly basis during 2007? What was the amount of the monthly payments? 
Write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers.
*/

SELECT t1.customer_name, t2.*
FROM
        (SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
               SUM(p.amount) AS total_paid
        FROM customer c
        JOIN payment p
        ON c.customer_id = p.customer_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 10) AS t1
JOIN 
		(SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                DATE_TRUNC('month', p.payment_date) AS pay_month,
         		COUNT(p.payment_id) AS paycount_permonth,
         		SUM(p.amount) AS pay_amount
        FROM customer c
        JOIN payment p
        ON c.customer_id = p.customer_id
        WHERE (DATE_PART('year', p.payment_date) = 2007)
        GROUP BY 1,2
        ORDER BY 1,2,3) AS t2
ON t1.customer_name = t2.customer_name
