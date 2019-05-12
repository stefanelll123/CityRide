drop table DEBIT_CARD;
drop table ISSUES;
drop table BORROW;
drop table BICYCLES;
drop table PICKUP_POINTS;
drop table USERS;
drop table PRICES;


CREATE TABLE PRICES (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  value number(10,2) not null enable,
  start_date timestamp not null enable,
  end_date timestamp,
  
  PRIMARY KEY (id)
);
/
--insert into prices (value, start_date, end_date) values (15, sysdate, null);

CREATE TABLE USERS (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  first_name varchar2(32) not null enable,
  last_name varchar2(32) not null enable,
  email varchar2(100) not null enable,
  cnp number(13, 0) not null enable,
  address varchar2(200) not null enable,
  password varchar2(40) not null enable,
  role varchar2(20),
  
  PRIMARY KEY (id),
  constraint ck_valid_role check (role in ('user', 'admin')),
  constraint email_unique unique (email),
  constraint ck_valid_email check (email like '%@%.%'),
  constraint ck_valid_cnp check ((cnp like '1%' or cnp like '2%' or cnp like '5%' or cnp like '6%') and length(cnp) = 13)
);
/
--insert into users (address, cnp, first_name, last_name, email, password, role)
--  values ('aaa', 1234567897654, 'Ion', 'Ion', 'email2@yahoo.cpm', 'aaa', 'user');
--/
--insert into users (address, cnp, first_name, last_name, email, password, role)
--  values ('aaa', 1234567897654, 'Ion', 'Ion', 'email1@yahoo.cpm', 'aaa', 'user');

CREATE TABLE pickup_points (
  id number GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  name varchar2(32) NOT NULL,
  address varchar2(200) NOT NULL,
  slots number(38, 0) NOT NULL,
  available_slots number(38, 0) NOT NULL,
  
  PRIMARY KEY (id),
  CONSTRAINT check_valid_slots check (available_slots <= slots)
);
/
create table BICYCLES (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),  
  qr_code varchar2(2000) not null enable,
  register_date timestamp not null enable,
  status varchar2(20) not null enable,
  point_id number(38, 0),
  
  primary key (id),  
  constraint FK_BICYCLE_ID_PICK_POINT foreign key (point_id)
	  references pickup_points (id) enable,
  constraint CK_STATUS_ENUM check (status in ('available', 'broken', 'borrowed'))
);
/
CREATE TABLE BORROW (
  id number(38, 0)  GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  bicycle_id number(38, 0) not null,
  user_id number(38, 0) not null,
  borrow_date timestamp not null,
  end_date timestamp,
  price_id number(3, 0) not null,
  
  PRIMARY KEY (id),  
  constraint FK_BORROW_BICYCLE_ID foreign key (bicycle_id)
	  references BICYCLES(id),
  constraint FK_BORROW_USER_ID foreign key (user_id)
      references USERS(id),
  constraint FK_BORROW_PRICE_ID foreign key (price_id)
	  references PRICES(id)
);
/
create table ISSUES (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  registration_date timestamp          not null enable,
  description       varchar2(250)      not null enable,
  severity          varchar2(50)       not null enable,
  borrow_id         number(38, 0),
  bicycle_id        number(38, 0),
  type_issue        varchar2(50)       default 'report',  
  STATUS            NVARCHAR2(50)      DEFAULT 'none',
  
  primary key (id),
  constraint CK_SEVERITY_ENUM check (severity in ('low', 'medium', 'major', 'critical')),  
  constraint FK_ISSUES_ID_BICYCLE foreign key (borrow_id)
	  references borrow (id) enable,  
  constraint FK_ISSUES_BICYCLE_ID_BICYCLE foreign key (bicycle_id)
	  references bicycles (id) enable,       
  constraint CK_type_issue_ENUM check (type_issue in ('report', 'notification_mentenance', 'notification', 'time expired'))
);
/
CREATE TABLE DEBIT_CARD (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  user_id number(38, 0) not null enable ,
  card_number number(16, 0) not null enable,
  expiration_date date not null enable,
  cvv number(3, 0) not null enable,
  
  PRIMARY KEY (id),  
  constraint ck_valid_card_number check (length(card_number) = 16),
  constraint ck_valid_cvc check (length(cvv) = 3),
  constraint FK_DEBIT_CARD_ID_USER foreign key (user_id)
	  references users (id) enable
);
/
CREATE TABLE MOVE_BICYCLE (
  id number(38, 0) GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
  bicycle_id NUMBER(38, 0) NOT NULL,
  from_point_id NUMBER(38, 0) NOT NULL,
  to_point_id NUMBER(38, 0) NOT NULL,
  move_date TIMESTAMP(6) NOT NULL,

  PRIMARY KEY (id),  
  constraint FK_MOVE_BICYCLE foreign key (bicycle_id)
	  references bicycles (id) ENABLE,    
  constraint FK_MOVE_POINT_1 foreign key (from_point_id)
	  references pickup_points (id) ENABLE,    
  constraint FK_MOVE_POINT_2 foreign key (to_point_id)
	  references pickup_points (id) enable
);
/
-- populare baza de date
set serveroutput on;
create or replace procedure detele_all_from_database as
begin
  DBMS_OUTPUT.PUT_LINE('Stergem inregistrarile din toate tabelele aflate in baza de date.');
  delete from MOVE_BICYCLE;
  delete from DEBIT_CARD;
  delete from ISSUES;
  delete from BORROW;
  delete from BICYCLES;
  delete from PICKUP_POINTS;
  delete from USERS;
  delete from PRICES;
end detele_all_from_database;
/
begin
  detele_all_from_database;
end;
/
create or replace 
procedure populate_prices(p_number_of_inserts integer) as
  v_curent_date timestamp := sysdate;
  v_start_date timestamp;
  v_end_date timestamp;
  v_value number(10, 2);
begin
  DBMS_OUTPUT.PUT_LINE('Populam tabela PRICES.');
  
    v_end_date := v_curent_date - numtodsinterval(dbms_random.value(0, 9537467), 'MINUTE');
         
  for i in 1..p_number_of_inserts loop
    v_start_date := v_end_date;
    v_end_date := v_end_date + dbms_random.value(0, 56); -- dureza maxim un an un pret
    v_value := trunc(dbms_random.value(5.00, 25.00), 2);
    
    insert into prices (value, start_date, end_date) values (v_value, v_start_date, v_end_date);
  end loop;
    v_value := trunc(dbms_random.value(5.00, 25.00), 2);
    insert into prices (value, start_date, end_date) values (v_value, v_end_date, null);
end populate_prices;
/
create or replace 
procedure populate_debit_card(user_id number) as 
  v_card_number number(16, 0);
  v_card_number_first number(17, 0);
  v_card_number_second number(17, 0);
  v_cvv number(3, 0);
  v_expiration_date date;
  v_count integer;
begin
      <<generate_card>>
      v_card_number_first := to_number(to_char(dbms_random.value(10000000, 99999999)));      
      v_card_number_second := to_number(to_char(dbms_random.value(10000000, 99999999)));
      v_card_number := to_number(v_card_number_second || v_card_number_first);
      
      select * into v_count from (select count(*) from debit_card where card_number = v_card_number);
      if(v_count > 0) then
        goto generate_card;
      end if;
      
      v_cvv := dbms_random.value(100, 999);
      
      v_expiration_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2019-01-01', 'J'), TO_CHAR(sysdate + 14*365, 'J'))), 'J');
    
    insert into debit_card (user_id, card_number, expiration_date, cvv) values (user_id, v_card_number, v_expiration_date, v_cvv);
    commit;
