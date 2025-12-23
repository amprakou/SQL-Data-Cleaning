/*==============================================================================
  SETUP SCRIPT: Create staging and production tables


                    STAGING TABLE: raw_transactions
All columns are NVARCHAR to accept any input from CSV file

*/


CREATE TABLE raw_transactions (
  transaction_id NVARCHAR(100),
  item NVARCHAR(100),
  quantity NVARCHAR(100),
  unit_price NVARCHAR(100),
  total_spent NVARCHAR(100),
  payment_method NVARCHAR(100),
  location NVARCHAR(100),
  trn_date NVARCHAR(100)
);


/*==============================================================================
                    PRODUCTION TABLE: transactions
Stores clean records with proper data types and audit flags
Only records passing all validation checks are inserted here

 */

 CREATE TABLE transactions (
  transaction_id VARCHAR(50) PRIMARY KEY,
  item VARCHAR(50) NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(20) NULL,
  location VARCHAR(50) NULL,
  trn_date DATE NOT NULL,
  quantity_calculated BIT NOT NULL DEFAULT 0,
  price_calculated BIT NOT NULL DEFAULT 0,
  total_calculated BIT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT GETDATE()
);


/*==============================================================================

                    AUDIT TABLE: rejected_transactions
Stores records that failed validation with detailed error flags
Allows data quality review

*/

CREATE TABLE rejected_transactions (
  rejection_id INT IDENTITY(1,1) PRIMARY KEY,
  transaction_id VARCHAR(50),
  item VARCHAR(50),
  quantity INT,
  unit_price DECIMAL(10,2),
  total DECIMAL(10,2),
  payment_method VARCHAR(20),
  location VARCHAR(50),
  trn_date DATE,
  critical_errors INT NOT NULL,
  missing_count INT NOT NULL,
  calculated_count INT NOT NULL,
  item_missing BIT NOT NULL,
  quantity_still_null BIT NOT NULL,
  price_still_null BIT NOT NULL,
  total_still_null BIT NOT NULL,
  date_missing BIT NOT NULL,
  rejected_at DATETIME NOT NULL DEFAULT GETDATE()
);

/*==============================================================================
                    DATA INSERTION
Prerequisites:
SQL Server service account must have READ access to CSV file path, otherwise data will not be loaded.
Execute : 
*/
                            SELECT
                                servicename,
                                service_account
                            FROM sys.dm_server_services;  

/*
Copy the account (typically: NT SERVICE\MSSQLSERVER)
After that, move the CSV file to desired folder and 
right click the folder --> Properties --> Security --> Edit Permission --> Add --> Paste the previously copied NT SERVICE\
in "Enter the object names to select ", press Check Names and now it should appear underlined. 
Press okay, and check Allow to "Read & Execute". Press OK and proceed copying your CSV's
path and pasting it to FROM clause in BULK INSERT statement, as shown below : 
*/

                            BULK INSERT raw_transactions
                            FROM 'C:\Users\User\Downloads\Data cleaning\dirty_cafe_sales.csv'
                            WITH (
                            FIRSTROW = 2,
                            FIELDTERMINATOR = ',',
                            ROWTERMINATOR = '\n'
                            );

/* 
After that, proceed executing : 
*/

                        SELECT COUNT(*) FROM raw_transactions  --(10.000 rows expected)
   /* to verify how much rows were inserted and if their number matches the rows of the initially downloaded CSV. */
   -- Optionally, you could execute :
                        SELECT TOP(200) * FROM raw_transactions 
   -- to inspect your dataset.


