select * 
from Mart.dim_terminal
-------------------------------------------
select * 
from staging.terminals

--Inserting Test row 
insert into staging.terminals(terminal_id, terminal_code, terminal_name, zone, terminal_type)
values(5,'T5','TEST','TEST','TEST');

--Updating 
UPDATE staging.terminals
SET terminal_name = 'TEST_UPDATED'
WHERE terminal_id = 5;
truncate table staging.terminals
DELETE FROM staging.terminals
WHERE terminal_id = 5;
---------------------------------------------------
--Testing SCD Type2
UPDATE Staging.Customers
SET 
	customer_tier = 'Diamond',     
    credit_limit = 6000000.00     
WHERE customer_id = 5;

select * from Staging.Customers

select * from Mart.dim_customer
