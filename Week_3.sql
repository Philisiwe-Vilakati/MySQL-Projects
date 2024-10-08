### Week 3: Targets for DSB
```markdown
# Preppin Data 2023 - Week 3: Targets for DSB

## Objective
Compare actual sales against targets for DSB.

## Steps
1. **Load Data**: Import the sales and targets datasets.
2. **Data Cleaning**: Ensure consistency in product names.
3. **Comparison**: Calculate the difference between actual sales and targets.
4. **Output**: Create a table showing sales performance against targets.

## SQL Code
SELECT * FROM pd_2023_wk_3;
ALTER TABLE pd_2023_wk_3 RENAME COLUMN `ï»¿Transaction Code` TO Transaction_Code,
RENAME COLUMN `Customer Code` TO Customer_Code,
RENAME COLUMN `Online or In-Person` TO Online_or_In_Person,
RENAME COLUMN `Transaction Date` TO Transaction_Date;
#######For the transactions file:###############
#Filter the transactions to just look at DSB 
# IN MY UNDERSTANDING FILTERING OUT MEANS REMOVING ALL ROWS THAT DO NOT CONTAIN DSB IN THE TRANSACTION CODE
SELECT * FROM pd_2023_wk_3 WHERE Transaction_Code NOT LIKE '%DSB%';
DELETE FROM pd_2023_wk_3 WHERE Transaction_Code NOT LIKE '%DSB%';
#Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
ALTER TABLE pd_2023_wk_3 MODIFY COLUMN Online_or_In_Person varchar(255);
UPDATE pd_2023_wk_3 SET Online_or_In_Person =  CASE
WHEN Online_or_In_Person = 1 THEN 'Online'
WHEN Online_or_In_Person = 2 THEN 'In-Person'
END;
#Change the date to be the quarter
SELECT STR_TO_DATE(Transaction_Date,'%d/%m/%Y') FROM pd_2023_wk_3;
UPDATE pd_2023_wk_3 SET Transaction_Date = STR_TO_DATE(Transaction_Date,'%d/%m/%Y %H:%i:%s');
SELECT QUARTER(Transaction_Date) FROM pd_2023_wk_3;
UPDATE pd_2023_wk_3 SET Transaction_Date = QUARTER(Transaction_Date);
ALTER TABLE pd_2023_wk_3 RENAME COLUMN Transaction_Date TO Quarter;
#Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person)
SELECT Quarter,Online_or_In_Person,SUM(Value) Value FROM pd_2023_wk_3 WHERE Online_or_In_Person IN ('Online','In-Person') GROUP BY Quarter,Online_or_In_Person;
###############For the targets file############
#Unpivot the quarterly targets so we have a row for each Type of Transaction and each Quarter 
#Rename the fields
SELECT * FROM pd_2023_wk_3_targets;
CREATE TEMPORARY TABLE temp_wk_3_2023 SELECT Online_or_In_Person,X.* FROM pd_2023_wk_3_targets CROSS JOIN LATERAL(
SELECT 'Q1' Quarter,Q1 Quarterly_Targets
UNION ALL SELECT 'Q2',Q2 
UNION ALL SELECT 'Q3',Q3 
UNION ALL SELECT 'Q4',Q4 ) X ;
SELECT * FROM temp_wk_3_2023;

#Remove the 'Q' from the quarter field and make the data type numeric 
UPDATE temp_wk_3_2023 SET Quarter = REPLACE(Quarter,'Q','');

#Join the two datasets together
#############Join the two datasets together ###############
# Instead of joining the tables ,I added a new column to the main table pd_2023_wk_3 and used the values from the pd_2023_wk_3_targets for the THEN part of the CASE statement
ALTER TABLE pd_2023_wk_3 ADD COLUMN Quarterly_Targets int;
UPDATE pd_2023_wk_3 SET Quarterly_Targets = CASE
WHEN Online_or_In_Person = 'Online' AND Quarter= 1 THEN 72500
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 1 THEN 75000
WHEN Online_or_In_Person = 'Online' AND Quarter = 2 THEN 70000
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 2 THEN 70000
WHEN Online_or_In_Person = 'Online' AND Quarter = 3 THEN 60000
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 3 THEN 70000
WHEN Online_or_In_Person = 'Online' AND Quarter = 4 THEN 60000
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 4 THEN 60000
END;

SELECT * FROM temp_wk_3_2023;
SELECT * FROM pd_2023_wk_3;
# I also added a new column to the main table pd_2023_wk_3 and added the values to the column using the CASE statement
#I used the results from the Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) step for the THEN 
#part of the CASE statement, the query below is from the step mentioned above
#SELECT Quarter,Online_or_In_Person,SUM(Value) Value FROM pd_2023_wk_3 WHERE Online_or_In_Person IN ('Online','In-Person') 
#GROUP BY Quarter,Online_or_In_Person;
SELECT SUM(Value),Online_or_In_Person,Quarter FROM pd_2023_wk_3 WHERE Online_or_In_Person IN('Online','In-Person') GROUP BY Online_or_In_Person,Quarter;
ALTER TABLE pd_2023_wk_3 ADD COLUMN New_Value int;
UPDATE pd_2023_wk_3 SET New_Value = CASE
WHEN Online_or_In_Person = 'Online' AND Quarter= 1 THEN 74562
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 1 THEN 77576
WHEN Online_or_In_Person = 'Online' AND Quarter = 2 THEN 69325
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 2 THEN 70634
WHEN Online_or_In_Person = 'Online' AND Quarter = 3 THEN 59072
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 3 THEN 74186
WHEN Online_or_In_Person = 'Online' AND Quarter = 4 THEN 61908
WHEN Online_or_In_Person = 'In-Person' AND Quarter = 4 THEN 43223
END;

#Calculate the Variance to Target for each row
ALTER TABLE pd_2023_wk_3 ADD COLUMN Variance_to_Target INT;
SELECT New_Value- Quarterly_Targets   FROM pd_2023_wk_3 ;
UPDATE pd_2023_wk_3 SET Variance_to_Target = New_Value- Quarterly_Targets;
#Remove unnecessary fields
ALTER TABLE pd_2023_wk_3 DROP Transaction_Code,DROP Value,DROP Customer_Code;
SELECT * FROM pd_2023_wk_3;
#Output the data
SELECT DISTINCT * FROM pd_2023_wk_3;
CREATE TABLE pd_2023_wk_3_final_table SELECT DISTINCT * FROM pd_2023_wk_3;
SELECT * FROM pd_2023_wk_3_final_table;

