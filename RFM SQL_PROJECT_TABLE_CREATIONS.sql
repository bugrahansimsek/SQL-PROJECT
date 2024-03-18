
SET datestyle = 'ISO, MDY';

CREATE TABLE IF NOT EXISTS rfm
(
    invoiceno character varying ,
    stockcode character varying ,
    description character varying ,
    quantity integer,
    invoicedate timestamp without time zone,
    unitprice real,
    customer_id character varying ,
    country character varying 
);

COPY rfm FROM PROGRAM 'curl "https://raw.githubusercontent.com/Mylinear/RFM_alaysis/main/data.csv"' (DELIMITER ',', FORMAT CSV, HEADER, ENCODING win1251);

select * from rfm;