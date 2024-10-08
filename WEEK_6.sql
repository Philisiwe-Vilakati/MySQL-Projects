SELECT * FROM pd_2023_wk_6;
#Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
CREATE TABLE PD_2023_WK_6_FINAL_TABLE 
SELECT * FROM pd_2023_wk_6  CROSS JOIN LATERAL(
SELECT 'Mobile App - Ease of Use' AS  col1,`Mobile App - Ease of Use` AS 'Mobile', 
'Online Interface - Ease of Use' AS col2,`Online Interface - Ease of Use` AS 'Online'
UNION ALL 
SELECT 'Mobile App - Ease of Access' AS col1,`Mobile App - Ease of Access` 
,'Online Interface - Ease of Access' AS col2,`Online Interface - Ease of Access` 
UNION ALL
SELECT 'Mobile App - Navigation' ,`Mobile App - Navigation`,
'Online Interface - Navigation' ,`Online Interface - Navigation`
UNION ALL
SELECT 'Mobile App - Likelihood to Recommend',`Mobile App - Likelihood to Recommend`,
'Online Interface - Likelihood to Recommend',`Online Interface - Likelihood to Recommend`
UNION ALL
SELECT 'Mobile App - Overall Rating',`Mobile App - Overall Rating`,
'Online Interface - Overall Rating',`Online Interface - Overall Rating`  ) as col;

SELECT * FROM pd_2023_wk_6_final_table;
ALTER TABLE pd_2023_wk_6_final_table DROP COLUMN `Mobile App - Ease of Use`, DROP COLUMN `Mobile App - Ease of Access`,
DROP COLUMN `Mobile App - Navigation`,DROP COLUMN `Mobile App - Likelihood to Recommend`,
DROP COLUMN `Mobile App - Overall Rating`,DROP COLUMN `Online Interface - Ease of Use`,
DROP COLUMN `Online Interface - Ease of Access`, DROP COLUMN `Online Interface - Navigation`,
DROP COLUMN `Online Interface - Likelihood to Recommend`, DROP COLUMN `Online Interface - Overall Rating`; 
ALTER TABLE pd_2023_wk_6_final_table RENAME COLUMN col1 TO Mobile_App,RENAME COLUMN col2 TO Online_Interface,
RENAME COLUMN Mobile TO Mobile_Response, 
RENAME COLUMN `Online` TO Online_Response, RENAME COLUMN `Customer ID` TO Customer_ID;

#Clean the question categories so they don't have the platform in from of them
#e.g. Mobile App - Ease of Use should be simply Ease of Use
UPDATE pd_2023_wk_6_final_table SET Mobile_App = REPLACE(Mobile_App,SUBSTRING_INDEX(`Mobile_App`,' ',3),'');
UPDATE pd_2023_wk_6_final_table SET Online_Interface = REPLACE(Online_Interface,SUBSTRING_INDEX(Online_Interface,' ',3),'');
UPDATE pd_2023_wk_6_final_table SET Mobile_App = TRIM(Mobile_App);
UPDATE pd_2023_wk_6_final_table SET Online_Interface = TRIM(Online_Interface);
#Exclude the Overall Ratings, these were incorrectly calculated by the system
DELETE FROM pd_2023_wk_6_final_table WHERE Mobile_App = 'Overall Rating';

#Calculate the Average Ratings for each platform for each customer 
SELECT TRIM(Online_Interface) FROM pd_2023_wk_6_final_table;
ALTER TABLE pd_2023_wk_6_final_table ADD COLUMN Mobile_App_Avg_Ratings float ;
ALTER TABLE pd_2023_wk_6_final_table ADD COLUMN Online_Interface_Avg_Ratings float;

UPDATE pd_2023_wk_6_final_table T1 JOIN(
SELECT AVG(Mobile_Response) Avg_Mobile_Response,Customer_ID FROM pd_2023_wk_6_final_table GROUP BY Customer_ID) T2
ON T1.Customer_ID = T2.Customer_ID
SET T1.Mobile_App_Avg_Ratings =T2.Avg_Mobile_Response;
UPDATE pd_2023_wk_6_final_table T1 JOIN(
SELECT AVG(Online_Response) Avg_Online_Response,Customer_ID FROM pd_2023_wk_6_final_table GROUP BY Customer_ID) T2
ON T1.Customer_ID =T2.Customer_ID
SET T1.Online_Interface_Avg_Ratings = T2.Avg_Online_Response;

#Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
SELECT Mobile_App_Avg_Ratings,Online_Interface_Avg_Ratings,(Online_Interface_Avg_Ratings- Mobile_App_Avg_Ratings) dif FROM pd_2023_wk_6_final_table;
ALTER TABLE pd_2023_wk_6_final_table ADD COLUMN DIFF INT;
ALTER TABLE pd_2023_wk_6_final_table MODIFY COLUMN DIFF FLOAT;
UPDATE pd_2023_wk_6_final_table SET DIFF = (Mobile_App_Avg_Ratings-Online_Interface_Avg_Ratings);

#Catergorise customers as being: Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
#Mobile App Fans if difference >= 1 ,Online Interface Fan
#Online Interface Superfan,Neutral if difference is between 0 and 1
ALTER TABLE pd_2023_wk_6_final_table ADD COLUMN Status varchar(255);
UPDATE pd_2023_wk_6_final_table SET Status = CASE
WHEN DIFF <=-2 THEN 'Online Interface Superfan'
WHEN DIFF >-2 AND DIFF <=-1 THEN 'Online Interface Fan'
WHEN DIFF >=2 THEN 'Mobile App Superfans'
WHEN DIFF >=1 AND DIFF <2 THEN 'Mobile App Fans'
ELSE 'Neutral' 
END;
SELECT * FROM pd_2023_wk_6_final_table;

#Calculate the Percent of Total customers in each category, rounded to 1 decimal place
ALTER TABLE pd_2023_wk_6_final_table ADD COLUMN Percent_Of_Total_Customers FLOAT;
UPDATE pd_2023_wk_6_final_table T1 JOIN (SELECT Status,
CASE WHEN Status = 'Online Interface Superfan' THEN ROUND(COUNT(Status)/3072*100,1)
WHEN Status = 'Online Interface Fan' THEN ROUND(COUNT(Status)/3072*100,1)
WHEN Status = 'Neutral' THEN ROUND(COUNT(Status)/3072*100,1)
WHEN Status = 'Mobile App Fans' THEN ROUND(COUNT(Status)/3072*100,1)
WHEN Status = 'Mobile App Superfans' THEN ROUND(COUNT(Status)/3072*100,1)
END Percent FROM pd_2023_wk_6_final_table GROUP BY Status) T2 
ON T1.Status = t2.Status
SET Percent_Of_Total_Customers =t2.Percent;
SELECT * FROM pd_2023_wk_6_final_table;


#Output the data
ALTER TABLE pd_2023_wk_6_final_table DROP COLUMN Customer_ID, DROP COLUMN Mobile_App, DROP COLUMN Mobile_Response, DROP COLUMN Online_Interface,
DROP COLUMN Online_Response,DROP COLUMN Mobile_App_Avg_Ratings, DROP COLUMN Online_Interface_Avg_Ratings,DROP COLUMN DIFF  ;
CREATE TEMPORARY TABLE temp_1 SELECT DISTINCT *  FROM pd_2023_wk_6_final_table;
SELECT * FROM temp_1;
DELETE FROM pd_2023_wk_6_final_table;
INSERT INTO pd_2023_wk_6_final_table SELECT * FROM temp_1;
DROP TABLE temp_1;
SELECT * FROM pd_2023_wk_6_final_table;
