-- Course: CSCE 4350.501 - 11546 Fundamentals of Database Systems
-- Team1:	Diana Pappe Casco
-- 	Jiya Singh
-- 	Colton Pulliam
-- Assignment: Group Project


-- 1. Show sales trends for various brands over the past 3 years, by year, month,week.
-- Then break these data out by gender of the buyer and then by income range.

-- Income in this qury is broken down into high, medium and low income.
-- High Income- 60k+
-- Medium Income- 30k-60k
-- Low Income - <30k

-- Yearly trend
-- Groups data by year, starting at the oldest 2022. The data is then ordered by the demographic which purchased the most cars that year.
Select V.BrandID, Year(S.SaleDate) sYear, C.Gender, 
 CASE 
        WHEN C.Income < 30000 THEN 'Low'
        WHEN C.Income BETWEEN 30000 AND 60000 THEN 'Medium'
        ELSE 'High'
    END AS IncomeRange
, Sum(S.GrandTotal) as grandTotal, COUNT(V.Vin) AS VehiclesSold
from Sales S
	join SalesVehicle SV on SV.SaleNumber = S.SaleNumber
    join Vehicle V on V.Vin = SV.Vin
    join Customer C on C.CustomerID = S.CustomerID
Where S.SaleType = "V" and Year(S.SaleDate) >= year(now()) - 3 and S.SaleDate <= now()
Group by V.BrandID, Year(S.SaleDate), C.Gender, IncomeRange
Order by sYear asc, VehiclesSold desc;

-- Monthly trend
-- Groups data by months, Janurary(1)-December(12). Then the data ordered by which demograpic ordered the most cars that month.

Select V.BrandID, Month(S.SaleDate) sMonth, C.Gender, 
 CASE 
        WHEN C.Income < 30000 THEN 'Low'
        WHEN C.Income BETWEEN 30000 AND 60000 THEN 'Medium'
        ELSE 'High'
    END AS IncomeRange
, Sum(S.GrandTotal) as grandTotal, COUNT(V.Vin) AS VehiclesSold
from Sales S
	join SalesVehicle SV on SV.SaleNumber = S.SaleNumber
    join Vehicle V on V.Vin = SV.Vin
    join Customer C on C.CustomerID = S.CustomerID
Where S.SaleType = "V" and Year(S.SaleDate) >= year(now()) - 3 and S.SaleDate <= now()
Group by V.BrandID, Month(S.SaleDate), C.Gender, IncomeRange
Order by sMonth asc, VehiclesSold desc;

-- Weekly trend
-- Grouped by the weeks in a year 0-52. Then ordered by the demographic that purchased the most cars that week.
-- Most weeks consist of 1-2 cars sold

Select V.BrandID, week(S.SaleDate) sWeek, C.Gender, 
 CASE 
        WHEN C.Income < 30000 THEN 'Low'
        WHEN C.Income BETWEEN 30000 AND 60000 THEN 'Medium'
        ELSE 'High'
    END AS IncomeRange
, Sum(S.GrandTotal) as gTotal, COUNT(V.Vin) AS VehiclesSold
from Sales S
	join SalesVehicle SV on SV.SaleNumber = S.SaleNumber
    join Vehicle V on V.Vin = SV.Vin
    join Customer C on C.CustomerID = S.CustomerID
Where S.SaleType = "V" and Year(S.SaleDate) >= year(now()) - 3 and S.SaleDate <= now()
Group by V.BrandID, Week(S.SaleDate), C.Gender, IncomeRange
Order by sWeek asc, VehiclesSold desc;


-- 2. Suppose that it is found that transmissions made by supplier Getrag between two given dates are defective.
-- Find the VIN of each car containing such a transmission and the customer to which it was sold.
-- If your design allows, suppose the defective transmissions all come from only one of Getrag’s plants.
Select V.Vin, concat(IfNull(C.FirstName, ''), ' ' , IfNull(C.LastName, ''))
as SoldTo, Sp.Name
from csce4350_248_team1_proj.Vehicle V
join csce4350_248_team1_proj.Assembler A on A.Vin = V.VIN
join csce4350_248_team1_proj.PartsInventory P on trim(P.PartInventoryID) =
trim(A.PartInventoryID)
join csce4350_248_team1_proj.Parts Pt on trim(Pt.PartNumber) =
trim(P.PartNumber)
join csce4350_248_team1_proj.Supplier Sp on Sp.SupplierId = P.SuplierId
left join csce4350_248_team1_proj.SalesVehicle SV on SV.VIN = V.Vin
left join csce4350_248_team1_proj.Sales S on S.SaleNumber = SV.SaleNumber
left join csce4350_248_team1_proj.Customer C on C.CustomerId = S.CustomerId
Where S.SaleType = "V" and Sp.Name = "PowerTrain Technologies" and P.ProductionDate
= "2022-03-01" and Pt.type = "Transmission";

-- Call DefectiveProduct("PowerTrain Technologies","2022-03-01","Transmission");


-- 3. Find the top 2 brands by dollar-amount sold in the past year.
Select Sum(S.Total) TotalAmtSale, B.BrandName
from csce4350_248_team1_proj.SalesVehicle S
join csce4350_248_team1_proj.Sales H on S.SaleNumber = H.SaleNumber
join csce4350_248_team1_proj.Vehicle V on S.Vin = V.vin
join csce4350_248_team1_proj.Brand B on B.BrandId = V.BrandId
Where H.SaleType = "V" and Year(H.SaleDate) = year(now()) - 1
Group By B.BrandId
Order by count(V.Vin) desc
Limit 2;
-- call TopBrandSold(2, year(now()) - 1);


-- 4. Find the top 2 brands by unit sales in the past year.
Select count(V.Vin) TotalSale, B.BrandName
from csce4350_248_team1_proj.SalesVehicle S
join csce4350_248_team1_proj.Sales H on S.SaleNumber = H.SaleNumber
join csce4350_248_team1_proj.Vehicle V on S.Vin = V.vin
join csce4350_248_team1_proj.Brand B on B.BrandId = V.BrandId
Where H.SaleType = "V" and Year(H.SaleDate) = year(now()) - 1
Group By B.BrandId
Order by count(V.Vin) desc
limit 2;

-- call TopBrandUnitSold(2, year(now()) - 1);


-- 5. In what month(s) do convertibles sell best?
Select month(H.SaleDate) as monthSale, Count(S.SaleNumber) as maxN
from csce4350_248_team1_proj.SalesVehicle S
join csce4350_248_team1_proj.Sales H on S.SaleNumber = H.SaleNumber
join csce4350_248_team1_proj.Vehicle V on S.Vin = V.vin
join csce4350_248_team1_proj.Model M on trim(M.ModelId) = trim(V.ModelId)
Where H.SaleType = "V" and Lower(M.BodyStyle) = "convertible"
Group by month(H.SaleDate)
Order by Count(S.SaleNumber) desc
limit 1;

-- call ModelBestSold("convertible", 2023);


-- 6. Find those dealers who keep a vehicle in inventory for the longest average time.
Select I.DealerId, Dl.Name, Round(AVG(DATEDIFF(now(), I.InsertDate)),0) as
AvgInDays from csce4350_248_team1_proj.DealerInventory I join
csce4350_248_team1_proj.Dealer Dl on I.DealerId = Dl.DealerID
Where DATEDIFF(now(), I.InsertDate) > (select AVG(DATEDIFF(now(), I.InsertDate)) as
AvgT from csce4350_248_team1_proj.DealerInventory I
join csce4350_248_team1_proj.Dealer D on I.DealerID = D.DealerID
where I.vehiclestatus = "I")
Group by DealerID;

