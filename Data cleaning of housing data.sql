-- Create Database
create database data_cleaning;

-- Use database
use data_cleaning;

-- Display the top 10 data 
select * 
from housing_data 
limit 10
;

-- Number of rows
select count(*) as row_num 
from housing_data
;

-- Number of columns
select count(*) as col_num 
from information_schema.columns 
where table_name="housing_data"
;

-- Distinct land Use options
select distinct(landuse) 
from housing_data
;

-- Set update safe mode on
SET SQL_SAFE_UPDATES = 0;

-- Convert Sales date into Standard sales date format
alter table housing_data 
add saledata2 date
;

update housing_data
set saledata2= DATE_FORMAT(STR_TO_DATE(saledate, '%M %e, %Y'), '%Y-%m-%d')
;

-- Identify Missing propert address
select parcelid, propertyaddress 
from housing_data 
where propertyaddress = isnull(propertyaddress)
;

-- Delete Missing Values in the table
delete from housing_data 
where propertyaddress = isnull(propertyaddress)
;

-- Breaking address into individual column (Address, City, State)
alter table housing_data 
add Address varchar(50), 
add City varchar(30),
add State varchar(10)
;

update housing_data
set address= trim(substring_index(owneraddress,",",1));

update housing_data
set City=trim(substring_index(substring_index(owneraddress,",",2),",",-1)) ;

update housing_data
set State= trim(substring_index(owneraddress,",",-1));

-- Replace the data of sale as vacant feature
select distinct(soldasvacant), count(soldasvacant) 
from housing_data 
group by soldasvacant
;

update housing_data 
set soldasvacant = case 
when soldasvacant="N" then "No"
when soldasvacant="Y" then "Yes"
else soldasvacant
end  
;

-- Check for duplicate values
select uniqueid, parcelid, 
row_number() over(
partition by parcelid 
order by parcelid) as rownum 
from housing_data
;

-- Delete Duplicate data from the table
delete 
from housing_data 
where uniqueid in (
select uniqueid 
from (select uniqueid, parcelid, 
row_number() over (
partition by parcelid 
order by parcelid )as rownum 
from housing_data ) as temp_table 
where rownum>1
)
;

-- Drop Unsual columns
alter table housing_data 
drop column saledate, 
drop owneraddress
;

-- Taking average sale price for sold as vacant are available or not.
select soldasvacant, avg(saleprice) as average 
from housing_data 
where soldasvacant="No"
;

select soldasvacant, avg(saleprice) as average
from housing_data 
where soldasvacant="Yes"
;

-- count and percentage of land use in the overall data
select landuse, count(*), round(count(*)/(select count(*) from housing_data)*100,1) as pct 
from housing_data 
group by 1 
order by 3 desc
;

-- Date wise total sale price 
select saledata2 date, sum(saleprice) as total_price
from housing_data 
group by saledata2
;

-- Total sale price 
select sum(saleprice) 
from housing_data
;

------ END -------