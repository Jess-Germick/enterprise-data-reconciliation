/*
    Project: Enterprise Data Reconciliation
    File: 03-control-totals.sql

    Purpose:
    Establishes authoritative financial control totals from the
    simulated ERP source data.

    These totals provide the baseline used later to reconcile
    downstream reporting results.

    All project data is synthetic.
*/


------------------------------------------------------------
-- PARAMETERS
------------------------------------------------------------

DECLARE @FiscalYear INT = 2026;
DECLARE @AsOfDate DATE = '2026-07-31';


------------------------------------------------------------
-- 1. REVISED BUDGET CONTROL TOTALS
--
-- Establish the approved/revised budget by department and account.
------------------------------------------------------------

SELECT
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name,
    b.original_budget,
    b.revised_budget
FROM dbo.budgets AS b

INNER JOIN dbo.departments AS d
    ON b.department_id = d.department_id

INNER JOIN dbo.accounts AS a
    ON b.account_id = a.account_id

WHERE b.fiscal_year = @FiscalYear

ORDER BY
    d.department_code,
    a.account_number;


------------------------------------------------------------
-- 2. ACTUAL EXPENDITURE CONTROL TOTALS
--
-- ERP business rule:
-- Only POSTED transactions are recognized as actual expenditures.
-- Transactions are recognized based on posting date.
------------------------------------------------------------

SELECT
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name,
    SUM(t.amount) AS actual_amount
FROM dbo.transactions AS t

INNER JOIN dbo.departments AS d
    ON t.department_id = d.department_id

INNER JOIN dbo.accounts AS a
    ON t.account_id = a.account_id

INNER JOIN dbo.fiscal_periods AS fp
    ON t.period_id = fp.period_id

WHERE
    fp.fiscal_year = @FiscalYear
    AND t.status = 'POSTED'
    AND t.posting_date <= @AsOfDate

GROUP BY
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name

ORDER BY
    d.department_code,
    a.account_number;


------------------------------------------------------------
-- 3. ENCUMBRANCE CONTROL TOTALS
--
-- ERP business rule:
-- Only active commitments contribute to outstanding encumbrances.
-- Remaining amount, rather than original PO amount, is used.
------------------------------------------------------------

SELECT
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name,
    SUM(e.remaining_amount) AS outstanding_encumbrance
FROM dbo.encumbrances AS e

INNER JOIN dbo.departments AS d
    ON e.department_id = d.department_id

INNER JOIN dbo.accounts AS a
    ON e.account_id = a.account_id

WHERE
    e.fiscal_year = @FiscalYear
    AND e.status IN
    (
        'OPEN',
        'PARTIALLY_LIQUIDATED'
    )

GROUP BY
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name

ORDER BY
    d.department_code,
    a.account_number;


------------------------------------------------------------
-- 4. COMBINED ERP CONTROL TOTALS
--
-- Combine budget, actual, and encumbrance values to calculate
-- available budget by department and account.
------------------------------------------------------------

WITH actuals AS
(
    SELECT
        t.department_id,
        t.account_id,
        SUM(t.amount) AS actual_amount
    FROM dbo.transactions AS t

    INNER JOIN dbo.fiscal_periods AS fp
        ON t.period_id = fp.period_id

    WHERE
        fp.fiscal_year = @FiscalYear
        AND t.status = 'POSTED'
        AND t.posting_date <= @AsOfDate

    GROUP BY
        t.department_id,
        t.account_id
),

encumbrances AS
(
    SELECT
        e.department_id,
        e.account_id,
        SUM(e.remaining_amount) AS encumbrance_amount
    FROM dbo.encumbrances AS e

    WHERE
        e.fiscal_year = @FiscalYear
        AND e.status IN
        (
            'OPEN',
            'PARTIALLY_LIQUIDATED'
        )

    GROUP BY
        e.department_id,
        e.account_id
)

SELECT
    d.department_code,
    d.department_name,
    a.account_number,
    a.account_name,

    b.revised_budget,

    COALESCE(act.actual_amount, 0.00)
        AS actual_amount,

    COALESCE(enc.encumbrance_amount, 0.00)
        AS encumbrance_amount,

    b.revised_budget
        - COALESCE(act.actual_amount, 0.00)
        - COALESCE(enc.encumbrance_amount, 0.00)
        AS available_budget

FROM dbo.budgets AS b

INNER JOIN dbo.departments AS d
    ON b.department_id = d.department_id

INNER JOIN dbo.accounts AS a
    ON b.account_id = a.account_id

LEFT JOIN actuals AS act
    ON b.department_id = act.department_id
    AND b.account_id = act.account_id

LEFT JOIN encumbrances AS enc
    ON b.department_id = enc.department_id
    AND b.account_id = enc.account_id

WHERE
    b.fiscal_year = @FiscalYear

ORDER BY
    d.department_code,
    a.account_number;


------------------------------------------------------------
-- 5. ORGANIZATION-WIDE CONTROL TOTAL
--
-- Provides a single high-level ERP control total for reconciliation.
------------------------------------------------------------

WITH actuals AS
(
    SELECT
        t.department_id,
        t.account_id,
        SUM(t.amount) AS actual_amount
    FROM dbo.transactions AS t

    INNER JOIN dbo.fiscal_periods AS fp
        ON t.period_id = fp.period_id

    WHERE
        fp.fiscal_year = @FiscalYear
        AND t.status = 'POSTED'
        AND t.posting_date <= @AsOfDate

    GROUP BY
        t.department_id,
        t.account_id
),

encumbrances AS
(
    SELECT
        e.department_id,
        e.account_id,
        SUM(e.remaining_amount) AS encumbrance_amount
    FROM dbo.encumbrances AS e

    WHERE
        e.fiscal_year = @FiscalYear
        AND e.status IN
        (
            'OPEN',
            'PARTIALLY_LIQUIDATED'
        )

    GROUP BY
        e.department_id,
        e.account_id
),

control_totals AS
(
    SELECT
        b.revised_budget,

        COALESCE(act.actual_amount, 0.00)
            AS actual_amount,

        COALESCE(enc.encumbrance_amount, 0.00)
            AS encumbrance_amount

    FROM dbo.budgets AS b

    LEFT JOIN actuals AS act
        ON b.department_id = act.department_id
        AND b.account_id = act.account_id

    LEFT JOIN encumbrances AS enc
        ON b.department_id = enc.department_id
        AND b.account_id = enc.account_id

    WHERE
        b.fiscal_year = @FiscalYear
)

SELECT
    SUM(revised_budget) AS total_revised_budget,
    SUM(actual_amount) AS total_actual,
    SUM(encumbrance_amount) AS total_encumbrance,

    SUM(revised_budget)
        - SUM(actual_amount)
        - SUM(encumbrance_amount)
        AS total_available_budget

FROM control_totals;
