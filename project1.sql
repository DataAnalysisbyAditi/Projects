
---------------------------------------------------DATA CLEANING USING SQL----------------------------------------


Select * from
PROJECTHOUSING.dbo.housingdata


--STANDARDISING THE DATE--

Select SaleDate
from PROJECTHOUSING.dbo.housingdata

ALTER TABLE housingdata
ADD SaleDateConverted date

Update housingdata
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM housingdata

--POPULATE PROPERTY ADDRESS DATA--

SELECT PropertyAddress
FROM housingdata
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
FROM housingdata a
JOIN housingdata b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
FROM housingdata a
JOIN housingdata b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--SPLITTING ADDRESS--

ALTER TABLE housingdata
ADD PropertySplitAddress nvarchar(250);
UPDATE housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
                       

ALTER TABLE housingdata
ADD PropertySplitCity nvarchar(250);
UPDATE housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM housingdata

ALTER TABLE housingdata
ADD OwnerSplitAddress nvarchar(250);
UPDATE housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE housingdata
ADD OwnerSplitCity nvarchar(100);
UPDATE housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE housingdata
ADD OwnerSplitState nvarchar(100);
UPDATE housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--CHANGING Y AND N INTO 'YES' AND 'NO' 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as TOT_COUNT
FROM housingdata
GROUP BY SoldAsVacant
ORDER BY TOT_COUNT

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                          WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END
from housingdata

UPDATE housingdata
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END


-- REMOVE DUPLICATES FROM COPIED DATA--

WITH REMOVE_DUPLICATE AS
(SELECT *, ROW_NUMBER() OVER( PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference 
                             ORDER BY UniqueID) AS Row_Num
FROM housingdata)
DELETE FROM REMOVE_DUPLICATE
WHERE Row_Num >1


--REMOVING UNUSED COLUMNS FROM COPIED DATA--

ALTER TABLE housingdata
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict


