--EJERCICIO 1
CREATE TABLE Libro(
ISBN CHAR(15) PRIMARY KEY,
Titulo VARCHAR2(50) NOT NULL,
Autor VARCHAR2(30) NOT NULL,
Genero VARCHAR2(20) NOT NULL
);

CREATE TABLE Ejemplar(
IdEjemplar NUMBER(6),
ISBN CHAR(15) NOT NULL REFERENCES Libro, --Pero si viene de una primary key no puede ser nulo de base
FechaCompra DATE NOT NULL
);

CREATE TABLE Socio(
NumSocio NUMBER(4) PRIMARY KEY,
Nombre VARCHAR2(50) NOT NULL,
MaxEjemplares NUMBER(6) NOT NULL,
Edad CHAR(3)
);

CREATE TABLE Prestamo(
Ejemplar CHAR(15) REFERENCES Ejemplar,
FechaPrestamo DATE,
NumSocio NUMBER(4) REFERENCES Socio,
FechaVto DATE NOT NULL,
PRIMARY KEY (Ejemplar, FechaPrestamo)
);

--CREATE TABLE Compras(
--ISBN CHAR(15) NOT NULL,
--NumEjemplares NUMBER(6)
--);

--EJERCICIO 2
INSERT INTO Compras
SELECT UNIQUE Li.ISBN, Li.Titulo
FROM Libro Li JOIN Ejemplar Ej ON Li.ISBN = Ej.ISBN
JOIN Prestamo Pr ON Ej.IdEjemplar = Pr.Ejemplar
WHERE FechaPrestamo >= TO_DATE('01/09/2016')
GROUP BY ISBN, Titulo,
HAVING COUNT(*) >= 15; --?????????

UPDATE Socios SET (MaxEjemplares = MaxEjemplares * 1.1) WHERE
NumSocio IN (SELECT NumSocio
			 FROM Prestamo
			 WHERE Fecha > TO_DATE('01/12/2016')
			 GROUP BY NumSocio --IMPORTANTE SABER QUE ESTO SE PUEDE HACER (20/12/2016)
			 HAVING COUNT(*) > 5);

--EJERCICIO 3
SELECT IdEjemplar, FechaPrestamo, FechaVto
FROM Prestamo
WHERE FechaPrestamo >= TO_DATE('01/07/2016') -- Que se encuentre seguro en el
AND FechaPrestamo < TO_DATE('01/10/2016')   -- tercer trimestre
AND FechaVto >= SYSDATE --Tampoco puede sobrepasar sysdate
ORDER BY EXTRACT(MONTH FROM FechaPrestamo), NumSocio;
SELECT Li.ISBN, Li.Titulo

FROM Libro Li JOIN Ejemplar Ej ON Li.ISBN = Ej.ISBN
JOIN Prestamo Pr ON Ej.IdEjemplar = Pr.Ejemplar
WHERE Li.Autor LIKE '%Arthur C. Clarke%'
AND EXTRACT(YEAR FROM Pr.FechaPestamo) = 2016;

SELECT Li.ISBN, Li.Titulo, COUNT(DISTINCT Pr.NumSocio)
FROM Libro Li JOIN Ejemplar Ej ON Li.ISBN = Ej.ISBN
JOIN Prestamo Pr ON Ej.IdEjemplar = Pr.Ejemplar
WHERE Pr.FechaPrestamo >= '01/12/16'
AND EXTRACT(YEAR FROM Pr.FechaPrestamo) = 2016
GROUP BY Li.ISBN, Li.Titulo;

SELECT So.NumSocio, So.Nombre
FROM Socio So JOIN Prestamo Pr ON So.NumSocio = Pr.NumSocio
WHERE FechaPrestamo >= ('01/06/16')
AND FechaPrestamo < ('01/01/2017')
GROUP BY So.NumSocio, So.Nombre
HAVING COUNT(*) <= 10
AND So.NumSocio NOT IN (SELECT Pr2.NumSocio
					    FROM Libro Li2 JOIN Ejemplar Ej2 ON Li.2ISBN = Ej2.ISBN
						JOIN Prestamo Pr2 ON Ej2.IdEjemplar = Pr2.Ejemplar
					    WHERE Li.Genero = 'misterio');

