-- =================================================================================================
-- File: SQLFile_30_09_26.sql
-- Date: 30-Sept-2026
-- Topic: T-SQL PIVOT Operator Examples & Hospital Database Assignments
-- =================================================================================================

-- -------------------------------------------------------------------------------------------------
-- PART 1: CUSTOMERS PIVOT DEMO (Initial Practice)
-- -------------------------------------------------------------------------------------------------
IF OBJECT_ID('Customers', 'U') IS NOT NULL DROP TABLE Customers;
CREATE TABLE Customers
(
    CustomerName VARCHAR(50),
    ProductName VARCHAR(50),
    Amount INT
);

INSERT INTO Customers VALUES('James', 'Laptop', 30000);
INSERT INTO Customers VALUES('James', 'Desktop', 25000);
INSERT INTO Customers VALUES('David', 'Laptop', 25000);
INSERT INTO Customers VALUES('Smith', 'Desktop', 30000);
INSERT INTO Customers VALUES('Pam', 'Laptop', 45000);
INSERT INTO Customers VALUES('Pam', 'Laptop', 30000);
INSERT INTO Customers VALUES('John', 'Desktop', 30000);
INSERT INTO Customers VALUES('John', 'Desktop', 30000);
INSERT INTO Customers VALUES('John', 'Laptop', 30000);

SELECT * FROM Customers;

-- PIVOT Operator Demo
SELECT CustomerName, Laptop, Desktop
FROM
(
    SELECT CustomerName,
           ProductName,
           Amount
    FROM Customers
) AS PivotData
PIVOT
(
    SUM(Amount) FOR ProductName
    IN (Laptop, Desktop)
) AS PivotTable;
GO


-- =================================================================================================
-- PART 2: HOSPITAL MANAGEMENT SYSTEM SCHEMA & DATA SETUP (SQL Server T-SQL)
-- =================================================================================================

-- Drop existing tables if re-running (reverse order of foreign keys)
IF OBJECT_ID('Appointments', 'U') IS NOT NULL DROP TABLE Appointments;
IF OBJECT_ID('Doctors', 'U') IS NOT NULL DROP TABLE Doctors;
IF OBJECT_ID('Patients', 'U') IS NOT NULL DROP TABLE Patients;
IF OBJECT_ID('Departments', 'U') IS NOT NULL DROP TABLE Departments;
GO

-- 1. Departments Table
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    head_of_department VARCHAR(100),
    phone_extension VARCHAR(10)
);

-- 2. Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    department_id INT,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- 3. Patients Table
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    phone_number VARCHAR(20),
    blood_group VARCHAR(5)
);

-- 4. Appointments Table
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled' CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No-Show')),
    reason_for_visit VARCHAR(MAX),
    diagnosis VARCHAR(MAX),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- Insert Departments
INSERT INTO Departments (department_id, department_name, head_of_department, phone_extension) VALUES
(1, 'Cardiology', 'Dr. Robert Smith', '1001'),
(2, 'Neurology', 'Dr. Sarah Connor', '1002'),
(3, 'Orthopedics', 'Dr. James Wilson', '1003'),
(4, 'Pediatrics', 'Dr. Emily Watson', '1004'),
(5, 'Oncology', 'Dr. Michael Chang', '1005'),
(6, 'Gastroenterology', 'Dr. Laura Vance', '1006'),
(7, 'Dermatology', 'Dr. Alan Grant', '1007'),
(8, 'Urology', 'Dr. Susan Calvin', '1008'),
(9, 'Pulmonology', 'Dr. David Bowman', '1009'),
(10, 'Endocrinology', 'Dr. Grace Augustine', '1010'),
(11, 'Ophthalmology', 'Dr. Thomas Kane', '1011'),
(12, 'Otolaryngology (ENT)', 'Dr. Rachel Tyrell', '1012'),
(13, 'Psychiatry', 'Dr. Bruce Banner', '1013'),
(14, 'Nephrology', 'Dr. Eleanor Arroway', '1014'),
(15, 'Rheumatology', 'Dr. Henry Wu', '1015'),
(16, 'General Surgery', 'Dr. Stephen Strange', '1016'),
(17, 'Emergency Medicine', 'Dr. Leonard McCoy', '1017'),
(18, 'Obstetrics & Gynecology', 'Dr. Beverly Crusher', '1018'),
(19, 'Hematology', 'Dr. John Watson', '1019'),
(20, 'Radiology', 'Dr. Dana Scully', '1020');