end populate_debit_card;
/
create or replace 
procedure populate_users(p_number_of_inserts integer) as  
  TYPE lista IS VARRAY(1000) OF varchar2(50);
  v_lista_nume lista := lista('Popescu', 'Ionescu', 'Popa', 'Pop', 'Ni??', 'Ni?u', 'Constantinescu', 'Stan', 'Stanciu', 'Dumitrescu', 'Dima', 'Gheorghiu', 'Ioni??', 'Marin', 'Tudor', 'Dobre', 'Barbu', 'Nistor', 'Florea', 'Fr??il?', 'Dinu', 'Dinescu', 'Georgescu', 'Stoica', 'Diaconu', 'Diaconescu', 'Mocanu', 'Voinea', 'Albu', 'Petrescu', 'Manole', 'Cristea', 'Toma', 'St?nescu', 'Pu?ca?u', 'Tomescu', 'Sava', 'Ciobanu', 'Rusu', 'Ursu', 'Lupu', 'Munteanu', 'Mehedin?u', 'Andreescu', 'Sava', 'Mih?ilescu', 'Iancu', 'Blaga', 'Teodoru', 'Teodorescu', 'Moise', 'Moisescu', 'C?linescu', 'Tabacu');
  v_lista_prenume lista := lista('Ana-Maria', 'Alexandru', 'Mihaela', 'Andreea', 'Elena', 'Adrian', 'Andrei', 'Alexandra', 'Mihai', 'Ionut', 'Cristina', 'Florin', 'Daniel', 'Marian', 'Marius', 'Cristian', 'Daniela', 'Alina', 'Maria', 'Ioana', 'Constantin', 'Nicoleta', 'Georgiana', 'Mariana', 'Bogdan', 'Vasile', 'Gabriel', 'Gabriela', 'Nicolae', 'Gheorghe', 'George', 'Ioan', 'Valentin', 'Adriana', 'Ionela', 'Catalin', 'Stefan', 'Ion', 'Florentina', 'Anca', 'Anamaria', 'Simona', 'Iulian', 'Roxana', 'Oana', 'Irina', 'Diana', 'Mirela', 'Iuliana', 'Madalina', 'Raluca', 'Ionel', 'Lucian', 'Cosmin', 'Sorin', 'Loredana', 'Claudia', 'Monica', 'Ramona', 'Dumitru', 'Ana', 'Ciprian', 'Corina', 'Laura', 'Vlad', 'Razvan', 'Radu', 'Liliana', 'Valentina', 'Viorel', 'Iulia', 'Ovidiu', 'Florina', 'Robert', 'Catalina', 'Carmen', 'Claudiu', 'Alin', 'Oana-Maria', 'Camelia', 'Andreea-Elena', 'Dan', 'Costel', 'Alina-Elena', 'Elena-Cristina', 'Mircea', 'Laurentiu', 'Georgeta', 'Maria-Cristina', 'Paul', 'Alina-Maria', 'Dragos', 'Silviu', 'Andreea-Maria', 'Adina', 'Attila', 'Liviu', 'Petru', 'Cristina-Elena', 'Vasilica', 'Victor', 'Alina-Mihaela', 'Ileana', 'Silvia', 'Veronica', 'Marinela', 'Cristina-Maria', 'Rodica', 'Anca-Maria', 'Violeta', 'Roxana-Elena', 'Zoltan', 'Alexandra-Maria', 'Ioana-Alexandra', 'Ancuta', 'Alexandru-Ionut', 'Viorica', 'Sergiu', 'Ionut-Alexandru', 'Zsolt', 'Ioana-Maria', 'Andreea-Cristina', 'Emilia', 'Timea', 'Mihai-Alexandru', 'Istvan', 'Andreea-Mihaela', 'Teodora', 'Elena-Alina', 'Eugen', 'Luminita', 'Cornelia', 'Maria-Magdalena', 'Maria-Alexandra', 'Levente', 'Lavinia', 'Elena-Andreea');
  v_lista_roluri lista := lista('user', 'admin');
  v_lista_parole lista := lista('123456', 'password', '12345678', 'qwerty', '123456789', '12345', '1234', '111111', '1234567', 'dragon', '123123', 'baseball', 'abc123', 'football', 'monkey', 'letmein', '696969', 'shadow', 'master', '666666', 'qwertyuiop', '123321', 'mustang', '1234567890', 'michael', '654321', 'pussy', 'superman', '1qaz2wsx', '7777777', 'fuckyou', '121212', '000000', 'qazwsx', '123qwe', 'killer', 'trustno1', 'jordan', 'jennifer', 'zxcvbnm', 'asdfgh', 'hunter', 'buster', 'soccer', 'harley', 'batman', 'andrew', 'tigger', 'sunshine', 'iloveyou', 'fuckme', '2000', 'charlie', 'robert', 'thomas', 'hockey', 'ranger', 'daniel', 'starwars', 'klaster', '112233', 'george', 'asshole', 'computer', 'michelle', 'jessica', 'pepper', '1111', 'zxcvbn', '555555', '11111111', '131313', 'freedom', '777777', 'pass', 'fuck', 'maggie', '159753', 'aaaaaa', 'ginger', 'princess', 'joshua', 'cheese', 'amanda', 'summer', 'love', 'ashley', '6969', 'nicole', 'chelsea', 'biteme', 'matthew', 'access', 'yankees', '987654321', 'dallas', 'austin', 'thunder', 'taylor', 'matrix', 'william', 'corvette', 'hello', 'martin', 'heather', 'secret', 'fucker', 'merlin', 'diamond', '1234qwer', 'gfhjkm', 'hammer', 'silver', '222222', '88888888', 'anthony', 'justin', 'test', 'bailey', 'q1w2e3r4t5', 'patrick', 'internet', 'scooter', 'orange', '11111', 'golfer', 'cookie', 'richard', 'samantha', 'bigdog', 'guitar', 'jackson', 'whatever', 'mickey', 'chicken', 'sparky', 'snoopy', 'maverick', 'phoenix', 'camaro', 'sexy', 'peanut', 'morgan', 'welcome', 'falcon', 'cowboy', 'ferrari', 'samsung', 'andrea', 'smokey', 'steelers', 'joseph', 'mercedes', 'dakota', 'arsenal', 'eagles', 'melissa', 'boomer', 'booboo', 'spider', 'nascar', 'monster', 'tigers', 'yellow', 'xxxxxx', '123123123', 'gateway', 'marina', 'diablo', 'bulldog', 'qwer1234', 'compaq', 'purple', 'hardcore', 'banana', 'junior', 'hannah', '123654', 'porsche', 'lakers', 'iceman', 'money', 'cowboys', '987654', 'london', 'tennis', '999999', 'ncc1701', 'coffee', 'scooby', '0000', 'miller', 'boston', 'q1w2e3r4', 'fuckoff', 'brandon', 'yamaha', 'chester', 'mother', 'forever', 'johnny', 'edward', '333333', 'oliver', 'redsox', 'player', 'nikita', 'knight', 'fender', 'barney', 'midnight', 'please', 'brandy', 'chicago', 'badboy', 'iwantu', 'slayer', 'rangers', 'charles', 'angel', 'flower', 'bigdaddy', 'rabbit', 'wizard', 'bigdick', 'jasper', 'enter', 'rachel', 'chris', 'steven', 'winner', 'adidas', 'victoria', 'natasha', '1q2w3e4r', 'jasmine', 'winter', 'prince', 'panties', 'marine', 'ghbdtn', 'fishing', 'cocacola', 'casper', 'james', '232323', 'raiders', '888888', 'marlboro', 'gandalf', 'asdfasdf', 'crystal', '87654321', '12344321', 'sexsex', 'golden', 'blowme', 'bigtits', '8675309', 'panther', 'lauren', 'angela', 'bitch', 'spanky', 'thx1138', 'angels', 'madison', 'winston', 'shannon', 'mike', 'toyota', 'blowjob', 'jordan23', 'canada', 'sophie', 'Password', 'apples', 'dick', 'tiger', 'razz', '123abc', 'pokemon', 'qazxsw', '55555', 'qwaszx', 'muffin', 'johnson', 'murphy');
  v_lista_orase lista := lista('Abrud', 'Adjud', 'Agnita', 'Aiud', 'Alba Iulia', 'Ale?d', 'Alexandria', 'Amara', 'Anina', 'Aninoasa', 'Arad', 'Ardud', 'Avrig', 'Azuga', 'Babadag', 'B?beni', 'Bac?u', 'Baia de Aram?', 'Baia de Arie?', 'Baia Mare', 'Baia Sprie', 'B?icoi', 'B?ile Govora', 'B?ile Herculane', 'B?ile Ol?ne?ti', 'B?ile Tu?nad', 'B?ile?ti', 'B?lan', 'B?lce?ti', 'Bal?', 'Baraolt', 'Bârlad', 'Bechet', 'Beclean', 'Beiu?', 'Berbe?ti', 'Bere?ti', 'Bicaz', 'Bistri?a', 'Blaj', 'Boc?a', 'Bolde?ti-Sc?eni', 'Bolintin-Vale', 'Bor?a', 'Borsec', 'Boto?ani', 'Brad', 'Bragadiru', 'Br?ila', 'Bra?ov', 'Breaza', 'Brezoi', 'Bro?teni', 'Bucecea', 'Bucure?ti', 'Bude?ti', 'Buftea', 'Buhu?i', 'Bumbe?ti-Jiu', 'Bu?teni', 'Buz?u', 'Buzia?', 'Cajvana', 'Calafat', 'C?lan', 'C?l?ra?i', 'C?lim?ne?ti', 'Câmpeni', 'Câmpia Turzii', 'Câmpina', 'Câmpulung Moldovenesc', 'Câmpulung', 'Caracal', 'Caransebe?', 'Carei', 'Cavnic', 'C?z?ne?ti', 'Cehu Silvaniei', 'Cernavod?', 'Chi?ineu-Cri?', 'Chitila', 'Ciacova', 'Cisn?die', 'Cluj-Napoca', 'Codlea', 'Com?ne?ti', 'Comarnic', 'Constan?a', 'Cop?a Mic?', 'Corabia', 'Coste?ti', 'Covasna', 'Craiova', 'Cristuru Secuiesc', 'Cugir', 'Curtea de Arge?', 'Curtici', 'D?buleni', 'Darabani', 'D?rm?ne?ti', 'Dej', 'Deta', 'Deva', 'Dolhasca', 'Dorohoi', 'Dr?g?ne?ti-Olt', 'Dr?g??ani', 'Dragomire?ti', 'Drobeta-Turnu Severin', 'Dumbr?veni', 'Eforie', 'F?g?ra?', 'F?get', 'F?lticeni', 'F?urei', 'Fete?ti', 'Fieni', 'Fierbin?i-Târg', 'Filia?i', 'Fl?mânzi', 'Foc?ani', 'Frasin', 'Fundulea', 'G?e?ti', 'Gala?i', 'G?taia', 'Geoagiu', 'Gheorgheni', 'Gherla', 'Ghimbav', 'Giurgiu', 'Gura Humorului', 'Hârl?u', 'Hâr?ova', 'Ha?eg', 'Horezu', 'Huedin', 'Hunedoara', 'Hu?i', 'Ianca', 'Ia?i', 'Iernut', 'Ineu', 'Însur??ei', 'Întorsura Buz?ului', 'Isaccea', 'Jibou', 'Jimbolia', 'Lehliu Gar?', 'Lipova', 'Liteni', 'Livada', 'Ludu?', 'Lugoj', 'Lupeni', 'M?cin', 'M?gurele', 'Mangalia', 'M?r??e?ti', 'Marghita', 'Medgidia', 'Media?', 'Miercurea Ciuc', 'Miercurea Nirajului', 'Miercurea Sibiului', 'Mih?ile?ti', 'Mili??u?i', 'Mioveni', 'Mizil', 'Moine?ti', 'Moldova Nou?', 'Moreni', 'Motru', 'Murfatlar', 'Murgeni', 'N?dlac', 'N?s?ud', 'N?vodari', 'Negre?ti', 'Negre?ti-Oa?', 'Negru Vod?', 'Nehoiu', 'Novaci', 'Nucet', 'Ocna Mure?', 'Ocna Sibiului', 'Ocnele Mari', 'Odobe?ti', 'Odorheiu Secuiesc', 'Olteni?a', 'One?ti', 'Oradea', 'Or??tie', 'Oravi?a', 'Or?ova', 'O?elu Ro?u', 'Otopeni', 'Ovidiu', 'Panciu', 'Pâncota', 'Pantelimon', 'Pa?cani', 'P?târlagele', 'Pecica', 'Petrila', 'Petro?ani', 'Piatra Neam?', 'Piatra-Olt', 'Pite?ti', 'Ploie?ti', 'Plopeni', 'Podu Iloaiei', 'Pogoanele', 'Pope?ti-Leordeni', 'Potcoava', 'Predeal', 'Pucioasa', 'R?cari', 'R?d?u?i', 'Râmnicu S?rat', 'Râmnicu Vâlcea', 'Râ?nov', 'Reca?', 'Reghin', 'Re?i?a', 'Roman', 'Ro?iorii de Vede', 'Rovinari', 'Roznov', 'Rupea', 'S?cele', 'S?cueni', 'Salcea', 'S?li?te', 'S?li?tea de Sus', 'Salonta', 'Sângeorgiu de P?dure', 'Sângeorz-B?i', 'Sânnicolau Mare', 'Sântana', 'S?rma?u', 'Satu Mare', 'S?veni', 'Scornice?ti', 'Sebe?', 'Sebi?', 'Segarcea', 'Seini', 'Sfântu Gheorghe', 'Sibiu', 'Sighetu Marma?iei', 'Sighi?oara', 'Simeria', '?imleu Silvaniei', 'Sinaia', 'Siret', 'Sl?nic', 'Sl?nic-Moldova', 'Slatina', 'Slobozia', 'Solca', '?omcuta Mare', 'Sovata', '?tef?ne?ti, Arge?', '?tef?ne?ti, Boto?ani', '?tei', 'Strehaia', 'Suceava', 'Sulina', 'T?lmaciu', '??nd?rei', 'Târgovi?te', 'Târgu Bujor', 'Târgu C?rbune?ti', 'Târgu Frumos', 'Târgu Jiu', 'Târgu L?pu?', 'Târgu Mure?', 'Târgu Neam?', 'Târgu Ocna', 'Târgu Secuiesc', 'Târn?veni', 'T??nad', 'T?u?ii-M?gher?u?', 'Techirghiol', 'Tecuci', 'Teiu?', '?icleni', 'Timi?oara', 'Tismana', 'Titu', 'Topli?a', 'Topoloveni', 'Tulcea', 'Turceni', 'Turda', 'Turnu M?gurele', 'Ulmeni', 'Ungheni', 'Uricani', 'Urla?i', 'Urziceni', 'Valea lui Mihai', 'V?lenii de Munte', 'Vânju Mare', 'Va?c?u', 'Vaslui', 'Vatra Dornei', 'Vicovu de Sus', 'Victoria', 'Videle', 'Vi?eu de Sus', 'Vl?hi?a', 'Voluntari', 'Vulcan', 'Zal?u', 'Z?rne?ti', 'Zimnicea', 'Zlatna');
  v_lista_strazi lista := lista('Alee Alecsandri Vasile', 'Alee Basarabi', 'Alee Canta', 'Alee Copou', 'Alee Ghica Grigore Voda', 'Alee Mircea cel Batran', 'Alee Nicolina', 'Alee Parcului', 'Alee Plopii fara Sot', 'Alee Rozelor', 'Alee Spital Pascanu', 'Alee Trandafirilor', 'Bulevard Alexandru cel Bun', 'Bulevard Dacia', 'Bulevard Iorga Nicolae', 'Bulevard Poitiers', 'Bulevard Socola', 'Bulevard Vladimirescu Tudor', 'Fundac 40 Sfinti', 'Fundac Balusescu', 'Fundac Bucovinei', 'Fundac Catargi Lascar', 'Fundac Dancinescu', 'Fundac Dragos Voda', 'Fundac Ferentz', 'Fundac Ispirescu Petre', 'Fundac Mielului', 'Fundac Moara de Vant', 'Fundac Olari', 'Fundac Pietrariei', 'Fundac Racovita Emil', 'Fundac Sararie', 'Fundac Sf. Vasile', 'Fundac Strugurilor', 'Fundac Trei Ierarhi', 'Fundac Zaverei', 'Pasaj Muzicescu Gavril', 'Piata Garii', 'Piata Stefan cel Mare si Sfant', 'Platou Abator', 'Sosea Barnova', 'Sosea Galata', 'Sosea Manta Rosie', 'Sosea Neculai Tudor', 'Sosea Rediu', 'Sosea Voinesti', 'Strada 14 Decembrie 1989', 'Strada Aeroportului', 'Strada Alba Iulia', 'Strada Alecsandri Vasile', 'Strada Alistar', 'Strada Andrei Petre', 'Strada Arbore Luca', 'Strada Armeana', 'Strada Asachi Gheorghe', 'Strada Aterizaj', 'Strada Avionului', 'Strada Bacalu Iancu', 'Strada Baltii', 'Strada Bancii', 'Strada Barboi', 'Strada Barnovschi', 'Strada Bas Ceaus', 'Strada Beldiceanu Nicolae', 'Strada Berthelot, g-ral', 'Strada Boiangiu', 'Strada Bradetului', 'Strada Brates', 'Strada Breazu', 'Strada Bucovinei', 'Strada Bularga', 'Strada Buridava', 'Strada Buzescu', 'Strada Calarasi', 'Strada Cantacuzino Dumitrascu', 'Strada Capsunilor', 'Strada Caraman Petru', 'Strada Carlig', 'Strada Catargi Lascar', 'Strada Cazimir Otilia', 'Strada Cerna', 'Strada Cihac Iosif', 'Strada Ciric', 'Strada Ciusmeaua Pacurari', 'Strada Columnei', 'Strada Conta Vasile', 'Strada Costin Nicolae', 'Strada Crihan Anton', 'Strada Crivat', 'Strada Cupidon', 'Strada Dacia', 'Strada De Nord', 'Strada Dealul Zorilor', 'Strada Delfini', 'Strada Dimitrescu Toma, g-ral', 'Strada Donos', 'Strada Draghici Manolache', 'Strada Duca Voda', 'Strada Egalitatii', 'Strada Enescu George', 'Strada Fagului', 'Strada Fericirii', 'Strada Florea', 'Strada Folescu Marchian', 'Strada Fratilor', 'Strada Frunzei', 'Strada Galateanu', 'Strada Gane Nicolae', 'Strada Ghica Grigore Voda', 'Strada Golia', 'Strada Gradinari', 'Strada Halipa Pantelimon', 'Strada Hasdeu B. Petriceicu', 'Strada Holboca', 'Strada Hotin', 'Strada Icoanei', 'Strada Ignat', 'Strada Ion Grigore, serg.', 'Strada Iosif Stefan Octavian', 'Strada Ispirescu Petre', 'Strada Izbandei', 'Strada Kogalniceanu Mihail', 'Strada Lascar Gheorghe', 'Strada Lotrului', 'Strada Luterana', 'Strada Macedoniei', 'Strada Maiorescu Titu', 'Strada Manolescu', 'Strada Marasesti', 'Strada Marta', 'Strada Meteor', 'Strada Mihai Voda Viteazul', 'Strada Minervei', 'Strada Miron Costin', 'Strada Misai', 'Strada Mitropolit Veniamin Costache', 'Strada Mocanului', 'Strada Mosu', 'Strada Movilei', 'Strada Musatini', 'Strada Muzicii', 'Strada Neculau', 'Strada Negri Costache', 'Strada Niceman', 'Strada Nisipari', 'Strada Oastei', 'Strada Ogorului', 'Strada Olt', 'Strada Orientului', 'Strada Ovidiu', 'Strada Pacureti', 'Strada Pallady Theodor', 'Strada Panu Anastasie', 'Strada Patria', 'Strada Pavlov I. P.', 'Strada Petru Rares', 'Strada Pictorului', 'Strada Plaiesilor', 'Strada Plopii fara Sot', 'Strada Podoleanu', 'Strada Poetului', 'Strada Pojarniciei', 'Strada Pompieri', 'Strada Popauti', 'Strada Porumbului', 'Strada Rachiti', 'Strada Rafael', 'Strada Rampei', 'Strada Rapei', 'Strada Razoarelor', 'Strada Roadelor', 'Strada Roman Voda', 'Strada Rosiori', 'Strada Russo Alecu', 'Strada Sambetei', 'Strada Sarmisegetuza', 'Strada Savini, Dr.', 'Strada Semanatorului', 'Strada Sesan A., prof.', 'Strada Sf. Atanasiei', 'Strada Sf. Ioan', 'Strada Sf. Teodor', 'Strada Simionescu I. I.', 'Strada Soarelui', 'Strada Spancioc', 'Strada Stanciu', 'Strada Stihii', 'Strada Stramosilor', 'Strada Stroici', 'Strada Sucidava', 'Strada Tacuta', 'Strada Talpalari', 'Strada Teodoreanu Al. O.', 'Strada Ticaul de Jos', 'Strada Tomida, cpt.', 'Strada Transilvaniei', 'Strada Trei Ierarhi', 'Strada Tufescu', 'Strada Ungheni', 'Strada Ureche Grigore', 'Strada Uzinei', 'Strada Vamasoaia', 'Strada Varlaam, Mitropolit', 'Strada Venerei', 'Strada Vicol N., dr.', 'Strada Virgiliu', 'Strada Viticultori', 'Strada Vlahuta Alexandru', 'Strada Vovideniei', 'Strada Xenopol A.', 'Strada Zidari', 'Strada Zmeu', 'Stradela Adunati', 'Stradela Barboi', 'Stradela Bucsinescu', 'Stradela Caramidari', 'Stradela Cicoarei', 'Stradela Copou', 'Stradela Florilor', 'Stradela Harhas', 'Stradela Iosif Stefan Octavian', 'Stradela Langa, col.', 'Stradela Manta Rosie', 'Stradela Moara de Vant', 'Stradela Paun', 'Stradela Poienilor', 'Stradela Sararie', 'Stradela Sf. Andrei', 'Stradela Sf. Gheorghe', 'Stradela Spinti', 'Stradela Uzinei', 'Trecere Alpilor', 'Trecere Cazimir Otilia', 'Trecere Davidel', 'Trecere Fantanilor', 'Trecere Mincu Ion, arh.', 'Trecere Paun', 'Trecere Transeului', '', 'Alee Alexa Gheorghe, prof. dr. ing.', 'Alee Basota', 'Alee Cimitirul Evreiesc', 'Alee Decebal', 'Alee Gradinari', 'Alee Musatini', 'Alee Oltea Doamna', 'Alee Petrescu Vasile, prof. dr. doc.', 'Alee Poni Petru', 'Alee Sadoveanu Mihail', 'Alee Strugurilor', 'Alee Uzinei', 'Bulevard Carol I', 'Bulevard Dimitrie Cantemir', 'Bulevard Mangeron Dimitrie, prof. dr. doc.', 'Bulevard Primaverii', 'Bulevard Stefan cel Mare si Sfant', 'Cale Chisinaului', 'Fundac Armeana', 'Fundac Boiangiu', 'Fundac Calarasi', 'Fundac Cocoarei', 'Fundac Delfini', 'Fundac Elena Doamna', 'Fundac Florentz', 'Fundac Kogalniceanu Mihail', 'Fundac Mircea', 'Fundac Muntenimii', 'Fundac Paun', 'Fundac Plopii fara Sot', 'Fundac Ralet Dimitrie', 'Fundac Sf. Andrei', 'Fundac Sipotel', 'Fundac Tanasescu', 'Fundac Ursulea', 'Fundac Zlataust', 'Piata 14 Decembrie 1989', 'Piata Halei', 'Piata Unirii', 'Sosea Albinet', 'Sosea Bucium', 'Sosea Iasi-Ciurea', 'Sosea Moara de Foc', 'Sosea Nicolina', 'Sosea Sararie', 'Splai Bahlui Mal Drept', 'Strada Abrahamfi', 'Strada Agricultori', 'Strada Albinelor', 'Strada Alexandrescu Emil', 'Strada Alunis', 'Strada Apelor', 'Strada Arcu', 'Strada Armoniei', 'Strada Atelierului', 'Strada Aurora', 'Strada Azilului', 'Strada Bacinschi', 'Strada Balusescu', 'Strada Bancila Octav, pictor', 'Strada Barbu Lautaru', 'Strada Barnutiu Simion', 'Strada Basarabi', 'Strada Belvedere', 'Strada Bistrita', 'Strada Borcea', 'Strada Bradului', 'Strada Bratianu I.C.', 'Strada Brudea', 'Strada Bucur', 'Strada Buna Vestire', 'Strada Busuioc', 'Strada Buznea', 'Strada Calugareni', 'Strada Cantacuzino G.M., arh.', 'Strada Caragiale I. L.', 'Strada Caramidari', 'Strada Carpati', 'Strada Cazangiilor', 'Strada Ceahlau', 'Strada Cetatuia', 'Strada Ciornei', 'Strada Cismeaua lui Butuc', 'Strada Clopotari', 'Strada Cometa', 'Strada Cosbuc George', 'Strada Cozma Toma', 'Strada Cristofor', 'Strada Cucu', 'Strada Curelari', 'Strada Dancinescu', 'Strada Dealul Bucium', 'Strada Decebal', 'Strada Deliu', 'Strada Dochia', 'Strada Dorobanti', 'Strada Dragos Voda', 'Strada Dudescu', 'Strada Elena Doamna', 'Strada Eternitate', 'Strada Fantanilor', 'Strada Fierbinte', 'Strada Florilor', 'Strada Fragilor', 'Strada Friederick', 'Strada Fulger', 'Strada Galbeni', 'Strada Garii', 'Strada Ghioceilor', 'Strada Gospodari', 'Strada Graniceri', 'Strada Han Tatar', 'Strada Heliade', 'Strada Horga', 'Strada Iarmaroc', 'Strada Iepurilor', 'Strada Imas', 'Strada Ion Paul, prof.', 'Strada Ipsilanti Alexandru Voda', 'Strada Istrati N.', 'Strada Izvor', 'Strada Lacului', 'Strada Leon N., dr.', 'Strada Luminei', 'Strada Macarescu Nicolae', 'Strada Magurei', 'Strada Malu', 'Strada Manta Rosie', 'Strada Marasti', 'Strada Masinii', 'Strada Micsunelelor', 'Strada Milcov', 'Strada Mioritei', 'Strada Mironescu I. I.', 'Strada Mistretului', 'Strada Mizil', 'Strada Moldovei', 'Strada Motilor', 'Strada Munteni', 'Strada Mustea, cronicar', 'Strada Namoloasa', 'Strada Neculce Ion', 'Strada Negustori', 'Strada Nicolina', 'Strada Noua', 'Strada Obreja', 'Strada Oituz', 'Strada Olteniei', 'Strada Ornescu', 'Strada Pacii', 'Strada Padurii', 'Strada Pantel', 'Strada Parcului', 'Strada Paulescu, dr.', 'Strada Penes Curcanul', 'Strada Petru Schiopu', 'Strada Pietrariei', 'Strada Plantelor', 'Strada Podgoriilor', 'Strada Podu de Piatra', 'Strada Pogor Vasile', 'Strada Poligon', 'Strada Poni Petru', 'Strada Popescu Eremia, mr.', 'Strada Potcoavei', 'Strada Racovita Emil', 'Strada Ralet Dimitrie', 'Strada Randunica', 'Strada Rascanu Teodor', 'Strada Rece', 'Strada Roata Ion', 'Strada Romana', 'Strada Rovine', 'Strada Sadoveanu Mihail', 'Strada Sapte Oameni', 'Strada Saulescu Gheorghe', 'Strada Scaricica', 'Strada Semnului', 'Strada Sevastopol', 'Strada Sf. Constantin', 'Strada Sf. Lazar', 'Strada Sf. Vasile', 'Strada Sipotel', 'Strada Soficu', 'Strada Spinti', 'Strada Stejar', 'Strada Stindardului', 'Strada Strapungere Silvestru', 'Strada Strugurilor', 'Strada Sulfinei', 'Strada Tafrali Orest, prof.', 'Strada Tanasescu', 'Strada Teodoreanu Ionel', 'Strada Timpului', 'Strada Toparceanu George', 'Strada Trantomir', 'Strada Trofeelor', 'Strada Turcu', 'Strada Universitatii', 'Strada Urechia Vasile', 'Strada Valea Adanca', 'Strada Vanatori', 'Strada Vascauteanu', 'Strada Veniamin Costache', 'Strada Viespei', 'Strada Visan', 'Strada Vladiceni', 'Strada Vlaicu Aurel', 'Strada Vulpe', 'Strada Zarafi', 'Strada Zimbrului', 'Strada Zorilor', 'Stradela Armeana', 'Stradela Barbu Lautaru', 'Stradela Canta', 'Stradela Cazangiilor', 'Stradela Ciric', 'Stradela Dealul Bucium', 'Stradela Galateanu', 'Stradela Inculet Ion, prof.', 'Stradela Ipsilanti Alexandru Voda', 'Stradela Luminei', 'Stradela Mironescu I. I.', 'Stradela Nicorita', 'Stradela Perju', 'Stradela Primaverii', 'Stradela Savescu Toma', 'Stradela Sf. Atanasiei', 'Stradela Sf. Stefan', 'Stradela Stefan cel Mare si Sfant', 'Stradela Vantu', 'Trecere Bravilor', 'Trecere Ciobanului', 'Trecere Doamnei', 'Trecere Hotin', 'Trecere Nucului', 'Trecere Podgoriilor', 'Trecere Trei Ierarhi', '', 'Alee Atanasiu Dimitrie, prof. dr. ing.', 'Alee Bucium', 'Alee Columnei', 'Alee Dumbrava Rosie', 'Alee Micle Veronica', 'Alee Neculai Tudor', 'Alee Pacurari', 'Alee Plaiesilor', 'Alee Procopiu Stefan', 'Alee Simionescu I. I.', 'Alee Sucidava', 'Alee Vitejilor', 'Bulevard Chimiei', 'Bulevard Independentei', 'Bulevard Metalurgiei', 'Bulevard Rosetti C. A.', 'Bulevard Tutora', 'Cale Galata', 'Fundac Aurora', 'Fundac Bucium', 'Fundac Caramidari', 'Fundac Codrescu Teodor', 'Fundac Dochia', 'Fundac Eternitate', 'Fundac Gandu', 'Fundac Maracineanu Valter', 'Fundac Mitocul Maicilor', 'Fundac Muzicescu Gavril', 'Fundac Perjoaia', 'Fundac Pralea', 'Fundac Salciilor', 'Fundac Sf. Teodor', 'Fundac Socola', 'Fundac Tanjala', 'Fundac Vantu', 'Pasaj Cuza Voda', 'Piata Eminescu Mihai', 'Piata Natiunii', 'Piata Voievozilor', 'Sosea Arcu', 'Sosea Carlig', 'Sosea Iasi-Tomesti', 'Sosea Nationala', 'Sosea Pacurari', 'Sosea Stefan cel Mare si Sfant', 'Splai Bahlui Mal Stang', 'Strada Adunati', 'Strada Alba', 'Strada Albinet', 'Strada Alexandru Lapusneanu', 'Strada Amurgului', 'Strada Arapului', 'Strada Arges', 'Strada Aroneanu', 'Strada Ateneului', 'Strada Aviatiei', 'Strada Babes Victor', 'Strada Balcescu Nicolae', 'Strada Banat', 'Strada Banu', 'Strada Bariera Veche', 'Strada Barsescu Agatha', 'Strada Basota', 'Strada Berindei Ioan, arh.', 'Strada Bogdan Voda', 'Strada Botez Octav', 'Strada Brandusa', 'Strada Bratului', 'Strada Bucium', 'Strada Bujor Paul', 'Strada Burada Teodor', 'Strada Butnari', 'Strada Calafat', 'Strada Canta', 'Strada Caprelor', 'Strada Caraiman', 'Strada Caranda, lt.', 'Strada Casin', 'Strada Cazarmilor', 'Strada Cerchez', 'Strada Cicoarei', 'Strada Ciresica', 'Strada Ciurchi', 'Strada Codrescu Teodor', 'Strada Conductelor', 'Strada Costachescu Mihai', 'Strada Creanga Ion', 'Strada Crisului', 'Strada Cujba Petru, prof.', 'Strada Cuza Voda', 'Strada Dancu', 'Strada Dealul Galata', 'Strada Delavrancea Barbu Stefanescu', 'Strada Dezrobirii', 'Strada Doja Gheorghe', 'Strada Dorojinca', 'Strada Drobeta', 'Strada Dumbrava Rosie', 'Strada Eminescu Mihai', 'Strada Fagetului', 'Strada Fatu Anastasie', 'Strada Flammarion Camile', 'Strada Fluturilor', 'Strada Franta', 'Strada Frumoasa', 'Strada Functionarilor', 'Strada Gandu', 'Strada Ghibanescu Gheorghe', 'Strada Gloriei', 'Strada Grabovenschi', 'Strada Greerul', 'Strada Hanciuc', 'Strada Hlincea', 'Strada Horia', 'Strada Ibraileanu Garabet', 'Strada Iernii', 'Strada Inculet Ion, prof.', 'Strada Ionescu, lt.', 'Strada Islaz', 'Strada Italiana', 'Strada Jelea', 'Strada Langa, col.', 'Strada Libertatii', 'Strada Lupitei', 'Strada Macazului', 'Strada Mahu', 'Strada Manastirii', 'Strada Maracineanu Valter', 'Strada Marginei', 'Strada Mayer Octav', 'Strada Mihai Radu', 'Strada Millo Matei', 'Strada Mircea cel Batran', 'Strada Miroslava', 'Strada Mitropoliei', 'Strada Moara de Vant', 'Strada Morilor', 'Strada Movila Pacureti', 'Strada Muntenimii', 'Strada Muzicescu Gavril', 'Strada Naniescu Iosif, mitropolit', 'Strada Negel Gheorghe, lt.', 'Strada Neptun', 'Strada Nicorita', 'Strada Oancea', 'Strada Occident', 'Strada Olari', 'Strada Orfelinatului', 'Strada Otelari', 'Strada Pacurari', 'Strada Palat', 'Strada Pantelimon', 'Strada Pastorului', 'Strada Paun', 'Strada Perju', 'Strada Philippide, prof.', 'Strada Pinului', 'Strada Plevnei', 'Strada Podisului', 'Strada Podul Inalt', 'Strada Poienilor', 'Strada Pompei', 'Strada Ponoarelor', 'Strada Popovici, lt.', 'Strada Protopopescu, cpt.', 'Strada Radu Voda', 'Strada Ramadan Constantin', 'Strada Rapa Galbena', 'Strada Razboieni', 'Strada Rediu', 'Strada Rojnita', 'Strada Roscani', 'Strada Rufeni', 'Strada Salciilor', 'Strada Sararie', 'Strada Savescu Toma', 'Strada Scoalei', 'Strada Sendrea, Hatman', 'Strada Sf. Andrei', 'Strada Sf. Gheorghe', 'Strada Sf. Sava', 'Strada Silvestru', 'Strada Smardan', 'Strada Sorogari', 'Strada Spital Pascanu', 'Strada Stere Constantin, prof.', 'Strada Stoicescu, lt.', 'Strada Stroescu Vasile', 'Strada Sturdza Mihai', 'Strada Tabacului', 'Strada Taietoarei', 'Strada Tatarasi', 'Strada Tepes Voda', 'Strada Toamnei', 'Strada Traian', 'Strada Trei Fantani', 'Strada Trompeta', 'Strada Tutea Petre', 'Strada Urcusului', 'Strada Ursulea', 'Strada Valeni', 'Strada Vantu', 'Strada Vasile Lupu', 'Strada Verdes', 'Strada Viitor', 'Strada Vitejilor', 'Strada Vladimirescu Tudor', 'Strada Voinicilor', 'Strada Vulturilor', 'Strada Zborului', 'Strada Zlataust', 'Strada Zugravi', 'Stradela Baltii', 'Stradela Berindei Ioan, arh.', 'Stradela Caprelor', 'Stradela Cetatuia', 'Stradela Clopotari', 'Stradela Elena Doamna', 'Stradela Gradinari', 'Stradela Ionescu de la Brad Ion', 'Stradela Italiana', 'Stradela Macazului', 'Stradela Mizil', 'Stradela Pacureti', 'Stradela Plopii fara Sot', 'Stradela Rediu', 'Stradela Scaricica', 'Stradela Sf. Constantin', 'Stradela Silvestru', 'Stradela Trei Ierarhi', 'Stradela Vladimirescu Tudor', 'Trecere Bucsinescu', 'Trecere Corbului', 'Trecere Duzilor', 'Trecere Leului', 'Trecere Oitelor', 'Trecere Pricop');
  
  v_nume varchar2(64);
  v_prenume varchar2(64);
  v_email varchar2(80);
  v_password varchar2(64);
  v_role varchar2(20);
  v_adresa varchar2(200);
  v_cnp number(13,0);
  v_random integer;
  v_random_date date;
  v_strada varchar2(200);
  v_oras varchar2(64);
  v_numar number(38,0);