SELECT So.NumSocio, So.Nombre, So.Edad
FROM Prestamo Pr JOIN EjemplarLibro Ej ON Ej.IdEjemplar = Pr.Ejemplar
GROUP BY So.NumSocio, So.Nombre, So.Edad
HAVING COUNT(DISTINCT Ej.ISBN) >= ALL( --SE PODRIA HACER >= MAX(X)???
	SELECT COUNT(DISTINCT Ej2.ISBN)
	FROM EjemplarLibro Ej2 JOIN Prestamo Pr2 ON  Ej2.Ejemplar = Pr2.EjemplarLibro
	JOIN Socio So2 ON So2.NumSocio = Pr2.NumSocio
	WHERE So2.Edad = So.Edad
	GROUP BY So2.NumSocio
)

SELECT Li.Autor, COUNT(DISTINCT So.NumSocio), MIN(So.Edad)
FROM Libro Li JOIN Ejemplar Ej ON Li.ISBN = Ej.ISBN
JOIN Prestamo Pr ON Ej.IdEjemplar = Pr.Ejemplar
JOIN Socio So ON Pr.NumSocio = So.NumSocio
WHERE Pr.FechaPestamo >= ('31/06/2016')
AND Pr.FechaPrestamo <= ('31/08/2016')
GROUP BY Li.Autor
HAVING COUNT(DISTINCT So.NumSocio) <= 10;

--Cosas a tener en cuenta que me van a solucionar la vida en el examen
COUNT(DISTINCT NUMSOCIO) --Cuenta el numero de socios DISTINTOS a los que se ha prestado el libro
HAVING COUNT(*) < 10 --Solo cuenta si existen menos de 10 sentencias
WHERE So2.Edad = So.Edad --Compara la edad 1 con la edad 2 y coge los que tengan la misma edad
SELECT INTO Selecciona una sola fila mientras que el puntero devuelve una lista
------------------------------------------------------------------------------------------------------
--EJERCICIO 1
Cuadro <Nombre, Siglo, Tecnica>
Pintor <_Nombre, FechaN>
Exposcion <_Nombre, FechaIni, FechaFin, Museo >
Museo <_Nombre, Ciudad>

--EJERCICIO 2
Persona <_DNI, Nombre>
Alumno <_DNI>
Email <_DNI, _Email>
Profesor <_DNI, Email, Puesto>
Curso <_Codigo, Nombre, Coordinador>
Matricula <_DNIAlumno, _CodCurso, Año, Nota>
Tutor <_DNIProfesor, _CodCurso>

-- No se puede representar la cardinalidad Maxima 4 en la relacion TUTOR
-- No se puede representar la participacion minima de alumno en Matricula

--EJERCICIO 3
SELECT Pe.Titulo
FROM Pelicula Pe JOIN Pases Pa ON Pe.TPelicula = Pa.TPelicula
JOIN Cine Ci ON Ci.Cod = Pa.CodCine
WHERE Pe.Duracion > 90
AND Ci.Distrito = 24321;

SELECT Pe.Titulo, Sa.Afoto
FROM Pelicula Pe JOIN Pases Pa ON Pe.TPelicula = Pa.TPelicula
JOIN Sala Sa ON Sa.CodCine = Pa.CodCine
JOIN Cine Ci ON Ci.cod = Sa.CodCine
WHERE Pe.Duracion > 90
GROUP BY TPelicula, Ci.Distrito
HAVING SUM(Aforo) > 300;

SELECT Pa.CodCine, COUNT(Pa.TPelicula)
FROM Pases Pa
WHERE EntradasVendidas = 0
GROUP BY Pa.CodCine
UNION ALL
SELECT Pa.CodCine, 0
FROM Pases Pa

SELECT Pa.CodCine
FROM Pases Pa JOIN Pelicula Pe ON Pa.TPelicula = Pe.TPelicula
WHERE EXTRACT (YEAR FROM Pe2.FechaEstreno) = 2016)
AND Pa.CodCine NOT IN (SELECT Pa2.CodCine
					   FROM FROM Pases Pa2 JOIN Pelicula Pe2
					   ON Pa2.TPelicula = Pe2.TPelicula
					   WHERE EXTRACT (YEAR FROM Pe2.FechaEstreno) != 2016);

SELECT Ci.Distrito, COUNT(DISTINCT Pa.TPelicula)
FROM Pases Pa JOIN Cine Ci ON Ci.cod = Pa.CodCine
GROUP BY Ci.Distrito
HAVING COUNT(DISTINT Pa.TPelicula) >= ALL( SELECT COUNT(DISTINCT Pa2.TPelicula)
										FROM Pases Pa2 JOIN Cine Ci2
										ON Ci2.cod = Pa2.CodCine
										GROUP BY Ci.Distrito);

