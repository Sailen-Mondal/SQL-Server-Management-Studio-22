SELECT SCOPE_IDENTITY();

CREATE table T1(
[id] INT IDENTITY (100,1) constraint t1_id PRIMARY KEY,
[name] VARCHAR (30) NOT NULL
)

INSERT INTO T1 values ('AA'),('BB'),('CC');


SELECT 
IIF(order_status = 1,'Pending', 
IIF(order_status=2, 'Processing',
IIF(order_status=3, 'Rejected',
IIF(order_status=4,'Completed','N/A')
)
)
) order_status,
COUNT(order_id) order_count
FROM sales.orders
WHERE YEAR(order_date) = 2018
GROUP BY order_status;


SELECT TRIM ('  Hi  ') as 'Trim';

DECLARE @d DATE = GETDATE(); 
SELECT FORMAT( @d, 'dd/MM/yyyy', 'en-US' ) AS 'Date' ,FORMAT(123456789678678,'###-##-####') AS 'Custom Number';
SELECT format(GETDATE(),'dd/MM/yyyy hh:mm tt') 'Today'