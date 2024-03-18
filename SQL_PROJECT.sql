----CASE 1 / Soru 1 / Sipariş Analizi
---Aylık olarak order dağılımını inceleyiniz. Tarih verisi için order_approved_at kullanılmalıdır.

SELECT 
TO_CHAR(order_approved_at,'YYYY-MM')as order_date,
COUNT(DISTINCT order_id) AS order_count
FROM orders 
WHERE order_approved_at IS NOT NULL
GROUP BY 1
ORDER BY order_date;

----Soru 2
---Aylık olarak order status kırılımında order sayılarını inceleyiniz. Sorgu sonucunda çıkan outputu excel ile görselleştiriniz. Dramatik bir düşüşün ya da yükselişin olduğu aylar var mı? Veriyi inceleyerek yorumlayınız.

SELECT 
TO_CHAR(order_approved_at,'YYYY-MM')as order_date,
order_status,
COUNT(DISTINCT order_id) AS order_count
FROM orders
WHERE order_approved_at IS NOT NULL
GROUP BY 1,2
ORDER BY order_date;

----Soru 3
---Ürün kategorisi kırılımında sipariş sayılarını inceleyiniz. Özel günlerde öne çıkan kategoriler nelerdir? Örneğin yılbaşı, sevgililer günü…
--Ürün Kategorisi Kırılımı;
SELECT  
DISTINCT(p.product_category_name),
t.category_name_english,
COUNT(DISTINCT oi.order_id) AS order_count
From products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN TRANSLATION T ON t.category_name = p.product_category_name
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name,2
ORDER BY order_count DESC;
-- 24 KASIM 2017 BLACK FRIDAY
SELECT  
DISTINCT(p.product_category_name),
t.category_name_english,
COUNT(DISTINCT oi.order_id) AS order_count
From products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id
LEFT JOIN TRANSLATION T ON t.category_name = p.product_category_name
WHERE O.ORDER_PURCHASE_TIMESTAMP::date  = '2017-11-24'
GROUP BY p.product_category_name,2
ORDER BY order_count DESC;
-- 14 ŞUBAT SEVGİLİLER GÜNÜ / 2017
SELECT  
DISTINCT(p.product_category_name),
t.category_name_english,
COUNT(DISTINCT oi.order_id) AS order_count
From products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id
LEFT JOIN TRANSLATION T ON t.category_name = p.product_category_name
WHERE O.order_delivered_customer_date BETWEEN '2017-02-07' AND '2017-02-14'
GROUP BY p.product_category_name,2
ORDER BY order_count DESC;
-- 14 ŞUBAT SEVGİLİLER GÜNÜ / 2018
SELECT  
DISTINCT(p.product_category_name),
t.category_name_english,
COUNT(DISTINCT oi.order_id) AS order_count
From products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id
LEFT JOIN TRANSLATION T ON t.category_name = p.product_category_name
WHERE O.order_delivered_customer_date BETWEEN '2018-02-07' AND '2018-02-14'
GROUP BY p.product_category_name,2
ORDER BY order_count DESC;
--YILBAŞI
SELECT  
DISTINCT(p.product_category_name),
t.category_name_english,
COUNT(DISTINCT oi.order_id) AS order_count
From products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id
LEFT JOIN TRANSLATION T ON t.category_name = p.product_category_name
WHERE O.order_delivered_customer_date BETWEEN '2017-12-25' AND '2018-01-01'
GROUP BY p.product_category_name,2
ORDER BY order_count DESC;

---- Soru 4
---Haftanın günleri(pazartesi, perşembe, ….) ve ay günleri (ayın 1’i,2’si gibi) bazında order sayılarını inceleyiniz. Yazdığınız sorgunun outputu ile excel’de bir görsel oluşturup yorumlayınız.

SELECT 
	DISTINCT (TO_CHAR(order_purchase_timestamp,'DAY')) AS day_of_week,
	COUNT(DISTINCT order_id) AS order_count
FROM orders
GROUP BY day_of_week
ORDER BY order_count DESC;
--
SELECT 
	EXTRACT(DAY FROM order_purchase_timestamp) AS day_of_month,
	COUNT(DISTINCT order_id) AS order_count
FROM orders
GROUP BY day_of_month
ORDER BY day_of_month;

----CASE 2 / Soru 1 / Müşteri Analizi
---Hangi şehirlerdeki müşteriler daha çok alışveriş yapıyor? Müşterinin şehrini en çok sipariş verdiği şehir olarak belirleyip analizi ona göre yapınız
---Örneğin; Sibel Çanakkale’den 3, Muğla’dan 8 ve İstanbul’dan 10 sipariş olmak üzere 3 farklı şehirden sipariş veriyor. Sibel’in şehrini en çok sipariş verdiği şehir olan İstanbul olarak seçmelisiniz ve Sibel’in yaptığı siparişleri İstanbul’dan 21 sipariş vermiş şekilde görünmelidir.

