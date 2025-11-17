# Snowflake dbt Iceberg Table

This repository demonstrates how to use dbt with Snowflake to create and manage Iceberg tables.

## Overview

This project showcases:
- Setting up dbt with Snowflake connector
- Creating Iceberg tables using dbt models
- Using Python environment management with `uv`
- Sample transformation models with Iceberg table materialization

## Prerequisites

- Python 3.9-3.12
- [uv](https://docs.astral.sh/uv/) for Python environment management
- Snowflake account with Iceberg table support enabled
- External volume configured in Snowflake for Iceberg storage

## Setup

1. Clone this repository:
```bash
git clone https://github.com/RyutoYoda/dbt-snowflake-iceberg-table.git
cd dbt-snowflake-iceberg-table
```

2. Install dependencies using uv:
```bash
uv sync
```

3. Configure your Snowflake connection in `profiles.yml`:
```yaml
snowflake_iceberg:
  target: default
  outputs:
    default:
      type: snowflake
      account: 'YOUR_ACCOUNT'
      user: 'YOUR_USERNAME'
      role: TRANSFORMER
      warehouse: COMPUTE_WH
      database: SAMPLE_DATABASE
      schema: ANALYTICS
      authenticator: 'externalbrowser'  # or use password authentication
```

4. Test your connection:
```bash
uv run dbt debug --profiles-dir .
```

## Project Structure

```
.
├── profiles.yml                    # Snowflake connection configuration
├── pyproject.toml                  # Python dependencies
├── snowflake_iceberg/
│   ├── dbt_project.yml            # dbt project configuration
│   ├── models/
│   │   ├── sales_summary_iceberg.sql  # Sample Iceberg table model
│   │   └── sources.yml                # Source definitions
│   └── seeds/
│       └── raw_sales_data.csv         # Sample seed data
```

## Using Iceberg Tables

The project includes a sample model that creates an Iceberg table:

```sql
{{
  config(
    materialized='table',
    catalog_name='catalog_horizon'
  )
}}

select 
  category,
  date(transaction_date) as sales_date,
  count(distinct customer_id) as unique_customers,
  count(*) as transaction_count,
  sum(total_amount) as total_sales,
  avg(total_amount) as avg_sales
from {{ source('raw_data', 'sales_transactions') }}
where transaction_date is not null
group by category, date(transaction_date)
```

### Key Configuration for Iceberg Tables

- `materialized='table'`: Creates a managed Iceberg table
- `catalog_name`: Specifies the Snowflake catalog for Iceberg tables
- External volume must be configured in your Snowflake account

### Catalog Configuration

Add the following configuration to your `dbt_project.yml` if you need to specify catalog settings:

```yaml
catalogs:
  - name: catalog_horizon
    active_write_integration: snowflake_write_integration
    write_integrations:
      - name: snowflake_write_integration
        external_volume: dbt_external_volume
        table_format: iceberg
        catalog_type: built_in
        adapter_properties:
          change_tracking: true
```

This configuration:
- Defines a catalog named `catalog_horizon` for Iceberg tables
- Specifies the external volume where Iceberg metadata and data files will be stored
- Enables change tracking for the tables
- Uses Snowflake's built-in catalog type

## Running the Project

1. Run all models:
```bash
cd snowflake_iceberg
uv run dbt run --profiles-dir ..
```

2. Run specific models:
```bash
uv run dbt run --select sales_summary_iceberg --profiles-dir ..
```

3. Load seed data (optional):
```bash
uv run dbt seed --profiles-dir ..
```

## Requirements

See `pyproject.toml` for Python dependencies:
- dbt-core >= 1.8.0
- dbt-snowflake >= 1.8.0

## Notes

- Iceberg table support requires dbt-snowflake 1.8.0 or later
- Ensure your Snowflake account has the necessary privileges for creating Iceberg tables
- The external volume specified in the model configuration must exist in your Snowflake account