begin
  for i in 1..p_number_of_inserts loop
    v_nume := v_lista_nume(TRUNC(DBMS_RANDOM.VALUE(0,v_lista_nume.count))+1);
    v_prenume := v_lista_prenume(TRUNC(DBMS_RANDOM.VALUE(0,v_lista_prenume.count))+1);
    v_password := v_lista_parole(TRUNC(DBMS_RANDOM.VALUE(0,v_lista_parole.count))+1);

    v_random :=DBMS_RANDOM.VALUE(0,999);   
    if (v_random < 10) then
      v_role := 'admin';
    else
      v_role := 'user'; 
    end if;
    
    <<generate_email>>
    v_random := DBMS_RANDOM.VALUE(0,99);
    if (v_random > 15 and v_random < 74) then
      v_email := v_nume || '.' || substr(v_prenume, 0, 15) || '@gmail.com';
    else
      if(v_random < 15) then        
        v_email := v_nume || '.' || substr(v_prenume, 0, 15) || '@info.ro';
      else        
        v_email := substr(v_prenume, 0, 15) || '_' || v_nume || to_char(DBMS_RANDOM.VALUE(0,999)) || '@yahoo.ro';
      end if;  
    end if;
    v_email := lower(v_email);
    
    select * into v_numar from (select count(*) from users where email = v_email);
    if(v_numar > 0) then
      goto generate_email;
    end if;

    if(v_prenume like '%a') then
      v_random :=DBMS_RANDOM.VALUE(1,2);
      if(v_random = 1) then
        v_cnp := 2;
      else      
        v_cnp := 6;
      end if;     
    else
      v_random :=DBMS_RANDOM.VALUE(1,2);
      if(v_random = 1) then
        v_cnp := 1;
      else      
        v_cnp := 5;
      end if;
    end if;
    v_random_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '1940-01-01', 'J'), TO_CHAR(sysdate - 14*365, 'J'))), 'J');
    v_cnp := to_number(v_cnp || to_char(v_random_date, 'DDMMYYYY') || DBMS_RANDOM.VALUE(1000, 9999));
    
    v_strada := v_lista_strazi(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_strazi.count))+1);
    v_oras := v_lista_orase(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_orase.count))+1);
    v_numar := DBMS_RANDOM.VALUE(1, 999);
    
    v_adresa := v_strada || ', Nr. ' || v_numar || ' ' || v_oras;
    
    insert into users (address, cnp, first_name, last_name, email, password, role) 
        values (v_adresa, v_cnp, v_nume, v_prenume, v_email, v_password, v_role);
    commit;
    select * into v_numar from (select id from users where email = v_email);
    if(v_role = 'user') then
      populate_debit_card(v_numar);
    else      
      v_random :=DBMS_RANDOM.VALUE(1,100);
      if(v_random < 25) then      
        populate_debit_card(v_numar);
      end if;
    end if;
  end loop;
 
