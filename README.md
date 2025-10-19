
```markdown
# Hospital & Clinic Management System

This project is a comprehensive Hospital and Clinic Management System designed to streamline various administrative and patient management tasks. It is built using an Oracle database and includes a set of tables, queries, and PL/SQL packages to manage patient information, appointments, treatments, billing, and more.

## Database Schema

The system's database is composed of seven main tables, each designed to store specific information. Primary keys are automatically incremented using sequences.

### **Tables and Columns**

Below are the details of each table, including its columns and the sequence used for its primary key.

| Table Name | Column Name | Data Type | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| **PATIENTS** | `PATIENT_ID` | NUMBER | **Primary Key** (from `PATIENT_ID_SEQ`) | Unique identifier for each patient |
| | `FIRST_NAME` | VARCHAR2(50) | NOT NULL | Patient's first name |
| | `LAST_NAME` | VARCHAR2(50) | NOT NULL | Patient's last name |
| | `DATE_OF_BIRTH` | DATE | NOT NULL | Patient's date of birth |
| | `GENDER` | VARCHAR2(10) | CHECK ('Male', 'Female') | Patient's gender |
| | `PHONE_NUMBER` | VARCHAR2(15) | | Patient's contact number |
| | `ADDRESS` | VARCHAR2(200) | | Patient's physical address |
| **DOCTORS** | `DOCTOR_ID` | NUMBER | **Primary Key** (from `DOCTOR_ID_SEQ`) | Unique identifier for each doctor |
| | `FIRST_NAME` | VARCHAR2(50) | NOT NULL | Doctor's first name |
| | `LAST_NAME` | VARCHAR2(50) | NOT NULL | Doctor's last name |
| | `SPECIALIZATION` | VARCHAR2(100) | NOT NULL | Doctor's medical specialization |
| | `PHONE_NUMBER` | VARCHAR2(15) | | Doctor's contact number |
| | `EMAIL` | VARCHAR2(100) | UNIQUE | Doctor's unique email address |
| **APPOINTMENTS**| `APPOINTMENT_ID` | NUMBER | **Primary Key** (from `APPOINTMENT_ID_SEQ`) | Unique identifier for each appointment |
| | `PATIENT_ID` | NUMBER | NOT NULL, Foreign Key to PATIENTS | The patient who booked the appointment |
| | `DOCTOR_ID` | NUMBER | NOT NULL, Foreign Key to DOCTORS | The doctor for the appointment |
| | `APPOINTMENT_DATE`| DATE | NOT NULL | The date and time of the appointment |
| | `STATUS` | VARCHAR2(20) | CHECK ('Scheduled', 'Completed', '...') | The current status of the appointment |
| | `NOTES` | VARCHAR2(500) | | Additional notes for the appointment |
| **TREATMENTS** | `TREATMENT_ID` | NUMBER | **Primary Key** (from `TREATMENT_ID_SEQ`) | Unique identifier for each treatment |
| | `APPOINTMENT_ID` | NUMBER | NOT NULL, Foreign Key to APPOINTMENTS | The appointment associated with the treatment |
| | `TREATMENT_TYPE` | VARCHAR2(100) | | The type of treatment provided |
| | `DESCRIPTION` | VARCHAR2(500) | | A detailed description of the treatment |
| | `COST` | NUMBER(10,2) | | The cost of the treatment |
| **MEDICINES** | `MEDICINE_ID` | NUMBER | **Primary Key** (from `MEDICINE_ID_SEQ`) | Unique identifier for each medicine |
| | `NAME` | VARCHAR2(100) | NOT NULL | The name of the medicine |
| | `MANUFACTURER` | VARCHAR2(100) | | The manufacturer of the medicine |
| | `PRICE` | NUMBER(10,2) | CHECK (PRICE > 0) | The price per unit of the medicine |
| | `STOCK_QUANTITY` | NUMBER | | The quantity available in stock |
| **PRESCRIPTIONS**|`PRESCRIPTION_ID`| NUMBER | **Primary Key** (from `PRESCRIPTION_ID_SEQ`)| Unique identifier for each prescription |
| | `APPOINTMENT_ID` | NUMBER | NOT NULL, Foreign Key to APPOINTMENTS | The associated appointment |
| | `MEDICINE_ID` | NUMBER | NOT NULL, Foreign Key to MEDICINES | The prescribed medicine |
| | `QUANTITY` | NUMBER | | The quantity of medicine prescribed |
| | `DOSAGE` | VARCHAR2(200) | | Instructions on how to take the medicine |
| **BILLS** | `BILL_ID` | NUMBER | **Primary Key** (from `BILL_ID_SEQ`) | Unique identifier for each bill |
| | `APPOINTMENT_ID` | NUMBER | NOT NULL, Foreign Key to APPOINTMENTS | The appointment for which the bill is generated |
| | `TOTAL_AMOUNT` | NUMBER(10,2) | NOT NULL | The total amount to be paid |
| | `PAYMENT_STATUS` | VARCHAR2(20) | CHECK ('Paid', 'Pending', 'Unpaid') | The current status of the payment |
| | `PAYMENT_DATE` | DATE | | The date the payment was made |

---

## Business Intelligence Queries

Here are six queries designed to extract valuable insights from the database. **Remember to replace the placeholder image URLs with your actual screenshots.**

### Query 1: List All Patient Appointments
**Explanation:** This query retrieves a comprehensive list of all appointments, showing the patient's full name, the doctor's full name, the appointment date, and its status. It joins the `APPOINTMENTS`, `PATIENTS`, and `DOCTORS` tables to gather this information.

**SQL:**
```sql
SELECT
    P.FIRST_NAME || ' ' || P.LAST_NAME AS PATIENT_NAME,
    D.FIRST_NAME || ' ' || D.LAST_NAME AS DOCTOR_NAME,
    A.APPOINTMENT_DATE,
    A.STATUS
