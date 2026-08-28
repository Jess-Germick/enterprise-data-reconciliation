# Data Dictionary

## Overview

This document defines the data model for the Enterprise Data Reconciliation project.

The project simulates a financial ERP environment and a downstream reporting process using entirely synthetic data. The schema supports budget, actual expenditure, and encumbrance reporting while providing realistic conditions for investigating reconciliation discrepancies.

The initial model contains six core tables:

- `departments`
- `accounts`
- `fiscal_periods`
- `budgets`
- `transactions`
- `encumbrances`

---

## Table: departments

Stores organizational departments used to categorize financial activity.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| department_id | INT | PK | No | Unique identifier for the department |
| department_code | VARCHAR(10) |  | No | Short organizational code |
| department_name | VARCHAR(100) |  | No | Full department name |
| division | VARCHAR(100) |  | Yes | Higher-level organizational division |
| active_flag | CHAR(1) |  | No | Indicates whether the department is active (`Y` or `N`) |

### Example

| department_id | department_code | department_name | division | active_flag |
|---:|---|---|---|---|
| 101 | FIN | Finance | Administration | Y |
| 102 | OPS | Operations | Public Services | Y |
| 103 | IT | Information Technology | Administration | Y |

---

## Table: accounts

Stores the chart of accounts used to classify financial activity.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| account_id | INT | PK | No | Unique identifier for the account |
| account_number | VARCHAR(20) |  | No | Financial account number |
| account_name | VARCHAR(100) |  | No | Descriptive account name |
| account_type | VARCHAR(50) |  | No | Classification such as Salary, Services, Supplies, or Equipment |
| active_flag | CHAR(1) |  | No | Indicates whether the account is active (`Y` or `N`) |



## Table: fiscal_periods

Defines accounting periods used to determine when financial activity is recognized.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| period_id | INT | PK | No | Unique identifier for the fiscal period |
| fiscal_year | INT |  | No | Fiscal year |
| period_number | INT |  | No | Sequential accounting period number |
| period_name | VARCHAR(50) |  | No | Descriptive period name |
| period_start | DATE |  | No | First date included in the period |
| period_end | DATE |  | No | Last date included in the period |
| closed_flag | CHAR(1) |  | No | Indicates whether the accounting period is closed (`Y` or `N`) |

---

## Table: budgets

Stores approved budget amounts by fiscal year, department, and account.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| budget_id | INT | PK | No | Unique identifier for the budget record |
| fiscal_year | INT |  | No | Fiscal year associated with the budget |
| department_id | INT | FK | No | Department receiving the budget |
| account_id | INT | FK | No | Account receiving the budget |
| original_budget | DECIMAL(12,2) |  | No | Original approved budget amount |
| revised_budget | DECIMAL(12,2) |  | No | Current budget after amendments or transfers |

### Foreign Keys

- `department_id` → `departments.department_id`
- `account_id` → `accounts.account_id`

### Business Rule

Available budget is calculated as:

`Revised Budget - Actual Expenditures - Outstanding Encumbrances`

---

## Table: transactions

Stores individual financial transactions representing actual expenditures and adjustments.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| transaction_id | INT | PK | No | Unique identifier for the transaction |
| document_number | VARCHAR(30) |  | No | Source document or transaction reference number |
| account_id | INT | FK | No | Account charged by the transaction |
| department_id | INT | FK | No | Department responsible for the transaction |
| transaction_date | DATE |  | No | Date the underlying business transaction occurred |
| posting_date | DATE |  | No | Date the transaction was posted to the accounting system |
| period_id | INT | FK | No | Fiscal period in which the transaction was posted |
| amount | DECIMAL(12,2) |  | No | Monetary amount of the transaction |
| transaction_type | VARCHAR(30) |  | No | Type of transaction |
| status | VARCHAR(20) |  | No | Current transaction status |
| source_system | VARCHAR(50) |  | No | System from which the record originated |

### Foreign Keys

- `account_id` → `accounts.account_id`
- `department_id` → `departments.department_id`
- `period_id` → `fiscal_periods.period_id`

### Transaction Types

Initial synthetic data may include:

- `INVOICE`
- `JOURNAL`
- `PAYROLL`
- `ADJUSTMENT`
- `CREDIT`

### Transaction Statuses

Initial synthetic data may include:

- `POSTED`
- `PENDING`
- `VOID`
- `REVERSED`

Only transactions that meet defined reporting rules should be included in financial control totals.

---

## Table: encumbrances

Stores outstanding financial commitments such as purchase orders.

| Column | Data Type | Key | Nullable | Description |
|---|---|---|---|---|
| encumbrance_id | INT | PK | No | Unique identifier for the encumbrance |
| po_number | VARCHAR(30) |  | No | Purchase order or commitment reference |
| account_id | INT | FK | No | Account associated with the commitment |
| department_id | INT | FK | No | Department responsible for the commitment |
| fiscal_year | INT |  | No | Fiscal year associated with the encumbrance |
| original_amount | DECIMAL(12,2) |  | No | Original committed amount |
| liquidated_amount | DECIMAL(12,2) |  | No | Amount released or converted to actual expense |
| remaining_amount | DECIMAL(12,2) |  | No | Outstanding commitment balance |
| status | VARCHAR(20) |  | No | Current status of the encumbrance |
| created_date | DATE |  | No | Date the commitment was created |
| closed_date | DATE |  | Yes | Date the commitment was fully closed |

### Foreign Keys

- `account_id` → `accounts.account_id`
- `department_id` → `departments.department_id`

### Business Rule

Remaining encumbrance is calculated as:

`Original Amount - Liquidated Amount`

---

# Relationships

The primary relationships in the data model are:

- One department can have many budget records.
- One department can have many transactions.
- One department can have many encumbrances.
- One account can be used by many departments through financial activity.
- One account can have many budget records.
- One account can have many transactions.
- One account can have many encumbrances.
- One fiscal period can contain many transactions.
- A department and account are associated through budget, transaction, and encumbrance records rather than through a direct department-to-account relationship.

---

# Reconciliation Considerations

The synthetic data will intentionally include conditions that can cause discrepancies between ERP control totals and downstream reporting results.

These conditions may include:

1. Duplicate transaction records.
2. Incorrect transaction-status filtering.
3. Differences between transaction dates and posting dates.
4. Incorrect encumbrance liquidation calculations.
5. Account-mapping discrepancies.

These scenarios will be used to demonstrate SQL-based reconciliation, exception detection, root-cause analysis, corrective reporting logic, and later Python automation.

---

# Data Privacy

All records used in this project are fictional and synthetically generated.

No employer, customer, confidential, personally identifiable, or production data is included in this repository.