end populate_users;
/
create or replace 
procedure populate_pickup_ponts(p_number_of_inserts integer) as
  TYPE lista IS VARRAY(1000) OF varchar2(50);
  v_lista_nume lista := lista('Gaephenon', 'Flakkeovion', 'Maseorus', 'Kiossagoth', 'Veaclamos', 'The Dormant World', 'The Hell Reach', 'The Night Realm', 'The Hibernating Planet', 'The Shivering Isles', 'Kriototria', 'Jeojarah', 'Uyocion', 'Jaettariel', 'Ioppitha', 'The Twilight Vales', 'The Living Realms', 'The Monster Lands', 'The Conjured Vales', 'The Transient Vales', 'Cleodiasos', 'Phittuspea', 'Eostrioryon', 'Stioleasos', 'Meclodu', 'The Severed Isles', 'The Mist Sanctuary', 'The Mammoth Realms', 'The Single Earth', 'The All Land', 'Konnadore', 'Uhotha', 'Bravomel', 'Issiovion', 'Grahirune', 'The Ageless Territories', 'The Winter Earth', 'The Ancient Realm', 'The Feral Plane', 'The Slumbering Territories', 'Izicion', 'Miagrother', 'Socregana', 'Blaejotara', 'Igreotopia', 'The Onyx Yonder', 'The Eclipse Reach', 'The Patriarch Sanctuary', 'The Flowing Earth', 'The Autumn Realms', 'Siagludell', 'Pakkolas', 'Gogleotis', 'Kleamerus', 'Stusinium', 'The Paralyzed Moon', 'The Nimbus World', 'The Miniature Universe', 'The Injured Sea', 'The Double Isle');
  v_lista_orase lista := lista('Abrud', 'Adjud', 'Agnita', 'Aiud', 'Alba Iulia', 'Ale?d', 'Alexandria', 'Amara', 'Anina', 'Aninoasa', 'Arad', 'Ardud', 'Avrig', 'Azuga', 'Babadag', 'B?beni', 'Bac?u', 'Baia de Aram?', 'Baia de Arie?', 'Baia Mare', 'Baia Sprie', 'B?icoi', 'B?ile Govora', 'B?ile Herculane', 'B?ile Ol?ne?ti', 'B?ile Tu?nad', 'B?ile?ti', 'B?lan', 'B?lce?ti', 'Bal?', 'Baraolt', 'Bârlad', 'Bechet', 'Beclean', 'Beiu?', 'Berbe?ti', 'Bere?ti', 'Bicaz', 'Bistri?a', 'Blaj', 'Boc?a', 'Bolde?ti-Sc?eni', 'Bolintin-Vale', 'Bor?a', 'Borsec', 'Boto?ani', 'Brad', 'Bragadiru', 'Br?ila', 'Bra?ov', 'Breaza', 'Brezoi', 'Bro?teni', 'Bucecea', 'Bucure?ti', 'Bude?ti', 'Buftea', 'Buhu?i', 'Bumbe?ti-Jiu', 'Bu?teni', 'Buz?u', 'Buzia?', 'Cajvana', 'Calafat', 'C?lan', 'C?l?ra?i', 'C?lim?ne?ti', 'Câmpeni', 'Câmpia Turzii', 'Câmpina', 'Câmpulung Moldovenesc', 'Câmpulung', 'Caracal', 'Caransebe?', 'Carei', 'Cavnic', 'C?z?ne?ti', 'Cehu Silvaniei', 'Cernavod?', 'Chi?ineu-Cri?', 'Chitila', 'Ciacova', 'Cisn?die', 'Cluj-Napoca', 'Codlea', 'Com?ne?ti', 'Comarnic', 'Constan?a', 'Cop?a Mic?', 'Corabia', 'Coste?ti', 'Covasna', 'Craiova', 'Cristuru Secuiesc', 'Cugir', 'Curtea de Arge?', 'Curtici', 'D?buleni', 'Darabani', 'D?rm?ne?ti', 'Dej', 'Deta', 'Deva', 'Dolhasca', 'Dorohoi', 'Dr?g?ne?ti-Olt', 'Dr?g??ani', 'Dragomire?ti', 'Drobeta-Turnu Severin', 'Dumbr?veni', 'Eforie', 'F?g?ra?', 'F?get', 'F?lticeni', 'F?urei', 'Fete?ti', 'Fieni', 'Fierbin?i-Târg', 'Filia?i', 'Fl?mânzi', 'Foc?ani', 'Frasin', 'Fundulea', 'G?e?ti', 'Gala?i', 'G?taia', 'Geoagiu', 'Gheorgheni', 'Gherla', 'Ghimbav', 'Giurgiu', 'Gura Humorului', 'Hârl?u', 'Hâr?ova', 'Ha?eg', 'Horezu', 'Huedin', 'Hunedoara', 'Hu?i', 'Ianca', 'Ia?i', 'Iernut', 'Ineu', 'Însur??ei', 'Întorsura Buz?ului', 'Isaccea', 'Jibou', 'Jimbolia', 'Lehliu Gar?', 'Lipova', 'Liteni', 'Livada', 'Ludu?', 'Lugoj', 'Lupeni', 'M?cin', 'M?gurele', 'Mangalia', 'M?r??e?ti', 'Marghita', 'Medgidia', 'Media?', 'Miercurea Ciuc', 'Miercurea Nirajului', 'Miercurea Sibiului', 'Mih?ile?ti', 'Mili??u?i', 'Mioveni', 'Mizil', 'Moine?ti', 'Moldova Nou?', 'Moreni', 'Motru', 'Murfatlar', 'Murgeni', 'N?dlac', 'N?s?ud', 'N?vodari', 'Negre?ti', 'Negre?ti-Oa?', 'Negru Vod?', 'Nehoiu', 'Novaci', 'Nucet', 'Ocna Mure?', 'Ocna Sibiului', 'Ocnele Mari', 'Odobe?ti', 'Odorheiu Secuiesc', 'Olteni?a', 'One?ti', 'Oradea', 'Or??tie', 'Oravi?a', 'Or?ova', 'O?elu Ro?u', 'Otopeni', 'Ovidiu', 'Panciu', 'Pâncota', 'Pantelimon', 'Pa?cani', 'P?târlagele', 'Pecica', 'Petrila', 'Petro?ani', 'Piatra Neam?', 'Piatra-Olt', 'Pite?ti', 'Ploie?ti', 'Plopeni', 'Podu Iloaiei', 'Pogoanele', 'Pope?ti-Leordeni', 'Potcoava', 'Predeal', 'Pucioasa', 'R?cari', 'R?d?u?i', 'Râmnicu S?rat', 'Râmnicu Vâlcea', 'Râ?nov', 'Reca?', 'Reghin', 'Re?i?a', 'Roman', 'Ro?iorii de Vede', 'Rovinari', 'Roznov', 'Rupea', 'S?cele', 'S?cueni', 'Salcea', 'S?li?te', 'S?li?tea de Sus', 'Salonta', 'Sângeorgiu de P?dure', 'Sângeorz-B?i', 'Sânnicolau Mare', 'Sântana', 'S?rma?u', 'Satu Mare', 'S?veni', 'Scornice?ti', 'Sebe?', 'Sebi?', 'Segarcea', 'Seini', 'Sfântu Gheorghe', 'Sibiu', 'Sighetu Marma?iei', 'Sighi?oara', 'Simeria', '?imleu Silvaniei', 'Sinaia', 'Siret', 'Sl?nic', 'Sl?nic-Moldova', 'Slatina', 'Slobozia', 'Solca', '?omcuta Mare', 'Sovata', '?tef?ne?ti, Arge?', '?tef?ne?ti, Boto?ani', '?tei', 'Strehaia', 'Suceava', 'Sulina', 'T?lmaciu', '??nd?rei', 'Târgovi?te', 'Târgu Bujor', 'Târgu C?rbune?ti', 'Târgu Frumos', 'Târgu Jiu', 'Târgu L?pu?', 'Târgu Mure?', 'Târgu Neam?', 'Târgu Ocna', 'Târgu Secuiesc', 'Târn?veni', 'T??nad', 'T?u?ii-M?gher?u?', 'Techirghiol', 'Tecuci', 'Teiu?', '?icleni', 'Timi?oara', 'Tismana', 'Titu', 'Topli?a', 'Topoloveni', 'Tulcea', 'Turceni', 'Turda', 'Turnu M?gurele', 'Ulmeni', 'Ungheni', 'Uricani', 'Urla?i', 'Urziceni', 'Valea lui Mihai', 'V?lenii de Munte', 'Vânju Mare', 'Va?c?u', 'Vaslui', 'Vatra Dornei', 'Vicovu de Sus', 'Victoria', 'Videle', 'Vi?eu de Sus', 'Vl?hi?a', 'Voluntari', 'Vulcan', 'Zal?u', 'Z?rne?ti', 'Zimnicea', 'Zlatna');
  v_lista_strazi lista := lista('Alee Alecsandri Vasile', 'Alee Basarabi', 'Alee Canta', 'Alee Copou', 'Alee Ghica Grigore Voda', 'Alee Mircea cel Batran', 'Alee Nicolina', 'Alee Parcului', 'Alee Plopii fara Sot', 'Alee Rozelor', 'Alee Spital Pascanu', 'Alee Trandafirilor', 'Bulevard Alexandru cel Bun', 'Bulevard Dacia', 'Bulevard Iorga Nicolae', 'Bulevard Poitiers', 'Bulevard Socola', 'Bulevard Vladimirescu Tudor', 'Fundac 40 Sfinti', 'Fundac Balusescu', 'Fundac Bucovinei', 'Fundac Catargi Lascar', 'Fundac Dancinescu', 'Fundac Dragos Voda', 'Fundac Ferentz', 'Fundac Ispirescu Petre', 'Fundac Mielului', 'Fundac Moara de Vant', 'Fundac Olari', 'Fundac Pietrariei', 'Fundac Racovita Emil', 'Fundac Sararie', 'Fundac Sf. Vasile', 'Fundac Strugurilor', 'Fundac Trei Ierarhi', 'Fundac Zaverei', 'Pasaj Muzicescu Gavril', 'Piata Garii', 'Piata Stefan cel Mare si Sfant', 'Platou Abator', 'Sosea Barnova', 'Sosea Galata', 'Sosea Manta Rosie', 'Sosea Neculai Tudor', 'Sosea Rediu', 'Sosea Voinesti', 'Strada 14 Decembrie 1989', 'Strada Aeroportului', 'Strada Alba Iulia', 'Strada Alecsandri Vasile', 'Strada Alistar', 'Strada Andrei Petre', 'Strada Arbore Luca', 'Strada Armeana', 'Strada Asachi Gheorghe', 'Strada Aterizaj', 'Strada Avionului', 'Strada Bacalu Iancu', 'Strada Baltii', 'Strada Bancii', 'Strada Barboi', 'Strada Barnovschi', 'Strada Bas Ceaus', 'Strada Beldiceanu Nicolae', 'Strada Berthelot, g-ral', 'Strada Boiangiu', 'Strada Bradetului', 'Strada Brates', 'Strada Breazu', 'Strada Bucovinei', 'Strada Bularga', 'Strada Buridava', 'Strada Buzescu', 'Strada Calarasi', 'Strada Cantacuzino Dumitrascu', 'Strada Capsunilor', 'Strada Caraman Petru', 'Strada Carlig', 'Strada Catargi Lascar', 'Strada Cazimir Otilia', 'Strada Cerna', 'Strada Cihac Iosif', 'Strada Ciric', 'Strada Ciusmeaua Pacurari', 'Strada Columnei', 'Strada Conta Vasile', 'Strada Costin Nicolae', 'Strada Crihan Anton', 'Strada Crivat', 'Strada Cupidon', 'Strada Dacia', 'Strada De Nord', 'Strada Dealul Zorilor', 'Strada Delfini', 'Strada Dimitrescu Toma, g-ral', 'Strada Donos', 'Strada Draghici Manolache', 'Strada Duca Voda', 'Strada Egalitatii', 'Strada Enescu George', 'Strada Fagului', 'Strada Fericirii', 'Strada Florea', 'Strada Folescu Marchian', 'Strada Fratilor', 'Strada Frunzei', 'Strada Galateanu', 'Strada Gane Nicolae', 'Strada Ghica Grigore Voda', 'Strada Golia', 'Strada Gradinari', 'Strada Halipa Pantelimon', 'Strada Hasdeu B. Petriceicu', 'Strada Holboca', 'Strada Hotin', 'Strada Icoanei', 'Strada Ignat', 'Strada Ion Grigore, serg.', 'Strada Iosif Stefan Octavian', 'Strada Ispirescu Petre', 'Strada Izbandei', 'Strada Kogalniceanu Mihail', 'Strada Lascar Gheorghe', 'Strada Lotrului', 'Strada Luterana', 'Strada Macedoniei', 'Strada Maiorescu Titu', 'Strada Manolescu', 'Strada Marasesti', 'Strada Marta', 'Strada Meteor', 'Strada Mihai Voda Viteazul', 'Strada Minervei', 'Strada Miron Costin', 'Strada Misai', 'Strada Mitropolit Veniamin Costache', 'Strada Mocanului', 'Strada Mosu', 'Strada Movilei', 'Strada Musatini', 'Strada Muzicii', 'Strada Neculau', 'Strada Negri Costache', 'Strada Niceman', 'Strada Nisipari', 'Strada Oastei', 'Strada Ogorului', 'Strada Olt', 'Strada Orientului', 'Strada Ovidiu', 'Strada Pacureti', 'Strada Pallady Theodor', 'Strada Panu Anastasie', 'Strada Patria', 'Strada Pavlov I. P.', 'Strada Petru Rares', 'Strada Pictorului', 'Strada Plaiesilor', 'Strada Plopii fara Sot', 'Strada Podoleanu', 'Strada Poetului', 'Strada Pojarniciei', 'Strada Pompieri', 'Strada Popauti', 'Strada Porumbului', 'Strada Rachiti', 'Strada Rafael', 'Strada Rampei', 'Strada Rapei', 'Strada Razoarelor', 'Strada Roadelor', 'Strada Roman Voda', 'Strada Rosiori', 'Strada Russo Alecu', 'Strada Sambetei', 'Strada Sarmisegetuza', 'Strada Savini, Dr.', 'Strada Semanatorului', 'Strada Sesan A., prof.', 'Strada Sf. Atanasiei', 'Strada Sf. Ioan', 'Strada Sf. Teodor', 'Strada Simionescu I. I.', 'Strada Soarelui', 'Strada Spancioc', 'Strada Stanciu', 'Strada Stihii', 'Strada Stramosilor', 'Strada Stroici', 'Strada Sucidava', 'Strada Tacuta', 'Strada Talpalari', 'Strada Teodoreanu Al. O.', 'Strada Ticaul de Jos', 'Strada Tomida, cpt.', 'Strada Transilvaniei', 'Strada Trei Ierarhi', 'Strada Tufescu', 'Strada Ungheni', 'Strada Ureche Grigore', 'Strada Uzinei', 'Strada Vamasoaia', 'Strada Varlaam, Mitropolit', 'Strada Venerei', 'Strada Vicol N., dr.', 'Strada Virgiliu', 'Strada Viticultori', 'Strada Vlahuta Alexandru', 'Strada Vovideniei', 'Strada Xenopol A.', 'Strada Zidari', 'Strada Zmeu', 'Stradela Adunati', 'Stradela Barboi', 'Stradela Bucsinescu', 'Stradela Caramidari', 'Stradela Cicoarei', 'Stradela Copou', 'Stradela Florilor', 'Stradela Harhas', 'Stradela Iosif Stefan Octavian', 'Stradela Langa, col.', 'Stradela Manta Rosie', 'Stradela Moara de Vant', 'Stradela Paun', 'Stradela Poienilor', 'Stradela Sararie', 'Stradela Sf. Andrei', 'Stradela Sf. Gheorghe', 'Stradela Spinti', 'Stradela Uzinei', 'Trecere Alpilor', 'Trecere Cazimir Otilia', 'Trecere Davidel', 'Trecere Fantanilor', 'Trecere Mincu Ion, arh.', 'Trecere Paun', 'Trecere Transeului', '', 'Alee Alexa Gheorghe, prof. dr. ing.', 'Alee Basota', 'Alee Cimitirul Evreiesc', 'Alee Decebal', 'Alee Gradinari', 'Alee Musatini', 'Alee Oltea Doamna', 'Alee Petrescu Vasile, prof. dr. doc.', 'Alee Poni Petru', 'Alee Sadoveanu Mihail', 'Alee Strugurilor', 'Alee Uzinei', 'Bulevard Carol I', 'Bulevard Dimitrie Cantemir', 'Bulevard Mangeron Dimitrie, prof. dr. doc.', 'Bulevard Primaverii', 'Bulevard Stefan cel Mare si Sfant', 'Cale Chisinaului', 'Fundac Armeana', 'Fundac Boiangiu', 'Fundac Calarasi', 'Fundac Cocoarei', 'Fundac Delfini', 'Fundac Elena Doamna', 'Fundac Florentz', 'Fundac Kogalniceanu Mihail', 'Fundac Mircea', 'Fundac Muntenimii', 'Fundac Paun', 'Fundac Plopii fara Sot', 'Fundac Ralet Dimitrie', 'Fundac Sf. Andrei', 'Fundac Sipotel', 'Fundac Tanasescu', 'Fundac Ursulea', 'Fundac Zlataust', 'Piata 14 Decembrie 1989', 'Piata Halei', 'Piata Unirii', 'Sosea Albinet', 'Sosea Bucium', 'Sosea Iasi-Ciurea', 'Sosea Moara de Foc', 'Sosea Nicolina', 'Sosea Sararie', 'Splai Bahlui Mal Drept', 'Strada Abrahamfi', 'Strada Agricultori', 'Strada Albinelor', 'Strada Alexandrescu Emil', 'Strada Alunis', 'Strada Apelor', 'Strada Arcu', 'Strada Armoniei', 'Strada Atelierului', 'Strada Aurora', 'Strada Azilului', 'Strada Bacinschi', 'Strada Balusescu', 'Strada Bancila Octav, pictor', 'Strada Barbu Lautaru', 'Strada Barnutiu Simion', 'Strada Basarabi', 'Strada Belvedere', 'Strada Bistrita', 'Strada Borcea', 'Strada Bradului', 'Strada Bratianu I.C.', 'Strada Brudea', 'Strada Bucur', 'Strada Buna Vestire', 'Strada Busuioc', 'Strada Buznea', 'Strada Calugareni', 'Strada Cantacuzino G.M., arh.', 'Strada Caragiale I. L.', 'Strada Caramidari', 'Strada Carpati', 'Strada Cazangiilor', 'Strada Ceahlau', 'Strada Cetatuia', 'Strada Ciornei', 'Strada Cismeaua lui Butuc', 'Strada Clopotari', 'Strada Cometa', 'Strada Cosbuc George', 'Strada Cozma Toma', 'Strada Cristofor', 'Strada Cucu', 'Strada Curelari', 'Strada Dancinescu', 'Strada Dealul Bucium', 'Strada Decebal', 'Strada Deliu', 'Strada Dochia', 'Strada Dorobanti', 'Strada Dragos Voda', 'Strada Dudescu', 'Strada Elena Doamna', 'Strada Eternitate', 'Strada Fantanilor', 'Strada Fierbinte', 'Strada Florilor', 'Strada Fragilor', 'Strada Friederick', 'Strada Fulger', 'Strada Galbeni', 'Strada Garii', 'Strada Ghioceilor', 'Strada Gospodari', 'Strada Graniceri', 'Strada Han Tatar', 'Strada Heliade', 'Strada Horga', 'Strada Iarmaroc', 'Strada Iepurilor', 'Strada Imas', 'Strada Ion Paul, prof.', 'Strada Ipsilanti Alexandru Voda', 'Strada Istrati N.', 'Strada Izvor', 'Strada Lacului', 'Strada Leon N., dr.', 'Strada Luminei', 'Strada Macarescu Nicolae', 'Strada Magurei', 'Strada Malu', 'Strada Manta Rosie', 'Strada Marasti', 'Strada Masinii', 'Strada Micsunelelor', 'Strada Milcov', 'Strada Mioritei', 'Strada Mironescu I. I.', 'Strada Mistretului', 'Strada Mizil', 'Strada Moldovei', 'Strada Motilor', 'Strada Munteni', 'Strada Mustea, cronicar', 'Strada Namoloasa', 'Strada Neculce Ion', 'Strada Negustori', 'Strada Nicolina', 'Strada Noua', 'Strada Obreja', 'Strada Oituz', 'Strada Olteniei', 'Strada Ornescu', 'Strada Pacii', 'Strada Padurii', 'Strada Pantel', 'Strada Parcului', 'Strada Paulescu, dr.', 'Strada Penes Curcanul', 'Strada Petru Schiopu', 'Strada Pietrariei', 'Strada Plantelor', 'Strada Podgoriilor', 'Strada Podu de Piatra', 'Strada Pogor Vasile', 'Strada Poligon', 'Strada Poni Petru', 'Strada Popescu Eremia, mr.', 'Strada Potcoavei', 'Strada Racovita Emil', 'Strada Ralet Dimitrie', 'Strada Randunica', 'Strada Rascanu Teodor', 'Strada Rece', 'Strada Roata Ion', 'Strada Romana', 'Strada Rovine', 'Strada Sadoveanu Mihail', 'Strada Sapte Oameni', 'Strada Saulescu Gheorghe', 'Strada Scaricica', 'Strada Semnului', 'Strada Sevastopol', 'Strada Sf. Constantin', 'Strada Sf. Lazar', 'Strada Sf. Vasile', 'Strada Sipotel', 'Strada Soficu', 'Strada Spinti', 'Strada Stejar', 'Strada Stindardului', 'Strada Strapungere Silvestru', 'Strada Strugurilor', 'Strada Sulfinei', 'Strada Tafrali Orest, prof.', 'Strada Tanasescu', 'Strada Teodoreanu Ionel', 'Strada Timpului', 'Strada Toparceanu George', 'Strada Trantomir', 'Strada Trofeelor', 'Strada Turcu', 'Strada Universitatii', 'Strada Urechia Vasile', 'Strada Valea Adanca', 'Strada Vanatori', 'Strada Vascauteanu', 'Strada Veniamin Costache', 'Strada Viespei', 'Strada Visan', 'Strada Vladiceni', 'Strada Vlaicu Aurel', 'Strada Vulpe', 'Strada Zarafi', 'Strada Zimbrului', 'Strada Zorilor', 'Stradela Armeana', 'Stradela Barbu Lautaru', 'Stradela Canta', 'Stradela Cazangiilor', 'Stradela Ciric', 'Stradela Dealul Bucium', 'Stradela Galateanu', 'Stradela Inculet Ion, prof.', 'Stradela Ipsilanti Alexandru Voda', 'Stradela Luminei', 'Stradela Mironescu I. I.', 'Stradela Nicorita', 'Stradela Perju', 'Stradela Primaverii', 'Stradela Savescu Toma', 'Stradela Sf. Atanasiei', 'Stradela Sf. Stefan', 'Stradela Stefan cel Mare si Sfant', 'Stradela Vantu', 'Trecere Bravilor', 'Trecere Ciobanului', 'Trecere Doamnei', 'Trecere Hotin', 'Trecere Nucului', 'Trecere Podgoriilor', 'Trecere Trei Ierarhi', '', 'Alee Atanasiu Dimitrie, prof. dr. ing.', 'Alee Bucium', 'Alee Columnei', 'Alee Dumbrava Rosie', 'Alee Micle Veronica', 'Alee Neculai Tudor', 'Alee Pacurari', 'Alee Plaiesilor', 'Alee Procopiu Stefan', 'Alee Simionescu I. I.', 'Alee Sucidava', 'Alee Vitejilor', 'Bulevard Chimiei', 'Bulevard Independentei', 'Bulevard Metalurgiei', 'Bulevard Rosetti C. A.', 'Bulevard Tutora', 'Cale Galata', 'Fundac Aurora', 'Fundac Bucium', 'Fundac Caramidari', 'Fundac Codrescu Teodor', 'Fundac Dochia', 'Fundac Eternitate', 'Fundac Gandu', 'Fundac Maracineanu Valter', 'Fundac Mitocul Maicilor', 'Fundac Muzicescu Gavril', 'Fundac Perjoaia', 'Fundac Pralea', 'Fundac Salciilor', 'Fundac Sf. Teodor', 'Fundac Socola', 'Fundac Tanjala', 'Fundac Vantu', 'Pasaj Cuza Voda', 'Piata Eminescu Mihai', 'Piata Natiunii', 'Piata Voievozilor', 'Sosea Arcu', 'Sosea Carlig', 'Sosea Iasi-Tomesti', 'Sosea Nationala', 'Sosea Pacurari', 'Sosea Stefan cel Mare si Sfant', 'Splai Bahlui Mal Stang', 'Strada Adunati', 'Strada Alba', 'Strada Albinet', 'Strada Alexandru Lapusneanu', 'Strada Amurgului', 'Strada Arapului', 'Strada Arges', 'Strada Aroneanu', 'Strada Ateneului', 'Strada Aviatiei', 'Strada Babes Victor', 'Strada Balcescu Nicolae', 'Strada Banat', 'Strada Banu', 'Strada Bariera Veche', 'Strada Barsescu Agatha', 'Strada Basota', 'Strada Berindei Ioan, arh.', 'Strada Bogdan Voda', 'Strada Botez Octav', 'Strada Brandusa', 'Strada Bratului', 'Strada Bucium', 'Strada Bujor Paul', 'Strada Burada Teodor', 'Strada Butnari', 'Strada Calafat', 'Strada Canta', 'Strada Caprelor', 'Strada Caraiman', 'Strada Caranda, lt.', 'Strada Casin', 'Strada Cazarmilor', 'Strada Cerchez', 'Strada Cicoarei', 'Strada Ciresica', 'Strada Ciurchi', 'Strada Codrescu Teodor', 'Strada Conductelor', 'Strada Costachescu Mihai', 'Strada Creanga Ion', 'Strada Crisului', 'Strada Cujba Petru, prof.', 'Strada Cuza Voda', 'Strada Dancu', 'Strada Dealul Galata', 'Strada Delavrancea Barbu Stefanescu', 'Strada Dezrobirii', 'Strada Doja Gheorghe', 'Strada Dorojinca', 'Strada Drobeta', 'Strada Dumbrava Rosie', 'Strada Eminescu Mihai', 'Strada Fagetului', 'Strada Fatu Anastasie', 'Strada Flammarion Camile', 'Strada Fluturilor', 'Strada Franta', 'Strada Frumoasa', 'Strada Functionarilor', 'Strada Gandu', 'Strada Ghibanescu Gheorghe', 'Strada Gloriei', 'Strada Grabovenschi', 'Strada Greerul', 'Strada Hanciuc', 'Strada Hlincea', 'Strada Horia', 'Strada Ibraileanu Garabet', 'Strada Iernii', 'Strada Inculet Ion, prof.', 'Strada Ionescu, lt.', 'Strada Islaz', 'Strada Italiana', 'Strada Jelea', 'Strada Langa, col.', 'Strada Libertatii', 'Strada Lupitei', 'Strada Macazului', 'Strada Mahu', 'Strada Manastirii', 'Strada Maracineanu Valter', 'Strada Marginei', 'Strada Mayer Octav', 'Strada Mihai Radu', 'Strada Millo Matei', 'Strada Mircea cel Batran', 'Strada Miroslava', 'Strada Mitropoliei', 'Strada Moara de Vant', 'Strada Morilor', 'Strada Movila Pacureti', 'Strada Muntenimii', 'Strada Muzicescu Gavril', 'Strada Naniescu Iosif, mitropolit', 'Strada Negel Gheorghe, lt.', 'Strada Neptun', 'Strada Nicorita', 'Strada Oancea', 'Strada Occident', 'Strada Olari', 'Strada Orfelinatului', 'Strada Otelari', 'Strada Pacurari', 'Strada Palat', 'Strada Pantelimon', 'Strada Pastorului', 'Strada Paun', 'Strada Perju', 'Strada Philippide, prof.', 'Strada Pinului', 'Strada Plevnei', 'Strada Podisului', 'Strada Podul Inalt', 'Strada Poienilor', 'Strada Pompei', 'Strada Ponoarelor', 'Strada Popovici, lt.', 'Strada Protopopescu, cpt.', 'Strada Radu Voda', 'Strada Ramadan Constantin', 'Strada Rapa Galbena', 'Strada Razboieni', 'Strada Rediu', 'Strada Rojnita', 'Strada Roscani', 'Strada Rufeni', 'Strada Salciilor', 'Strada Sararie', 'Strada Savescu Toma', 'Strada Scoalei', 'Strada Sendrea, Hatman', 'Strada Sf. Andrei', 'Strada Sf. Gheorghe', 'Strada Sf. Sava', 'Strada Silvestru', 'Strada Smardan', 'Strada Sorogari', 'Strada Spital Pascanu', 'Strada Stere Constantin, prof.', 'Strada Stoicescu, lt.', 'Strada Stroescu Vasile', 'Strada Sturdza Mihai', 'Strada Tabacului', 'Strada Taietoarei', 'Strada Tatarasi', 'Strada Tepes Voda', 'Strada Toamnei', 'Strada Traian', 'Strada Trei Fantani', 'Strada Trompeta', 'Strada Tutea Petre', 'Strada Urcusului', 'Strada Ursulea', 'Strada Valeni', 'Strada Vantu', 'Strada Vasile Lupu', 'Strada Verdes', 'Strada Viitor', 'Strada Vitejilor', 'Strada Vladimirescu Tudor', 'Strada Voinicilor', 'Strada Vulturilor', 'Strada Zborului', 'Strada Zlataust', 'Strada Zugravi', 'Stradela Baltii', 'Stradela Berindei Ioan, arh.', 'Stradela Caprelor', 'Stradela Cetatuia', 'Stradela Clopotari', 'Stradela Elena Doamna', 'Stradela Gradinari', 'Stradela Ionescu de la Brad Ion', 'Stradela Italiana', 'Stradela Macazului', 'Stradela Mizil', 'Stradela Pacureti', 'Stradela Plopii fara Sot', 'Stradela Rediu', 'Stradela Scaricica', 'Stradela Sf. Constantin', 'Stradela Silvestru', 'Stradela Trei Ierarhi', 'Stradela Vladimirescu Tudor', 'Trecere Bucsinescu', 'Trecere Corbului', 'Trecere Duzilor', 'Trecere Leului', 'Trecere Oitelor', 'Trecere Pricop');
  
  v_name varchar2(32);
  v_adresa varchar2(200);
  v_slots number(38, 0);
  v_available_slots number(38, 0);
  v_count integer;
  v_strada varchar2(64);
  v_oras varchar2(64);
  v_numar number(3,0);
