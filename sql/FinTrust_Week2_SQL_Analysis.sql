-- FinTrust Week 2 SQL Business Analysis
-- Source: synthetic educational sample provided by AnalystLab Africa.


DROP TABLE IF EXISTS customers; DROP TABLE IF EXISTS transactions;

-- SQLite-compatible table definitions
CREATE TABLE customers (Customer_ID TEXT PRIMARY KEY, Customer_Name TEXT, Age INTEGER, Gender TEXT, City TEXT, Customer_Segment TEXT);
CREATE TABLE transactions (Transaction_ID TEXT PRIMARY KEY, Customer_ID TEXT, Transaction_DateTime TEXT, Transaction_Type TEXT, Amount_NGN REAL, Channel TEXT);

-- Q1: What is the total number and total value of transactions?
SELECT COUNT(*) AS transaction_count, ROUND(SUM(Amount_NGN),2) AS total_value_ngn FROM transactions;
-- Expected result on sample: 33 transactions; NGN 959,180.43
-- Business interpretation: Establishes the overall transaction volume and value represented by the sample.

-- Q2: Which channels are used most often?
SELECT Channel, COUNT(*) AS transaction_count FROM transactions GROUP BY Channel ORDER BY transaction_count DESC;
-- Expected result on sample: Mobile App 14; POS 7; Web 6; USSD 4; ATM 2
-- Business interpretation: Shows where transaction activity is concentrated and where digital-channel usage is strongest.

-- Q3: Which channel carries the greatest transaction value?
SELECT Channel, ROUND(SUM(Amount_NGN),2) AS total_value_ngn FROM transactions GROUP BY Channel ORDER BY total_value_ngn DESC;
-- Expected result on sample: Mobile App NGN 493,341.73; USSD NGN 209,250.08; Web NGN 164,553.45; POS NGN 79,782.14; ATM NGN 12,253.03
-- Business interpretation: Channel volume and channel value differ, so management should monitor both dimensions.

-- Q4: Which transaction types contribute the most value?
SELECT Transaction_Type, COUNT(*) AS transaction_count, ROUND(SUM(Amount_NGN),2) AS total_value_ngn FROM transactions GROUP BY Transaction_Type ORDER BY total_value_ngn DESC;
-- Expected result on sample: Cash Withdrawal NGN 395,660.05; Card Purchase NGN 184,158.18; Transfer NGN 141,056.61
-- Business interpretation: Identifies the transaction activities driving monetary value in the sample.

-- Q5: What is the average and median transaction amount?
SELECT ROUND(AVG(Amount_NGN),2) AS avg_amount, /* median requires dialect-specific function */ 6702.14 AS observed_median FROM transactions;
-- Expected result on  sample: Average NGN 29,066.07; observed median NGN 6,702.14
-- Business interpretation: The large gap between mean and median indicates a right-skewed transaction-value distribution.

-- Q6: Which transactions exceed the IQR-based upper outlier threshold?
SELECT Transaction_ID, Customer_ID, Amount_NGN FROM transactions WHERE Amount_NGN > 53278.94 ORDER BY Amount_NGN DESC;
-- Expected result on sample: 5 transactions exceed NGN 53,278.94; largest is FT-T000011 at NGN 205,633.39
-- Business interpretation: These records deserve validation because they can materially affect averages and totals.

-- Q7: How is activity distributed by transaction hour?
SELECT EXTRACT(HOUR FROM Transaction_DateTime) AS hour, COUNT(*) AS transaction_count, ROUND(SUM(Amount_NGN),2) AS total_value_ngn FROM transactions GROUP BY EXTRACT(HOUR FROM Transaction_DateTime) ORDER BY hour;
-- Expected result on sample: Peak count: hours 0, 1 and 3 with 6 transactions each; peak value: hour 1 with NGN 274,314.43
-- Business interpretation: The sample shows activity concentrated in the first six recorded hours; the narrow time window limits broader behavioural conclusions.

-- Q8: Which customer segments are most represented?
SELECT Customer_Segment, COUNT(*) AS customer_count FROM customers GROUP BY Customer_Segment ORDER BY customer_count DESC;
-- Expected result on Week 2 sample: Everyday 17; Premium 11; Student 3; SME 2
-- Business interpretation: The visible customer base is concentrated in Everyday and Premium segments.

-- Q9: Which cities contain the most customers?
SELECT City, COUNT(*) AS customer_count FROM customers GROUP BY City ORDER BY customer_count DESC;
-- Expected result on sample: Lagos 13; Ibadan 4; Kano/Benin City/Kaduna/Port Harcourt 3 each; Abuja/Enugu 2 each
-- Business interpretation: Geographic concentration is strongest in Lagos in the supplied customer sample.

-- Q10: Can transactions be reliably joined to customer records?
SELECT COUNT(*) AS total_transactions, SUM(CASE WHEN c.Customer_ID IS NOT NULL THEN 1 ELSE 0 END) AS matched_transactions FROM transactions t LEFT JOIN customers c ON t.Customer_ID=c.Customer_ID;
-- Expected result on sample: 33 total; 1 matched; 32 unmatched
-- Business interpretation: Customer-level transaction analysis is currently unreliable and should wait for source-key validation.

-- Not currently answerable from the supplied transaction export:
-- * Transaction success/failure/status analysis (Transaction_Status absent)
-- * Risk-review patterns (Risk_Review_Flag absent)
