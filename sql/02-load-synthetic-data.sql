/*
    Project: Enterprise Data Reconciliation
    File: 02-load-synthetic-data.sql

    Purpose:
    Loads synthetic financial data used to simulate an
    enterprise ERP environment and support reconciliation analysis.

    The dataset includes normal financial activity as well as
    realistic edge cases that may affect downstream reporting.

    All project data is synthetic.
*/


------------------------------------------------------------
-- DEPARTMENTS
------------------------------------------------------------

INSERT INTO dbo.departments
(
    department_id,
    department_code,
    department_name,
    division,
    active_flag
)
VALUES
    (101, 'FIN', 'Finance',                'Administration', 'Y'),
    (102, 'OPS', 'Operations',             'Public Services', 'Y'),
    (103, 'IT',  'Information Technology','Administration', 'Y');


------------------------------------------------------------
-- ACCOUNTS
------------------------------------------------------------

INSERT INTO dbo.accounts
(
    account_id,
    account_number,
    account_name,
    account_type,
    active_flag
)
VALUES
    (501, '510100', 'Salaries',              'Salary',    'Y'),
    (502, '520200', 'Professional Services', 'Services',  'Y'),
    (503, '530300', 'Operating Supplies',    'Supplies',  'Y'),
    (504, '540400', 'Equipment',             'Equipment', 'Y'),
    (505, '550500', 'Software and Licensing','Services',  'Y');


------------------------------------------------------------
-- FISCAL PERIODS
------------------------------------------------------------

INSERT INTO dbo.fiscal_periods
(
    period_id,
    fiscal_year,
    period_number,
    period_name,
    period_start,
    period_end,
    closed_flag
)
VALUES
    (202601, 2026, 1,  'January',   '2026-01-01', '2026-01-31', 'Y'),
    (202602, 2026, 2,  'February',  '2026-02-01', '2026-02-28', 'Y'),
    (202603, 2026, 3,  'March',     '2026-03-01', '2026-03-31', 'Y'),
    (202604, 2026, 4,  'April',     '2026-04-01', '2026-04-30', 'Y'),
    (202605, 2026, 5,  'May',       '2026-05-01', '2026-05-31', 'Y'),
    (202606, 2026, 6,  'June',      '2026-06-01', '2026-06-30', 'Y'),
    (202607, 2026, 7,  'July',      '2026-07-01', '2026-07-31', 'Y'),
    (202608, 2026, 8,  'August',    '2026-08-01', '2026-08-31', 'N'),
    (202609, 2026, 9,  'September', '2026-09-01', '2026-09-30', 'N'),
    (202610, 2026, 10, 'October',   '2026-10-01', '2026-10-31', 'N'),
    (202611, 2026, 11, 'November',  '2026-11-01', '2026-11-30', 'N'),
    (202612, 2026, 12, 'December',  '2026-12-01', '2026-12-31', 'N');


------------------------------------------------------------
-- BUDGETS
------------------------------------------------------------

INSERT INTO dbo.budgets
(
    budget_id,
    fiscal_year,
    department_id,
    account_id,
    original_budget,
    revised_budget
)
VALUES
    -- Finance
    (1, 2026, 101, 501, 400000.00, 410000.00),
    (2, 2026, 101, 502,  75000.00,  80000.00),
    (3, 2026, 101, 503,  30000.00,  30000.00),

    -- Operations
    (4, 2026, 102, 501, 650000.00, 665000.00),
    (5, 2026, 102, 502, 150000.00, 160000.00),
    (6, 2026, 102, 503, 100000.00, 110000.00),
    (7, 2026, 102, 504, 175000.00, 190000.00),

    -- Information Technology
    (8,  2026, 103, 501, 375000.00, 385000.00),
    (9,  2026, 103, 504, 125000.00, 135000.00),
    (10, 2026, 103, 505, 225000.00, 240000.00);


------------------------------------------------------------
-- TRANSACTIONS
------------------------------------------------------------

