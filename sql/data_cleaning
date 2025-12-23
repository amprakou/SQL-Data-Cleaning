/*==============================================================================

                    DATA QUALITY CHECKS:

   Verified no NULL transaction_ids exist in raw data:  */
   SELECT COUNT(*) FROM raw_transactions WHERE transaction_id IS NULL
--   Result: 0 rows 

/*                   TYPE CONVERSIONS AND DATE PARSING:

   Cast string columns to correct numeric data types for calculations
   Parse dates with multiple format fallbacks (MM-DD-YYYY, DD-MM-YYYY, default)
   TRANSLATE converts common separators (. / ,) to hyphens for consistent parsing */

 --                 CALCULATED MISSING VALUES: QUANTITY, PRICE, TOTAL

-- Each item has exactly one fixed price in the dataset (validated via query): 


   SELECT DISTINCT ITEM, UNIT_PRICE FROM RAW_TRANSACTIONS
   WHERE ITEM NOT IN ('ERROR','UNKNOWN') AND ITEM IS NOT NULL
   AND UNIT_PRICE NOT IN ('ERROR','UNKNOWN') AND UNIT_PRICE IS NOT NULL;
   
/*  Given fixed pricing, we can proceed calculating missing values using: total = quantity x price
   If quantity missing: quantity = total / price
   If price missing: price = total / quantity  
   If total missing: total = quantity x price */

WITH cleaning AS ( 
SELECT 
UPPER(transaction_id) as transaction_id, 
    
CASE 
      WHEN item IS NULL OR item IN ('UNKNOWN','ERROR') THEN NULL 
      ELSE UPPER(LEFT(item,1)) + LOWER(SUBSTRING(item,2,LEN(item))) 
END as item,
    
    msrs.quantity_cleaned as quantity_original,
    msrs.price_cleaned as price_original,
    msrs.total_spent_cl as total_original,
    
ISNULL(msrs.quantity_cleaned, msrs.total_spent_cl / NULLIF(msrs.price_cleaned, 0)) as quantity,
ISNULL(msrs.price_cleaned, msrs.total_spent_cl / NULLIF(msrs.quantity_cleaned, 0)) as price,
    
CASE 
      WHEN payment_method IS NULL OR payment_method IN ('UNKNOWN','ERROR') THEN NULL
      ELSE UPPER(LEFT(payment_method,1)) + LOWER(SUBSTRING(payment_method,2,LEN(payment_method)))
END AS payment_method,
    
CASE 
      WHEN location IS NULL OR location IN ('UNKNOWN','ERROR') THEN NULL 
      ELSE location 
END AS location,
    
CASE 
      WHEN dt.trn_date_parsed > CAST(GETDATE() AS DATE) THEN NULL -- ensure transaction wasn't made in future
      ELSE dt.trn_date_parsed 
END as trn_date
    
FROM raw_transactions
  
  CROSS APPLY (
SELECT 
TRY_CAST(quantity AS INT) as quantity_cleaned,
TRY_CAST(unit_price AS DECIMAL(10,2)) as price_cleaned,
TRY_CAST(total_spent AS DECIMAL(10,2)) as total_spent_cl) msrs
  
  CROSS APPLY (
SELECT COALESCE(
TRY_PARSE(TRANSLATE(trn_date, './,', '---') AS DATE USING 'en-US'),
TRY_PARSE(TRANSLATE(trn_date, './,', '---') AS DATE USING 'en-GB'),
TRY_PARSE(TRANSLATE(trn_date, './,', '---') AS DATE)) AS trn_date_parsed) dt
),

/* Deduplication step to keep the most recent transactions if duplicates exist(optional as it was already checked)
   Calculate total from calculated values if original was NULL */
dedup AS (
SELECT *,
COALESCE(total_original, quantity * price) as total,
ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY trn_date DESC) AS rn  
FROM cleaning
),

/* DATA QUALITY FLAGS
   Track missing values from the initial dataset
   Track values that remain NULL after calculations
   Track values that were successfully calculated for audit */


flagging AS (
SELECT 
    transaction_id,
    item,
    quantity,
    price,
    total,
    payment_method,
    location,
    trn_date,
    
    CASE WHEN item IS NULL THEN 1 ELSE 0 END AS item_missing,
    CASE WHEN quantity_original IS NULL THEN 1 ELSE 0 END AS quantity_missing,
    CASE WHEN price_original IS NULL THEN 1 ELSE 0 END AS price_missing,
    CASE WHEN total_original IS NULL THEN 1 ELSE 0 END AS total_missing,
    CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END AS payment_missing,
    CASE WHEN location IS NULL THEN 1 ELSE 0 END AS location_missing,
    CASE WHEN trn_date IS NULL THEN 1 ELSE 0 END AS date_missing,
    
    CASE WHEN quantity IS NULL THEN 1 ELSE 0 END AS quantity_still_null,
    CASE WHEN price IS NULL THEN 1 ELSE 0 END AS price_still_null,
    CASE WHEN total IS NULL THEN 1 ELSE 0 END AS total_still_null,
    
    CASE WHEN quantity_original IS NULL AND quantity IS NOT NULL THEN 1 ELSE 0 END AS quantity_calculated,
    CASE WHEN price_original IS NULL AND price IS NOT NULL THEN 1 ELSE 0 END AS price_calculated,
    CASE WHEN total_original IS NULL AND total IS NOT NULL THEN 1 ELSE 0 END AS total_calculated
    
  FROM dedup
  WHERE rn = 1
),

final AS (
  SELECT 
    transaction_id,
    item,
    quantity,
    price,
    total,
    payment_method,
    location,
    trn_date,
    quantity_calculated,
    price_calculated,
    total_calculated,
    
    (quantity_missing + price_missing + total_missing + item_missing + payment_missing + location_missing + date_missing) AS missing_count,
    
    (quantity_calculated + price_calculated + total_calculated) AS calculated_count,
    
    (item_missing + quantity_still_null + price_still_null + total_still_null + date_missing) AS critical_errors,
    
    item_missing,
    quantity_missing,
    price_missing,
    total_missing,
    payment_missing,
    location_missing,
    date_missing,
    quantity_still_null,
    price_still_null,
    total_still_null
    
  FROM flagging
)

-- Insert records that failed validation

INSERT INTO rejected_transactions (
  transaction_id,
   item, 
   quantity, 
   unit_price, 
   total,
  payment_method, 
  location, 
  trn_date,
  critical_errors, 
  missing_count, 
  calculated_count,
  item_missing, 
  quantity_still_null, 
  price_still_null, 
  total_still_null, 
  date_missing
)
SELECT 
  transaction_id, 
  item, 
  quantity,
  price, 
  total,
  payment_method, 
  location,
  trn_date,
  critical_errors, 
  missing_count, 
  calculated_count,
  item_missing, 
  quantity_still_null, 
  price_still_null,
  total_still_null, 
  date_missing
FROM final
WHERE critical_errors > 0;


-- Insert clean records

INSERT INTO transactions (
  transaction_id, 
  item, 
  quantity, 
  unit_price, 
  total,
  payment_method, 
  location, 
  trn_date,
  quantity_calculated, 
  price_calculated, 
  total_calculated
)
SELECT 
  transaction_id, 
  item, 
  quantity, 
  price, 
  total,
  payment_method, 
  location, 
  trn_date,
  quantity_calculated, 
  price_calculated, 
  total_calculated
FROM final
WHERE critical_errors = 0;
