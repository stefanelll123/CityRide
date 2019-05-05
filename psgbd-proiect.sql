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

create or replace procedure getOutBicycle as
begin
  
end scoateBicicletaDinUz;

alter table ISSUES
  modify BORROW_ID NUMBER(38,0) null;
  
create or replace procedure sendNotification(textNotification varchar2) as
begin
end sendNotification;