--SQL Advance Case Study


--Q1--BEGIN 
	
	select State

	from DIM_LOCATION l
	left join  FACT_TRANSACTIONS t on
	l.IDLocation = t.IDLocation

	where year(Date) between 2005 and year(GETDATE())
	group by State;



--Q1--END

--Q2--BEGIN
	

	select top 1 state

	from DIM_LOCATION l inner join FACT_TRANSACTIONS ft on
	l.IDLocation = ft.IDLocation inner join DIM_MODEL mo on 
	ft.IDModel = mo.IDModel inner join DIM_MANUFACTURER manu on
	mo.IDManufacturer = manu.IDManufacturer

	where Country in ('US') and Manufacturer_Name = 'Samsung'
	group by State
	order by sum(ft.Quantity) desc 




--Q2--END

--Q3--BEGIN      
	


	select IDModel, l.ZipCode , l.State , count(tr.IDCustomer) [No. of trans]

	from FACT_TRANSACTIONS tr inner join DIM_LOCATION l
	on tr.IDLocation = l.IDLocation

	group by IDModel, ZipCode, state 


--Q3--END

--Q4--BEGIN


	select top 1 Model_Name , mo.Unit_price

	from DIM_MODEL mo inner join DIM_MANUFACTURER manu on
	mo.IDManufacturer = manu.IDManufacturer

	order by Unit_price asc




--Q4--END

--Q5--BEGIN

select model_name,
avg(TotalPrice) [avg total price]

from dim_model mo inner join DIM_MANUFACTURER manu
on mo.IDManufacturer = manu.IDManufacturer inner join FACT_TRANSACTIONS t on mo.IDModel = t.IDModel

where Manufacturer_Name in

(	select top 5 Manufacturer_Name

	from DIM_MANUFACTURER as manu inner join DIM_MODEL as dm
	on manu.IDManufacturer = dm.IDManufacturer inner join FACT_TRANSACTIONS tr
	on tr.IDModel = dm.IDModel

	group by Manufacturer_Name
	order by sum(Quantity) desc ) 

group by Model_Name
order by [avg total price] ;


-------------------------------==================== THROUGH CTE ==========================

	with top_5
	as (
		select top 5 manu.Manufacturer_Name [name]

		from DIM_MANUFACTURER manu inner join DIM_MODEL m
		on manu.IDManufacturer = m.IDManufacturer inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel

		group by Manufacturer_Name
		order by sum(Quantity) desc

		)

		select m.IDModel , avg(TotalPrice) [avg_price]

		from DIM_MODEL m inner join FACT_TRANSACTIONS t 
		on m.IDModel = t.IDModel inner join DIM_MANUFACTURER manu
		on m.IDManufacturer = manu.IDManufacturer
		
		where Manufacturer_Name in (select * from top_5 )
		group by m.IDModel
		order by avg_price ;
		


		

--Q5--END

--Q6--BEGIN


	select Customer_Name, avg(TotalPrice) avg_spent

	from DIM_CUSTOMER cu inner join FACT_TRANSACTIONS tr on
	cu.IDCustomer = tr.IDCustomer

	where year(date) = 2009 
	group by Customer_Name
	having avg(TotalPrice) > 500





--Q6--END
	
--Q7--BEGIN

	select *
	from

		(select top 5 Model_Name

		from FACT_TRANSACTIONS t inner join DIM_MODEL mo
		on t.IDModel = mo.IDModel

		where year(Date) = 2008
		group by Model_Name
		order by sum(Quantity) desc) sub1

	intersect
	
	select *
	from

		(select top 5 Model_Name

		from FACT_TRANSACTIONS t inner join DIM_MODEL mo
		on t.IDModel = mo.IDModel

		where year(Date) = 2009
		group by Model_Name
		order by sum(Quantity) desc) sub2

	intersect
	
	select *
	from

		(select top 5 Model_Name

		from FACT_TRANSACTIONS t inner join DIM_MODEL mo
		on t.IDModel = mo.IDModel

		where year(Date) = 2010
		group by Model_Name
		order by sum(Quantity) desc) sub3
		


		--=============ANOTHER APPROACH ( with DENSE_RANK )----------------

		select names
		from 
		(
		select m.Model_Name [names] , DENSE_RANK() over(order by sum(quantity) desc) [ranks]

		from DIM_MODEL m inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel

		where year(date) = 2008
		group by Model_Name ) sub1
		where ranks <= 5

		intersect 

		select names
		from 
		(
		select m.Model_Name [names] , DENSE_RANK() over(order by sum(quantity) desc) [ranks]

		from DIM_MODEL m inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel

		where year(date) = 2009
		group by Model_Name) sub2
		where ranks <= 5

		intersect 
		 
		select names
		from 
		(
		select m.Model_Name [names] , DENSE_RANK() over(order by sum(quantity) desc) [ranks]

		from DIM_MODEL m inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel

		where year(date) = 2010
		group by Model_Name ) sub3
		where ranks <= 5