-- Insert Doctors
INSERT INTO Doctors (doctor_id, first_name, last_name, specialization, department_id, email, phone_number) VALUES
(1, 'Robert', 'Smith', 'Cardiologist', 1, 'r.smith@hospital.org', '555-0101'),
(2, 'Sarah', 'Connor', 'Neurologist', 2, 's.connor@hospital.org', '555-0102'),
(3, 'James', 'Wilson', 'Orthopedic Surgeon', 3, 'j.wilson@hospital.org', '555-0103'),
(4, 'Emily', 'Watson', 'Pediatrician', 4, 'e.watson@hospital.org', '555-0104'),
(5, 'Michael', 'Chang', 'Oncologist', 5, 'm.chang@hospital.org', '555-0105'),
(6, 'Laura', 'Vance', 'Gastroenterologist', 6, 'l.vance@hospital.org', '555-0106'),
(7, 'Alan', 'Grant', 'Dermatologist', 7, 'a.grant@hospital.org', '555-0107'),
(8, 'Susan', 'Calvin', 'Urologist', 8, 's.calvin@hospital.org', '555-0108'),
(9, 'David', 'Bowman', 'Pulmonologist', 9, 'd.bowman@hospital.org', '555-0109'),
(10, 'Grace', 'Augustine', 'Endocrinologist', 10, 'g.augustine@hospital.org', '555-0110'),
(11, 'Thomas', 'Kane', 'Ophthalmologist', 11, 't.kane@hospital.org', '555-0111'),
(12, 'Rachel', 'Tyrell', 'ENT Specialist', 12, 'r.tyrell@hospital.org', '555-0112'),
(13, 'Bruce', 'Banner', 'Psychiatrist', 13, 'b.banner@hospital.org', '555-0113'),
(14, 'Eleanor', 'Arroway', 'Nephrologist', 14, 'e.arroway@hospital.org', '555-0114'),
(15, 'Henry', 'Wu', 'Rheumatologist', 15, 'h.wu@hospital.org', '555-0115'),
(16, 'Stephen', 'Strange', 'General Surgeon', 16, 's.strange@hospital.org', '555-0116'),
(17, 'Leonard', 'McCoy', 'Emergency Physician', 17, 'l.mccoy@hospital.org', '555-0117'),
(18, 'Beverly', 'Crusher', 'Obstetrician', 18, 'b.crusher@hospital.org', '555-0118'),
(19, 'John', 'Watson', 'Hematologist', 19, 'j.watson@hospital.org', '555-0119'),
(20, 'Dana', 'Scully', 'Radiologist', 20, 'd.scully@hospital.org', '555-0120');

-- Insert Patients
INSERT INTO Patients (patient_id, first_name, last_name, date_of_birth, gender, phone_number, blood_group) VALUES
(1, 'Alice', 'Johnson', '1985-04-12', 'Female', '555-0201', 'A+'),
(2, 'Bob', 'Williams', '1972-09-25', 'Male', '555-0202', 'O-'),
(3, 'Charlie', 'Brown', '1990-11-03', 'Male', '555-0203', 'B+'),
(4, 'Diana', 'Prince', '1988-03-22', 'Female', '555-0204', 'AB+'),
(5, 'Ethan', 'Hunt', '1980-07-18', 'Male', '555-0205', 'O+'),
(6, 'Fiona', 'Gallagher', '1995-01-30', 'Female', '555-0206', 'A-'),
(7, 'George', 'Clark', '1965-06-14', 'Male', '555-0207', 'B-'),
(8, 'Hannah', 'Abbott', '2001-12-05', 'Female', '555-0208', 'AB-'),
(9, 'Ian', 'Malcolm', '1978-08-09', 'Male', '555-0209', 'O+'),
(10, 'Julia', 'Roberts', '1992-05-17', 'Female', '555-0210', 'A+'),
(11, 'Kevin', 'Flynn', '1983-02-28', 'Male', '555-0211', 'B+'),
(12, 'Laura', 'Palmer', '1998-10-10', 'Female', '555-0212', 'O-'),
(13, 'Michael', 'Scott', '1964-03-15', 'Male', '555-0213', 'A+'),
(14, 'Nina', 'Sayers', '1993-07-04', 'Female', '555-0214', 'B-'),
(15, 'Oscar', 'Martinez', '1975-11-20', 'Male', '555-0215', 'O+'),
(16, 'Pam', 'Beesly', '1984-03-25', 'Female', '555-0216', 'AB+'),
(17, 'Quinn', 'Fabray', '1996-09-08', 'Female', '555-0217', 'A-'),
(18, 'Ron', 'Swanson', '1961-05-06', 'Male', '555-0218', 'O+'),
(19, 'Samantha', 'Jones', '1979-04-28', 'Female', '555-0219', 'B+'),
(20, 'Tim', 'Drake', '2003-01-12', 'Male', '555-0220', 'AB-');

