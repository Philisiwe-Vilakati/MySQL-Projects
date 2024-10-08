SELECT * FROM pd_2023_wk_1;
ALTER TABLE pd_2023_wk_1 RENAME COLUMN `ï»¿Transaction Code` TO Transaction_Code,
RENAME COLUMN `Customer Code` TO Customer_Code,
RENAME COLUMN `Online or In-Person` TO Online_or_In_Person,
RENAME COLUMN `Transaction Date` TO Transaction_Date;

#Split the Transaction Code to extract the letters at the start of the transaction code. These identify the bank who processes the transaction

ALTER TABLE pd_2023_wk_1 ADD COLUMN Bank varchar(255) AFTER Transaction_Code;
UPDATE pd_2023_wk_1 SET Bank = SUBSTRING_INDEX(Transaction_Code,'-',1);
UPDATE pd_2023_wk_1 SET Transaction_Code = SUBSTRING_INDEX(Transaction_Code,'-',-3);

#Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values. 

ALTER TABLE pd_2023_wk_1 MODIFY COLUMN `Online_or_In_Person` varchar(255);
UPDATE pd_2023_wk_1 SET `Online_or_In_Person` = CASE
WHEN `Online_or_In_Person` = 1 THEN 'Online'
WHEN `Online_or_In_Person` = 2 	THEN 'In-Person'
END;

#Change the date to be the day of the week

SELECT STR_TO_DATE(Transaction_Date,'%d/%m/%Y %H:%i:%s'),Transaction_Date FROM pd_2023_wk_1;
UPDATE pd_2023_wk_1 SET Transaction_Date = STR_TO_DATE(Transaction_Date,'%d/%m/%Y %H:%i:%s');
SELECT DATE(Transaction_Date) FROM pd_2023_wk_1;
UPDATE pd_2023_wk_1 SET Transaction_Date = DATE(Transaction_Date);
SELECT DAYNAME(Transaction_Date) FROM pd_2023_wk_1;
UPDATE pd_2023_wk_1 SET Transaction_Date = DAYNAME(Transaction_Date);

#Different levels of detail are required in the outputs. You will need to sum up the values of the transactions in three ways
#Total Values of Transactions by each bank

SELECT Bank,SUM(Value) Value FROM pd_2023_wk_1 WHERE Bank IN('DS','DSB','DTB') GROUP BY Bank;

# Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
 
SELECT Bank,Transaction_Date,Online_or_In_Person,SUM(Value) Value FROM pd_2023_wk_1 WHERE Bank IN('DS','DSB','DTB')
AND Online_or_In_Person IN ('Online','In-Person') GROUP BY Bank,Transaction_Date,Online_or_In_Person;
#Total Values by Bank and Customer Code
SELECT Bank,Customer_Code,SUM(Value) Value FROM pd_2023_wk_1 WHERE Bank IN('DS','DSB','DTB') GROUP BY Bank,Customer_Code;