WITH customermaxorders AS (
SELECT
c.customer_unique_id,
c.customer_city,
COUNT(o.order_id) AS order_count,
RANK() OVER (PARTITION BY c.customer_unique_id ORDER BY COUNT(o.order_id) DESC, o.order_purchase_timestamp DESC) AS RNK
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id,c.customer_city,o.order_id
) SELECT
customer_city AS city_orders,
COUNT(order_count) AS order_count
FROM customermaxorders
WHERE rnk = 1
GROUP BY 1
ORDER BY order_count DESC;

----CASE 3 / Soru 1 / Satıcı Analizi
---Siparişleri en hızlı şekilde müşterilere ulaştıran satıcılar kimlerdir? Top 5 getiriniz. Bu satıcıların order sayıları ile ürünlerindeki yorumlar ve puanlamaları inceleyiniz ve yorumlayınız.
--- En hızlı satıcılar 1 ürün satmış..
SELECT 
	oi.seller_id,
	AVG(o.order_delivered_customer_date -o.order_approved_at)AS deliveredday,
	COUNT(o.order_id)AS order_count,
	ROUND(AVG(r.review_score),2) AS review_avg,
	COUNT(r.review_comment_message) AS comment_count
FROM orders AS o 
	INNER JOIN order_items AS oi ON o.order_id = oi.order_id 
	INNER JOIN reviews AS r ON r.order_id = o.order_id
GROUP BY oi.seller_id
ORDER BY deliveredday
LIMIT 5;

---Order > 20 ekliyoruz filtre edebilmek için.

SELECT 
	oi.seller_id,
	AVG(o.order_delivered_customer_date -o.order_approved_at)AS deliveredday,
	COUNT(o.order_id)AS order_count,
	ROUND(AVG(r.review_score),2) AS review_avg,
	COUNT(r.review_comment_message) AS comment_count
FROM orders AS o 
	INNER JOIN order_items AS oi ON o.order_id = oi.order_id 
	INNER JOIN reviews AS r ON r.order_id = o.order_id
GROUP BY oi.seller_id
HAVING COUNT(o.order_id) > 20
ORDER BY deliveredday
LIMIT 5;

----Soru 2
---Hangi satıcılar daha fazla kategoriye ait ürün satışı yapmaktadır? 
---Fazla kategoriye sahip satıcıların order sayıları da fazla mı? 

SELECT 
s.seller_id,
COUNT(DISTINCT p.product_category_name) AS category_count,
COUNT(o.order_id) AS order_count
FROM sellers AS s
LEFT JOIN order_items AS oi ON oi.seller_id = s.seller_id
LEFT JOIN products AS p ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON o.order_id = oi.order_id
GROUP BY s.seller_id
ORDER BY category_count DESC , order_count DESC;

----CASE 4 / Soru 1 / Payment Analizi
----Ödeme yaparken taksit sayısı fazla olan kullanıcılar en çok hangi bölgede yaşamaktadır? Bu çıktıyı yorumlayınız.

SELECT 
c.customer_state,
p.payment_installments,
COUNT(DISTINCT c.customer_unique_id) AS customer_count
FROM payments AS p
LEFT JOIN orders AS o ON p.order_id = o.order_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
WHERE payment_installments > 2
GROUP BY c.customer_state, payment_installments
HAVING COUNT(DISTINCT customer_unique_id) > 5
ORDER BY 2 DESC
---
SELECT 
c.customer_state,
p.payment_installments,
COUNT(DISTINCT c.customer_unique_id) AS customer_count
FROM payments AS p
LEFT JOIN orders AS o ON p.order_id = o.order_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
WHERE payment_installments > 2
GROUP BY c.customer_state, payment_installments
HAVING COUNT(DISTINCT customer_unique_id) > 5
ORDER BY 3 DESC

----Soru 2
---Ödeme tipine göre başarılı order sayısı ve toplam başarılı ödeme tutarını hesaplayınız. En çok kullanılan ödeme tipinden en az olana göre sıralayınız.

SELECT 
	p.payment_type,
	COUNT(DISTINCT o.order_id) AS succesful_order_count,
	SUM(p.payment_value) AS total_payment
FROM payments AS p
LEFT JOIN orders AS o ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY succesful_order_count DESC;

----Soru 3
----Tek çekimde ve taksitle ödenen siparişlerin kategori bazlı analizini yapınız. En çok hangi kategorilerde taksitle ödeme kullanılmaktadır?
---TEK ÇEKİM (sadece kredi kartı için bakmamız gerekirse sonuç değişir.)

