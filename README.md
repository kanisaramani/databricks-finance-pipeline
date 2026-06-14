# databricks-finance-pipeline
End-to-end financial reporting pipeline built on Databricks, medallion architecture (Bronze → Silver → Gold), PySpark transformations, Delta Lake, and a Power BI dashboard connected to 6.3M transaction records

# Finance Transaction Analytics, Databricks Lakehouse Pipeline

An end-to-end financial reporting pipeline built on Databricks, processing 6.3 million 
transaction records through a medallion architecture (Bronze → Silver → Gold) and serving 
Clean, reporting-ready data to a Power BI dashboard.

---

## The Problem

Finance teams receive raw transaction dumps daily. The data lands unvalidated, 
inconsistently typed, and unusable for reporting. Analysts spend hours manually 
cleaning CSVs in Excel before any insight can be produced.

This pipeline eliminates that. Raw payment data is ingested, validated, 
modelled as a general ledger, and surfaced through an interactive dashboard, 
automatically, end to end.

---

## Architecture

### Bronze — Raw Ingestion
- 6.3M rows ingested from the PaySim synthetic payment dataset
- Written to a Delta Lake table with schema enforcement
- No transformations — data lands exactly as received

### Silver — Transformation & Validation
- Columns renamed to business-friendly names (general ledger structure)
- Types enforced, derived columns calculated (balance_movement, month_period)
- Six data quality checks run before any data is written
- Delta MERGE-ready schema with overwriteSchema support

### Gold — Reporting Layer
Three purpose-built tables for finance reporting:

| Table | Purpose |
|---|---|
| gold_monthly_cashflow | Total inflow, outflow, net cash flow by month |
| gold_transaction_pnl | Volume, average size, and net balance impact by transaction type |
| gold_account_exposure | Top 1000 accounts ranked by total amount sent |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Databricks (Serverless) | Compute and notebook environment |
| Apache Spark / PySpark | Data processing at scale |
| Delta Lake | ACID-compliant storage layer |
| Spark SQL | Gold layer aggregations |
| Unity Catalogue | Data governance and volume storage |
| Databricks Workflows | Orchestration with dependency chaining |
| Power BI | Interactive reporting dashboard |

---

## Pipeline Orchestration

The three notebooks are chained in a Databricks Workflow with explicit dependencies:

Silver only runs if Bronze succeeds. Gold only runs if Silver succeeds. 
If any stage fails, downstream tasks are blocked automatically.

---

## Power BI Dashboard

### Visuals
- KPI cards — Net Cash Flow, Total Inflow, Total Outflow
- Doughnut chart — Transaction volume breakdown by type
- Bar chart — Total monetary volume by transaction type
- Cash Flow Ratio by month — inflow to outflow ratio trend
- Top Account Exposure table — ranked by total amount sent

### Key Findings
- Outflows exceed inflows by 129.97bn, net cash flow negative across the full period
- TRANSFER transactions carry the highest average value at 910k per transaction
- CASH_OUT has the highest transaction count but lower average value than TRANSFER
- PAYMENT is the highest frequency, with the lowest average value at 13k per transaction
- A small number of accounts account for disproportionate total volume

### Interactivity
- Transaction type slicer filters all visuals simultaneously
- Month period slicer allows time-based filtering
- Cross-filtering enabled; clicking any chart segment filters the full dashboard

---

## Dataset

PaySim Synthetic Financial Dataset — available on Kaggle.
6,362,620 rows, 11 columns simulating a mobile payment system.
Used as a corporate transaction ledger, not for fraud detection.

---

## Project Structure

databricks-finance-pipeline/

│

├── notebooks/

│   ├── 01_bronze_ingestion.py

│   ├── 02_silver_transformation.py

│   └── 03_gold_reporting.sql

│

├── docs/

│   ├── workflow_graph.png

│   └── dashboard_screenshot.png

│

└── README.md
