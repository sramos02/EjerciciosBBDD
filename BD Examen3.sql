--Ejercicio 1
Modelo entidad relacion
Modelo relacional

--Ejercicio 2
-- Mostrar  el  DNI  de  los  alumnos  (sin  repeticiones)  de  mas  de  30
-- años  matriculados en  una asignatura de 6 cr ́editos.
SELECT DISTINCT Al.DNI
FROM Alumno Al JOIN Matricula ON Al.DNI = Ma.DNIAlumno
JOIN Asignatura Asi ON Ma.CodAsignatura = Asi.Codigo
WHERE Al.Edad > 30
AND Ma.NumCreditos = 6;


-- Mostrar el nombre de las asignaturas de 12 creditos
-- con mas de 300 alumnos.
SELECT A.Nombre
FROM Alumno Al JOIN Matricula ON Al.DNI = Ma.DNIAlumno
JOIN Asignatura A ON Ma.CodAsignatura = Asi.Codigo
WHERE A.NumCreditos = 12
GROUP BY Al.Nombre
WHERE COUNT(*) > 300;

-- Mostrar para todos los alumnos el nombre y el numero
-- de asignaturas en las que esta matriculado. Si algun alumno no esta
-- matriculado en ninguna asignatura se debe de mostrar un 0.
SELECT Al.Nombre, COUNT(*) AS NumAsig
FROM Alumno Al JOIN Matricula ON Al.DNI = Ma.DNIAlumno --Aqui entran los alumnos que estan matriculados de alguna asignatura
GROUP BY Al.Nombre
UNION ALL
SELECT Al2.Nombre, 0
FROM Alumno Al2
WHERE Al2.Nombre NOT IN (SELECT M2.DNIAlumno FROM MAtricula M2)

-- Mostrar el DNI de los alumnos que solo tienen
-- asignaturas matriculadas de 6 creditos.

SELECT DISTINCT Ma.DNIAlumno --NO ME CONVENCE ESTA FORMA DE RESOLUCION
FROM Matricula Ma
WHERE NOT EXIST (SELECT Al.DNI
				 FROM Alumno Al JOIN Matricula ON Al.DNI = Ma.DNIAlumno
				 JOIN Asignatura Asi ON Ma.CodAsignatura = Asi.Codigo
				 WHERE Ma2.DNIAlumno = Ma.DNIAlumno
				 AND A.NumCreditos <> 6);

-- Mostrar el nombre del alumno de mayor edad
-- matriculado en la asignatura de codigo 123.
SELECT Al.Nombre
FROM Alumno Al JOIN Matricula M ON Al.DNI = Ma.DNIAlumno
WHERE M.CodAsignatura = 123
AND Al.Edad >= (SELECT Al2.Nombre
				FROM Alumno Al2 JOIN Matricula M2 ON Al2.DNI = M2.DNIAlumno
				WHERE M2.CodAsignatura = 123)

-- Crea un procedimiento almacenado que reciba por
-- argumento el DNI de un alumno y muestre todas las asignaturas en
-- las que esta matriculado el alumno (nombre, numero de creditos y
-- nota), el numero total de creditos matriculados y la nota media del
-- expediente de dicho alumno.  Para calcular la nota media se suman
-- la nota * numCreditosAsignatura de todas las asignaturas aprobadas
-- (nota >= 5) y se divide por el numero de creditos en los que esta
-- matriculado el alumno.  Si el alumno no esta matriculado en ninguna
-- asignatura se mostrara el siguiente mensaje ’El alumno xxx no se ha
-- matriculado de ninguna asignatura’.

CREATE OR REPLACE PROCEDURE muestraAsignaturas (pDNI Alumno.DNI%TYPE) AS
	CURSOR cAsignaturas IS
		SELECT A.Nombre, A.creditos, Mt.Nota
		FROM Asignatura A JOIN Matricula Mt ON A.Codigo = Mt.CodAsignatura
		WHERE Mt.DNIAlumno = pDNI;
	lineAsig cAsignatura%ROWTYPE; --Para poder coger las lineas de una en una
	totalCreditos integer := 0;
	notaMedia := 0;
BEGIN
	OPEN cAsignaturas;
	FETCH cAsignaturas INTO rAsig; --Cogemos la primera linea de la consulta antes de entrar en el bucle
	IF cAsignaturas%ROWCOUNT = 0 THEN
		DBMS_OUTPUT.PUT_LINE('El alumno no se encuentra matriculado de ninguna asignatura');
	ELSE
		DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('Nombre Asignatura 														Creditos	 Nota');
		DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');

		WHILE cAsignaturas%FOUND LOOP
			DBMS_OUTPUT.PUT_LINE(lineAsig.Nombre || ' ' || lineAsig.Creditos || ' ' || lineAsig.Nota);
			totalCreditos := totalCreditos + lineAsig.Creditos;
			IF lineAsig.Nota > 5 THEN
				notaMedia := notaMedia + (lineAsig.Nota * lineAsig.Creditos);
			END IF;
			FETCH cAsignaturas INTO lineAsig; --Introduce la siguiente linea de la consulta
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('Creditos totales: ' || totalCreditos || '		Nota Media: ' || notaMedia);
		DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');
	END IF;
	CLOSE cAsignatura; --Importante cerrar el cursor despues de utilizarlo
