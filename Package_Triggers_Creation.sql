-- Create Package Specification
CREATE OR REPLACE PACKAGE PKG_HOSPITAL_MANAGEMENT IS
    PROCEDURE ADD_PATIENT(v_patient_rec patients%rowtype);
    PROCEDURE SCHEDULE_APPOINTMENT(v_appointment_rec APPOINTMENTS%rowtype);
    PROCEDURE ISSUE_BILL(v_bill_rec bills%rowtype);
    FUNCTION GET_TOTAL_REVENUE_BY_DOCTOR(p_doctor_id doctors.doctor_id%type) RETURN NUMBER;
    FUNCTION calculate_patient_age(p_patient_id number) RETURN NUMBER;
END pkg_hospital_management;
/

-- Create Package Body
CREATE OR REPLACE PACKAGE BODY PKG_HOSPITAL_MANAGEMENT IS

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

    FUNCTION calculate_patient_age(p_patient_id number) RETURN NUMBER IS
        v_return NUMBER;
    BEGIN
        SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, DATE_OF_BIRTH) / 12) INTO v_return 
        FROM patients WHERE PATIENT_ID = p_patient_id;
        RETURN v_return;
    END calculate_patient_age;

END pkg_hospital_management;
/

-- Create Trigger: Update Medicine Stock after prescription
CREATE OR REPLACE TRIGGER TRG_UPDATE_MEDICINE_STOCK
AFTER INSERT ON prescriptions
FOR EACH ROW
BEGIN
    UPDATE medicines SET STOCK_QUANTITY = (STOCK_QUANTITY - :new.QUANTITY) 
    WHERE MEDICINE_ID = :new.MEDICINE_ID;
END TRG_UPDATE_MEDICINE_STOCK;
/

-- Create Trigger: Automatically issue bill after treatment
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

-- Create Trigger: Prevent doctor overbooking
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