INSERT INTO dbo.transactions
(
    transaction_id,
    document_number,
    account_id,
    department_id,
    transaction_date,
    posting_date,
    period_id,
    amount,
    transaction_type,
    status,
    source_system
)
VALUES

    --------------------------------------------------------
    -- Finance
    --------------------------------------------------------

    (1001, 'PAY-2026-001', 501, 101,
     '2026-01-31', '2026-01-31', 202601,
     32000.00, 'PAYROLL', 'POSTED', 'ERP'),

    (1002, 'INV-2001', 502, 101,
     '2026-02-10', '2026-02-12', 202602,
     4250.00, 'INVOICE', 'POSTED', 'ERP'),

    (1003, 'INV-2014', 503, 101,
     '2026-03-05', '2026-03-06', 202603,
     1850.00, 'INVOICE', 'POSTED', 'ERP'),

    (1004, 'PAY-2026-002', 501, 101,
     '2026-02-28', '2026-02-28', 202602,
     32000.00, 'PAYROLL', 'POSTED', 'ERP'),


    --------------------------------------------------------
    -- Operations
    --------------------------------------------------------

    (1005, 'PAY-2026-003', 501, 102,
     '2026-01-31', '2026-01-31', 202601,
     51000.00, 'PAYROLL', 'POSTED', 'ERP'),

    (1006, 'INV-2027', 503, 102,
     '2026-03-18', '2026-03-20', 202603,
     6200.00, 'INVOICE', 'POSTED', 'ERP'),

    (1007, 'INV-2032', 504, 102,
     '2026-04-03', '2026-04-04', 202604,
     18750.00, 'INVOICE', 'POSTED', 'ERP'),

    (1008, 'INV-2039', 502, 102,
     '2026-05-11', '2026-05-12', 202605,
     9600.00, 'INVOICE', 'POSTED', 'ERP'),


    --------------------------------------------------------
    -- Information Technology
    --------------------------------------------------------

    (1009, 'LIC-2026-101', 505, 103,
     '2026-01-15', '2026-01-16', 202601,
     24000.00, 'INVOICE', 'POSTED', 'ERP'),

    (1010, 'INV-2048', 504, 103,
     '2026-04-15', '2026-04-17', 202604,
     7500.00, 'INVOICE', 'POSTED', 'ERP'),

    (1011, 'INV-2048', 504, 103,
     '2026-04-15', '2026-04-17', 202604,
     7500.00, 'INVOICE', 'POSTED', 'ERP'),

    (1012, 'LIC-2026-122', 505, 103,
     '2026-05-01', '2026-05-02', 202605,
     12800.00, 'INVOICE', 'POSTED', 'ERP'),

    (1013, 'INV-2057', 505, 103,
     '2026-05-22', '2026-05-23', 202605,
     4850.00, 'INVOICE', 'REVERSED', 'ERP'),

    (1014, 'ADJ-2026-014', 505, 103,
     '2026-05-24', '2026-05-24', 202605,
     4850.00, 'ADJUSTMENT', 'POSTED', 'ERP'),

    (1015, 'INV-2063', 503, 102,
     '2026-06-30', '2026-07-02', 202607,
     5350.00, 'INVOICE', 'POSTED', 'ERP'),

    (1016, 'INV-2071', 504, 103,
     '2026-07-09', '2026-07-10', 202607,
     11250.00, 'INVOICE', 'POSTED', 'ERP'),

    (1017, 'INV-2080', 502, 101,
     '2026-07-21', '2026-07-22', 202607,
     3600.00, 'INVOICE', 'PENDING', 'ERP'),

    (1018, 'JRN-2026-044', 503, 101,
     '2026-07-25', '2026-07-25', 202607,
     -1250.00, 'CREDIT', 'POSTED', 'ERP'),

    (1019, 'PAY-2026-007', 501, 103,
     '2026-07-31', '2026-07-31', 202607,
     30500.00, 'PAYROLL', 'POSTED', 'ERP'),

    (1020, 'LIC-2026-188', 505, 103,
     '2026-08-04', '2026-08-05', 202608,
     6750.00, 'INVOICE', 'POSTED', 'ERP');


------------------------------------------------------------
-- ENCUMBRANCES
------------------------------------------------------------

INSERT INTO dbo.encumbrances
(
    encumbrance_id,
    po_number,
    account_id,
    department_id,
    fiscal_year,
    original_amount,
    liquidated_amount,
    remaining_amount,
    status,
    created_date,
    closed_date
)
VALUES

    (2001, 'PO-2026-1001', 502, 101, 2026,
     18000.00, 6000.00, 12000.00,
     'PARTIALLY_LIQUIDATED',
     '2026-01-10', NULL),

    (2002, 'PO-2026-1002', 503, 101, 2026,
     9500.00, 0.00, 9500.00,
     'OPEN',
     '2026-02-14', NULL),

    (2003, 'PO-2026-1003', 504, 102, 2026,
     25000.00, 16500.00, 8500.00,
     'PARTIALLY_LIQUIDATED',
     '2026-03-01', NULL),

    (2004, 'PO-2026-1004', 502, 102, 2026,
     12000.00, 12000.00, 0.00,
     'CLOSED',
     '2026-02-20', '2026-06-15'),

    (2005, 'PO-2026-1005', 505, 103, 2026,
     36000.00, 9000.00, 27000.00,
     'PARTIALLY_LIQUIDATED',
     '2026-01-05', NULL),

    (2006, 'PO-2026-1006', 504, 103, 2026,
     15000.00, 0.00, 15000.00,
     'CANCELLED',
     '2026-04-08', '2026-04-12');


------------------------------------------------------------
-- LOAD VALIDATION
------------------------------------------------------------

SELECT 'departments' AS table_name, COUNT(*) AS row_count
FROM dbo.departments

UNION ALL

SELECT 'accounts', COUNT(*)
FROM dbo.accounts

UNION ALL

SELECT 'fiscal_periods', COUNT(*)
FROM dbo.fiscal_periods

UNION ALL

SELECT 'budgets', COUNT(*)
FROM dbo.budgets

UNION ALL

SELECT 'transactions', COUNT(*)
FROM dbo.transactions

UNION ALL

SELECT 'encumbrances', COUNT(*)
FROM dbo.encumbrances;
