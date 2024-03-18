
SET datestyle = 'ISO, MDY';

DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS sellers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS translation;

-- Table: public.customers


CREATE TABLE IF NOT EXISTS customers
(
    customer_id character varying(50) ,
    customer_unique_id character varying(50) ,
    customer_zip_code_prefix integer,
    customer_city character varying(50) ,
    customer_state character varying(50) ,
    PRIMARY KEY (customer_id)
);

COPY customers FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_-Public_Dataset_by_Olist/main/olist_customers_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);


-- Table: public.orders

CREATE TABLE IF NOT EXISTS orders
(
    order_id character varying(50) ,
    customer_id character varying(50) ,
    order_status character varying(50) ,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) 
);

COPY orders FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_orders_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);





CREATE TABLE IF NOT EXISTS reviews
(
    review_id character varying(100) ,
    order_id character varying(100) ,
    review_score smallint,
    review_comment_title character varying(100) ,
    review_comment_message varchar ,
    review_creation_date date,
    review_answer_timestamp timestamp without time zone,
    FOREIGN KEY (order_id)
        REFERENCES orders (order_id) 
        
);

COPY reviews FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_order_reviews_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);

CREATE TABLE IF NOT EXISTS payments
(
    order_id character varying(100) ,
    payment_sequential integer,
    payment_type character varying(100) ,
    payment_installments integer,
    payment_value double precision,
    FOREIGN KEY (order_id)
        REFERENCES orders (order_id) 
);

COPY payments FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_order_payments_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);


-- Table: public.sellers

CREATE TABLE IF NOT EXISTS sellers
(
    seller_id character varying(100),
    seller_zip_code_prefix integer,
    seller_city character varying(100) ,
    seller_state character varying(100) ,
    PRIMARY KEY (seller_id)
);

COPY sellers FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_sellers_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);

CREATE TABLE IF NOT EXISTS products
(
    product_id character varying(100) ,
    product_category_name character varying(100) ,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer,
    PRIMARY KEY (product_id)
);

COPY products FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_products_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);


CREATE TABLE IF NOT EXISTS order_items
(
    order_id character varying(100) ,
    order_item_id integer,
    product_id character varying(100) ,
    seller_id character varying(100) ,
    shipping_limit_date timestamp without time zone,
    price real,
    freight_value real,
	FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
	FOREIGN KEY (product_id)
        REFERENCES products (product_id),
	FOREIGN KEY (seller_id)
        REFERENCES public.sellers (seller_id)
    );

COPY order_items FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/olist_order_items_dataset.csv"' (DELIMITER ',', FORMAT CSV, HEADER);




CREATE TABLE IF NOT EXISTS translation
(
    category_name character varying ,
    category_name_english character varying 
);

COPY translation FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/Brazilian_E_Commerce_Public_Dataset_by_Olist/main/product_category_name_translation.csv"' (DELIMITER ',', FORMAT CSV, HEADER);