FROM
    APPOINTMENTS A
JOIN
    PATIENTS P ON A.PATIENT_ID = P.PATIENT_ID
JOIN
    DOCTORS D ON A.DOCTOR_ID = D.DOCTOR_ID;
```
**Result:**
![Query 1 Result](https://i.imgur.com/your-query-1-screenshot.png)

### Query 2: Show the Most Expensive Treatment
**Explanation:** This query identifies the most expensive treatment recorded in the system. It uses a subquery to first find the maximum cost from the `TREATMENTS` table and then retrieves the details of the treatment(s) with that cost.

**SQL:**
```sql
SELECT
    TREATMENT_TYPE,
    DESCRIPTION,
    COST
FROM
    TREATMENTS
WHERE
    COST = (SELECT MAX(COST) FROM TREATMENTS);
```
**Result:**
![Query 2 Result](https://i.imgur.com/your-query-2-screenshot.png)

### Query 3: Find Doctors With No Upcoming Appointments
**Explanation:** This query helps in identifying doctors who are currently available by listing those who do not have any 'Scheduled', 'Pending', or 'Unpaid' appointments. This is useful for scheduling and resource management.

**SQL:**
```sql
SELECT
    D.FIRST_NAME || ' ' || D.LAST_NAME AS DOCTOR_NAME,
    D.SPECIALIZATION
FROM
    DOCTORS D
WHERE
    D.DOCTOR_ID NOT IN (SELECT DOCTOR_ID FROM APPOINTMENTS WHERE STATUS IN ('Scheduled', 'Pending', 'Unpaid'));
```
**Result:**
![Query 3 Result](https://i.imgur.com/your-query-3-screenshot.png)

### Query 4: Find Patients Who Missed Their Appointments
**Explanation:** This query identifies patients who had a 'Scheduled' appointment but did not receive any treatment. This can indicate a missed appointment or a "no-show."

**SQL:**
```sql
SELECT DISTINCT
    P.FIRST_NAME || ' ' || P.LAST_NAME AS PATIENT_NAME
FROM
    PATIENTS P
JOIN
    APPOINTMENTS A ON P.PATIENT_ID = A.PATIENT_ID
WHERE
    A.STATUS = 'Scheduled'
    AND A.APPOINTMENT_ID NOT IN (SELECT APPOINTMENT_ID FROM TREATMENTS);
