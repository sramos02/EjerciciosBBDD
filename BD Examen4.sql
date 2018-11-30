--Ejercicio 1
Modelo entidad relacion

--Ejercicio 2
Tienda<_ID, Nombre>
Departamento<_NumDpt, _IDTienda, CodAlmacen*, Descr>
Producto<_Codigo, Descr>
Almacen<_Cod, Direc>
Compuesto<_CodProducto1, _CodProducto2>
Ubicacion<_CodProducto, _CodAlmacen, Unidades>
Abastece<_IdTienda, _CodProducto, _CodAlmacen>

No se puede mostar la cardinalidad 4 en la relacion UBICACION
Se pierde informacion en la relacion COORDINA con respecto a la cardinalidad N
Tambien se pierde la particpiacion total en la relacion ABASTECE

--Ejercicio 3
Ordenador <_IdOrdenador, Nombre, Procesador, Memoria>
Programa <_IdPrograma, Denominacion, TipoLicencia, MinimoMemoria>
Instalacion <_IdOrdenador, _IdPrograma>

--Muestra la denominacion de aquellos programas que estan instalados en algun
--ordenador que no tiene memoria suficiente para ejecutarlo
P(Denominacion,IdPrograma)(S(Memoria < MinimoMemoria)(PROGRAMA X INSTALACION) X ORDENADOR)

--Muestra los nombres de los ordenadores que tienen algun programa instalado
--con el mismo tipo de licencia que el programa denominado 'GNU Emacs'
p(IdOrdenador, Nombre)(P(TipoLicencia)(S(Denominacion = 'GNU Emacs')(PROGRAMA))X (ORDENADOR X INSTALACION) X PROGRAMA)

--Muestra los nombres de los ordenadores que tienen instalados tanto programas
--con licencias de tipo 'GPL' como programas con licencias de tipo
--'Creative Commons'
GLP <- P(IdOrdenador, Nombre)((S(TipoLicencia = 'GNU Emacs')(PROGRAMA) X INSTALACION) X ORDENADOR)
CComon <- P(IdOrdenador, Nombre)((S(TipoLicencia = 'Creative Commons')(PROGRAMA) X INSTALACION) X ORDENADOR)
Resultado <- GLP I CComon

--Ejercicio 4
--Proporciona las sentencias SQL necesarias para crear las tablas correspondientes suponiendo lo siguiente:
--como maximo se va a almacenar informaci ́on sobre 2000 alumnos y 110 asignaturas, todos los alumnos obligatoriamente
--reciben beca y todas las asignaturas tienen cr ́editos asociados. Todos los identificadores son numericos excepto el
--departamento, que es un string de hasta 10 caracteres
CREATE TABLE Alumno(
  IdAlumno NUMBER(4,0) PRIMARY KEY,
  Nombre VARCHAR2(30) NOT NULL,
  ImporteBeca NUMBER(4,2)
  CHECK (ImporteBeca > 0));

CREATE TABLE Asignatura(
  IdAsignatura Number(3,0) PRIMARY KEY,
  Descr VARCHAR2(300),
  Creditos INTEGER NOT NULL,
  Departamento VARCHAR2(10) NOT NULL
  CHECK (Creditos > 0));

CREATE TABLE Colaboracion(
  IdAlumno NUMBER(4,0) REFERENCES Alumno,
  IdAsignatura NUMBER(3,0) REFERENCES Asignatura,
  Horas NUMBER(3,0),
  PRIMARY KEY(IdAlumno, IdAsignatura));

CREATE TABLE Aula(
  IdAlumno NUMBER(4,0),
  IdAsignatura NUMBER(3,0),
  IdAula NUMBER(3,0),
  PRIMARY KEY (IdAlumno, IdAsignatura, IdAula),
  FOREIGN KEY (IdAlumno, IdAsignatura) REFERENCES Colaboracion
);

--Escribe  una  sentencia  SQL  que  incremente  un  5 %  la  beca  de  los  alumnos
--que  colaboran  en  mas  de  3 asignaturas y mas de 50 horas en total
UPDATE Alumno SET ImporteBeca = (ImporteBeca * 1.05) WHERE IdAlumno IN
  SELECT Al.IdAlumno
  FROM Alumno Al JOIN Colaboracion Co ON Al.IdAlumno = Co.IdAlumno
  GROUP BY Al.IdAlumno
  HAVING COUNT(*) > 3
  AND SUM(Co.Horas) > 50;

--Escribe una consulta que muestre los departamentos y los alumnos que colaboran
--en sus asignaturas de 12 creditos
SELECT A.Departamento, Al.Nombre
FROM Alumno Al JOIN Colaboracion Co ON Al.IdAlumno = Co.IdAlumno
JOIN Asignatura A ON Co.IdAsignatura = A.IdAsignatura
WHERE As.Creditos = 12;

--Escribe una consulta SQL que muestre el nombre de los alumnos y el total de horas
--de todas sus colaboraciones, solo para aquellos alumnos con beca superior a 300
--euros y que colaboran en al menos una asignatura de mas de 9 creditos
SELECT Al.Nombre, SUM(Todas las horas de las asignaturas)
FROM Alumno Al JOIN Colaboracion Co ON Al.IdAlumno = Co.IdAlumno
JOIN Asignatura A ON Co.IdAsignatura = A.IdAsignatura
WHERE Al.ImporteBeca > 300
GROUP BY Al.Nombre
HAVING MAX(A.Creditos) > 9;

--Escribe una consulta que muestre el nombre de aquellos alumnos que no colaboran
--en ninguna asignatura en la que colabore 'John Doe'
SELECT Al.Nombre
FROM Alumnos Al
WHERE Al.Nombre NOT IN (SELECT Al2.Nombre
                        FROM Alumnos Al2 JOIN Colaboracion Co2 ON Al2.IdAlumno = Co2.IdAlumno
                        JOIN Colaboracion Co3 ON Co2.IdAsignatura = Co3.IdAsignatura
                        JOIN Alumnos Al3 ON Al3.IdAlumno = Co3.IdAlumno
                        WHERE Al3.Nombre = 'John Doe');

--Escribe una consulta que muestre las asignaturas dentro de cada
--departamento en las que más horas colaboran los alumnos. Debe mostrar
--el nombre de la asignatura y el departamento.
SELECT A.Nombre, A.Departamento
FROM Asignatura A JOIN Colaboracion Co ON A.IdAsignatura = Co.IdAsignatura
GROUP BY A.Departamento
HAVING SUM(Co.Horas) >= (SELECT SUM(Co2.Horas)
                         FROM Colaboracion Co2 JOIN Asignatura A2 ON A2.IdAsignatura = Co2.IdAsignatura
                         WHERE A.Departamento = A2.Departamento
                         GROUP BY A2.Departamento)
