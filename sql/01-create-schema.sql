/*
    Project: Enterprise Data Reconciliation
    File: 01-create-schema.sql

    Purpose:
    Creates the relational database schema used to simulate an
    enterprise financial ERP environment for reconciliation analysis.

    All project data is synthetic.
*/

------------------------------------------------------------
-- CLEANUP
-- Drop tables in reverse dependency order so the script
-- can be executed repeatedly during development.
------------------------------------------------------------

DROP TABLE IF EXISTS dbo.encumbrances;
DROP TABLE IF EXISTS dbo.transactions;
DROP TABLE IF EXISTS dbo.budgets;
DROP TABLE IF EXISTS dbo.fiscal_periods;
DROP TABLE IF EXISTS dbo.accounts;
DROP TABLE IF EXISTS dbo.departments;


------------------------------------------------------------
-- DEPARTMENTS
------------------------------------------------------------

CREATE TABLE dbo.departments
(
    department_id      INT           NOT NULL,
    department_code    VARCHAR(10)   NOT NULL,
    department_name    VARCHAR(100)  NOT NULL,
    division           VARCHAR(100)  NULL,
    active_flag        CHAR(1)       NOT NULL,

    CONSTRAINT PK_departments
        PRIMARY KEY (department_id),

    CONSTRAINT UQ_departments_code
        UNIQUE (department_code),

    CONSTRAINT CK_departments_active_flag
        CHECK (active_flag IN ('Y', 'N'))
);


------------------------------------------------------------
-- ACCOUNTS
------------------------------------------------------------

CREATE TABLE dbo.accounts
(
    account_id         INT           NOT NULL,
    account_number     VARCHAR(20)   NOT NULL,
    account_name       VARCHAR(100)  NOT NULL,
    account_type       VARCHAR(50)   NOT NULL,
    active_flag        CHAR(1)       NOT NULL,

    CONSTRAINT PK_accounts
        PRIMARY KEY (account_id),

    CONSTRAINT UQ_accounts_number
        UNIQUE (account_number),

    CONSTRAINT CK_accounts_active_flag
        CHECK (active_flag IN ('Y', 'N'))
);


------------------------------------------------------------
-- FISCAL PERIODS
------------------------------------------------------------

CREATE TABLE dbo.fiscal_periods
(
    period_id          INT          NOT NULL,
    fiscal_year        INT          NOT NULL,
    period_number      INT          NOT NULL,
    period_name        VARCHAR(50)  NOT NULL,
    period_start       DATE         NOT NULL,
    period_end         DATE         NOT NULL,
    closed_flag        CHAR(1)      NOT NULL,

    CONSTRAINT PK_fiscal_periods
        PRIMARY KEY (period_id),

    CONSTRAINT UQ_fiscal_period
        UNIQUE (fiscal_year, period_number),

    CONSTRAINT CK_fiscal_period_number
        CHECK (period_number BETWEEN 1 AND 12),

    CONSTRAINT CK_fiscal_period_dates
        CHECK (period_end >= period_start),

    CONSTRAINT CK_fiscal_period_closed_flag
        CHECK (closed_flag IN ('Y', 'N'))
);


------------------------------------------------------------
-- BUDGETS
------------------------------------------------------------

CREATE TABLE dbo.budgets
(
    budget_id          INT            NOT NULL,
    fiscal_year        INT            NOT NULL,
    department_id      INT            NOT NULL,
    account_id         INT            NOT NULL,
    original_budget    DECIMAL(12,2)  NOT NULL,
    revised_budget     DECIMAL(12,2)  NOT NULL,

    CONSTRAINT PK_budgets
        PRIMARY KEY (budget_id),

    CONSTRAINT FK_budgets_department
        FOREIGN KEY (department_id)
        REFERENCES dbo.departments(department_id),

    CONSTRAINT FK_budgets_account
        FOREIGN KEY (account_id)
        REFERENCES dbo.accounts(account_id),

    CONSTRAINT UQ_budget_department_account
        UNIQUE (fiscal_year, department_id, account_id),

    CONSTRAINT CK_budgets_original
        CHECK (original_budget >= 0),

    CONSTRAINT CK_budgets_revised
        CHECK (revised_budget >= 0)
);


