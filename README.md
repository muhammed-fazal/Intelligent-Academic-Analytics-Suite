# Student Success & Early Intervention Analytics System 🎓🚀

An end-to-end data engineering and predictive analytics ecosystem designed to transition higher education from reactive reporting to proactive student support. To consolidate scattered student performance records into a unified Data Warehouse in SQL Server. Engineer an Interactive Power BI dashboards that visualize academic trends, identifying student performance and implement predictive analytics.

---

## 📌 Business Problem
Most universities rely on **Reactive Analytics**—they identify academic struggles only *after* a student has failed a semester. This "post-mortem" approach makes it impossible to provide timely support.

**The Challenges:**
* **Delayed Insights:** Failure is identified too late for intervention.
* **Data Fragmentation:** Attendance, internal marks, and demographics are siloed.
* **Predictive Gap:** No mechanism exists to forecast a student’s final graduation honors based on early performance.

## 💡 The Solution: Proactive Intervention
This project implements an **Early Warning System (EWS)** and **Predictive Modeling** to identify at-risk students in real-time.

**Key Innovations:**
* **Early Warning System:** Automatically flags students with <75% attendance or low internal marks mid-semester.
* **Predictive Analytics:** Uses a **Linear Regression** model to forecast Final Graduation CGPA ($R^2 = 0.76$).
* **Medallion Architecture:** A professional SQL-based data pipeline (Bronze -> Silver -> Gold).
* **Persona-Driven BI:** Tailored dashboards for the **Principal**, **HOD**, and **Faculty Mentor**.

---

## 🏗️ Architecture & Methodology
The project follows an industry-standard Data Engineering lifecycle:

1. **Ingestion (Bronze):** Raw CSV/Excel files (generated via Python Faker) land in SQL Server.
2. **Cleansing (Silver):** Data validation, type casting, and anomaly detection via T-SQL.
3. **Analytical Modeling (Gold):** A Star Schema optimized for BI, featuring the `Is_At_Risk_Flag` logic.
4. **Machine Learning:** A Python script connects to the Gold Layer, trains on historical graduate data, and predicts outcomes for active students.
5. **Visualization:** Interactive Power BI reports with **Drill-Through** capabilities and **Row-Level Security (RLS)**.

##📊 Dashboard Previews


---

## 🛠️ Technology Stack
* **Excel:** Initial data source and synthetic data generation.
* **SQL Server:** Data Warehousing and ETL using Medallion Architecture.
* **Python (Pandas, Scikit-Learn):** Data manipulation and Predictive Modeling (Linear Regression).
* **Power BI:** Business Intelligence, DAX measures, and interactive reporting.

---

## 📂 Project Structure
```text
├── Data_Generation/         # Python scripts to generate synthetic datasets
├── SQL_Scripts/             # T-SQL scripts for Bronze, Silver, and Gold layers
├── ML_Models/               # Python scripts for Linear Regression & Predictions
├── PowerBI_Reports/         # .pbix files for the 3-tier dashboard
├── Datasets/                # Sample CSV files (Fact_Performance, Dim_Student, etc.)
└── README.md                # Project documentation
