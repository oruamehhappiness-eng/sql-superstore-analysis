
Data Catalog for Gold Layer
------------------------------------------------------------

Overview
------------------------------------------------------------
The Gold Layer is the business-level representation of the Superstore data, structured to support analytical and reporting use cases. It consists of dimension tables and a fact table containing key business metrics related to sales, customers, products, returns, and regional performance.

------------------

**1. gold.dim_customers**
- **Purpose:** Stores unique customer information to provide descriptive attributes for customer-level analysis and to support joins with the fact_sales table.
- **Columns:**

  |Column Name | Data Type | Description |
  |---|---|---|
  | Customer Key | INT | Surrogate key uniquely identifying each customer record in the dimension table. |
  | Customer ID | NVARCHAR(50) | Unique numerical identifier assigned to each customer. |
  | Customer Name | NVARCHAR(50) | The customer's name, as recorded in the system |
  | Segment | NVARCHAR(50) | Customer segment used to classify customers based on purchasing behavior (Consumer, Corporate, or Home Office).|
----------------------

**2. gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

 |Column Name | Data Type | Description |
 |---|---|---|
 | product_key	| INT	| Surrogate key uniquely identifying each product record in the product dimension table. |
 | product_id	| INT |	A unique identifier assigned to the product for internal tracking and referencing. |
 | product_name |	NVARCHAR(50) | Descriptive name of the product. |
 | category	| NVARCHAR(50) | The broader classification of the product (e.g., Furniture, Office, Technology) to group related items. |
 | subcategory | NVARCHAR(50) |	A more detailed classification of the product within each category. |

 -------

 **3. gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes..
- **Columns:**

 |Column Name | Data Type | Description |
 |---|---|---|
 | Row ID | INT | Unique identifier assigned to each sales transaction record. |
 | Order ID | NVARCHAR(50) | Unique identifier assigned to each customer order. |
 | Customer Key | INT | Foreign key linking the sales record to the corresponding customer in dim_customers. |
 | Product Key | INT | Foreign key linking the sales record to the corresponding product in dim_products. |
 | Order Date | DATE | Date when the order was placed. |
 | Ship Date |	DATE |	Date when the order was shipped. |
 | Ship Mode |	NVARCHAR(50) |	Shipping method selected for the order. |
 | Country | NVARCHAR(50) | Country where the sales transaction occurred. |
 | State | NVARCHAR(50) | State where the sales transaction occurred. |
 | City | NVARCHAR(50) | City where the sales transaction occurred. |
 | Region |	NVARCHAR(50) |	Geographic region associated with the order. |
 | Sales |	DECIMAL |	Revenue generated from the sales transaction. |
 | Quantity |	DECIMAL |	Number of units purchased in the sales transaction. |
 | Discount |	FLOAT	| Discount applied to the sales transaction. |
 | Profit	| DECIMAL |	Profit generated from the sales transaction. |
 |Regional Manager|	NVARCHAR(50)	| Manager responsible for the corresponding sales region. |
 |Return Status	| VARCHAR(12)	| Indicates whether the order was returned. |


