### Week 5: DSB Ranking
markdown
# Preppin Data 2023 - Week 5: DSB Ranking

## Objective
Rank customers based on their total purchase amount.

## Steps
1. **Load Data**: Import the purchase dataset.
2. **Data Cleaning**: Ensure data consistency.
3. **Ranking**: Calculate the total purchase amount and rank customers.
4. **Output**: Create a table with customer rankings.

## SQL Code
SELECT * FROM pd_2023_wk_5;
ALTER TABLE pd_2023_wk_5 RENAME COLUMN `ï»¿Transaction Code` TO Transaction_Code;
ALTER TABLE pd_2023_wk_5 RENAME COLUMN `Customer Code` TO Customer_Code;
ALTER TABLE pd_2023_wk_5 RENAME COLUMN `Online or In-Person` TO Online_or_In_Person;
ALTER TABLE pd_2023_wk_5 RENAME COLUMN `Transaction Date` TO Transaction_Date;

#Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
SELECT SUBSTRING_INDEX(Transaction_Code,'-',1) FROM pd_2023_wk_5;
UPDATE pd_2023_wk_5 SET Transaction_Code = SUBSTRING_INDEX(Transaction_Code,'-',1);

#Change transaction date to the just be the month of the transaction
UPDATE pd_2023_wk_5 SET Transaction_Date = STR_TO_DATE(Transaction_Date,'%d/%m/%Y');
UPDATE pd_2023_wk_5 SET Transaction_Date = MONTHNAME(`Transaction_Date`);

#Total up the transaction values so you have one row for each bank and month combination
CREATE TABLE pd_2023_wk_5_final_table SELECT Transaction_Code,Transaction_Date,SUM(Value) AS Total_Value FROM pd_2023_wk_5 WHERE Transaction_Code IN ('DTB','DS','DSB') 
GROUP BY Transaction_Code,Transaction_Date ORDER BY Transaction_Date;
SELECT * FROM pd_2023_wk_5_final_table;
ALTER TABLE pd_2023_wk_5_final_table ADD COLUMN Bank_Rank_Per_Month int;
WITH Ranking  AS 
(SELECT *, RANK() OVER ( PARTITION BY Transaction_Date ORDER BY Total_Value DESC) AS Ranking FROM pd_2023_wk_5_final_table) 
UPDATE pd_2023_wk_5_final_table,Ranking r 
SET pd_2023_wk_5_final_table.Bank_Rank_Per_Month = r.Ranking
WHERE pd_2023_wk_5_final_table.Total_Value = r.Total_Value;
SELECT * FROM pd_2023_wk_5_final_table ORDER BY Transaction_Date,Total_Value DESC;

#Without losing all of the other data fields, find:
#The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
ALTER TABLE pd_2023_wk_5_final_table ADD COLUMN Avg_Rank_Per_Bank float;
SELECT AVG(Bank_Rank_Per_Month),Transaction_Code FROM pd_2023_wk_5_final_table GROUP BY Transaction_Code;
UPDATE pd_2023_wk_5_final_table T1 JOIN(
SELECT AVG(Bank_Rank_Per_Month) AS Avg_Bank,Transaction_Code FROM pd_2023_wk_5_final_table GROUP BY Transaction_Code) T2
ON T1.Transaction_Code = T2.Transaction_Code
SET T1.Avg_Rank_Per_Bank = T2.Avg_Bank;
#WITH Avg_Bank AS
#(SELECT AVG(Bank_Rank_Per_Month) Avg_Bank,Transaction_Code FROM pd_2023_wk_5_final_table GROUP BY Transaction_Code)
#UPDATE pd_2023_wk_5_final_table,Avg_Bank a
#SET pd_2023_wk_5_final_table.Avg_Rank_Per_Bank = a.Avg_Bank
#WHERE pd_2023_wk_5_final_table.Transaction_Code = a.Transaction_Code;
#
ALTER TABLE pd_2023_wk_5_final_table ADD COLUMN Avg_Transaction_Value_Per_Rank float;
UPDATE pd_2023_wk_5_final_table T1 JOIN
(SELECT AVG(Total_Value) Avg_Value,Bank_Rank_Per_Month FROM pd_2023_wk_5_final_table GROUP BY Bank_Rank_Per_Month) T2
ON T1.Bank_Rank_Per_Month = T2.Bank_Rank_Per_Month
SET T1.Avg_Transaction_Value_Per_Rank = T2.Avg_Value;