begin
  for i in 1..p_number_of_inserts loop
    v_name := v_lista_nume(TRUNC(DBMS_RANDOM.VALUE(0,v_lista_nume.count))+1);    
    select * into v_count from (select count(*) from pickup_points where name like (v_name || '%'));
    
    if(v_count > 0) then
      v_name := v_name || ' ' || to_char(v_count + 1);
    end if;
    
    v_strada := v_lista_strazi(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_strazi.count))+1);
    v_oras := v_lista_orase(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_orase.count))+1);
    v_numar := DBMS_RANDOM.VALUE(1, 999);
    
    v_adresa := v_strada || ', Nr. ' || v_numar || ' ' || v_oras;
    
    v_slots := DBMS_RANDOM.VALUE(1, 200);
    v_available_slots := v_slots;
    
    insert into pickup_points (name, address, slots, available_slots) values (v_name, v_adresa, v_slots, v_available_slots);
  end loop;
end populate_pickup_ponts;
/
create or replace 
procedure populate_bicycles(p_number_of_inserts integer) as
  TYPE lista IS VARRAY(1000) OF varchar2(50);
  v_lista_statusuri lista := lista('available', 'broken', 'borrowed');
  
  v_qr_code varchar2(200);
  v_registration_date timestamp;
  v_status varchar2(20) := null;
  v_point_id number(38, 0);
  v_id_max_pickup_point number(38, 0);
