set serveroutput on;

-- Functie pentru a determina urmatorul id din tabela
create or replace function getNextId(tableName varchar2)
return number is
  maxId number;
begin
  execute immediate 'select max(id) from ' || tableName into maxId;
  return maxid;  
exception 
  when OTHERS then 
    dbms_output.put_line('Tabela nu are o coloana numita id.');
    return -1;
end getNextId;

begin
  dbms_output.put_line(getNextId('PRICES'));
end;

-- HEADER: 'low', 'medium', 'major', 'critical'
create or replace type severities as object
(
  low varchar2(8),
  medium varchar2(8),
  major varchar2(8),
  critical varchar2(8),
constructor function severities return self as result
);

-- BODY:
create or replace type body severities is
  constructor function severities return self as result is
  begin
    self.low := 'low';
    self.medium := 'medium';
    self.major := 'major';
    self.critical := 'critical';
    return;
  end;
end;

declare
  l severities := new severities;
begin
   dbms_output.put_line(l.critical);
end;

create or replace procedure sendBibycleNotification(textNotification varchar2, severity varchar2, bicycleId number) as
  v_already_present_id number;
  v_already_present number;
begin
  select count(*) into v_already_present from issues where bicycle_id = bicycleId;
  if (v_already_present > 0) then  
    select id into v_already_present_id from issues where bicycle_id = bicycleId and rownum = 1;  
    delete from issues where id = v_already_present_id;
  end if;
  
  insert into ISSUES (REGISTRATION_DATE, DESCRIPTION, SEVERITY, BICYCLE_ID, TYPE_ISSUE) values (sysdate, textNotification, severity, bicycleId, 'notification');
  commit;
end sendBibycleNotification;

create or replace procedure findOldBicycles as
  cursor c_old_bicycles is 
      (select id, months_between(sysdate, REGISTER_DATE)/12 as years from bicycles where months_between(sysdate, REGISTER_DATE)/12  >= 2);
  v_old_bicycles c_old_bicycles%rowtype;
  
  v_severities severities := new severities;
  v_severity varchar2(50);
begin
  for v_old_bicycles in c_old_bicycles loop
    if v_old_bicycles.years < 3 then
      v_severity := v_severities.low;
    elsif v_old_bicycles.years < 5 then
      v_severity := v_severities.medium;
    elsif v_old_bicycles.years < 8 then
      v_severity := v_severities.major;
    else
      v_severity := v_severities.critical;
    end if;
    
    sendBibycleNotification('Bicicleta prea batrana.', v_severity, v_old_bicycles.id);
  end loop;
end findOldBicycles;

begin
  findOldBicycles;
end;


select count(*) from issues;
select id, months_between(sysdate, REGISTER_DATE)/12 as years from bicycles where months_between(sysdate, REGISTER_DATE)/12  >= 2;

-- In cazul in care ai deja date in tabela
alter table ISSUES
  modify BORROW_ID NUMBER(38,0) null
  add bicycle_id NUMBER(38,0)
  add constraint FK_ISSUES_BICYCLE_ID_BICYCLE foreign key (bicycle_id)
	  references bicycles (id) enable;

