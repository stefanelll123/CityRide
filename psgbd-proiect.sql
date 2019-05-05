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

create or replace procedure getOutBicycle as
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
end getOutBicycle;

begin
  getOutBicycle;
end;


select count(*) from issues;
select id, months_between(sysdate, REGISTER_DATE)/12 as years from bicycles where months_between(sysdate, REGISTER_DATE)/12  >= 2;









-- In cazul in care ai deja date in tabela
alter table ISSUES
  modify BORROW_ID NUMBER(38,0) null
  add bicycle_id NUMBER(38,0)
  add constraint FK_ISSUES_BICYCLE_ID_BICYCLE foreign key (bicycle_id)
	  references bicycles (id) enable;