```
**Result:**
![Query 4 Result](https://i.imgur.com/your-query-4-screenshot.png)

### Query 5: Show Top 3 Most Prescribed Medicines
**Explanation:** This query provides insight into medication trends by identifying the top three most frequently prescribed medicines. It counts the occurrences of each medicine in the `PRESCRIPTIONS` table and orders the result in descending order.

**SQL:**
```sql
SELECT
    M.NAME,
    COUNT(PR.MEDICINE_ID) AS TIMES_PRESCRIBED
FROM
    PRESCRIPTIONS PR
JOIN
    MEDICINES M ON PR.MEDICINE_ID = M.MEDICINE_ID
GROUP BY
    M.NAME
ORDER BY
    TIMES_PRESCRIBED DESC
FETCH FIRST 3 ROWS ONLY;
```
**Result:**
![Query 5 Result](https://i.imgur.com/your-query-5-screenshot.png)

### Query 6: Calculate Total Revenue Per Doctor
**Explanation:** This financial query calculates the total revenue generated by each doctor from 'Paid' bills. It joins the `BILLS`, `APPOINTMENTS`, and `DOCTORS` tables, sums the total amount for each doctor, and presents the results in descending order of revenue.

**SQL:**
```sql
SELECT
    D.FIRST_NAME || ' ' || D.LAST_NAME AS DOCTOR_NAME,
    SUM(B.TOTAL_AMOUNT) AS TOTAL_REVENUE
FROM
    BILLS B
JOIN
    APPOINTMENTS A ON B.APPOINTMENT_ID = A.APPOINTMENT_ID
JOIN
    DOCTORS D ON A.DOCTOR_ID = D.DOCTOR_ID
WHERE
    B.PAYMENT_STATUS = 'Paid'
GROUP BY
    D.FIRST_NAME, D.LAST_NAME
ORDER BY
    TOTAL_REVENUE DESC;
```
**Result:**
![Query 6 Result](https://i.imgur.com/your-query-6-screenshot.png)

---

## PL/SQL Package: PKG_HOSPITAL_MANAGEMENT

To encapsulate business logic and ensure data integrity, the system uses a PL/SQL package named `PKG_HOSPITAL_MANAGEMENT`. This package contains procedures and functions to handle common operations.

### Package Specification
The package specification defines the public procedures and functions that can be called from outside the package.

```sql
CREATE OR REPLACE PACKAGE PKG_HOSPITAL_MANAGEMENT IS
    -- Procedures
    PROCEDURE ADD_PATIENT(v_patient_rec patients%rowtype);
    PROCEDURE SCHEDULE_APPOINTMENT(v_appointment_rec APPOINTMENTS%rowtype);
    PROCEDURE ISSUE_BILL(v_bill_rec bills%rowtype);

    -- Functions
    FUNCTION GET_TOTAL_REVENUE_BY_DOCTOR(p_doctor_id doctors.doctor_id%type) RETURN NUMBER;
    FUNCTION calculate_patient_age(p_patient_id number) RETURN NUMBER;