-- Insert Appointments
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status, reason_for_visit, diagnosis) VALUES
(1, 1, 1, '2026-10-01 09:00:00', 'Scheduled', 'Chest tightness during exercise', NULL),
(2, 2, 2, '2026-10-01 10:30:00', 'Scheduled', 'Chronic migraines', NULL),
(3, 3, 3, '2026-09-28 14:00:00', 'Completed', 'Right knee pain after running', 'Mild ligament strain'),
(4, 4, 4, '2026-09-29 11:15:00', 'Completed', 'Annual pediatric checkup', 'Healthy growth metrics'),
(5, 5, 5, '2026-10-02 13:00:00', 'Scheduled', 'Follow-up post-chemotherapy', NULL),
(6, 6, 6, '2026-09-27 15:30:00', 'Completed', 'Acid reflux and abdominal bloating', 'GERD'),
(7, 7, 7, '2026-09-25 09:45:00', 'Cancelled', 'Skin rash on forearms', NULL),
(8, 8, 8, '2026-10-03 10:00:00', 'Scheduled', 'Routine kidney ultrasound review', NULL),
(9, 9, 9, '2026-09-26 16:00:00', 'Completed', 'Persistent cough and shortness of breath', 'Mild asthma exacerbation'),
(10, 10, 10, '2026-10-04 08:30:00', 'Scheduled', 'Thyroid panel consultation', NULL),
(11, 11, 11, '2026-09-24 11:00:00', 'Completed', 'Blurry vision in left eye', 'Early-stage cataract'),
(12, 12, 12, '2026-09-23 14:30:00', 'No-Show', 'Sore throat and earache', NULL),
(13, 13, 13, '2026-10-05 15:00:00', 'Scheduled', 'Anxiety and insomnia consultation', NULL),
(14, 14, 14, '2026-09-22 10:00:00', 'Completed', 'Elevated creatinine levels', 'Stage 2 CKD management'),
(15, 15, 15, '2026-10-06 09:15:00', 'Scheduled', 'Joint stiffness in hands', NULL),
(16, 16, 16, '2026-09-21 13:30:00', 'Completed', 'Gallbladder consultation', 'Gallstones recommended for surgery'),
(17, 17, 17, '2026-09-20 22:00:00', 'Completed', 'Acute abdominal pain', 'Appendicitis, referred to surgery'),
(18, 18, 18, '2026-10-07 11:30:00', 'Scheduled', 'Prenatal checkup week 24', NULL),
(19, 19, 19, '2026-09-19 14:00:00', 'Completed', 'Low hemoglobin levels', 'Iron deficiency anemia'),
(20, 20, 20, '2026-09-18 16:30:00', 'Completed', 'Wrist X-ray review', 'Hairline fracture of distal radius');
GO


-- =================================================================================================
-- PART 3: BIPLAB SIR (MCC) ASSIGNMENTS - PIVOT QUERIES
-- =================================================================================================

----------------------------------------------------------------------------------------------------
-- Task 1:
-- Write a query to display each department name with total appointments pivoted by their status 
-- (Scheduled, Completed, Cancelled, No-Show).
----------------------------------------------------------------------------------------------------
SELECT 
    department_name,
    ISNULL([Scheduled], 0) AS Scheduled,
    ISNULL([Completed], 0) AS Completed,
    ISNULL([Cancelled], 0) AS Cancelled,
    ISNULL([No-Show], 0) AS [No-Show]
FROM
(
    SELECT 
        d.department_name,
        a.appointment_id,
        a.status
    FROM Departments d
    INNER JOIN Doctors doc ON d.department_id = doc.department_id
    INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
) AS SourceTable
PIVOT
(
    COUNT(appointment_id)
    FOR status IN ([Scheduled], [Completed], [Cancelled], [No-Show])
) AS PivotTable
ORDER BY department_name;
GO