CREATE OR REPLACE PACKAGE BODY CITY_RIDE_PACKAGE AS

  function get_next_id(tableName varchar2) 
   return NUMBER AS
    maxId number;
  BEGIN
    execute immediate 'select max(id) from ' || tableName into maxId;
    return maxid;  
  EXCEPTION 
    when OTHERS then 
      dbms_output.put_line('Tabela nu are o coloana numita id.');
      return -1;
  END get_next_id;

  FUNCTION compare_sererities(severity1 VARCHAR2, severity2 VARCHAR2)
    RETURN NUMBER IS
    v_severities severities := NEW SEVERITIES;
  BEGIN
    IF(severity1 = severity2) THEN
      RETURN 0;
    END IF;
  
    IF(severity1 = v_severities.LOW AND severity2 != v_severities.LOW) THEN
      RETURN 1;
    END IF;
  
    IF(severity1 = v_severities.MEDIUM AND severity2 != v_severities.LOW AND severity2 != v_severities.MEDIUM) THEN
      RETURN 1;
    END IF;
    
    IF(severity1 = v_severities.MAJOR AND severity2 = v_severities.CRITICAL) THEN
      RETURN 1;
    END IF;
  
    RETURN -1;
  END compare_sererities;

  PROCEDURE send_bibycle_notification(textNotification varchar2, severity varchar2, bicycleId number) IS
    v_already_present_id number;
    v_already_present number;
  BEGIN
    select count(*) into v_already_present from issues where bicycle_id = bicycleId;
    if (v_already_present > 0) then  
      select id into v_already_present_id from issues where bicycle_id = bicycleId and rownum = 1;  
      delete from issues where id = v_already_present_id;
    end if;
    
    insert into ISSUES (REGISTRATION_DATE, DESCRIPTION, SEVERITY, BICYCLE_ID, TYPE_ISSUE) values (sysdate, textNotification, severity, bicycleId, 'notification');
    commit;
  END send_bibycle_notification;

  PROCEDURE find_old_bicycles AS
    cursor c_old_bicycles is 
        (select id, months_between(sysdate, REGISTER_DATE)/12 as years from bicycles 
            where months_between(sysdate, REGISTER_DATE)/12  >= 2 AND (STATUS = 'available' OR STATUS = 'borrowed'));
    v_old_bicycles c_old_bicycles%rowtype;
    
    v_severities severities := new severities;
    v_severity varchar2(50);
  BEGIN
    for v_old_bicycles in c_old_bicycles loop
      if v_old_bicycles.years < 3 then
        v_severity := v_severities.low;
      elsif v_old_bicycles.years < 5 then
        v_severity := v_severities.medium;
      elsif v_old_bicycles.years < 8 then
        v_severity := v_severities.major;
      else
        v_severity := v_severities.critical;
      end if;
      
      send_bibycle_notification('Bicicleta prea batrana: ' || v_old_bicycles.years, v_severity, v_old_bicycles.id);
    end loop;
  END find_old_bicycles;

  procedure find_bicycles_maintenance AS
    v_severities SEVERITIES := NEW SEVERITIES;
    cursor c_bicyles_for_maintenance is 
        (select i.id, i.BICYCLE_ID AS b_id from ISSUES i
            where (SELECT COUNT(*) AS count FROM ISSUES i1 WHERE i1.BICYCLE_ID = i.ID AND i1.SEVERITY = v_severities.LOW) < 3);
    v_bicyles_for_maintenance c_bicyles_for_maintenance%ROWTYPE;
    v_count NUMBER;
  BEGIN
    FOR v_bicyles_for_maintenance in c_bicyles_for_maintenance LOOP
      SELECT COUNT(*) INTO v_count FROM issues i WHERE i.severity != v_severities.LOW AND i.id = V_BICYLES_FOR_MAINTENANCE.id;
      
      IF(V_COUNT = 0) THEN
        INSERT INTO ISSUES (REGISTRATION_DATE, DESCRIPTION, SEVERITY, TYPE_ISSUE, BICYCLE_ID) 
          VALUES  (SYSDATE, 'Bicicleta necesa revizie.', V_SEVERITIES.MEDIUM, 'notification_mentenance', v_bicyles_for_maintenance.b_id);
      END IF;
    END LOOP;
  END find_bicycles_maintenance;
  
  -- TODO: not done, yet
  function find_most_valueble_points(v_count_return integer) return bicycle_id_list IS
    v_to_return_list bicycle_id_list := bicycle_id_list();

    TYPE type_point_valueble IS TABLE OF NUMBER(5,2) INDEX BY BINARY_INTEGER;
    point_valueble type_point_valueble;
    cursor c_pickup_points is 
        (select id FROM PICKUP_POINTS);
    v_pickup_points c_pickup_points%ROWTYPE;
    v_date TIMESTAMP(6) := CURRENT_TIMESTAMP();
    v_date_start TIMESTAMP(6) := v_date - INTERVAL '1' MONTH ;
    v_count INTEGER;
    v_max INTEGER;
  BEGIN
    WHILE(v_date_start < v_date) LOOP
      FOR v_pickup_points IN c_pickup_points LOOP
        SELECT COUNT(*) INTO v_count FROM BICYCLES b JOIN BORROW b1 ON b.id = b1.BICYCLE_ID 
          WHERE b1.BORROW_DATE > V_DATE_START    
            AND b1.END_DATE < V_DATE_START + INTERVAL '1' DAY
            AND (SELECT COUNT(*) FROM MOVE_BICYCLE mb 
              WHERE MB.BICYCLE_ID = b1.BICYCLE_ID
                AND mb.FROM_POINT_ID = v_pickup_points.id 
                AND (MB.MOVE_DATE > b1.END_DATE - INTERVAL '5' SECOND AND MB.MOVE_DATE < b1.END_DATE + INTERVAL '5' SECOND)) > 0;

         IF (point_valueble.exists(v_pickup_points.id)) THEN
            point_valueble(v_pickup_points.id) := (point_valueble(v_pickup_points.id) + v_count) / 2;
         ELSE
            point_valueble(v_pickup_points.id) := v_count;
         END IF;

      END LOOP;

      v_date_start := v_date_start + INTERVAL '1' DAY;
    END LOOP;
    
    FOR i IN 1..V_COUNT_RETURN LOOP
      -- TODO: ask someone if is possible to do something to select directly or I should change the data type
      DBMS_OUTPUT.PUT_LINE(point_valueble.FIRST());
    END LOOP;
      
    RETURN v_to_return_list;
  END find_most_valueble_points;

  function find_overdue_borrows return borrow_id_list IS
     cursor c_old_bicycles is 
          (SELECT ID FROM BORROW WHERE (CURRENT_TIMESTAMP(6) - BORROW_DATE) > INTERVAL '24' HOUR AND END_DATE like null);
    v_old_bicycles c_old_bicycles%ROWTYPE;

    v_return_list borrow_id_list := borrow_id_list();
    v_count INTEGER := 1;
  BEGIN
    FOR v_old_bicycles IN c_old_bicycles LOOP
      v_return_list.EXTEND(1);
      v_return_list(v_count) := v_old_bicycles.id;
      v_count := v_count + 1;
    END LOOP;

    RETURN v_return_list;
  END find_overdue_borrows;

  function check_pickup_points_balance return pickup_point_id_list IS
  BEGIN
    RETURN pickup_point_id_list();
  END check_pickup_points_balance;
  
  function calculates_paid(borrow_id borrow.id%type) return number IS
    v_number_of_hours NUMBER(5,0);
    v_price NUMBER(5,0);
  BEGIN
    SELECT to_number(EXTRACT(DAY FROM 24 * (SYSDATE - borrow_date))) INTO V_NUMBER_OF_HOURS FROM BORROW WHERE id = BORROW_ID;
    SELECT p.value INTO v_price FROM BORROW b JOIN PRICES p ON p.id = b.PRICE_ID WHERE ROWNUM = 1;
    IF(V_NUMBER_OF_HOURS < 3) THEN 
      RETURN 3 * V_PRICE;
    END IF;

    RETURN V_NUMBER_OF_HOURS * V_PRICE;
  END calculates_paid;
  
  function get_bicycle_problems_reported(p_bicycle_id number) return issues_list IS
     v_issues_list issues_list := issues_list();
     cursor c_issues_list IS 
        (SELECT ID FROM ISSUES WHERE bicycle_id = p_bicycle_id);
      v_issue_id C_ISSUES_LIST%ROWTYPE;
      v_index NUMBER(38,0) := 1;
  BEGIN
    FOR v_issue_id IN c_issues_list LOOP
      V_ISSUES_LIST.EXTEND(1);
      v_issues_list(v_index) := v_issue_id.id;
      v_index := v_index + 1;
    END LOOP;

    RETURN v_issues_list;
  END get_bicycle_problems_reported;

  function get_user_borrow_history(user_id users.id%type, start_date date, end_date date) return user_borrow_history_list IS
  BEGIN
    RETURN user_borrow_history_list();
  END get_user_borrow_history;

  function get_price_history(start_date date, end_date date) return price_history_list IS
  BEGIN
    RETURN price_history_list();
  END get_price_history;
