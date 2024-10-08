SELECT * FROM account_holders_pd_2023_wk_7;
SELECT * FROM account_information_pd_2023_wk_7;
SELECT * FROM transaction_detail_pd_2023_wk_7;
SELECT * FROM transaction_path_pd_2023_wk_7;
#Make sure field naming convention matches the other tables
#i.e. instead of Account_From it should be Account From
ALTER TABLE `account_holders_pd_2023_wk_7` RENAME COLUMN `Account Holder ID` TO Account_Holder_ID,
RENAME COLUMN `Date of Birth` TO Date_of_Birth, RENAME COLUMN `Contact Number` TO Contact_Number,
RENAME COLUMN `First Line of Address` TO First_Line_of_Address;

ALTER TABLE account_information_pd_2023_wk_7 RENAME COLUMN `Account Number` TO Account_Number,
RENAME COLUMN `Account Type` TO Account_Type, RENAME COLUMN `Account Holder ID` TO Account_Holder_ID,
RENAME COLUMN `Balance Date` TO Balance_Date;

ALTER TABLE transaction_detail_pd_2023_wk_7 RENAME COLUMN `Transaction ID` TO Transaction_ID,
RENAME COLUMN `Transaction Date` TO Transaction_Date;

ALTER TABLE transaction_path_pd_2023_wk_7 RENAME COLUMN `Transaction ID` TO Transaction_ID;
#For the Account Information table:
#Make sure there are no null values in the Account Holder ID
SELECT * FROM account_information_pd_2023_wk_7 WHERE Account_Number IS NULL;

#Ensure there is one row per Account Holder ID
#Joint accounts will have 2 Account Holders, we want a row for each of them
SELECT * FROM account_information_pd_2023_wk_7 WHERE Account_Type ='Joint' ;
CREATE TEMPORARY TABLE temp1_wk_7
SELECT Account_Number,Account_Type, SUBSTRING_INDEX(Account_Holder_ID,',',1) AS Account_Holder_ID,
 Balance_Date,Balance FROM account_information_pd_2023_wk_7 
 UNION 
 SELECT Account_Number,Account_Type, SUBSTRING_INDEX(Account_Holder_ID,', ',-1) AS Account_Holder_ID,
 Balance_Date,Balance FROM account_information_pd_2023_wk_7  ORDER BY 
Account_Number ASC;
SELECT * FROM temp1_wk_7;
DELETE FROM account_information_pd_2023_wk_7;
INSERT INTO account_information_pd_2023_wk_7 SELECT * FROM temp1_wk_7;
SELECT * FROM account_information_pd_2023_wk_7;

#For the Account Holders table:
#Make sure the phone numbers start with 07
SELECT * FROM account_holders_pd_2023_wk_7;
SELECT CONCAT(0,Contact_Number) FROM account_holders_pd_2023_wk_7;
#Phone numbers should always be stored as a varchar.
ALTER TABLE account_holders_pd_2023_wk_7 MODIFY Contact_Number varchar(255);
UPDATE account_holders_pd_2023_wk_7 SET Contact_Number = CONCAT(0,Contact_Number);

#Bring the tables together
CREATE TEMPORARY TABLE temp2_wk_7
SELECT X.Name,X.Date_of_Birth,X.Contact_Number,X.First_Line_of_Address, Y.* FROM account_holders_pd_2023_wk_7 AS X INNER JOIN account_information_pd_2023_wk_7 AS Y
ON X.Account_Holder_ID = Y.Account_Holder_ID;
CREATE TEMPORARY TABLE temp3_wk_7
SELECT A.*,B.Account_To,B.Account_From FROM transaction_detail_pd_2023_wk_7 AS A INNER JOIN transaction_path_pd_2023_wk_7 AS B
ON A.Transaction_ID = B.Transaction_ID;
CREATE TABLE pd_2023_wk_7_final_table
SELECT C.* ,D.* FROM temp2_wk_7 AS C JOIN temp3_wk_7 AS D ON C.Account_Number = D.Account_From;
SELECT * FROM pd_2023_wk_7_final_table;

SELECT Transaction_ID,Account_To,Transaction_Date,`Value`,Account_Number,Account_Type,Balance_Date,Balance,`Name`,
Date_of_Birth,Contact_Number,First_Line_of_Address FROM pd_2023_wk_7_final_table 
WHERE `Value` > 1000 AND Account_Type NOT IN ('Platinum') AND `Cancelled?` = 'N' ;

#Cleaning up
SELECT * FROM pd_2023_wk_7_final_table;
UPDATE pd_2023_wk_7_final_table SET Date_of_Birth = STR_TO_DATE(Date_of_Birth,"%d/%m/%Y");
ALTER TABLE pd_2023_wk_7_final_table MODIFY Account_Holder_ID bigint;
UPDATE pd_2023_wk_7_final_table SET Balance_Date = STR_TO_DATE(Balance_Date,"%Y-%m-%d");
ALTER TABLE pd_2023_wk_7_final_table MODIFY Transaction_ID bigint;
UPDATE pd_2023_wk_7_final_table SET Transaction_Date = STR_TO_DATE(Transaction_Date,"%Y-%m-%d");