------------------------------------------------------------
-- TRANSACTIONS
------------------------------------------------------------

CREATE TABLE dbo.transactions
(
    transaction_id     INT            NOT NULL,
    document_number    VARCHAR(30)    NOT NULL,
    account_id         INT            NOT NULL,
    department_id      INT            NOT NULL,
    transaction_date   DATE           NOT NULL,
    posting_date       DATE           NOT NULL,
    period_id          INT            NOT NULL,
    amount             DECIMAL(12,2)  NOT NULL,
    transaction_type   VARCHAR(30)    NOT NULL,
    status             VARCHAR(20)    NOT NULL,
    source_system      VARCHAR(50)    NOT NULL,

    CONSTRAINT PK_transactions
        PRIMARY KEY (transaction_id),

    CONSTRAINT FK_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES dbo.accounts(account_id),

    CONSTRAINT FK_transactions_department
        FOREIGN KEY (department_id)
        REFERENCES dbo.departments(department_id),

    CONSTRAINT FK_transactions_period
        FOREIGN KEY (period_id)
        REFERENCES dbo.fiscal_periods(period_id),

    CONSTRAINT CK_transactions_type
        CHECK
        (
            transaction_type IN
            (
                'INVOICE',
                'JOURNAL',
                'PAYROLL',
                'ADJUSTMENT',
                'CREDIT'
            )
        ),

    CONSTRAINT CK_transactions_status
        CHECK
        (
            status IN
            (
                'POSTED',
                'PENDING',
                'VOID',
                'REVERSED'
            )
        )
);


------------------------------------------------------------
-- ENCUMBRANCES
------------------------------------------------------------

CREATE TABLE dbo.encumbrances
(
    encumbrance_id      INT            NOT NULL,
    po_number           VARCHAR(30)    NOT NULL,
    account_id          INT            NOT NULL,
    department_id       INT            NOT NULL,
    fiscal_year         INT            NOT NULL,
    original_amount     DECIMAL(12,2)  NOT NULL,
    liquidated_amount   DECIMAL(12,2)  NOT NULL,
    remaining_amount    DECIMAL(12,2)  NOT NULL,
    status              VARCHAR(20)    NOT NULL,
    created_date        DATE           NOT NULL,
    closed_date         DATE           NULL,

    CONSTRAINT PK_encumbrances
        PRIMARY KEY (encumbrance_id),

    CONSTRAINT FK_encumbrances_account
        FOREIGN KEY (account_id)
        REFERENCES dbo.accounts(account_id),

    CONSTRAINT FK_encumbrances_department
        FOREIGN KEY (department_id)
        REFERENCES dbo.departments(department_id),

    CONSTRAINT CK_encumbrances_original
        CHECK (original_amount >= 0),

    CONSTRAINT CK_encumbrances_liquidated
        CHECK (liquidated_amount >= 0),

    CONSTRAINT CK_encumbrances_remaining
        CHECK (remaining_amount >= 0),

    CONSTRAINT CK_encumbrances_liquidation
        CHECK (liquidated_amount <= original_amount),

    CONSTRAINT CK_encumbrances_balance
        CHECK (
            remaining_amount =
            original_amount - liquidated_amount
        ),

    CONSTRAINT CK_encumbrances_status
        CHECK
        (
            status IN
            (
                'OPEN',
                'PARTIALLY_LIQUIDATED',
                'CLOSED',
                'CANCELLED'
            )
        ),

    CONSTRAINT CK_encumbrances_closed_date
        CHECK
        (
            closed_date IS NULL
            OR closed_date >= created_date
        )
);


------------------------------------------------------------
-- INDEXES
-- Support common reconciliation and investigation queries.
------------------------------------------------------------

CREATE INDEX IX_transactions_department_account
    ON dbo.transactions (department_id, account_id);

CREATE INDEX IX_transactions_posting_date
    ON dbo.transactions (posting_date);

CREATE INDEX IX_transactions_document_number
    ON dbo.transactions (document_number);

CREATE INDEX IX_encumbrances_department_account
    ON dbo.encumbrances (department_id, account_id);

CREATE INDEX IX_encumbrances_po_number
    ON dbo.encumbrances (po_number);