END pkg_hospital_management;
/
```

### Package Body
The package body contains the implementation of the procedures and functions defined in the specification.

### Procedures

#### `ADD_PATIENT`
*   **Explanation:** This procedure adds a new patient to the `PATIENTS` table. It takes a record of the `patients%rowtype` as input to ensure all necessary fields are provided. It includes error handling to roll back the transaction if an issue occurs.
*   **Code:**
    ```sql
    PROCEDURE ADD_PATIENT(v_patient_rec patients%rowtype) IS
        error_code NUMBER;
        error_message VARCHAR2(255);
    BEGIN
        INSERT INTO patients VALUES
        (v_patient_rec.PATIENT_ID, v_patient_rec.FIRST_NAME, v_patient_rec.LAST_NAME, 
         v_patient_rec.DATE_OF_BIRTH, v_patient_rec.GENDER, v_patient_rec.PHONE_NUMBER, 
         v_patient_rec.ADDRESS);
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            error_code := SQLCODE;
            error_message := SQLERRM;
            RAISE_APPLICATION_ERROR(SQLCODE, SQLERRM);
    END ADD_PATIENT;
    ```

#### `SCHEDULE_APPOINTMENT`
*   **Explanation:** This procedure handles the scheduling of new appointments. It includes several business rules and validations:
    *   Verifies that the `DOCTOR_ID` and `PATIENT_ID` exist.
    *   Prevents a patient from booking multiple appointments on the same day.
    *   Enforces a daily limit of 5 appointments per doctor to prevent overbooking.
*   **Code:**
    ```sql
    PROCEDURE SCHEDULE_APPOINTMENT(v_appointment_rec APPOINTMENTS%rowtype) IS
        v_check_doctor NUMBER;
        v_check_patient NUMBER;
        v_check_patient_appointment NUMBER;
        v_daily_limit NUMBER;
        doctor_not_found EXCEPTION;
        patient_not_found EXCEPTION;
        change_appointment EXCEPTION;
        limit_five EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_check_doctor FROM doctors WHERE doctor_id = v_appointment_rec.DOCTOR_ID;
        SELECT COUNT(*) INTO v_check_patient FROM patients WHERE patient_id = v_appointment_rec.PATIENT_ID;
        SELECT COUNT(*) INTO v_check_patient_appointment FROM APPOINTMENTS 
        WHERE patient_id = v_appointment_rec.PATIENT_ID AND APPOINTMENT_DATE = v_appointment_rec.APPOINTMENT_DATE;
        SELECT COUNT(*) INTO v_daily_limit FROM APPOINTMENTS 
        WHERE doctor_id = v_appointment_rec.DOCTOR_ID AND APPOINTMENT_DATE = v_appointment_rec.APPOINTMENT_DATE;

        IF v_check_doctor < 1 THEN
            RAISE doctor_not_found;
        ELSIF v_check_patient < 1 THEN
            RAISE patient_not_found;
        ELSIF v_check_patient_appointment > 0 THEN
            RAISE change_appointment;
        ELSIF v_daily_limit > 4 THEN
            RAISE limit_five;
        END IF;
        
        INSERT INTO APPOINTMENTS VALUES 
        (v_appointment_rec.APPOINTMENT_ID, v_appointment_rec.PATIENT_ID, v_appointment_rec.DOCTOR_ID, 
         v_appointment_rec.APPOINTMENT_DATE, v_appointment_rec.STATUS, v_appointment_rec.NOTES);
        
        COMMIT;
    EXCEPTION
        WHEN doctor_not_found THEN
            RAISE_APPLICATION_ERROR(-20901, 'Doctor not found!');
        WHEN patient_not_found THEN
            RAISE_APPLICATION_ERROR(-20902, 'Patient not found!');
        WHEN change_appointment THEN
            RAISE_APPLICATION_ERROR(-20903, 'Patient have appointment in the same day!');
        WHEN limit_five THEN
            RAISE_APPLICATION_ERROR(-20904, 'Doctor will have more then 5 appointments in the same day!');
    END SCHEDULE_APPOINTMENT;
    ```

#### `ISSUE_BILL`
*   **Explanation:** This procedure creates a new bill for an appointment. It checks to ensure that a bill has not already been issued for the same appointment, preventing duplicate entries.
*   **Code:**
    ```sql
    PROCEDURE ISSUE_BILL(v_bill_rec bills%rowtype) IS
        v_check_appointment NUMBER;
        same_appointment EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_check_appointment FROM bills WHERE APPOINTMENT_ID = v_bill_rec.APPOINTMENT_ID;
        
        IF v_check_appointment > 0 THEN
            RAISE same_appointment;
        END IF;
        
        INSERT INTO bills VALUES v_bill_rec;
        COMMIT;
    EXCEPTION
        WHEN same_appointment THEN
            RAISE_APPLICATION_ERROR(-20905, 'Bill is already registered!');
    END ISSUE_BILL;
    ```

### Functions

#### `GET_TOTAL_REVENUE_BY_DOCTOR`
*   **Explanation:** This function calculates and returns the total revenue generated by a specific doctor from appointments with a 'Paid' status. It takes a `p_doctor_id` as input and returns the total sum as a `NUMBER`.
*   **Code:**
    ```sql
    FUNCTION GET_TOTAL_REVENUE_BY_DOCTOR(p_doctor_id doctors.doctor_id%type) RETURN NUMBER IS
        v_return NUMBER;
    BEGIN 
        SELECT SUM(B.TOTAL_AMOUNT) INTO v_return
        FROM BILLS B
        JOIN APPOINTMENTS A ON B.APPOINTMENT_ID = A.APPOINTMENT_ID
        JOIN DOCTORS D ON A.DOCTOR_ID = D.DOCTOR_ID
        WHERE B.PAYMENT_STATUS = 'Paid'
        AND A.DOCTOR_ID = p_doctor_id;
        
        RETURN v_return;
    END GET_TOTAL_REVENUE_BY_DOCTOR;
    ```

#### `calculate_patient_age`
*   **Explanation:** This utility function calculates the current age of a patient in years based on their `DATE_OF_BIRTH`. It takes a `p_patient_id` as input and returns the calculated age.
*   **Code:**
    ```sql
    FUNCTION calculate_patient_age(p_patient_id number) RETURN NUMBER IS
        v_return NUMBER;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, DATE_OF_BIRTH) / 12) INTO v_return 
        FROM patients WHERE PATIENT_ID = p_patient_id;
        RETURN v_return;
    END calculate_patient_age;
    ```

---

## Triggers

The system uses triggers to automate certain actions based on database events.

### `TRG_UPDATE_MEDICINE_STOCK`
*   **Explanation:** This trigger automatically updates the `STOCK_QUANTITY` in the `MEDICINES` table after a new record is inserted into the `PRESCRIPTIONS` table. It subtracts the prescribed quantity from the available stock.
*   **Code:**
    ```sql
    CREATE OR REPLACE TRIGGER TRG_UPDATE_MEDICINE_STOCK
    AFTER INSERT ON prescriptions
    FOR EACH ROW
    BEGIN
        UPDATE medicines SET STOCK_QUANTITY = (STOCK_QUANTITY - :new.QUANTITY) 
        WHERE MEDICINE_ID = :new.MEDICINE_ID;
    END TRG_UPDATE_MEDICINE_STOCK;
    /
    ```

### `Trg_After_Treatment_Issue_Bill`
*   **Explanation:** This trigger automatically creates a new bill with a 'Pending' status whenever a new treatment is recorded. It calls the `ISSUE_BILL` procedure from the `PKG_HOSPITAL_MANAGEMENT` package to generate the bill.
*   **Code:**
    ```sql
    CREATE OR REPLACE TRIGGER Trg_After_Treatment_Issue_Bill
    AFTER INSERT ON treatments
    FOR EACH ROW
    DECLARE
        v_bill_rec bills%ROWTYPE;
    BEGIN
        v_bill_rec.bill_id := BILL_ID_SEQ.NEXTVAL;
        v_bill_rec.appointment_id := :NEW.appointment_id;
        v_bill_rec.total_amount := :NEW.cost;
        v_bill_rec.payment_status := 'Pending';
        v_bill_rec.payment_date := SYSDATE;

        pkg_hospital_management.ISSUE_BILL(v_bill_rec);
    END Trg_After_Treatment_Issue_Bill;
    /
    ```

### `TRG_PREVENT_OVERBOOKING`
*   **Explanation:** This trigger prevents a doctor from being booked for more than five appointments on the same day. It runs before an `INSERT` on the `APPOINTMENTS` table and raises an error if the daily limit is exceeded.
*   **Code:**
    ```sql
    CREATE OR REPLACE TRIGGER TRG_PREVENT_OVERBOOKING
    BEFORE INSERT ON APPOINTMENTS
    FOR EACH ROW
    DECLARE
        v_daily_limit NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_daily_limit FROM APPOINTMENTS 
        WHERE doctor_id = :new.doctor_id AND APPOINTMENT_DATE = :new.APPOINTMENT_DATE;
        
        IF v_daily_limit >= 5 THEN
            RAISE_APPLICATION_ERROR(-20904, 'Doctor will have more than 5 appointments in the same day!');
        END IF;
    END TRG_PREVENT_OVERBOOKING;
    /
    ```
```
- Would you like me to help you create a separate SQL file containing all the table creation, insertion, and PL/SQL code for easier database setup?
- Should we add a "How to Use" or "Setup Instructions" section to the README?
- I can also help you draft a `.gitignore` file for this project.
