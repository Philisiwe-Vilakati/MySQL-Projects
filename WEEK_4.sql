### Week 4: New Customers
```markdown
# Preppin Data 2023 - Week 4: New Customers

## Objective
Identify and analyze new customers.

## Steps
1. **Load Data**: Import the customer dataset.
2. **Data Cleaning**: Remove duplicates and standardize customer information.
3. **Analysis**: Identify new customers based on their first purchase date.
4. **Output**: Generate a table with new customer details.

## SQL Code
#Make a Joining Date field based on the Joining Day, Table Names and the year 2023
UPDATE january SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'01','2023');
UPDATE february SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'02','2023');
UPDATE march SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'03','2023');
UPDATE april SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'04','2023');
UPDATE may SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'05','2023');
UPDATE june SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'06','2023');
UPDATE july SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'07','2023');
UPDATE august SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'08','2023');
UPDATE september SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'09','2023');
UPDATE october SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'10','2023');
UPDATE november SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'11','2023');
UPDATE december SET `Joining Day` = CONCAT_WS('/',`Joining Day`,'12','2023');

#stack the tables on top of one another, since they have the same fields in each sheet.
CREATE TABLE pd_2023_wk_4 
SELECT ID,`Joining Day`,
MAX(CASE WHEN Demographic = 'Ethnicity' THEN Value END) AS Ethnicity,
MAX(CASE WHEN Demographic = 'Date of Birth' THEN VALUE END) AS Date_of_Birth,
MAX(CASE WHEN Demographic = 'Account Type' THEN VALUE END) Account_Type
FROM ( SELECT * FROM january
UNION ALL SELECT * FROM february
UNION ALL SELECT * FROM march
UNION ALL SELECT * FROM april
UNION ALL SELECT * FROM may
UNION ALL SELECT * FROM june
UNION ALL SELECT * FROM july
UNION ALL SELECT * FROM august
UNION ALL SELECT * FROM september
UNION ALL SELECT * FROM october
UNION ALL SELECT * FROM november
UNION ALL SELECT * FROM december) combined_data GROUP BY ID,`Joining Day`;

SELECT * FROM pd_2023_wk_4;

#I renamed the Joining Day to Joining_Day
ALTER TABLE pd_2023_wk_4 RENAME COLUMN `Joining Day` TO Joining_Date;

# Change the data type of both Joining_Date and Date_of_Birth
UPDATE pd_2023_wk_4 SET Joining_Date = STR_TO_DATE(Joining_Date,'%d/%m/%Y');
UPDATE  pd_2023_wk_4 SET Date_of_Birth = STR_TO_DATE(Date_of_Birth,'%m/%d/%Y');

# I changed the date format because I personally like the dd-mm-yyyy format 
UPDATE pd_2023_wk_4 SET Joining_Date = DATE_FORMAT(Joining_Date,'%d-%m-%Y');
UPDATE pd_2023_wk_4 SET Date_of_Birth = DATE_FORMAT(Date_of_Birth,'%d-%m-%Y');