----------------------------------------------------------------------------------------------------
-- Task 2:
-- Business Goal: The blood bank team needs a demographic breakdown of registered patients to 
--                assess donor availability by blood group.
-- Task: Write a query to output each blood_group as a row and pivot the total count of patients 
--       by their gender (Male, Female, Other).
----------------------------------------------------------------------------------------------------
SELECT 
    blood_group,
    ISNULL([Male], 0) AS Male,
    ISNULL([Female], 0) AS Female,
    ISNULL([Other], 0) AS Other
FROM
(
    SELECT 
        blood_group,
        gender,
        patient_id
    FROM Patients
) AS SourceTable
PIVOT
(
    COUNT(patient_id)
    FOR gender IN ([Male], [Female], [Other])
) AS PivotTable
ORDER BY blood_group;
GO


----------------------------------------------------------------------------------------------------
-- Task 3:
-- Business Goal: Hospital management needs to track individual doctor activity to evaluate 
--                attendance and workload.
-- Task: Display each doctor's full name (first_name + last_name) with the total number of 
--       appointments pivoted across statuses (Completed, Scheduled, Cancelled, No-Show).
----------------------------------------------------------------------------------------------------
SELECT 
    doctor_name,
    ISNULL([Completed], 0) AS Completed,
    ISNULL([Scheduled], 0) AS Scheduled,
    ISNULL([Cancelled], 0) AS Cancelled,
    ISNULL([No-Show], 0) AS [No-Show]
FROM
(
    SELECT 
        CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name,
        a.appointment_id,
        a.status
    FROM Doctors doc
    INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
) AS SourceTable
PIVOT
(
    COUNT(appointment_id)
    FOR status IN ([Completed], [Scheduled], [Cancelled], [No-Show])
) AS PivotTable
ORDER BY doctor_name;
GO


----------------------------------------------------------------------------------------------------
-- Task 4:
-- Business Goal: The scheduling department wants to identify peak months for patient visits per 
--                department to optimize staffing.
-- Task: Display each department name with total appointments pivoted by month name 
--       (e.g., September, October) for the year 2026.
----------------------------------------------------------------------------------------------------
SELECT 
    department_name,
    ISNULL([September], 0) AS September,
    ISNULL([October], 0) AS October
FROM
(
    SELECT 
        d.department_name,
        a.appointment_id,
        DATENAME(MONTH, a.appointment_date) AS appointment_month
    FROM Departments d
    INNER JOIN Doctors doc ON d.department_id = doc.department_id
    INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
    WHERE YEAR(a.appointment_date) = 2026
) AS SourceTable
PIVOT
(
    COUNT(appointment_id)
    FOR appointment_month IN ([September], [October])
) AS PivotTable
ORDER BY department_name;
GO


----------------------------------------------------------------------------------------------------
-- Task 5:
-- Business Goal: The emergency response team needs to see which blood types are most frequently 
--                required across different specialty departments.
-- Task: Display each department name and pivot the count of distinct patient visits by their 
--       blood_group (A+, O+, B+, AB+, O-, A-, B-, AB-).
----------------------------------------------------------------------------------------------------
SELECT 
    department_name,
    ISNULL([A+], 0) AS [A+],
    ISNULL([O+], 0) AS [O+],
    ISNULL([B+], 0) AS [B+],
    ISNULL([AB+], 0) AS [AB+],
    ISNULL([O-], 0) AS [O-],
    ISNULL([A-], 0) AS [A-],
    ISNULL([B-], 0) AS [B-],
    ISNULL([AB-], 0) AS [AB-]
FROM
(
    SELECT 
        d.department_name,
        p.blood_group,
        a.appointment_id
    FROM Departments d
    INNER JOIN Doctors doc ON d.department_id = doc.department_id
    INNER JOIN Appointments a ON doc.doctor_id = a.doctor_id
    INNER JOIN Patients p ON a.patient_id = p.patient_id
) AS SourceTable
PIVOT
(
    COUNT(appointment_id)
    FOR blood_group IN ([A+], [O+], [B+], [AB+], [O-], [A-], [B-], [AB-])
) AS PivotTable
ORDER BY department_name;
GO