begin
  select * into v_id_max_pickup_point from (select count(*) from pickup_points);
  
  for i in 1..p_number_of_inserts loop
    v_qr_code := DBMS_RANDOM.string('x', 200);
    v_status := v_lista_statusuri(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_statusuri.count))+1);
    v_registration_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(sysdate - 9*365 - interval '64324' minute, 'J'), TO_CHAR(sysdate, 'J'))), 'J');
    
    if(v_status not like 'borrowed') then
      v_point_id := DBMS_RANDOM.value(1, v_id_max_pickup_point);
      update pickup_points set available_slots = (available_slots - 1) where id = v_point_id;
    else
      v_point_id := null;
    end if;
    
    insert into bicycles (qr_code, register_date, status, point_id) values (v_qr_code, v_registration_date, v_status, v_point_id);
  end loop;
end populate_bicycles;
/
create or replace 
procedure populate_borrow(p_number_of_inserts integer) as  
  v_bicyclet_id number(38, 0);
  v_user_id number(38, 0);  
  v_price_id number(38, 0);
  v_borrow_date timestamp(6);
  v_end_date timestamp(6);
  
  v_user_id_max number(38, 0);  
  v_bicycle_id_max number(38, 0);
  v_count integer := 0;
  v_status varchar2(20);
  v_random_type integer;
  v_random_date timestamp(6);
  v_random_number integer;
