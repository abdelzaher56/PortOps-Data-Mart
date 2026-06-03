# PortOps Data Mart & Power BI Dashboard

## Project Overview

This project implements a dimensional data mart and Power BI dashboard for a container terminal operator as part of the Data & Analytics Engineer technical assessment.

---

## Assumptions

* Fiscal year starts on 1 April.
* `move_start_time` is used as the transaction date for `fact_container_movement`.
* Customer history provided in `CustomerHistory` is the authoritative source for SCD Type 2 tracking.
* Unknown dimension members are assigned a surrogate key of `-1`.
* All model relationships use single-direction filtering (1:*).
* SCD Type 2 was implemented manually using Lookup and Conditional Split transformations.

---

## Tools Used

* SQL Server 2022
* SSIS (Visual Studio 2022)
* Power BI Desktop

---

## Implementation Notes

During development, an Excel connectivity issue was encountered with SSIS 2019. To avoid dependency on Excel drivers and ensure a stable load process, source files were converted from XLSX to CSV and loaded through Flat File Connections in SSIS 2022.

For Type 1 dimensions, updates were implemented using Lookup + Conditional Split + OLE DB Command. This approach is suitable for the small assessment dataset. For larger production workloads, a staging table with set-based UPDATE or MERGE operations would be preferred for better scalability and performance.

---

## Folder Structure

```text
README.md

part1_datamart/
│
├── ssis/
│   ├── PortOps.sln
│   └── *.dtsx
│
├── sql/
│   ├── staging_ddl.sql
│   ├── mart_ddl.sql
│   └── dim_date_seed.sql
│
├── design_doc.md
│
└── screenshots/

part2_powerbi/
│
├── dashboard.pbix
│
├── dax_measures.md
│
└── screenshots/
    ├── model_view.png
    ├── executive_summary.png
    ├── vessel_operations.png
    ├── gate_operations.png
    └── ...
```




* `part1_datamart/sql/` → Database objects and DDL scripts
* `part1_datamart/ssis/` → SSIS solution and packages
* `part2_powerbi/` → Power BI dashboard and DAX measures

---

## Setup Instructions

1. Execute all SQL scripts in `part1_datamart/sql/`
2. Open the SSIS solution and update connection managers if required
3. Run `00_Master_Load.dtsx`
4. Open the Power BI file and refresh the dataset

---

# Written Questions Answers

## DATA WAREHOUSING

### Explain the practical difference between SCD Type 1 and Type 2. Using examples from this assessment, justify where you applied each.

SCD Type 1 overwrites existing values and keeps only the latest state. It was used for `dim_terminal`, `dim_equipment`, and `dim_shift`. SCD Type 2 preserves history by creating new records when tracked attributes change. It was used in `dim_customer` to track changes in customer tier and credit limit over time.

### Why should a fact table reference a dimension via surrogate key rather than natural key? Give at least two reasons specific to your dim_customer implementation.

`dim_customer` contains multiple records for the same customer due to SCD Type 2 history, so the natural key is not unique. Using surrogate keys ensures facts remain linked to the correct historical customer version and isolates the warehouse from source-system changes.

### Your dim_date is bounded. What happens if a fact arrives with a date outside that range, and how would you design the pipeline to handle it without failure?

The date lookup would fail because no matching date key exists. In production, unmatched records should be redirected to an exception flow while the date dimension is automatically extended or the records are temporarily assigned to an "Unknown Date" member.

---

## SSIS

### Why is the built-in SSIS SCD Wizard not suitable for a production Type 2 load at scale? Give specific technical reasons.

The SCD Wizard relies on row-by-row processing and OLE DB Command updates, which do not scale well. It is also difficult to customize and troubleshoot. Lookup transformations with set-based SQL operations provide better performance and maintainability.

### Describe how you would implement automated row-count reconciliation between source, staging, and target — including what should happen when counts disagree.

Row counts would be captured at each stage and stored in an audit table. After loading, counts are compared automatically. Any discrepancy would be logged, the load flagged as failed, and an alert generated for investigation.

### What is the role of a staging layer in a data warehouse load? What would go wrong if you loaded the Excel file directly into the final fact tables?

The staging layer provides validation, cleansing, type conversion, and auditing before loading the mart. Loading directly into facts increases the risk of bad data, failed loads, and makes troubleshooting significantly harder.

---

## POWER BI

### Why does Power BI allow only one active relationship between two tables? What ambiguity would multiple active relationships create?

A single active relationship ensures there is only one filter path between tables. Multiple active relationships could create ambiguous filter propagation and produce inconsistent aggregation results.

### Explain the difference between USERELATIONSHIP and CROSSFILTER. When is each the right choice?

`USERELATIONSHIP` temporarily activates an existing inactive relationship inside a measure. `CROSSFILTER` changes filter direction or disables filtering. In this solution, `USERELATIONSHIP` was used for Gate-Out calculations using the inactive date relationship.

### A business user reports that a KPI on the dashboard does not respect the date slicer. List the most likely causes in the order you would investigate them.

1. Incorrect or inactive relationship.
2. Measure ignores filter context (e.g., uses `ALL()`).
3. Date slicer connected to the wrong table.
4. Data type mismatch between fact and dimension keys.
5. Visual, page, or report-level filters overriding the slicer.
6. Missing dates in the date dimension.
