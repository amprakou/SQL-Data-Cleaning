# SQL-Data-Cleaning
ETL data cleaning pipeline for cafe sales transactions using SQL Server.


## Project Goals
Transform 10,000 raw cafe transaction records into production-ready data through:
- Type conversion and validation
- Comprehensive data quality tracking
- Separation of clean vs rejected records

## 📈 Results at a Glance
| Metric | Value |
|--------|-------|
| Raw Records Processed | 10,000 |
| Clean Records | 8,564 (85.64%) |
| Rejected Records | 1,436 (14.36%) |
| Values Successfully Calculated | 1,182 |


## 🔍 Data Quality Issues Found
- 969 records missing item (9.7%)
- 460 records missing dates (4.6%)
- 2,912 records with incomplete numeric data (29.1%)
- Inconsistent formatting (mixed case, error codes)
- Multiple date formats requiring normalization

## 🛠️ Technical Approach
**Architecture**: Raw CSV → Staging Table → Cleaning Pipeline (CTEs) → Production Tables

**Key Techniques**:
- Staging table with NVARCHAR columns to preserve all raw values
- Multi-step CTE pipeline for transformation and validation
- Calculations using fixed item prices (`total = quantity × price`)
- Comprehensive audit flags tracking data lineage
- Two-table output: `transactions` (clean) + `rejected_transactions` (errors)

**See detailed implementation and comments in SQL files.**

## 💻 Technologies
- **Database**: Microsoft SQL Server
- **IDE**: Visual Studio Code with SQL Server extension