--Q7--END	
--Q8--BEGIN
	
	select names
	from 
	(
	select ma.Manufacturer_Name [names]

	from DIM_MODEL m inner join FACT_TRANSACTIONS t 
	on m.IDModel = t.IDModel inner join DIM_MANUFACTURER ma
	on m.IDManufacturer = ma.IDManufacturer

	where year(Date) = 2009
	group by ma.Manufacturer_Name
	order by sum(TotalPrice) desc
	offset 1 rows
	fetch next 1 rows only
	) sub1
	
	union all

	select names
	from 
	(
	select ma.Manufacturer_Name [names]

	from DIM_MODEL m inner join FACT_TRANSACTIONS t 
	on m.IDModel = t.IDModel inner join DIM_MANUFACTURER ma
	on m.IDManufacturer = ma.IDManufacturer

	where year(Date) = 2010
	group by ma.Manufacturer_Name
	order by sum(TotalPrice) desc
	offset 1 rows
	fetch next 1 rows only
	) sub2


	------------------------------------------------------- WITH CTE -----------------------------------

	with top_2
	as (
		select IDManufacturer [id] ,
		year(date) [years],
		sum(TotalPrice) [tot],
		rank() over(partition by year(date) order by sum(TotalPrice) desc) [ranks]

		from DIM_MODEL m inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel

		where year(Date) in (2009 , 2010)
		group by IDManufacturer, year(date)
	)

	select id , years , tot
	from top_2
	where ranks = 2





--Q8--END
--Q9--BEGIN
	


	select Manufacturer_Name

	from DIM_MANUFACTURER manu inner join DIM_MODEL m
	on manu.IDManufacturer = m.IDManufacturer inner join FACT_TRANSACTIONS t
	on m.IDModel = t.IDModel

	where year(Date) = 2010
	
	except 

	select Manufacturer_Name

	from DIM_MANUFACTURER manu inner join DIM_MODEL m
	on manu.IDManufacturer = m.IDManufacturer inner join FACT_TRANSACTIONS t
	on m.IDModel = t.IDModel

	where year(Date) = 2009


	------------------------------------------------------- WITH CTE -----------------------------------

	with sold_phones
	as (
		select Manufacturer_Name [names]
		from DIM_MANUFACTURER manu inner join DIM_MODEL m
		on manu.IDManufacturer = m.IDManufacturer inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel
		where YEAR(Date) = 2009
	) ,

	
	 sold_phones_2
	as (
		select Manufacturer_Name [names]
		from DIM_MANUFACTURER manu inner join DIM_MODEL m
		on manu.IDManufacturer = m.IDManufacturer inner join FACT_TRANSACTIONS t
		on m.IDModel = t.IDModel
		where YEAR(Date) = 2010
	)

	select s2.names
	from sold_phones s1 right join sold_phones_2 s2
	on s1.names = s2.names
	where s1.names is null





--Q9--END

--Q10--BEGIN
	
	with top_10
	as (
		select top 10 c.IDCustomer [id]

		from DIM_CUSTOMER c inner join FACT_TRANSACTIONS t
		on c.IDCustomer = t.IDCustomer
		group by c.IDCustomer
		order by sum(TotalPrice) desc
		) ,

		avg_spend_and_quan 
		as (
			select c.IDCustomer [ids] , year(Date) [Years] , avg(TotalPrice) [Total_Price] , avg(Quantity) [Total_quan]
			from DIM_CUSTOMER c inner join FACT_TRANSACTIONS t
			on c.IDCustomer = t.IDCustomer
			where c.IDCustomer in (select * from top_10)
			group by c.IDCustomer , year(Date)
		) , 

		avg_distribution
		as (
			select ids , years, Total_Price , Total_quan , lag(Total_Price , 1) over(partition by ids order by years) [last_price]
			from avg_spend_and_quan
		)

		select ids , years, Total_Price , Total_quan , (Total_Price - last_price) / last_price * 100 [avg_diff]
		from avg_distribution
	

		

--Q10--END
	