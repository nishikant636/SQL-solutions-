-- Recyclable and low fact product

select product_id from Products 
where low_fats='Y' And recyclable='Y';

-- find customer refree
select name from customer
where referee_id is null or referee_id!=2;

-- replace employee ID with unique identifier

select 
eu.unique_id as unique_id, e.name as name
from Employees e left join EmployeeUNI eu on e.id = eu.id;

-- product sale analysis 1
SELECT product_name, year, price
FROM Product INNER JOIN Sales 
USING(product_id);

-- not boring movies
select *
from Cinema
where id%2=1 and description !='boring'
order by rating  DESC