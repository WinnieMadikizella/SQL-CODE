-- Exploratory Data Analysis
SELECT *
FROM layoffs_working2;

-- total Employees
SELECT company, 
	   total_laid_off, 
       ROUND((total_laid_off / (percentage_laid_off/100))) AS total_employees
FROM layoffs_working2
ORDER BY 3 DESC;

-- maximum and minimum number of people laid off
SELECT MAX(total_laid_off) AS max_laid_off,
       MIN(total_laid_off) AS min_laid_off
FROM layoffs_working2;
SELECT *
FROM layoffs_working2
WHERE total_laid_off >= 12000;

SELECT *
FROM layoffs_working2
WHERE total_laid_off <= 3;

-- maximum and minimum percentage laid off
SELECT MAX(percentage_laid_off) AS max_percentage,
	   MIN(percentage_laid_off) AS min_percentage
FROM layoffs_working2;
SELECT *
FROM layoffs_working2
WHERE percentage_laid_off > 1 OR
	  percentage_laid_off < 0;
-- 1 implies 100% layoffs meaning closedown

-- sum of the total laid off for each company
SELECT company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;

-- dates of the layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_working2;

-- industry that had the most layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY industry
ORDER BY 2 DESC;

-- country that had the most layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY country
ORDER BY 2 DESC;

-- layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- stage of the company
SELECT stage, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY stage
ORDER BY 2 DESC;

-- percentages not so much information 
SELECT company, AVG(percentage_laid_off)
FROM layoffs_working2
GROUP BY company
ORDER BY 2 DESC;

-- monthly layoffs
SELECT MONTH(`date`), SUM(total_laid_off)
FROM layoffs_working2
GROUP BY MONTH(`date`)
ORDER BY 2 DESC;

-- rolling totals per month throughout the years
WITH R_total AS (
    SELECT 
        MONTH(`date`) AS month, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_working2
    WHERE `date` IS NOT NULL 
    GROUP BY MONTH(`date`)
    ORDER BY total_laid_off DESC)
SELECT 
    month, 
    total_laid_off, 
    SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total
FROM R_total;

-- rolling totals per month per year
WITH R_total AS (
    SELECT 
        YEAR(`date`) AS year, 
        MONTH(`date`) AS month, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_working2
    WHERE `date` IS NOT NULL
    GROUP BY YEAR(`date`), MONTH(`date`)
    ORDER BY year, month)
SELECT year, month, total_laid_off, 
    SUM(total_laid_off) OVER (ORDER BY year, month) AS rolling_total
FROM R_total;

-- sum of the total laid off for each company per year
SELECT YEAR(`date`), company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`), company
ORDER BY company ASC;

-- ranking the companies that laid off the most
SELECT YEAR(`date`), company, SUM(total_laid_off)
FROM layoffs_working2
GROUP BY YEAR(`date`), company
ORDER BY 3 DESC;

-- ranking of layoffs per year
-- create a CTE
WITH company_year (years, company,total_laid_off)  AS
	(SELECT YEAR(`date`), company, SUM(total_laid_off)
    FROM layoffs_working2
    GROUP BY YEAR(`date`), company), 
-- another CTE to rank
Year_Company_Rank AS
	(SELECT *,
	DENSE_RANK( ) OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
	FROM company_year
	WHERE years IS NOT NULL)
SELECT *
FROM Year_Company_Rank
WHERE ranking <=5;


