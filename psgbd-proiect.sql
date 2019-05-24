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
          (SELECT ID FROM BORROW WHERE (CURRENT_TIMESTAMP(6) - BORROW_DATE) > INTERVAL '24' HOUR AND END_DATE = null);
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
  BEGIN
    RETURN 1;
  END calculates_paid;

  function check_if_can_be_borrow(bicycle_id bicycles.id%type) return boolean IS
  BEGIN
    RETURN true;
  END check_if_can_be_borrow;
  
  function get_bicycle_problems_reported(user_id users.id%type, bicycle_id bicycles.id%type) return issues_list IS
  BEGIN
    RETURN issues_list();
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


