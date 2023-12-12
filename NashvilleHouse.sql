SELECT *
FROM PortFolioProject..NashvilleHouse

--Standardize Date Format

ALTER TABLE PortFolioProject..NashvilleHouse
ADD SaleDateConverted Date;

UPDATE PortFolioProject..NashvilleHouse
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM PortFolioProject..NashvilleHouse

--Populateproperty address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortFolioProject..NashvilleHouse a
JOIN PortFolioProject..NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortFolioProject..NashvilleHouse a
JOIN PortFolioProject..NashvilleHouse b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out Address into Individual Column

SELECT PropertyAddress
FROM PortFolioProject..NashvilleHouse

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM PortFolioProject..NashvilleHouse

ALTER TABLE PortFolioProject..NashvilleHouse
ADD PropertyAddressSplit Nvarchar(255);

Update PortFolioProject..NashvilleHouse
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortFolioProject..NashvilleHouse
ADD PropertyAddressCity Nvarchar(255);

Update PortFolioProject..NashvilleHouse
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

--Breaking OwnerAddress into individual columns

SELECT OwnerAddress
FROM PortFolioProject..NashvilleHouse

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortFolioProject..NashvilleHouse

ALTER TABLE PortFolioProject..NashvilleHouse
ADD OwnerSplitAddress Nvarchar(255);

Update PortFolioProject..NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortFolioProject..NashvilleHouse
ADD OwnerSplitCity Nvarchar(255);

Update PortFolioProject..NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortFolioProject..NashvilleHouse
ADD OwnerSplitState Nvarchar(255);

Update PortFolioProject..NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in "Sold as Vacant"

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) as Number
FROM PortFolioProject..NashvilleHouse
GROUP BY SoldAsVacant
ORDER BY Number

SELECT SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM PortFolioProject..NashvilleHouse

UPDATE PortFolioProject..NashvilleHouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 LandUse,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) RowNums
FROM PortFolioProject..NashvilleHouse)
DELETE
FROM RowNumCTE
WHERE RowNums > 1
--ORDER BY PropertyAddress

SELECT *
FROM PortFolioProject..NashvilleHouse
