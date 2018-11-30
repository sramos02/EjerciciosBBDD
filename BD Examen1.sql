Asignatura(_Codigo, Nombre, NumCreditos)
Alumno(_DNI, Nombre, Edad, NumCredAprobados)
Matricula(_DNIAlumno,_CodAsignatura, Nota)

--Crea un procedimiento almacenado que reciba por argumento el DNI de un alumno y muestre todas
--las asignaturas en las que est ́a matriculado el alumno (nombre, n ́umero de cr ́editos y nota), el n ́umero total de
--cr ́editos matriculados y la nota media del expediente de dicho alumno. Para calcular la nota media se suman
--la nota*numCreditosAsignatura de todas las asignaturas aprobadas (nota >= 5) y se divide por el n ́umero de
--creditos  en  los  que  est ́a  matriculado  el  alumno.  Si  el  alumno  no  est ́a  matriculado  en  ninguna
--asignatura  se mostrar ́a el siguiente mensaje ’El alumno xxx no se ha matriculado de ninguna asignatura’

CREATE OR REPLACE PROCEDURE MuestraAsignaturas(pDNI Alumno.DNI%TYPE) IS
numCreditos INTEGER;
notaTotal INTEGER;
CURSOR Asignatura IS
	SELECT Alu.Nombre, Asi.NumCreditos, Mat.Nota
	FROM Asignatura Asi JOIN Matricula Mat ON Asi.Codigo = Mat.CodigoAsignatura
	JOIN Alumno Alu ON Mat.DNIAlumno = Alu.DNI
	WHERE Alu.DNI = pDNI;
BEGIN
	OPEN Asignatura;
	IF (COUNT(Asignatura) = 0) THEN
		DBMS_OUTPUT.PUT_LINE('El alumno' || pDNI ||'no se ha matriculado en ninguna asignatura');
	ELSE
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('Asignatura 						Creditos	Nota');
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

		notaTotal := 0 --Inicializamos las variables declaradas anteriormente
		numCreditos := 0

		WHILE (Asignatura %FOUND) LOOP
			DBMS_OUTPUT.PUT_LINE(Asignatura.Nombre || Asignatura.NumCreditos || Asignatura.Nota);
			numCreditos:= numCreditos + Asignatura.NumCreditos;

			IF(Asignatura.Nota >= 5) THEN
				notaTotal = notaTotal + (Asignatura.NumCreditos * Asignatura.Nota);
			END IF;
		END LOOP;

		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
		DBMS_OUTPUT.PUT_LINE('CreditosTotales: '|| numCreditos || 'NotaMedia: ' || notaTotal/numCreditos);
		DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');

	END IF;
	CLOSE Asignatura;
END:/


--DISPARADORES

CREATE OR REPLACE TRIGGER CreditosAprobados
AFTER INSERT OR DELETE OR UPDATE OF Nota ON Matricula
FOR EACH ROW --Salta una vez por fila modificada
DECLARE
	AsignaturAux %TYPE Matricula.CodAsignatura;
	DNIAux %TYPE Matricula.DNIAlumno;
	NOTAux %TYPE Matricula.Nota;
	Operacion INTEGER := 0; --//1 suma//0 no modifica// -1 resta
BEGIN
	IF INSERTING OR UPDATING THEN
		DNIAux := NEW.DNIAlumno;
		AsignaturAux := NEW.CodAsignatura;

		IF (INSERTING AND (:NEW.Nota >= 5)) OR (UPDATING AND (:NEW.Nota >= 5) AND (:OLD.Nota < 5)) THEN
			Operacion := 1;
		ELSE IF UPDATING AND (:NEW.Nota < 5) AND (:OLD.Nota >= 5)) THEN
			Operacion = -1;

		END IF;

	ELSE IF DELETING THEN
		DNIAux := :OLD.DNIAlumno;
		AsignaturAux := :OLD.CodAsignatura;
		Operacion := -1;
	END IF;
END;/
