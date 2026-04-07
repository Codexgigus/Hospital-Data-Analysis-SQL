SELECT * FROM Hospital_dataset


ALTER TABLE [dbo].[Hospital_dataset]
ALTER COLUMN BED 

-- Patient Flow Analysis --

--Average Legnth of stay per department--
SELECT 
	Department_name,
	AVG(LOS) as Average_legnth_of_stay
From Hospital_dataset AS H
	join department AS D
	ON H.dpt_id = D.dpt_id
	Group by Department_name;

--Identify peak admission days and time--

SELECT 
	DATENAME(WEEKDAY, Date) as Weekday_name,
	Count(id) as Total_admits
from Hospital_dataset
Group by DATENAME(WEEKDAY, Date)
ORDER BY Count(id) DESC

--Readmission rates and Contributing factors--
WITH Readmit_CTE AS(
	SELECT 
		Count(CASE WHEN STATUS = 'Readmit' then 1 end) as Re_admits,
		Count(*) as Total_patients
	from Hospital_dataset
	
)

SELECT 
	Re_admits,
	Total_patients,
	Round((Re_admits * 100 / Total_patients),2) as Readmission_rate
from Readmit_CTE

--Bed occupancy rates among departemnts--


WITH BED_OCC_CTE AS(
SELECT
    Department_name,
    COUNT(Bed_ID) AS Occupied_Beds,
    ROUND(COUNT(Bed_ID) * 100.0 / SUM(COUNT(Bed_ID)) OVER (),2) AS Bed_occupancy_rate
FROM Department as D
left join Hospital_dataset as H
on D.dpt_id = H.dpt_id
group by Department_name
)

SELECT 
	Department_name,
	Bed_occupancy_rate
from Bed_OCC_CTE
Order by Bed_occupancy_rate desc



--Evaluate staff-to-patient ratios and their impact on care quality --

SELECT
	Department_name,
	COUNT(ID) AS PATIENT,
	COUNT(Distinct Staff_id) as Staff,
	ROUND(CAST(COUNT(ID) AS DECIMAL(10,4)) / COUNT(DISTINCT Staff_id),4 ) AS STF_RAT
from Hospital_dataset AS H
left join Department AS D
ON H.dpt_id = D.dpt_id
Group by Department_name


--Average Treatment cost by department--

SELECT
	Department_name,
	Round(Avg(treatemencost),2) as Avg_treat_cost
From Department as D
left join Hospital_dataset as H
ON D.dpt_id = H.dpt_id
Group by Department_name
Having Round(Avg(treatemencost),2) is not null

--o	Find departments with average ER time > 40 minutes--


SELECT 
	Department_name,
	Round(AVG(ER_time), 2) as average_ER_TIME
FROM Hospital_dataset AS H
join Department AS D
ON h.dpt_id = D.dpt_id
Group by D.Department_Name
Having AVG(ER_time) > 40
Order by average_ER_TIME DESC


--Ranking Departments by total treatement cost--
SELECT 
	Department_name,
	Sum(treatemencost) as Total_tr_cost,
	Dense_rank()Over(order by Sum(treatemencost) desc) as TC_rnk
FROM Hospital_dataset as H
join Department as D
	on H.dpt_id = D.dpt_id
Group by Department_name

--o	Find top 3 departments by patient count--
SELECT *
	FROM Hospital_dataset

SELECT TOP 3
	Department_name,
	COUNT(ID) AS Total_patients,
	Row_number()Over(order by COUNT(ID) DESC)as Rnk
from Hospital_dataset AS H
join Department AS D
	on H.dpt_id = D.dpt_id
group by Department_name


--Runing Total of treatemencost by date--
SELECT
	Distinct Datename(month, Date) as Month_name,
	SUM(treatemencost) Over(Partition by Datename(month, Date) order by Datename(month, Date) rows between Unbounded preceding and Unbounded following ) AS Rolling_TR_Cost
from Hospital_dataset
ORDER BY Rolling_tr_cost desc

--Find patients whose ER time is above overall average--
SELECT
	Distinct Id,
	Name,
	ER_time
From Hospital_dataset
where ER_TIME > (SELECT
AVG(ER_TIME) FROM Hospital_dataset
WHERE ER_TIME != 0)
Order by ER_time desc

--Find patients who visited the hospital more than once--
SELECT 
	ID,
	Status
FROM Hospital_dataset
where status = 'readmit'



SELECT
	Department_name,
	count(ER_TIME)
from department as D 
left join Hospital_dataset as H
on D.dpt_id = H.dpt_id
Group by department_name






SELECT 
	Department_name,
	Count(bed_id) as occupancy
From Hospital_dataset as H
Join Department as D
ON H.dpt_id = D.dpt_id
Group by Department_name
Order by Occupancy desc


SELECT
AVG(ER_TIME) FROM Hospital_dataset
WHERE ER_TIME != 0