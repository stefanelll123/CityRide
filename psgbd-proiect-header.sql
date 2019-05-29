l
  CREATE OR REPLACE TYPE issues_list IS table OF number;


  CREATE OR REPLACE TYPE borrow_id_list IS table OF NUMBER;  

CREATE OR REPLACE PACKAGE city_ride_package as
  TYPE bicycle_id_list IS table OF bicycles.id%type;
  TYPE borrow_id_list IS table OF borrow.id%type;  
  TYPE pickup_point_id_list IS table OF pickup_points.id%type;
  
  TYPE price_history IS RECORD (p_value number, p_date date);
  TYPE price_history_list IS TABLE OF price_history;
  
  TYPE user_borrow_history IS RECORD (p_times number, p_date date);
  TYPE user_borrow_history_list IS TABLE OF user_borrow_history;

  function get_next_id(tableName varchar2) return number;
  FUNCTION compare_sererities(severity1 VARCHAR2, severity2 VARCHAR2) RETURN NUMBER;
  
  procedure send_bibycle_notification(textNotification varchar2, severity varchar2, bicycleId number);
  procedure find_old_bicycles;
  procedure find_bicycles_maintenance;
  
  function find_most_valueble_points(v_count_return integer) return bicycle_id_list;
  function find_overdue_borrows return borrow_id_list;
  function check_pickup_points_balance return pickup_point_id_list;
  
  function calculates_paid(borrow_id borrow.id%type) return number;
  
  function get_bicycle_problems_reported(p_bicycle_id number) return issues_list;
  function get_user_borrow_history(user_id users.id%type, start_date date, end_date date) return user_borrow_history_list;
  function get_price_history(start_date date, end_date date) return price_history_list;
end city_ride_package;
/
CREATE OR REPLACE PACKAGE city_ride_crud_package as
end city_ride_crud_package;
/
CREATE OR REPLACE PACKAGE city_ride_login_package as
  PROCEDURE create_account (FIRST_NAME VARCHAR2, LAST_NAME  VARCHAR2, EMAIL VARCHAR2, CNP varchar2, ADDRESS VARCHAR2, PASSWORD VARCHAR2, CARD_NUMBER varchar2, EXPIRATION_DATE DATE, CVV NUMBER);
  FUNCTION login (p_email VARCHAR2, p_password VARCHAR2) RETURN NUMBER;
end city_ride_login_package;
/
CREATE OR REPLACE 
TRIGGER insert_move_bicycle
  BEFORE UPDATE OF point_id ON bicycles FOR EACH ROW
  DECLARE
    v_bicycle_id NUMBER(38, 0);
    v_from_point_id NUMBER(38, 0);
    v_to_point_id NUMBER(38, 0);
    v_move_date TIMESTAMP(6);
  BEGIN
    v_bicycle_id := :OLD.id;
    v_from_point_id := :OLD.point_id;
    v_to_point_id := :NEW.point_id;
    v_move_date := CURRENT_TIMESTAMP();
    
    INSERT INTO move_bicycle (bicycle_id, from_point_id, to_point_id, move_date) VALUES (v_bicycle_id, v_from_point_id, v_to_point_id, v_move_date);
  END insert_move_bicycle;
/
CREATE OR REPLACE PACKAGE CITY_RIDE_BORROW_PACKAGE AS
  PROCEDURE borrow_bicycle(p_user_id NUMBER, bicycle_qr_code VARCHAR2);
  FUNCTION check_borrow_bicycle(p_user_id NUMBER, bicycle_qr_code VARCHAR2) RETURN NUMBER;
  PROCEDURE return_bicycle(p_user_id number, p_point_id number);
  FUNCTION check_return_bicycle(p_user_id number) RETURN NUMBER;
END CITY_RIDE_BORROW_PACKAGE;