begin
  select * into v_user_id_max from (select count(*) from users);
  select * into v_bicycle_id_max from (select count(*) from bicycles);
  
  for i in 1..p_number_of_inserts loop
    v_random_type := DBMS_RANDOM.VALUE(1, 100);

    if(v_random_type < 10) then
      v_random_date := sysdate - numtodsinterval(dbms_random.value(0, 4635), 'MINUTE');
      v_borrow_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(v_random_date, 'J'), TO_CHAR(sysdate, 'J'))), 'J');
      v_end_date := null;
      
      <<user>>
        v_user_id := DBMS_RANDOM.value(1, v_user_id_max);
        select * into v_count from (select count(*) from borrow where user_id = v_user_id and (end_date > v_borrow_date or end_date is null));
        if(v_count > 0) then
          goto user;
        end if;
        
      <<bicileta>>
        v_bicyclet_id := DBMS_RANDOM.value(1, v_bicycle_id_max);
        select * into v_count from (select count(*) from borrow where bicycle_id = v_bicyclet_id and (end_date > v_borrow_date or end_date is null));
        if(v_count > 0) then
          goto bicileta;
        end if;
      
      select * into v_price_id from (select id from prices where start_date <= v_borrow_date and (end_date > v_borrow_date or end_date is null));
    else      
      v_borrow_date := sysdate - numtodsinterval(dbms_random.value(0, 157467), 'MINUTE');
      v_end_date := v_borrow_date + numtodsinterval(dbms_random.value(0, 6000), 'MINUTE');
      
      <<user1>>
        v_user_id := DBMS_RANDOM.value(1, v_user_id_max);
        select * into v_count from (select count(*) from borrow where user_id = v_user_id
              and ((v_borrow_date < borrow_date and v_end_date <= borrow_date) 
                  or (v_borrow_date >= end_date and v_end_date > end_date)));
        if(v_count > 0) then
          goto user1;
        end if;
        
      <<bicileta1>>
        v_bicyclet_id := DBMS_RANDOM.value(1, v_bicycle_id_max);
        select * into v_count from (select count(*) from borrow where bicycle_id = v_bicyclet_id
              and ((v_borrow_date < borrow_date and v_end_date <= borrow_date) 
                  or (v_borrow_date >= end_date and v_end_date > end_date)));
        if(v_count > 0) then
          goto bicileta1;
        end if;
      select * into v_price_id from (select id from prices where start_date <= v_borrow_date and (end_date > v_borrow_date or end_date is null));
    end if;
    
    insert into borrow (bicycle_id, user_id, borrow_date, end_date, price_id) values (v_bicyclet_id, v_user_id, v_borrow_date, v_end_date, v_price_id);
    commit;
  end loop;
