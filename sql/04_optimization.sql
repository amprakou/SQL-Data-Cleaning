/*==============================================================================

                    DATABASE OPTIMIZATION AND CONSTRAINTS

        Add indexes for query performance and constraints for data integrity
==============================================================================





                    ADD CHECK CONSTRAINTS TO TRANSACTIONS TABLE
-- ============================================================================ 

*/


/* Ensure quantity is always a positive number, which is less or equal 100 */

ALTER TABLE transactions
ADD CONSTRAINT chk_quantity CHECK (quantity > 0 AND quantity <=100);


/* Ensure price is always a positive number, which is less or equal 70 */

ALTER TABLE transactions
ADD CONSTRAINT chk_unitprice CHECK(unit_price >0 AND unit_price <=70) ;


/* Ensure total is always a positive number, which is less or equal the multiplication of max quantity and price, from the constraints above */

ALTER TABLE transactions
ADD CONSTRAINT chk_total CHECK (total > 0 AND total <=7000) ;

/* Ensure transaction date is within valid range */
ALTER TABLE transactions
ADD CONSTRAINT chk_date_range CHECK (trn_date >= '2023-01-01' AND trn_date <= CAST(GETDATE() AS DATE));

/*==============================================================================

                    TESTING CHECK CONSTRAINTS

    ============================================================================
*/


 --  Test 1: Date before predefined range

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_past', 'Coffee', 5, 10.00, 50.00, 'Cash', 'TakeAway', '2001-01-01', 0, 0, 0);

/*
Expected iutput : The INSERT statement conflicted with the CHECK constraint "chk_date_range". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'trn_date'.
The statement has been terminated.
*/


--  Test 2: Future date

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_fut', 'Coffee', 5, 10.00, 50.00, 'Cash', 'TakeAway', '2028-01-01', 0, 0, 0);

/*
Expected iutput : The INSERT statement conflicted with the CHECK constraint "chk_date_range". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'trn_date'.
The statement has been terminated.
*/

--  Test 3 : Negative Quantity

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_neg_quantity', 'Coffee', -5, 10.00, -50.00, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*
Expected output : The INSERT statement conflicted with the CHECK constraint "chk_quantity". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'quantity'.
The statement has been terminated.
*/

--  Test 4 : Quantity > Upper Limit

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_large_quantity', 'Coffee', 1000, 10.00, 10000, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*
Expected output : The INSERT statement conflicted with the CHECK constraint "chk_quantity". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'quantity'.
The statement has been terminated.
*/

--  Test 5 : Negavive Price

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_neg_price', 'Coffee', 10, -1 , -10, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*Expected output :
Msg 547, Level 16, State 0, Line 1
The INSERT statement conflicted with the CHECK constraint "chk_unitprice". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'unit_price'.
The statement has been terminated.
*/

--  Test 6 : Price > Upper Limit

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_large_price', 'Coffee', 10, 8000 , 80000, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*Expected output :
Msg 547, Level 16, State 0, Line 1
The INSERT statement conflicted with the CHECK constraint "chk_unitprice". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'unit_price'.
The statement has been terminated.
*/

--  Test 7 : Negative Total 

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_neg_total', 'Coffee', 10, 10 , -100, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*Expected output :
Msg 547, Level 16, State 0, Line 1
The INSERT statement conflicted with the CHECK constraint "chk_total". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'total'.
The statement has been terminated.
*/

--  Test 8 : Total > Upper Limit

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_neg_total', 'Coffee', 10, 100 , 7001, 'Cash', 'TakeAway', '2026-01-01', 0, 0, 0);
/*Expected output :
Msg 547, Level 16, State 0, Line 1
The INSERT statement conflicted with the CHECK constraint "chk_total". 
The conflict occurred in database "sales_cleaning", table "dbo.transactions", column 'total'.
The statement has been terminated.
*/

--  Test 9 : Valid records

INSERT INTO transactions(transaction_id, item, quantity, unit_price, total, payment_method, location, trn_date, quantity_calculated, price_calculated, total_calculated)
VALUES('test_valid', 'Coffee', 5, 10.00, 50.00, 'Cash', 'TakeAway', '2023-06-15', 0, 0, 0);
/*
Expected output: (1 row affected)
*/

-- Proceed deleting test data
DELETE FROM transactions WHERE transaction_id = 'test_valid';
/*
Expected output: (1 row affected)
*/



/*==============================================================================
                    INDEXES FOR TRANSACTIONS TABLE
==============================================================================*/

/*Enables efficient time-based queries */
CREATE NONCLUSTERED INDEX IX_transactions_date 
ON transactions(trn_date);

/*Enables efficient product analysis queries */
CREATE NONCLUSTERED INDEX IX_transactions_item 
ON transactions(item);

/*Optimizes time-series product analysis */
CREATE NONCLUSTERED INDEX IX_transactions_date_item 
ON transactions(trn_date, item);

/*==============================================================================
                    INDEXES FOR REJECTED_TRANSACTIONS TABLE
==============================================================================*/

/*Enables quick filtering by error severity */
CREATE NONCLUSTERED INDEX IX_rejected_critical_errors 
ON rejected_transactions(critical_errors);

/*Enables efficient audit queries */
CREATE NONCLUSTERED INDEX IX_rejected_timestamp 
ON rejected_transactions(rejected_at);
