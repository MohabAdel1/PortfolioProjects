
/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM PortfolioProject2..NASHVILLEHOUSING

------------------------------------------------------------------------------------------------

--Standarize the Data to a Specific Format

SELECT SaleDate,CONVERT(DATE,SaleDate)
FROM PortfolioProject2..NASHVILLEHOUSING

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD SalesDateCONV Date;

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET SalesDateCONV = CONVERT(DATE,SaleDate)

SELECT SalesDateCONV
FROM PortfolioProject2..NASHVILLEHOUSING

-------------------------------------------------------------------------------------------------
--Populate Address for Property Data where Property Address is Null

SELECT one.ParcelID,one.PropertyAddress,two.ParcelID,two.PropertyAddress,ISNULL(one.PropertyAddress,two.PropertyAddress)
FROM PortfolioProject2..NASHVILLEHOUSING one
JOIN PortfolioProject2..NASHVILLEHOUSING two
ON one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]
WHERE one.PropertyAddress is null

UPDATE one
SET PropertyAddress = ISNULL(one.PropertyAddress,two.PropertyAddress)
FROM PortfolioProject2..NASHVILLEHOUSING one
JOIN PortfolioProject2..NASHVILLEHOUSING two
ON one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]
WHERE one.PropertyAddress is null

-------------------------------------------------------------------------------------------------
--Breaking Address for Property Data where it will have a specific format(Address,City,State)
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as AddressCity
FROM PortfolioProject2..NASHVILLEHOUSING


ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD PropertyAddressSplit Varchar(255);

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD PropertyCitySplit Varchar(255);

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET PropertyCitySplit = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



------------------------------------------------------------------------------------------------
--Breaking Owner Address for Owner Property Data where it will have a specific format(Address,City,State)

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject2..NASHVILLEHOUSING

ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD OwnerAddressSplit Varchar(255);

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD OwnerCitySplit Varchar(255);

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject2..NASHVILLEHOUSING
ADD OwnerStateSplit Varchar(255);

UPDATE PortfolioProject2..NASHVILLEHOUSING
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------
--Just to view the output
SELECT *
FROM PortfolioProject2..NASHVILLEHOUSING
------------------------------------------------------------------------------------------------
--Change 'Y' and 'N' in Sold As Vacant to 'YES' and 'NO'
SELECT SoldAsVacant,COUNT(SoldAsVacant),
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END AS TESTVACANT
FROM PortfolioProject2..NASHVILLEHOUSING
Group By [UniqueID ],SoldAsVacant


UPDATE PortfolioProject2..NASHVILLEHOUSING
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
END

SELECT SoldAsVacant,COUNT(SoldAsVacant)
FROM PortfolioProject2..NASHVILLEHOUSING
GROUP BY SoldAsVacant

------------------------------------------------------------------------------------------------
--Remove Dupliates
 
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
From PortfolioProject2..NASHVILLEHOUSING 
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete the Columns that we are not using


ALTER TABLE  PortfolioProject2..NASHVILLEHOUSING
DROP COLUMN  TaxDistrict,OwnerAddress,  SaleDate,PropertyAddress


Select *
From PortfolioProject2..NASHVILLEHOUSING

