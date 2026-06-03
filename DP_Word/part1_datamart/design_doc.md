# Design Document

## Architecture Overview

The solution follows a layered data warehouse architecture:

```text
Source Files (CSV)
        ↓
Staging Layer
        ↓
Dimension Loads
        ↓
Fact Loads
        ↓
Power BI Semantic Model
```

A staging layer was implemented to isolate source data from the dimensional model and provide a location for validation, cleansing, and type standardization before loading the mart.

---

## Dimensional Model

The mart follows a star-schema design with shared dimensions.

### Dimensions

* dim_date
* dim_customer (SCD Type 2)
* dim_terminal (Type 1)
* dim_equipment (Type 1)
* dim_shift (Type 1)

### Facts

* fact_container_movement
* fact_vessel_call
* fact_gate_transaction

The design uses surrogate keys for all dimensions and foreign key references from facts.

---

## Fact Table Grain

### fact_container_movement

One row per container movement.

### fact_vessel_call

One row per vessel call.

### fact_gate_transaction

One row per gate transaction.

Defining the grain before development ensured consistent measure calculations and dimensional relationships.

---

## SCD Strategy

### dim_customer (Type 2)

Customer history is tracked using:

* Lookup Transformation
* Conditional Split
* OLE DB Command (expire current row)
* OLE DB Destination (insert new version)

Tracked Type 2 attributes:

* customer_tier
* credit_limit

Each change creates a new dimension version while preserving historical records through effective date ranges.

### Type 1 Dimensions

The following dimensions use overwrite-on-change behavior:

* dim_terminal
* dim_equipment
* dim_shift

Updates were implemented using:

```text
Lookup
    ↓
Conditional Split
    ↓
OLE DB Command
```

This approach was selected because the assessment dataset is relatively small.

For larger production workloads, changed rows would be staged and processed using set-based UPDATE or MERGE statements instead of row-by-row OLE DB Command updates.

---

## Date Dimension Design

The date dimension was generated to cover the full reporting period required by the assessment.

Attributes include:

* Calendar Year
* Quarter
* Month
* Month Name
* Day Name
* Fiscal Year
* Fiscal Quarter
* Fiscal Month

The fiscal calendar starts on 1 April as specified in the requirements.

The gate transaction fact contains two date foreign keys:

* GateInDateKey
* GateOutDateKey

This design supports active and inactive date relationships in Power BI using USERELATIONSHIP.

---

## Data Quality Handling

The following quality controls were implemented:

### Data Standardization

* Country codes converted to full country names.
* Date and datetime values standardized before loading.

### Referential Integrity

* Unknown dimension members assigned surrogate key = -1.
* Fact rows always maintain valid foreign key references.

### Lookup Validation

* Dimension lookups performed before fact loading.
* Missing dimension references redirected to unknown members.

---

## ETL Design Decisions

### Source Format Conversion

An Excel connectivity issue was encountered with SSIS 2019 due to provider compatibility limitations.

To ensure reliable package execution, source files were converted from XLSX to CSV and loaded through Flat File Connections in SSIS 2022.

This removed dependency on external Office drivers and simplified deployment.

### Manual SCD Implementation

The built-in SSIS SCD Wizard was intentionally avoided because:

* Limited scalability
* Row-by-row processing
* Difficult customization
* Reduced transparency during debugging

A manual implementation provides greater control and is closer to enterprise ETL practices.

---

## Performance Considerations

The assessment data volume is small; however, for production-scale implementations the following enhancements are recommended:

* Incremental loads using watermarks.
* Partitioning large fact tables.
* Set-based UPDATE/MERGE operations.
* Audit and reconciliation framework.
* Centralized error logging.
* Migration to Microsoft Fabric or Azure Synapse for larger workloads.

---

## Trade-offs

### OLE DB Command

Used for Type 1 updates because it simplifies implementation for small datasets.

Trade-off:

* Easy to understand and demonstrate.
* Not optimal for large-scale processing.

Production alternative:

* Stage changed rows.
* Apply set-based UPDATE or MERGE statements.

### Bounded Date Dimension

A bounded date dimension was generated for the reporting period.

Trade-off:

* Simpler implementation.
* Requires monitoring if future dates arrive outside the generated range.

Production alternative:

* Automatically extend the date dimension during scheduled loads.

---

## Power BI Model Design

The semantic model follows a star-schema approach.

Key design choices:

* Single-direction relationships.
* Shared date dimension.
* Active relationship for Gate-In Date.
* Inactive relationship for Gate-Out Date.
* USERELATIONSHIP used for Gate-Out calculations.

This approach avoids ambiguous filter propagation while supporting multiple business date perspectives.