end populate_borrow;
/

create or replace 
procedure populate_issues(p_number_of_inserts integer) as
  TYPE lista IS VARRAY(1000) OF varchar2(50);
  v_lista_statusuri lista := lista('report', 'notification', 'time expired');  
  v_lista_severitati lista := lista('low', 'medium', 'major', 'critical');  
  v_registration_date timestamp;
  v_description varchar2(200);
  v_severity varchar2(20);
  v_type_issue varchar2(20);
  v_borrow_id number(38, 0);
  v_borrow_max_id integer;
begin  
  select * into v_borrow_max_id from (select count(*) from borrow);

  for i in 1..p_number_of_inserts loop
    v_registration_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(sysdate - 9*365 - interval '64324' minute, 'J'), TO_CHAR(sysdate, 'J'))), 'J');
    v_description := 'descriere';
    v_severity := v_lista_severitati(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_severitati.count))+1);
    v_type_issue := v_lista_statusuri(TRUNC(DBMS_RANDOM.VALUE(0, v_lista_statusuri.count))+1);    
    v_borrow_id := DBMS_RANDOM.value(1, v_borrow_max_id);
    
    insert into issues (registration_date, description, severity, type_issue, borrow_id) values (v_registration_date, v_description, v_severity, v_type_issue, v_borrow_id);
  end loop;
end;
/
CREATE OR REPLACE
PROCEDURE populate_move_bicycle(p_number_of_inserts INTEGER) AS
  v_bicycle_id NUMBER(38, 0);
  v_from_point_id NUMBER(38, 0);
  v_to_point_id NUMBER(38, 0);
  v_move_date TIMESTAMP(6);
BEGIN
  for i in 1..p_number_of_inserts LOOP
    SELECT id INTO v_bicycle_id FROM (SELECT id FROM BICYCLES ORDER BY dbms_random.value) WHERE rownum = 1;
    SELECT id INTO v_from_point_id FROM (SELECT id FROM BICYCLES ORDER BY dbms_random.value) WHERE rownum = 1;
    SELECT id INTO v_to_point_id FROM (SELECT id FROM BICYCLES ORDER BY dbms_random.value) WHERE rownum = 1;
    v_move_date := TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(sysdate - 9*365 - interval '64324' minute, 'J'), TO_CHAR(sysdate, 'J'))), 'J');

    INSERT INTO move_bicycle (bicycle_id, from_point_id, to_point_id, move_date) VALUES (v_bicycle_id, v_from_point_id, v_to_point_id, v_move_date);
   end loop;
END;

/
  drop index IX_email_password;
  drop index IX_START_DATE;
  drop index IX_name_address;
  drop index IX_BICYCLE_QR_CODE;
  drop index IX_USER_ID;
  drop index IX_REGISTER_DATE;
  drop index IX_BICYCLE_ID;
  drop index IX_BORROW_USER_ID;
  drop index IX_PRICE_ID;
  drop index IX_BICYCLE_ID_BORROW_DATE;
  commit;
/
  create unique INDEX IX_email_password on users(email, password);
  create INDEX IX_START_DATE on prices(start_date);
  -- create unique INDEX IX_name_address on pickup_points(name, address);
  create INDEX IX_BICYCLE_QR_CODE on bicycles(qr_code);
  create INDEX IX_USER_ID on debit_card(user_id);
  create INDEX IX_REGISTER_DATE on issues(registration_date);
  create INDEX IX_BICYCLE_ID on borrow(bicycle_id);
  create INDEX IX_BORROW_USER_ID on borrow(user_id);
  create INDEX IX_PRICE_ID on borrow(price_id);
  -- create unique INDEX IX_BICYCLE_ID_BORROW_DATE on borrow(bicycle_id, borrow_date);
/
begin
  detele_all_from_database;
  commit;
  populate_prices(200); -- ajung 200
  dbms_output.put_line('Preturi adaugate');
  commit;
  
  populate_users(10000);
  dbms_output.put_line('Useri adaugati');
  commit;
  
  populate_pickup_ponts(2000);
  dbms_output.put_line('Pointuri adaugate');
  commit;
  
  populate_bicycles(5000);
  dbms_output.put_line('Biciclete adaugate');
  commit;
  
  populate_borrow(3000);
  dbms_output.put_line('Borrow adaugate');
  commit;
  
  populate_issues(200);
  commit;

  populate_move_bicycle(1000);
  COMMIT;
end;
/




