-- Data cleaning 
SELECT *
FROM layoffs;
-- I will do the following in cleaning the data:
-- 1. Remove any duplicates
-- 2. Standardize the data
-- 3. Remove null or blank values
-- 4. Remove any unnecessary columns that do not add value to the data.

-- duplicate the table to work on so as to leave the raw data intact
CREATE TABLE layoffs_working
Like layoffs;
SELECT *
FROM layoffs_working;

-- insert the data to the new table
INSERT layoffs_working
SELECT *
FROM layoffs;
SELECT *
FROM layoffs_working;

-- identifying the duplicates
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_working
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;
-- confirming the duplicate (indeed there are duplicates)
SELECT *
FROM layoffs_working
WHERE company = 'Casper';
SELECT *
FROM layoffs_working
WHERE company = 'Cazoo';

-- deleting the duplicates returning only one 
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_count
FROM layoffs_working; 

-- create another table and delete where row_count > 1

CREATE TABLE `layoffs_working2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_count` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_working2;

INSERT INTO layoffs_working2
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_count
FROM layoffs_working;

SELECT *
FROM layoffs_working2
WHERE row_count > 1;

DELETE 
FROM layoffs_working2
WHERE row_count > 1;
-- confirming if they have been deleted
SELECT *
FROM layoffs_working2
WHERE row_count > 1;
SELECT *
FROM layoffs_working2;

-- Standardizing data
-- company - remove the white space
SELECT company, TRIM(company)
FROM layoffs_working2;
UPDATE layoffs_working2
SET company = TRIM(company);
-- location - all look good
SELECT DISTINCT location 
FROM layoffs_working2
ORDER BY location;
-- industry
SELECT DISTINCT industry 
FROM layoffs_working2
ORDER BY industry;
SELECT * 
FROM layoffs_working2
WHERE industry LIKE 'Crypto%';
-- implies that they all should be updated to Crypto hence
UPDATE layoffs_working2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
SELECT DISTINCT industry 
FROM layoffs_working2
ORDER BY industry;

-- date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_working2;
UPDATE layoffs_working2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SELECT `date`
FROM layoffs_working2;
-- refresh and confirm if the date data changed to datetime type
ALTER TABLE layoffs_working2
MODIFY COLUMN `date` DATE;

-- country
SELECT DISTINCT country
FROM layoffs_working2
ORDER BY country;
UPDATE layoffs_working2
SET country = 'United States'
WHERE country IN ('United States', 'United States.');

SELECT *
FROM layoffs_working2;

-- remove null and blank values
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_working2
SET industry = NULL
WHERE industry = '';

SELECT DISTINCT industry
FROM layoffs_working2
ORDER BY industry;

SELECT *
FROM layoffs_working2
WHERE industry IS NULL
OR industry = '';
-- to see if we can populate the data
SELECT *
FROM layoffs_working2
WHERE company = 'Airbnb';
-- this implies Airbnb company is in the travel industry

-- to populate this data 
SELECT *
FROM layoffs_working2 w1
JOIN layoffs_working2 w2
	ON w1.company = w2.company
    AND w1.location = w2.location
WHERE w1.industry IS NULL
AND w2.industry IS NOT NULL;

SELECT w1.industry, w2.industry
FROM layoffs_working2 w1
JOIN layoffs_working2 w2
	ON w1.company = w2.company
    AND w1.location = w2.location
WHERE w1.industry IS NULL
AND w2.industry IS NOT NULL;

UPDATE layoffs_working2 w1
JOIN layoffs_working2 w2
	ON w1.company = w2.company
    AND w1.location = w2.location 
SET w1.industry = w2.industry
WHERE w1.industry IS NULL
AND w2.industry IS NOT NULL;

SELECT *
FROM layoffs_working2
WHERE company = 'Airbnb';
-- check if there is another raw to help populate Bally's Interactive
SELECT *
FROM layoffs_working2
WHERE company LIKE 'Bally%';
-- implying it is only one unique row

-- now selecting the entire dataset
SELECT *
FROM layoffs_working2;

-- remove any unnecessary column
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- delete because the data won't be useful as we don't have any additional information
DELETE
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- confirm deletion
SELECT *
FROM layoffs_working2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_working2;

-- we can delete the row_count column as it won't be necessary 
ALTER TABLE layoffs_working2
DROP COLUMN row_count;

SELECT *
FROM layoffs_working2;