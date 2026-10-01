------------01.10.26------------------

-- Auto-Commit Transaction Mode
CREATE TABLE #Accounts
(
    AccountId INT PRIMARY KEY,
    AccountName VARCHAR(50),
    Balance INT
);

INSERT INTO #Accounts
VALUES
(1, 'Sailen', 5000),
(2, 'Rahul', 3000);

Select * from #Accounts

UPDATE #Accounts
SET Balance = 8000
WHERE AccountId = 1;

-- Trying to cause error
INSERT into #Accounts
VALUES (1, 'Raj', 87887);       --PRIMARY KEY violation, because AccountId = 1 already exists.
----------------------------------------------------------------------------------------------

-- Implicit Transactions
SET  IMPLICIT_TRANSACTIONS ON;

UPDATE #Accounts
SET Balance = 78000
WHERE AccountId = 1;

SELECT @@TRANCOUNT AS TransactionCount;     -- Check the open transtion
--commit
COMMIT TRANSACTION;

-- Update and Rollback
UPDATE #Accounts
SET Balance = 6767000
WHERE AccountId = 1;

ROLLBACK TRANSACTION;

SET IMPLICIT_TRANSACTIONS OFF;

Select * from #Accounts
-----------------------------------------------------------------------------------------------
-- Explicit Transactions

BEGIN TRANSACTION;

UPDATE #Accounts
SET Balance = 9000
WHERE AccountId = 1;

SELECT *
FROM #Accounts;

SELECT @@TRANCOUNT AS TransactionCount;

COMMIT TRANSACTION;

---------------------------------------------------------------------------------------------
