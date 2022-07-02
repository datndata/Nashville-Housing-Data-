/* 

Project Aim: Cleaning Dataset with non-standardised data formate, NULL value and combined data values
Name: Datt Nguyen 
Dataset:  https://www.kaggle.com/tmthyjames/nashville-housing-data-1/data
Date: 7/11/2021	

*/

--Explore the data 
SELECT *
From PortfolioProject.dbo.NashvilleHousing

-- Step 1: Standardise Date Format 
-- As there is Time Data at the end as 00:00:00 that serve no values 

--Use ALTER TABLE function to add a col
ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

-- Update the newly created table with converted date (formate: date) from SaleDate
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Check if this works
Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

-- Step 2 - Populate Property Address Data  
-- Noted a lot of rows is missing PropertyAddress
-- It seems that PropertyAddress was sometimes only mentioned once per ParcelID 
-- To populate missing PropertyAddress 
-- Split the data into 2 tables (a & b), each has 2 cols being ParcelID and PropertyAddress
-- Noted each cell has a uniqueID (Checked through count(distinct) function below
Select COUNT(DISTINCT(UniqueID))
From NashvilleHousing
--
Select *
From PortfolioProject.dbo.NashvilleHousing
-- Check completed. No issues noted. 

--Where a.PropertyAddress is null, populate it from b.PropertyAddress for all data point that share the same ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND	a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Update the table to replace all null value 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND	a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address,City,State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
-- CHARINDEX is a the number location of the character in the string
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

-- Alter the table with 2 new cols
-- Step 1: Add the col
ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);
-- Step 2: Update the col
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
-- Same process here for City 
ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- Check to see if this has been implemented correctly
SELECT *
From PortfolioProject.dbo.NashvilleHousing
-- 2 columns of the split addresses were added at the end 

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
-- Separate the owner address columns using a different method 
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

-- Update the table with these 3 new shiny cols
-- Create the new cols first 
ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);
ALTER TABLE NashvilleHousing 
Add OwnerSplitCity nvarchar(255);
ALTER TABLE NashvilleHousing 
Add OwnerSplitState nvarchar(255);


-- Update all cols in one go for better efficiency 
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field 

-- Explore the data 
-- Noted 'Yes' and 'No' are the preferred options 
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) 
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

-- Test Code to change Y and N to Yes and No using CASE function 
SELECT SoldASVacant
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldASVacant 
		END
From PortfolioProject.dbo.NashvilleHousing

-- Update the table 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldASVacant 
		END


--------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates 
WITH RowNumCTE as(SELECT *,ROW_NUMBER()OVER
		  	(PARTITION BY ParcelID, 
			 	PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num
				From PortfolioProject.dbo.NashvilleHousing
				)
SELECT*
FROM RowNumCTE
--Order by ParcelID
Where row_num > 1
--Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns that we no longer want to see 

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,
			TaxDistrict, 
			PropertyAddress,
			SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate




