END CITY_RIDE_PACKAGE;

DECLARE
BEGIN
  --DELETE FROM issues;
  --COMMIT;
  --FIND_BICYCLES_MAINTENANCE();
  CITY_RIDE_PACKAGE.find_overdue_borrows();
END;
/
SELECT COUNT(*) FROM ISSUES "i";

SELECT CITY_RIDE_PACKAGE.find_overdue_borrows() FROM dual;
/
CREATE OR REPLACE PACKAGE BODY city_ride_login_package AS
  PROCEDURE create_account (FIRST_NAME VARCHAR2, LAST_NAME  VARCHAR2, EMAIL VARCHAR2, CNP VARCHAR2, ADDRESS VARCHAR2, PASSWORD VARCHAR2, CARD_NUMBER VARCHAR2, EXPIRATION_DATE DATE, CVV NUMBER)
  AS
    v_user_id NUMBER(38, 0);
  BEGIN
    -- TODO: adauga criptare la parola
    INSERT INTO USERS(FIRST_NAME, LAST_NAME, EMAIL, CNP, ADDRESS, PASSWORD, ROLE) VALUES (FIRST_NAME, LAST_NAME, EMAIL, TO_NUMBER(CNP),  ADDRESS, PASSWORD, 'user');
    COMMIT;

    SELECT id INTO v_user_id FROM USERS u WHERE u.email = EMAIL;

    INSERT INTO DEBIT_CARD(USER_ID, CARD_NUMBER, EXPIRATION_DATE, CVV) VALUES (v_user_id, TO_NUMBER(CARD_NUMBER), EXPIRATION_DATE, CVV);
    COMMIT;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
  END create_account;

  FUNCTION login (p_email VARCHAR2, p_password VARCHAR2)
  RETURN NUMBER IS
    v_count NUMBER;
    v_id NUMBER := -1;
  BEGIN
    -- TODO: adauga criptare la parola
    SELECT COUNT(*) INTO v_count FROM USERS u WHERE u.EMAIL = p_email AND u.PASSWORD = p_password;
    IF(v_count = 0) THEN
      RETURN V_ID;
    END IF;

    SELECT id INTO V_ID FROM USERS u WHERE u.EMAIL = p_email AND u.PASSWORD = p_password AND ROWNUM = 1;
    RETURN V_ID;
  END login;
