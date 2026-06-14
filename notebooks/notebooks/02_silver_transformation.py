# Databricks notebook source
bronze_df = spark.table("finance_lakehouse.bronze_transactions")
bronze_df.printSchema()

# COMMAND ----------

from pyspark.sql import functions as F

silver_df = bronze_df \
    .withColumn("step_period", F.col("step").cast("integer")) \
    .withColumn("month_period", (F.col("step") / 720).cast("integer") + 1) \
    .withColumnRenamed("nameOrig", "sender_account") \
    .withColumnRenamed("nameDest", "receiver_account") \
    .withColumnRenamed("oldbalanceOrg", "sender_opening_balance") \
    .withColumnRenamed("newbalanceOrig", "sender_closing_balance") \
    .withColumnRenamed("oldbalanceDest", "receiver_opening_balance") \
    .withColumnRenamed("newbalanceDest", "receiver_closing_balance") \
    .withColumn("balance_movement", 
        F.col("sender_closing_balance") - F.col("sender_opening_balance")) \
    .drop("isFraud", "isFlaggedFraud")

print(f"Row count: {silver_df.count()}")
silver_df.printSchema()

# COMMAND ----------

checks = {
    "null_amounts": silver_df.filter(F.col("amount").isNull()).count(),
    "negative_amounts": silver_df.filter(F.col("amount") < 0).count(),
    "null_sender": silver_df.filter(F.col("sender_account").isNull()).count(),
    "null_receiver": silver_df.filter(F.col("receiver_account").isNull()).count(),
    "null_step": silver_df.filter(F.col("step_period").isNull()).count(),
    "invalid_types": silver_df.filter(
        ~F.col("type").isin(["CASH_IN", "CASH_OUT", "TRANSFER", "PAYMENT", "DEBIT"])
    ).count()
}

For check, count in checks.items():
    status = "PASS" if count == 0 else "FAIL"
    print(f"{status} | {check}: {count}")

# COMMAND ----------

silver_df.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("finance_lakehouse.silver_transactions")

print("Silver table written successfully")
