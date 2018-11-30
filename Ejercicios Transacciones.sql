set autocommit off;
create table Enrolment (id char(10) primary key, subject char(10), credits number(2,0)); --Comienzo y Fin Transaccion 1 (DDL)
savepoint step_one;                                                                                                            --Sentencia Innecesaria
INSERT INTO ENROLMENT VALUES ('123456789X', 'DDBB', 6);                                  --Comienzo Transaccion 2 (DML)
savepoint step_two;
update ENROLMENT set Credits = Credits + 1 where Id = '123456789X' and Subject = 'DDBB';
rollback to savepoint step_two;
update ENROLMENT set Credits = Credits + 2 where Id = '123456789X' and Subject = 'DDBB';
INSERT INTO ENROLMENT VALUES (’123456789X’, ’DDBB’, 12);
update ENROLMENT set Credits = Credits + 3 where Id = '123456789X' and Subject = 'DDBB';
savepoint step_three;                                                                                                           --Sentencia Innecesaria
commit;                                                                                  --Fin Transaccion 2
create table AcademicRecord(ID varchar(20) PRIMARY KEY, Total number(5));                --Comienzo y fin Transaccion 3 (DDL)
Insert into AcademicRecord values('00000000P', 45);                                      --Comienzo Transaccion 4  (DML)
rollback to savepoint step_three;                                                                                               --Error, diferente transaccion
select * from AcademicRecord where ID = '00000000P';                                                                            --AcademicRecord ('00000000P', 45)
rollback;                                                                                --Fin Transaccion 4
select * from AcademicRecord where ID = '00000000P';                                     --Inicio Transaccion 5 (DML)           --AcademicRecord -
commit;                                                                                  --Fin Transaccion 5



savepoint step_one;                                                                                                     --Sentencia Innecesaria
create table Sales (Title varchar(25) primary key, TicketsSold number(3,0));    -- Inicio y fin Transaccion 1
commit;                                                                         -- No hay transaccion abierta -> Error  --Sentencia Innecesaria
INSERT INTO SALES VALUES ('My Fair Lady', 200);                                 -- Inicio Transaccion 2
savepoint step_two;                                                                                                     --Sentencia Innecesaria
update Sales set TicketsSold = TicketsSold + 100 where Title = 'My Fair Lady';
commit;                                                                         -- Fin Transaccion 2
update Sales set TicketsSold = TicketsSold + 200 where Title = 'My Fair Lady';  -- Inicio Transaccion 3
rollback;                                                                       -- Fin Transaccion 3
INSERT INTO Sales VALUES ('My Fair Lady', 315);                                 -- Inicio Transaccion 4
update Sales set TicketsSold = TicketsSold + 300 where Title = 'Hamlet';                                                --Sentencia Innecesaria (No existe 'Hamlet')                                                                 
commit;                                                                         -- Fin Transaccion 4
create table TopSales(Tfilm varchar(70), Total number(5));                      -- Inicio y fin Transaccion 5
Insert into TopSales values('Breakfast at Tiffany’s', 100);                     -- Inicio Transaccion 6
rollback to savepoint step_three;                                               -- No existe savepoint step_three
select * from TopSales where Tfilm = 'Breakfast at Tiffany’s';                  -- Inicio Transaccion 7                 --TopSales('Breakfast at Tiffany’s', 100)
select * from Sales;                                                                                                    --Sales('My Fair Lady', 315)
commit;                                                                         -- Fin Transaccion 7