end city_ride_login_package;
/
COMMIT;
/
CREATE OR REPLACE PACKAGE BODY CITY_RIDE_BORROW_PACKAGE AS
  PROCEDURE borrow_bicycle(p_user_id NUMBER, bicycle_qr_code VARCHAR2) AS
    v_user_count NUMBER(38,0);
    v_current_price_id NUMBER(38,0);
    v_bicycle_id NUMBER(38,0);
    v_status VARCHAR2(50);
  BEGIN
    SELECT COUNT(*) INTO V_USER_COUNT FROM BORROW b WHERE b.user_id = p_user_id AND B.END_DATE = NULL;
    IF(V_USER_COUNT = 0) THEN
        SELECT ID, STATUS INTO V_BICYCLE_ID, v_status FROM BICYCLES WHERE QR_CODE = bicycle_qr_code;
        SELECT ID INTO V_CURRENT_PRICE_ID FROM PRICES WHERE END_DATE IS NULL;
     
        IF(V_STATUS = 'available') THEN
          INSERT INTO BORROW (BICYCLE_ID, USER_ID, BORROW_DATE, END_DATE, PRICE_ID) VALUES (V_BICYCLE_ID, P_USER_ID, SYSDATE, NULL, V_CURRENT_PRICE_ID);
          UPDATE BICYCLES SET STATUS = 'borrowed' WHERE id = V_BICYCLE_ID;
          COMMIT;
        END IF;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
  END;

  FUNCTION check_borrow_bicycle(p_user_id NUMBER, bicycle_qr_code VARCHAR2) RETURN NUMBER IS
    v_result NUMBER(38, 0);
    V_BICYCLE_ID NUMBER(38, 0);
  BEGIN     
    SELECT ID INTO V_BICYCLE_ID FROM BICYCLES WHERE QR_CODE = bicycle_qr_code;
    SELECT COUNT(*) INTO V_RESULT FROM BORROW WHERE BICYCLE_ID = V_BICYCLE_ID AND USER_ID = p_user_id AND END_DATE is NULL;

    IF(V_RESULT != 0) THEN
      RETURN 1;
    END IF;

    RETURN 0;
  END;

  PROCEDURE return_bicycle(p_user_id NUMBER, p_point_id number) AS
    v_borrow_id NUMBER(38, 0);
    v_bicycle_id NUMBER(38, 0);
  BEGIN
    SELECT B.ID, B.BICYCLE_ID INTO V_BORROW_ID, v_bicycle_id FROM BORROW b WHERE B.USER_ID = P_USER_ID AND B.END_DATE IS NULL;
    UPDATE BORROW SET END_DATE = SYSDATE WHERE ID = V_BORROW_ID;
    UPDATE BICYCLES SET STATUS = 'available', POINT_ID = P_POINT_ID WHERE ID = V_BICYCLE_ID;
    COMMIT;
    EXCEPTION WHEN OTHERS THEN
      ROLLBACK;
  END;

  FUNCTION check_return_bicycle(p_user_id number) RETURN NUMBER AS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO V_COUNT FROM BORROW WHERE USER_ID = P_USER_ID AND END_DATE IS NULL;

    IF(V_COUNT > 0) THEN
      RETURN 1;
    END IF;
    RETURN V_COUNT;
  END;
