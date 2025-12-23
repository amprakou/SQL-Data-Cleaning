/*==============================================================================
                    
                    DATA QUALITY VALIDATION : 
    Validate that no NULL values exist in transaction table (0 Rows expected)
*/
SELECT 
COUNT(*) as null_values
FROM transactions
WHERE item IS NULL 
OR quantity IS NULL 
OR unit_price IS NULL 
OR total IS NULL 
OR trn_date IS NULL;

/*==============================================================================

                    COUNT OF REJECTED VALUES BY REASON :
    _null : values that were null from the initial dataset
    _calc_null : values that remain null after performing calculations 
*/

SELECT 
SUM(CAST(item_missing AS INT)) as item_null,
SUM(CAST(date_missing AS INT)) as date_null,
SUM(CAST(quantity_still_null AS INT)) as quantity_calc_null,
SUM(CAST(price_still_null AS INT)) as price_calc_null,
SUM(CAST(total_still_null AS INT)) as total_calc_null
FROM rejected_transactions;



/*==============================================================================

                    COUNT OF SUCCESSFULLY CALCULATED VALUES 
*/


SELECT 
SUM(CAST(quantity_calculated AS INT)) as quantity_calculated,
SUM(CAST(price_calculated AS INT)) as price_calculated,
SUM(CAST(total_calculated AS INT)) as total_calculated
FROM transactions;

