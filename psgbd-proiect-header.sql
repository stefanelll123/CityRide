CREATE OR REPLACE PACKAGE city_ride_package as
  TYPE bicycle_id_list IS table OF bicycles.id%type;
  TYPE borrow_id_list IS table OF borrow.id%type;  
  TYPE pickup_point_id_list IS table OF pickup_points.id%type;
  TYPE issues_list IS table OF issues.id%type;
  
  TYPE price_history IS RECORD (p_value number, p_date date);
  TYPE price_history_list IS TABLE OF price_history;
  
  TYPE user_borrow_history IS RECORD (p_times number, p_date date);
  TYPE user_borrow_history_list IS TABLE OF user_borrow_history;

  function getNextId(tableName varchar2) return number;
  
  procedure sendBibycleNotification(textNotification varchar2, severity varchar2, bicycleId number);
  procedure findOldBicycles;
  procedure findBicyclesNeededMaintenance;
  
  function findMostValueblePickupPoints return bicycle_id_list;
  function findOverdueBorrows return borrow_id_list;
  function checkPickupPointsBalance return pickup_point_id_list;
  
  function calculatesTheAMountToBePaid(borrow_id borrow.id%type) return number;
  function checkIfAbicycleCanBeBorrow(bicycle_id bicycles.id%type) return boolean;
  
  function getBicycleProblemsReported(user_id users.id%type, bicycle_id bicycles.id%type) return issues_list;
  function getUserBorrowHistory(user_id users.id%type, start_date date, end_date date) return 
  function getPriceHistory(start_date date, end_date date) return price_history_list;
end city_ride_package;