END CITY_RIDE_BORROW_PACKAGE;
/

CREATE OR REPLACE PACKAGE BODY city_ride_crud_package as
  FUNCTION get_bicycle(p_user_id NUMBER) RETURN BICYCLES%ROWTYPE AS
    v_bicycle_id NUMBER(38,0);
    v_bicycle_information BICYCLES%ROWTYPE;
  BEGIN
    SELECT bicycle_id INTO V_BICYCLE_ID FROM BORROW WHERE USER_ID = P_USER_ID;
    SELECT * INTO V_BICYCLE_INFORMATION FROM BICYCLES WHERE id = V_BICYCLE_ID;

    RETURN V_BICYCLE_INFORMATION;
  END get_bicycle;
end city_ride_crud_package;
/
CREATE OR REPLACE function find_overdue_borrows return borrow_id_list IS
   cursor c_old_bicycles is 
        (SELECT ID FROM BORROW WHERE (CURRENT_TIMESTAMP(6) - BORROW_DATE) > INTERVAL '24' HOUR AND END_DATE is null);
  v_old_bicycles c_old_bicycles%ROWTYPE;

  v_return_list borrow_id_list := borrow_id_list();
  v_count INTEGER := 1;
BEGIN
  FOR v_old_bicycles IN c_old_bicycles LOOP
    v_return_list.EXTEND(1);
    v_return_list(v_count) := v_old_bicycles.id;
    v_count := v_count + 1;
  END LOOP;

  RETURN v_return_list;
END find_overdue_borrows;
/
  CREATE OR REPLACE function get_bicycle_problems_reported(p_bicycle_id number) return issues_list IS
     v_issues_list issues_list := issues_list();
     cursor c_issues_list IS 
        (SELECT ID FROM ISSUES WHERE bicycle_id = p_bicycle_id);
      v_issue_id C_ISSUES_LIST%ROWTYPE;
      v_index NUMBER(38,0) := 1;
  BEGIN
    FOR v_issue_id IN c_issues_list LOOP
      V_ISSUES_LIST.EXTEND(1);
      v_issues_list(v_index) := v_issue_id.id;
      v_index := v_index + 1;
    END LOOP;

    RETURN v_issues_list;
  END get_bicycle_problems_reported;
/
CREATE OR REPLACE PROCEDURE find_most_valueble_points IS
    v_to_return_list bicycle_id_list := bicycle_id_list();

    TYPE type_point_valueble IS TABLE OF NUMBER(5,2) INDEX BY BINARY_INTEGER;
    point_valueble type_point_valueble;
    cursor c_pickup_points is 
        (select id FROM PICKUP_POINTS);
    v_pickup_points c_pickup_points%ROWTYPE;
    v_date TIMESTAMP(6) := CURRENT_TIMESTAMP();
    v_date_start TIMESTAMP(6) := v_date - INTERVAL '1' MONTH ;
    v_count INTEGER;
    v_max INTEGER;
    v_value INTEGER;
  BEGIN
    DELETE FROM Valueable_pickup_points;
    COMMIT;

      FOR v_pickup_points IN c_pickup_points LOOP
        
          SELECT COUNT(*) INTO v_value FROM MOVE_BICYCLE WHERE FROM_POINT_ID = v_pickup_points.id OR TO_POINT_ID = v_pickup_points.id;
          INSERT INTO VALUEABLE_PICKUP_POINTS (PICKUP_POINT_ID, value) VALUES (v_pickup_points.id, v_value);
          COMMIT;
      END LOOP;
  END find_most_valueble_points;
/
  EXEC find_most_valueble_points;
/

CREATE TABLE Valueable_pickup_points (
  ID NUMBER(38,0)  GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  pickup_point_id NUMBER(38, 0),
  VALUE NUMBER(38, 0),

  PRIMARY KEY (id)

);
COMMIT;
