--bai tap 1
ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN ordernumber TYPE varchar(10)
USING (ordernumber::varchar(10))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN quantityordered TYPE varchar(10)
USING (ordernumber::varchar(10))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderlinenumber TYPE varchar(10)
USING (orderlinenumber::varchar(10))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN sales TYPE numeric 
USING (sales::numeric)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN orderdate TYPE numeric 
USING (orderdate::date)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN status TYPE varchar(20) 
USING (status::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN productline TYPE varchar(20) 
USING (productline::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN msrp TYPE numeric 
USING (msrp::numeric)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN productcode TYPE varchar(20) 
USING (productcode::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN customername TYPE text
USING (customername::text)

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN phone TYPE char(15)
USING (phone::char(15))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN productcode TYPE varchar(20) 
USING (productcode::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN addressline1 TYPE varchar(100) 
USING (addressline1::varchar(100))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN city TYPE varchar(20) 
USING (city::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN state TYPE varchar(20) 
USING (state::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN postalcode TYPE varchar(20) 
USING (postalcode::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN country TYPE varchar(20) 
USING (country::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN territory TYPE varchar(20) 
USING (territory::varchar(20))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN contactfullname TYPE varchar(50) 
USING (contactfullname::varchar(50))

ALTER TABLE sales_dataset_rfm_prj
ALTER COLUMN dealsize TYPE varchar(20) 
USING (dealsize::varchar(20))

--bai tap 2
SELECT *
FROM sales_dataset_rfm_prj
WHERE 
    ORDERNUMBER IS NULL OR ORDERNUMBER = '' 
	OR
    QUANTITYORDERED IS NULL OR QUANTITYORDERED = '' 
	OR
    PRICEEACH IS NULL OR PRICEEACH = '' 
	OR
    ORDERLINENUMBER IS NULL OR ORDERLINENUMBER = '' 
	OR
    SALES IS NULL OR SALES = '' 
	OR
    ORDERDATE IS NULL OR ORDERDATE = ''

-- bai tap 3
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME VARCHAR(50),
ADD COLUMN CONTACTFIRSTNAME VARCHAR(50);

UPDATE sales_dataset_rfm_prj
SET 
  CONTACTLASTNAME = SUBSTRING(CONTACTFULLNAME from position ('-' in CONTACTFULLNAME)+1 for 15),
  CONTACTFIRSTNAME = SUBSTRING(CONTACTFULLNAME from position ('-' in CONTACTFULLNAME) -15 for 15);

--bai tap 4
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QRT_ID VARCHAR(50),
ADD COLUMN MONTH_ID VARCHAR(50),
ADD COLUMN YEAR_ID VARCHAR(50);

UPDATE sales_dataset_rfm_prj
SET 
  QRT_ID = (DATE_PART('quarter', ORDERDATE)),
  MONTH_ID = (DATE_PART('month', ORDERDATE)),
  YEAR_ID = (DATE_PART('year', ORDERDATE))

-- bai tap 5
select * from sales_dataset_rfm_prj;
with cte1 as(
Select Q1-1.5*IQR AS MIN_VALUE, Q3+1.5*IQR AS MAX_VALUE
FROM (
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS Q3,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY QUANTITYORDERED) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY QUANTITYORDERED) AS IQR
FROM sales_dataset_rfm_prj) AS a)
SELECT * FROM sales_dataset_rfm_prj
WHERE QUANTITYORDERED < (SELECT MIN_VALUE FROM cte1 )
or QUANTITYORDERED > (SELECT MAX_VALUE FROM cte1 );
update sales_dataset_rfm_prj
set QUANTITYORDERED= (select avg (QUANTITYORDERED)
					  from sales_dataset_rffrom 
					  where QUANTITYORDERED in (select QUANTITYORDERED from cte1)
