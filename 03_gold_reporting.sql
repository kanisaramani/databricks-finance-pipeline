# Databricks notebook source
# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE finance_lakehouse.gold_monthly_cashflow AS
# MAGIC SELECT
# MAGIC     month_period,
# MAGIC     SUM(CASE WHEN type IN ('CASH_IN', 'PAYMENT') THEN amount ELSE 0 END) AS total_inflow,
# MAGIC     SUM(CASE WHEN type IN ('CASH_OUT', 'DEBIT') THEN amount ELSE 0 END) AS total_outflow,
# MAGIC     SUM(CASE WHEN type IN ('CASH_IN', 'PAYMENT') THEN amount ELSE 0 END) -
# MAGIC     SUM(CASE WHEN type IN ('CASH_OUT', 'DEBIT') THEN amount ELSE 0 END) AS net_cashflow,
# MAGIC     COUNT(*) AS transaction_count
# MAGIC FROM finance_lakehouse.silver_transactions
# MAGIC GROUP BY month_period
# MAGIC ORDER BY month_period;
# MAGIC
# MAGIC SELECT * FROM finance_lakehouse.gold_monthly_cashflow;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE finance_lakehouse.gold_transaction_pnl AS
# MAGIC SELECT
# MAGIC     type,
# MAGIC     month_period,
# MAGIC     COUNT(*) AS transaction_count,
# MAGIC     ROUND(SUM(amount), 2) AS total_volume,
# MAGIC     ROUND(AVG(amount), 2) AS avg_transaction_size,
# MAGIC     ROUND(MIN(amount), 2) AS min_amount,
# MAGIC     ROUND(MAX(amount), 2) AS max_amount,
# MAGIC     ROUND(SUM(balance_movement), 2) AS net_balance_impact
# MAGIC FROM finance_lakehouse.silver_transactions
# MAGIC GROUP BY type, month_period
# MAGIC ORDER BY month_period, total_volume DESC;
# MAGIC
# MAGIC SELECT * FROM finance_lakehouse.gold_transaction_pnl;

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE OR REPLACE TABLE finance_lakehouse.gold_account_exposure AS
# MAGIC SELECT
# MAGIC     sender_account,
# MAGIC     COUNT(*) AS total_transactions,
# MAGIC     ROUND(SUM(amount), 2) AS total_amount_sent,
# MAGIC     ROUND(AVG(amount), 2) AS avg_amount_sent,
# MAGIC     ROUND(MAX(amount), 2) AS max_single_transaction,
# MAGIC     COUNT(DISTINCT type) AS transaction_types_used,
# MAGIC     MIN(step_period) AS first_active_step,
# MAGIC     MAX(step_period) AS last_active_step,
# MAGIC     MAX(step_period) - MIN(step_period) AS active_period_steps
# MAGIC FROM finance_lakehouse.silver_transactions
# MAGIC GROUP BY sender_account
# MAGIC HAVING total_transactions > 1
# MAGIC ORDER BY total_amount_sent DESC
# MAGIC LIMIT 1000;
# MAGIC
# MAGIC SELECT * FROM finance_lakehouse.gold_account_exposure;
