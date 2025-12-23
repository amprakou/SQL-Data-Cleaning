# SQL-Data-Cleaning
ETL data cleaning pipeline for cafe sales transactions using SQL Server.


## Project Goals
Transform 10,000 raw cafe transaction records into production-ready data through:
- Type conversion and validation
- Comprehensive data quality tracking
- Separation of clean vs rejected records

## Dataset
**Source**: [Cafe Sales Dirty Data - Kaggle](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training)

##  Results at a Glance
| Metric | Value |
|--------|-------|
| Raw Records Processed | 10,000 |
| Clean Records | 8,564 (85.64%) |
| Rejected Records | 1,436 (14.36%) |
| Values Successfully Calculated | 1,182 |


##  Data Quality Issues Found
- 969 records missing item
- 460 records missing dates
- 533 records missing price
- 479 records missing quantity
- 3969 records missing location
- 3178 records missing payment method
- Inconsistent formatting (mixed case, error codes)
- Multiple date formats requiring normalization

##  Technical Approach
**Architecture**: Raw CSV → Staging Table → Cleaning Pipeline (CTEs) → Production Tables

**Key Techniques**:
- Staging table with NVARCHAR columns to preserve all raw values
- Multi-step CTE pipeline for transformation and validation
- Calculations using fixed item prices (`total = quantity × price`)
- Audit flags
- Two-table output: `transactions` (clean) + `rejected_transactions` (errors)

**See detailed implementation and comments in SQL files.**

##  Technologies
- **Database**: Microsoft SQL Server
- **IDE**: Visual Studio Code with SQL Server extension