END;
/

Asignatura<_Codigo, Nombre, NumCreditos>
Alumno<_DNI, Nombre, Edad, NumCredAprobados>
Matricula<_DNIAlumno, _CodAsignatura, Nota>

-- Escribe un disparador que mantenga el numero de
-- creditos aprobados de la tabla Alumno actualizado. Es decir, cada
-- vez que se modifique una nota de la tabla Matricula se comprobara
-- si la nota es igual o superior a 5 y si lo es se actualizaran los
-- creditos aprobados del alumno

CREATE OR REPLACE TRIGGER creditosAprobados
AFTER INSERT OR UPDATE OR DELETE OF Nota ON Matricula -- OF Columnna ON Tabla
FOR EACH ROW
DECARE
	CodAsignatura Matricula.CodAsignatura%TYPE;
	DNIAlumno Matricula.DNIAlumno%TYPE;
	NumCreditos Asignatura.NumCreditos%TYPE;
BEGIN																																																								--Casos posibles
	IF INSERTING OR UPDATING THEN																																											--	Inserta y nota > 5 -> Se añade la nueva nota y se actualiza todo
		DNIAlumno := :NEW.DNIAlumno;																																											--	Inserta y nota < 5 -> Como es menor no entra
		CodAsignatura := :NEW.CodAsignatura;																																							-- 	Reemplaza, new.nota > 5 y old.nota > 5 Se queda con la antigua y no hace na
		IF (INSERTING AND  (:NEW.Nota > 5)) OR (UPDATING AND (:NEW.Nota > 5) AND (:OLD.Nota < 5)) THEN 									--	Reemplaza, new.nota > 5 y old.nota < 5 Sustituye a la antigua
			SET numCredAprobados = numCredAprobados + NumCreditos;																									-- 	Reemplaza, new.nota < 5 -> En tal caso no entra ya que es menor
		ELSE IF UPDATING AND (:NEW.Nota < 5 AND :OLD.Nota > 5)	THEN
			SET numCredAprobados = numCredAprobados - NumCreditos;
		END IF;
	ELSE IF DELETING THEN
		DNIAlumno := :OLD.DNIAlumno;																																											--	Inserta y nota < 5 -> Como es menor no entra
		CodAsignatura := :OLD.CodAsignatura;	 --No entiendo muy bien que hace aqui
END:
/

--Ejercicio 3
savepoint paso_uno;
INSERT INTO MATRICULA VALUES ('123456789X', 'BBDD', 6); --Inicio Trnasaccion 1 (DML)
-- paso 1 --
savepoint paso_dos;
update MATRICULA
	set Creditos = Creditos + 1
	where DNI = '123456789X'
	and asignatura = 'BBDD';
-- paso 2 --
rollback to savepoint paso_dos;													--No finaliza transaccion!
-- paso 3 --
update MATRICULA
	set Creditos = Creditos + 2
	where DNI = '123456789X'
	and asignatura = 'BBDD';
-- paso 4 --
rollback;																								--Fin transaccion 1 (rollback)
-- paso 5 --
INSERT INTO MATRICULA VALUES ('123456789X', 'BBDD', 12);--Inicio transaccion 2
update MATRICULA
	set Creditos=  Creditos+ 3
	where DNI= '123456789X'
	and asignatura = 'BBDD';
-- paso 6  --
savepoint paso_tres;
commit;																									--Fin transaccion 2 (commit)
-- paso 7 --
create table Expediente( 															  --Inicio transaccion 3 (DDL)
	DNI varchar(20) PRIMARY KEY
  MatriculaTotal number(5));														--Fin transaccion 3 ->Ya que la siguiente instruccion no forma parte de inguna transaccion
Insert into Expediente values ('00000000P', 45);				--Inicio transaccion 4
rollback to savepoint paso_tres;
-- paso 8 --
select * from Expediente where DNI = '00000000P';
rollback;																								--Fin transaccion 4	

--a) El valor de creditos al final del codigo es 15
--c) Se produce un error en la linea 164 por no estar el savepoint en la misma transacciones
--d) Matricula ('123456789X', 'BBDD', 15')
--	 Expediente ('Sin valores')																										--'¡¡¡¡REPASAR IMPORTANTE!!!!'
