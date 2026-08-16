
NAMING CONVENTIONS
------
This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the data warehouse.

------

Table of Contents
-------

1. [General Principles](#general-principles)
2. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Rules](#bronze-rules)
   - [Silver Rules](#silver-rules)
   - [Gold Rules](#gold-rules)
3. [Column Naming Conventions](#column-naming-conventions)
   - [Surrogate Keys](#surrogate_keys)
   - [Technical Columns](#technical_columns)
4. [Stored Procedure](#stored_procedure)
---

General Principles
----

- **Naming Conventions:** Use clear and descriptive names for database objects and columns. Table and view names use lowercase letters with underscores, while column names use Title Case with spaces between words.
  - For example:
    - Tables: bronze.ms_orderss, silver.ms_orderss
    - Views: gold.dim_customers, gold.dim_products, gold.fact_sales
    - Columns: Customer Key, Product Key, Order Date, Customer Name, Ship Mode

- **Consistency:** Apply naming conventions consistently across the data warehouse.

- **Clarity:** Use descriptive names that clearly communicate the purpose and business meaning of each object.

- **Source Preservation:** Retain original source column names where appropriate, particularly in the Bronze layer.

- **Language:** Use English for all names.

--------------------
Table Naming Conventions
--------

**Bronze Rules**

- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**
   - `<sourcesystem>:` Name of the source system (e.g., superstore).
   - `<entity>:` Exact table name from the source system (e.g., ms_orderss).
   - Example: `superstore_ms_orderss` → Orders information from the superstore system.

**Silver Rules**

- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**
   - `<sourcesystem>:` Name of the source system (e.g., superstore).
   - `<entity>:` Exact table name from the source system (e.g., ms_orderss).
   - Example: `superstore_ms_orderss` → Orders information from the superstore system.

**Gold Rules**

- All names must use meaningful, business-aligned names for tables, starting with the category prefix.
- **`<category>_<entity>`**
   - `<category>:` Describes the role of the table, such as dim (dimension) or fact (fact table).
   - `<entity>:` Descriptive name of the table, aligned with the business domain (e.g., customers, products, sales).
   - Examples:
      - `dim_customers` → Dimension table for customer data.
      - `fact_sales` → Fact table containing sales transactions.

**Glossary of Category Patterns**

| Pattern | Meaning | Example(s) |
|---|---|---|
| dim_ |	Dimension table |	dim_customer, dim_product |
| fact_	| Fact table |	fact_sales |
| report_	| Report table	| report_customers, report_sales_monthly |


Column Naming Conventions
------

**Surrogate Keys**

- Surrogate keys in dimension tables use the suffix `Key`.
- `<table_name> Key`
   - `<table_name>:` Refers to the entity the key belongs to.
   - `Key:` Indicates that the column is a surrogate key.
   - Example: `Customer Key` → Surrogate key in the `dim_customers` table.
   - Example: `Product Key` → Surrogate key in the `dim_products` table.

**Technical Columns**
- No additional technical columns are currently implemented in the Gold layer.


Stored Procedure
  -----------
- Stored procedures used for data loading follow the naming pattern load_<layer>.

  - `<layer>`: Represents the warehouse layer being loaded.
  - Example:
      - `load_bronze` → Loads data into the Bronze layer.
      - `load_silver` → Loads data into the Silver layer.
     
