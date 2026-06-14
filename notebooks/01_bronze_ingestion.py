# Databricks notebook source
spark.sql("CREATE DATABASE IF NOT EXISTS finance_lakehouse")
spark.sql("USE finance_lakehouse")
print("Database ready")

# COMMAND ----------

raw_df = spark.read.format("csv") \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .load("/Volumes/workspace/default/finance_raw/PS_20174392719_1491204439457_log.csv")

print(f"Row count: {raw_df.count()}")
print(f"Columns: {raw_df.columns}")

# COMMAND ----------

raw_df.write \
    .format("delta") \
    .mode("overwrite") \
    .saveAsTable("finance_lakehouse.bronze_transactions")

print("Bronze table written successfully")

# COMMAND ----------

spark.sql("SELECT type, COUNT(*) as transaction_count, ROUND(SUM(amount), 2) as total_amount FROM finance_lakehouse.bronze_transactions GROUP BY type ORDER BY total_amount DESC").show()