CREATE OR REPLACE PROCEDURE MyPorcedure (pCodigo Cine.Cod%TYPE) AS
CURSOR CPase IS
	SELECT Pa.Hora, Pa.NumSala, Pa.TPelicula, Sa.Aforo - Pa.EntradasVendidas locLibres
	FROM Salas Sa JOIN Pases Pa
	ON (Pa.CodCine = Sa.CodCine AND Pa.NumSala = Sa.NumSala)
	WHERE Pa.CodCine = pCodigo;
	ORDER BY Pa.Hora, Pa.NumSala;
BEGIN
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
	SELECT rPase INTO
	DBMS_OUTPUT.PUT_LINE('Cine: ' || pCodigo || ', NumSalas: ' || COUNT(CPase.NumSala)
						 || ', Aforo total: ' || SUM(CPase.Aforo);
	DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE('Hora	Sala 	Pelicula				 Loc.Libres');
	DBMS_OUTPUT.PUT_LINE('-------------------------------------------------');
	FOR muestraPase IN CPase --Muestra pase es una varibale no declarada anteriormente
	LOOP
		DBMS_OUTPUT.PUT_LINE(TO_CHAR(rPase.Hora) || ' ' || rPase.numSala ||
		' ' || rPase.TPelicula || rPase.locLibres)
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('El cine ' || pCodigo || ' no existe');
END;/

CREATE OR REPLACE TRIGGER EntradasVendidas
AFTER INSERT OR DELETE OR UPDATE ON CompraEntradas
FOR EACH ROW
BEGIN
	IF DELETING THEN
		UPDATE Pases
		SET EntradasVendidas = EntradasVendidas - :OLD.NumLocalidades
		WHERE CodCIne = :OLD.CodCine
		AND NumSala = :OLD.NumSala
		AND Hora = :OLD.Hora;
	ELSE IF INSERTING THEN
		UPDATE Pases
		SET EntradasVendidas = EntradasVendidas + :NEW.NumLocalidades
		WHERE CodCIne = :NEW.CodCine
		AND NumSala = :NEW.NumSala
		AND Hora = :NEW.Hora;
	--El enunciado no cubre la tercera opcion
	END IF;
END;/

--Ejercicio 4

SAVEPOINT PASO1;
INSERT INTO VENTAS VALUES ('Blancanitos', 200);				--Blancanitos = 200
SAVEPOINT PASO2;
UPDATE VENTAS												--Blancanitos = 300
	SET ENTRADASVENDIDAS = ENTRADASVENDIDAS + 100 (
	WHERE TPELICULA = 'Blancanitos';
ROLLBACK TO SABEPOINT PASO2;								--Blancanitos = 200 (Borra)
UPDATE VENTAS 												--Blancanitos = 400
	SET ENTRASVENDIDAS = ENTRADASVENDIDAS + 200
	WHERE TPELICULA = 'Blancanitos';
ROLLBACK; 													--Blancanitos = 200 (Borra)
INSERT INTO VENTAS VALUES ('Blancanitos', 1000);			--Blancanitos = 1000 'SOBREESCRIBE LO QUE HABIA'
UPDATE VENTAS												--Blancanitos = 1300
	SET ENTRADASVENDIDAS = ENTRADASVENDIDAS + 300
	WHERE TPELICULA = 'Blancanitos';
SAVEPOINT PASO3;
COMMIT;														--Guarda
CREATE TABLE SUPERVENTAS(); 								--Guarda
INSERT INTO SUPERVENTAS VALUES ('Enanieves', 100);
ROLLBACK TO SAVEPOINT PASO3 -> 								-- Error Y NO CAMBIA DE TRANSACCION
SELECT * FROM SUPERVENTAS WHHERE TPELI = 'Enanieves';
ROLLBACK; 													-- Borra hasta despues de crear la nueva tabla



a) Entradas Vendidas ('Blancanitos', 1300);
b)	1)215 - 220
	2)221 - 224
	4)225 - 230
	5)231
	6)232 - 233 --(El rollback da error por lo que no termina transaccion y despues hay un select que no contamos)
	--LOS COMMIT, SAVEPOINTS Y ROLLBACKS NO CUENTAN PARA LAS TRANSACCIONES
c) Si, se produce un error ya que en la linea 233 hace un rollback a un punto de otra transaccion (linea 231)
d) EntradasVendidas('Blancanitos', 1300)
   Superventas ('Enanieves', 100)
