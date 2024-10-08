# Week 2: International Bank Account Numbers
## Objective
Validate and format international bank account numbers.

## Steps
1. **Load Data**: Import the dataset containing bank account numbers.
2. **Validation**: Check the format of each account number.
3. **Formatting**: Standardize the format of valid account numbers.
4. **Output**: Generate a table with validated and formatted account numbers.

## SQL Code

SELECT * FROM pd_2023_wk_2_swift_codes;
SELECT * FROM pd_2023_wk_2_transactions;
ALTER TABLE pd_2023_wk_2_transactions RENAME COLUMN `Transaction ID` TO Transaction_ID,
RENAME COLUMN `Account Number` TO Account_Number,
RENAME COLUMN `Sort Code` TO Sort_Code;
ALTER TABLE pd_2023_wk_2_swift_codes RENAME COLUMN `SWIFT code` TO SWIFT_Code,
RENAME COLUMN `Check Digits` TO Check_Digits;
#In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string
SELECT REPLACE(Sort_Code,'-','') FROM pd_2023_wk_2_transactions;
UPDATE pd_2023_wk_2_transactions SET Sort_Code = REPLACE(Sort_Code,'-','');

#Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account
SELECT  pd_2023_wk_2_transactions.*,pd_2023_wk_2_swift_codes.SWIFT_Code,pd_2023_wk_2_swift_codes.Check_Digits 
FROM pd_2023_wk_2_transactions JOIN pd_2023_wk_2_swift_codes ON pd_2023_wk_2_transactions.Bank = pd_2023_wk_2_swift_codes.Bank;
CREATE TABLE pd_2023_wk_2_ct AS SELECT  pd_2023_wk_2_transactions.* ,pd_2023_wk_2_swift_codes.SWIFT_Code,pd_2023_wk_2_swift_codes.Check_Digits 
FROM pd_2023_wk_2_transactions JOIN pd_2023_wk_2_swift_codes ON pd_2023_wk_2_transactions.Bank = pd_2023_wk_2_swift_codes.Bank;
SELECT * FROM pd_2023_wk_2_ct;

#Add a field for the Country Code
ALTER TABLE pd_2023_wk_2_ct ADD COLUMN Country_Code varchar(100);
UPDATE pd_2023_wk_2_ct SET Country_Code = 'GB'; 

#Create the IBAN as above
ALTER TABLE pd_2023_wk_2_ct ADD COLUMN IBAN varchar(255);
UPDATE pd_2023_wk_2_ct SET IBAN = CONCAT_WS('-',Country_Code,Check_Digits,SWIFT_Code,Sort_Code,Account_Number);

#Remove unnecessary fields 
ALTER TABLE pd_2023_wk_2_ct DROP Account_Number,DROP Sort_Code,DROP Bank,DROP SWIFT_Code,DROP Check_Digits,DROP Country_Code;

