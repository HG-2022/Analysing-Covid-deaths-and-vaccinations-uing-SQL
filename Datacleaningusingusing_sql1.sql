--cleaning Nashville housing Data using SQL

----- Total #rows in the Table
select count(*) 
from Nashville_housingdata

select top 1000 *
from Nashville_housingdata 


--- standardize Data format
--- seperating Date from Time

select  saledate
from Nashville_housingdata

--- converting from datetime format to date format
select  saledate, convert(date,saledate) 
from Nashville_housingdata

select  saledate, convert(time,saledate) 
from Nashville_housingdata

---updating table with the new column
alter table Nashville_housingdata
add saledate_corrected date;

update Nashville_housingdata
set saledate_corrected =convert(date,saledate)

select * from portfolio.dbo.Nashville_housingdata



---populate propert address

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress
from Nashville_housingdata a join Nashville_housingdata b
on a.parcelid=b.parcelid and a.uniqueid<>b.uniqueid
where a.propertyaddress is null 


update  a
set propertyaddress= isnull(a.propertyaddress,b.propertyaddress)
from Nashville_housingdata a join Nashville_housingdata b
on a.parcelid=b.parcelid and a.uniqueid<>b.uniqueid
where a.propertyaddress is null 


select propertyaddress
from Nashville_housingdata
where propertyaddress is null

-- in the data parcelid is duplicated with the unique uniqueid. selfjoined the table to itself to check if there is address in 
--the table  with same parcelid and diffrent unique id. found the property address on same parce id can updated the null s .


---Breaking address into diffrent columns (address,city,state)

select * 
from Nashville_housingdata

select substring(propertyaddress, 1,CHARINDEX(',',propertyaddress)-1) as propertyaddress_streetname
from Nashville_housingdata

select substring(propertyaddress, CHARINDEX(',',propertyaddress)+1,len(propertyaddress) ) as propertycity
from Nashville_housingdata

alter table Nashville_housingdata
add propertyaddress_streetname nvarchar(255),
propertycity nvarchar(255)

update Nashville_housingdata
set propertyaddress_streetname=substring(propertyaddress, 1,CHARINDEX(',',propertyaddress)-1) 

update Nashville_housingdata
set propertycity=substring(propertyaddress, CHARINDEX(',',propertyaddress)+1,len(propertyaddress) )


select *
from Nashville_housingdata


----using Text functions substring,charindex and len, property address is broken into 2 fields address,city



---- Breaking owners address into 3 fields
select owneraddress 
from Nashville_housingdata

alter table Nashville_housingdata
add owneraddress nvarchar (255),
owner_city nvarchar(255),
owner_state nvarchar(255)


select SUBSTRING(owneraddress,1,charindex(',',owneraddress)-1) as owneraddress_new 
from Nashville_housingdata

select  PARSENAME(replace(owneraddress,',','.'),2) as owner_city ----SUBSTRING(owneraddress,charindex(',',owneraddress)+1,charindex(',',owneraddress)-1) as owner_city
from Nashville_housingdata

select  PARSENAME(replace(owneraddress,',','.'),1) as owner_state       --- SUBSTRING(owner_city,charindex(',',owner_city)+1,len(owneraddress)) as owner_state
from Nashville_housingdata



update Nashville_housingdata
set owneraddress_split= SUBSTRING(owneraddress,1,charindex(',',owneraddress)-1)

update Nashville_housingdata
set owner_city= PARSENAME(replace(owneraddress,',','.'),2) ---SUBSTRING(owneraddress,charindex(',',owneraddress)+1,charindex(',',owneraddress)-1)

update Nashville_housingdata
set owner_state= PARSENAME(replace(owneraddress,',','.'),1)   ---SUBSTRING(owner_city,charindex(',',owner_city)+1,len(owner_city))


--select REPLACE(owneraddress, 'TENESEE','TN')
--from Nashville_housingdata



--- change Y an N to  YES and NO in sold as vacant field


select distinct SoldAsVacant,count(SoldAsVacant) as num
from Nashville_housingdata
group by SoldAsVacant


--- Method 1:updating table with simple where clause 


update Nashville_housingdata
set SoldAsVacant='Yes'
where SoldAsVacant like 'Y'


---Method 2: using case statements ( if else clause in sql)
begin transaction
select SoldAsVacant,
case when SoldAsVacant = 'N' Then 'Not'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end
from Nashville_housingdata


update Nashville_housingdata
set SoldAsVacant =
case
when SoldAsVacant = 'N0' Then 'Not'
--when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end



select distinct SoldAsVacant,count(SoldAsVacant) as num
from Nashville_housingdata
group by SoldAsVacant


select distinct SoldAsVacant
from Nashville_housingdata

select * from Nashville_housingdata


---- Remove duplicates
with rownumcte as(
select *, 
ROW_NUMBER() over(partition by PropertyAddress,saledate,LegalReference,parcelid
                   order by uniqueid) as rownum
from Nashville_housingdata
--order by owner_state
)
select *
from rownumcte
where rownum>1
order by parcelid

-- we have 104 duplicates


-- difference between group by and Partition by in checking duplicates 
select propertyaddress,saledate,count(propertyaddress),count(SaleDate)
from Nashville_housingdata
group by propertyaddress,SaleDate


--Delete unused columns

alter table Nashville_housingdata
drop column <columnname>

