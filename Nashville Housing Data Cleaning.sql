-- Renaming of columns for future manipulation

EXEC sp_rename 'NashvilleHousing.PropertyAddress', 'FullPropertyAddress', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.OwnerAddress', 'FullOwnerAddress', 'COLUMN'
EXEC sp_rename 'NashvilleHousing.SaleDateNew', 'SaleDate', 'COLUMN'

SELECT *
FROM [Portfolio Project]..NashvilleHousing

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Change date format

--Approach #1 

SELECT SaleDate
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ALTER COLUMN SaleDate DATE

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Populating NULL Property Address values

SELECT a.ParcelID, a.FullPropertyAddress, 
	   b.ParcelID, b.FullPropertyAddress, 
	   ISNULL(b.FullPropertyAddress, a.FullPropertyAddress) 
	FROM [Portfolio Project]..NashvilleHousing a
	  JOIN [Portfolio Project]..NashvilleHousing b
	  ON a.ParcelID = b.ParcelID
	WHERE a.[UniqueID ] <> b.[UniqueID ]
	AND b.FullPropertyAddress IS NULL
	ORDER BY a.ParcelID

UPDATE b
	SET FullPropertyAddress = ISNULL(b.FullPropertyAddress, a.FullPropertyAddress) 
	FROM [Portfolio Project]..NashvilleHousing a
		JOIN [Portfolio Project]..NashvilleHousing b
		ON a.ParcelID = b.ParcelID
	WHERE a.[UniqueID ] <> b.[UniqueID ]
	  AND b.FullPropertyAddress IS NULL

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT FullPropertyAddress,
	SUBSTRING(FullPropertyAddress, 1, CHARINDEX(',', FullPropertyAddress) -1) AS PropertyAddress,
	SUBSTRING(FullPropertyAddress, CHARINDEX(',', FullPropertyAddress) +1, LEN(FullPropertyAddress)) AS PropertyCity
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddress = SUBSTRING(FullPropertyAddress, 1, CHARINDEX(',', FullPropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(FullPropertyAddress, CHARINDEX(',', FullPropertyAddress) +1, LEN(FullPropertyAddress))

SELECT 
	FullPropertyAddress,
	PropertyAddress,
	PropertyCity
FROM 
	[Portfolio Project]..NashvilleHousing

SELECT 
	PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 3) AS OwnerAddress,
	PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 2) AS OwnerCity,
	PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 1) AS OwnerState
FROM 
	[Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerAddress nvarchar(255);

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerCity nvarchar(255);

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerAddress = PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 3)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 2)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(FullOwnerAddress, ',', '.'), 1) 
	
/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Change Y and N values to the more populated Yes and No values (in SoldAsVacant column)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Remove Duplicates

WITH 
	DuplicatesCTE AS (
	SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY	ParcelID,
							FullPropertyAddress,
							SalePrice,
							LegalReference,
							OwnerName,
							SaleDate
							ORDER BY UniqueID) AS NumberOfDuplicates
	FROM [Portfolio Project]..NashvilleHousing
	)
SELECT *
FROM DuplicatesCTE
WHERE NumberOfDuplicates > 1
	

/* //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */

-- Delete Unused Columns

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN TaxDistrict
