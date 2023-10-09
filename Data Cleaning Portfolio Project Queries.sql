/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
-- Removing the SaleDate that include TIME 00:00:00.00.000, thus we need to do UPDATE TableName, SET Column = CONVERT(DataTypes, Column)

Select SaleDate
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE

-- If it doesn't Update properly, To change data type, one has to use ``` ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE ```

/*Below is the command if ALTER not work also, by adding new column*/
--ALTER TABLE NashvilleHousing
--Add SaleDateConverted Date;

--Update NashvilleHousing
--SET SaleDateConverted = CONVERT(Date,SaleDate)

--the reason the SaleDate column didn't "update" here is because UPDATE does not change data types.
--The table is actually updating, but the data type for the column SaleDate is still datetime.
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data. What mean by populate is, if there are duplicate data but both are missing some values, combine both.

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Populate can be done by using SELF JOIN, JOIN same Table

--This query to see the table, to find the fault, after identify it
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--This query to magnify the fault after detected the flaw
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--This confirm that a.PropertyAddress has null, how about we find in b.PropertyAddress too, by using ISNULL command.
--ISNULL(the column that has null value:SELFJOINTABLE1.TABLE1, what we wan to replace with:SELFJOINTABLE2.TABLE2)
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS WillReplace
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- The reason above is needed is to check before we update, to ensure we UPDATE and SET correctly. The process is just add to query
-- Add UPDATE SELFJOINTABLE1
-- SET Actual Column =(with) ISNULL(the column that has null value, we wan to replace with)
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Check after update
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL OR b.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- Since the Address is Full Address, not Individual Columns (Address, City, State)
-- Atleast it has DELIMITER, which is COMMA to break it


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID

-- SUBSTRING will be use to check the break, SUBSTRING require 3 argument
-- SUBSTRING(ColumnName, StartAt, EndUntil), mind you in SQL its start with 1. !!! 
-- CHARINDEX, looking for specific value. CHARINDEX(word or letter or expression to be looking for, ColumnName, StartLocation INT)
-- Mind you 3rd argument in CHARINDEX can be ignore
-- The result of SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) will result as 123 Taman ABC, and we dont want ','.
-- How to check first
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
CHARINDEX(',', PropertyAddress)
FROM NashvilleHousing

--After confirm, what we looking for the 3rd argument of SUBSTRING(EndUntil) is, we looking through the COMMA and we went back by 1, hence -1
-- As for the second string the SUBSTRING argument 2(StartAT) we start at the comma and +1 go to the next. As for SUBSTRING argument 3
-- since its usually diffrent length thus we cannot determine the correct ENDUNTIL thus use variable LEN(ColumnName)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

-- Then we create new column, for the break down of Full Address
-- varchar and nvarchar is the way they are stored, varchar is stored as regular 8-bit data(1 byte per character) 
-- nvarchar stores data at 2 bytes per character.
-- nvarchar can hold upto 4000 characters and it takes double the space as SQL varchar.
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Lets check the breakdown
Select *
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- For previous problem, its break into two, we use subtring, but this time we using diffrent method. Cause multiple break we use PARSENAME
-- PARSENAME do thing backward. Its only USEFULL with '.' PERIOD. Usually we need to replace COMMA with PERIOD
--  REPLACE(ColumnName, targeted value that want to be change, the replacement we want)
-- SUBSTRING and PARSENAME does not need to have SELECT *, because its already targeted which column.
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


-- Check it
Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- First we do Distinct to return diffrent type of VALUES

Select Distinct(SoldAsVacant)
FROM NashvilleHousing

--Lets count the SoldAsVacant, after we GROUP BY and DISTINCT it.
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


-- Then we test the change using ,CASE WHEN,THEN,ELSE END
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant = 'N'

-- As we just need to update DB, we Pput UPDATE SET and copy the test.
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates, we are using new thing call ROW_NUMBER() OVER (PARTITION BY

SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
-- We should see the row_num >1 meaning they have been Partition BY(if 2 it has 2 same and been group). We cannot use WHERE row_num > 1
--As the row_num just created, thus we create CTE


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Select * above will be replace by DELETE to delete the duplicates. SELECT * = DELETE

Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns, after drop table use in temp table, we can also drop column.



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