SELECT 
	pro.product_category_name,
	t.category_name_english,
	COUNT(DISTINCT o.order_id) AS order_count
FROM products AS pro
LEFT JOIN order_items AS oi ON pro.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
JOIN payments AS p ON p.order_id = o.order_id
JOIN translation AS t ON t.category_name = pro.product_category_name
WHERE p.payment_installments = 1 --AND payment_type = 'credit_card'
GROUP BY 1,2
ORDER BY 3 DESC;

---TAKSİTLİ ÇEKİM
SELECT 
	pro.product_category_name,
	t.category_name_english,
	COUNT(DISTINCT o.order_id) AS order_count
FROM products AS pro
LEFT JOIN order_items AS oi ON pro.product_id = oi.product_id
JOIN orders AS o ON o.order_id = oi.order_id
JOIN payments AS p ON p.order_id = o.order_id AND p.payment_installments > 1
JOIN translation AS t ON t.category_name = pro.product_category_name 
GROUP BY 1,2
ORDER BY 3 DESC;

----CASE 5 / RFM ANALİZİ 
---Recency hesaplarken bugünün tarihi değil en son sipariş tarihini(MAX(invoicedate::date)) baz alınız. 
SELECT * FROM rfm
SELECT MAX(invoicedate::date) FROM rfm
---RECENCY-FREQUENCY-MONETARY--

---RECENCY - '2011-12-09'

SELECT
DISTINCT customer_id,
MAX(invoicedate::date) AS last_invoicedate,
'2011-12-09'::date - MAX(invoicedate::date) AS recency
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id 
ORDER BY recency DESC;

---FREQUENCY

SELECT 
DISTINCT customer_id,
COUNT(DISTINCT invoiceno) AS frequency
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency DESC;

----MONETARY

SELECT 
DISTINCT customer_id,
ROUND(SUM(quantity*unitprice)::numeric,2) AS monetary
FROM rfm
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary DESC;

---BİRLEŞTİRME

WITH rfm AS (
	SELECT customer_id,
	invoiceno,
	quantity,
	invoicedate,
	unitprice
	FROM rfm
	WHERE customer_id IS NOT NULL AND invoiceno IS NOT NULL
	AND invoiceno NOT LIKE 'C%'
	AND quantity > 0
	AND unitprice > 0
),
	recency AS (
	SELECT
	DISTINCT customer_id,
	MAX(invoicedate::date) AS last_invoicedate,
	'2011-12-09'::date - MAX(invoicedate::date) AS recency
	FROM rfm
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id 
	ORDER BY recency DESC
),
	frequency AS (
	SELECT 
	DISTINCT customer_id,
	COUNT(DISTINCT invoiceno) AS frequency
	FROM rfm
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id
	ORDER BY frequency DESC
),
	monetary AS (
	SELECT 
	DISTINCT customer_id,
	ROUND(SUM(quantity*unitprice)::numeric,2) AS monetary
	FROM rfm
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id
	ORDER BY monetary DESC
)
	SELECT 
	r.customer_id,
	r.recency,
	f.frequency,
	m.monetary,
	NTILE(5) OVER (ORDER BY recency DESC) AS recency_score, 
	NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
	NTILE(5) OVER (ORDER BY monetary) AS monetary_score,
	CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) AS RFM_SCORE,
	CASE
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '11' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '12' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '21' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '22' 
	 THEN 'HIBERNATING'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '13' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '14' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '23' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '24' 
	 THEN 'AT RISK'
	  WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '15' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '25'
	 THEN 'CANT LOOSE'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '31' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '32' 
	 THEN 'ABOUT TO SLEEP'
	 WHEN CONCAT((NTILE(5) OVER (ORDER BY RECENCY DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '33'
	 THEN 'NEED ATTENTION'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '34' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '35' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '44' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '45' 
	 THEN 'LOYAL CUSTOMERS'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '41'
	 THEN 'PROMISING'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '42' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '43' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '52' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '53' 
	 THEN 'POTENTIAL LOYALISTS'
	 WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '51'
	 THEN 'NEW CUSTOMERS'
	  WHEN
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '54' OR
	 CONCAT((NTILE(5) OVER (ORDER BY recency DESC)),(NTILE(5) OVER (ORDER BY frequency))) = '55' 
	 THEN 'CHAMPIONS'
	 END AS RFM_CATEGORY
	FROM recency AS r
	INNER JOIN frequency AS f ON r.customer_id = f.customer_id
	INNER JOIN monetary AS m ON r.customer_id = m.customer_id	
	ORDER BY f.frequency;
	