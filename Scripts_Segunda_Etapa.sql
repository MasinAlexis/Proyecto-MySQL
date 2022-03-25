--FUNCIONES Y PROCEDIMIENTOS 

-- esta funcion recibe un intervalo de años de experiencia de emplados y devuelva el promedio de gastos 
delimiter //
create function gasto_avg (desde tinyint, hasta tinyint) returns real not deterministic
    begin
        declare salida int;
        set salida = (  select avg(g.monto) 
                        from Gasto g inner join Empleado e on g.empleado = e.cod_emple
                        where (desde <= e.experiencia) and ((desde >= e.experiencia)));    
        return salida;
    end;
//
delimiter ;

-- este procedimiento realiza un listado de la cantidad de productos de software por año de inicio
delimiter //
create procedure estadisticas_por_anio (desde decimal(10,2), hasta decimal(10,2)) 
    begin 
        select year(proy.fecha_ini) as 'Anio' , count(distinct(s.codigo_prod)) as 'Productos generados' 
        from ((Proyecto proy inner join Fase_Producto fp on fp.proyecto = proy.cod_proy) 
            inner join Producto prod on prod.cod_prod = fp.producto) inner join Software s on s.codigo_prod = cod_prod
        where (proy.presup >= desde) and (proy.presup <= hasta) 
        group by year(proy.fecha_ini);
    end;
//
delimiter ;

-- TRIGGERS

CREATE TABLE IF NOT EXISTS Gastos_altos (
	codigo INT UNSIGNED NOT NULL PRIMARY KEY,
    proyecto MEDIUMINT UNSIGNED NOT NULL,
	empleado SMALLINT UNSIGNED NOT NULL,
    monto DECIMAL(20,2) NOT NULL,
    fech_gasto DATE NOT NULL,
    CONSTRAINT FOREIGN KEY (empleado) REFERENCES Empleado(cod_emple)
    ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FOREIGN KEY (proyecto) REFERENCES Proyecto(cod_proy)
    ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE Empleado ADD cant_proy_act SMALLINT(2);

--Triggers
-- Crear un trigger que cada vez que se modifique la fecha de fin 
-- de proyecto (que significa que el proyecto terminó) descuente el campo “cantidad de proyectos activos”

-- Este procedimiento almacenado, actualiza las cantidades de proyectos activos de cada empleado
drop procedure if exists cant_proyectos;
delimiter //
create procedure cant_proyectos ()
    begin
        declare emple int;
        declare cant int;
        set emple = 1;
        while emple < 1001 do
            set cant = (select count(*) from Trabaja t inner join Proyecto p on t.proyecto = p.cod_proy 
                        where (t.informatico = emple) and (isnull(p.fecha_fin)) );
            update Empleado
            set cant_proy_act = cant
            where cod_emple = emple;
            set emple = emple + 1;
        end while;
end ;
//
delimiter ;
call cant_proyectos();

DROP TRIGGER IF EXISTS contadord_proy;
DELIMITER // 
CREATE TRIGGER contadord_proy
BEFORE UPDATE ON Proyecto 
FOR EACH ROW
BEGIN
    IF ISNULL(old.fecha_fin) AND NOT ISNULL(new.fecha_fin) THEN
	     UPDATE Empleado SET cant_proy_act=cant_proy_act-1
         WHERE cod_emple IN (SELECT DISTINCT(i.cod_emple)
							FROM (Informatico i INNER JOIN Trabaja t ON t.informatico=i.cod_emple)
							WHERE old.cod_proy=t.proyecto); 
    END IF;
END //
DELIMITER ;

-- Crear un trigger que automatice el incremento de la cantidad de 
-- proyectos activos de un empleado, cada vez que se le asigne un proyecto.

DROP TRIGGER IF EXISTS cant_proy_emple;
DELIMITER // 
CREATE TRIGGER cant_proy_emple
AFTER INSERT ON Trabaja 
FOR EACH ROW
BEGIN
	UPDATE Empleado SET cant_proy_act=cant_proy_act+1
    WHERE cod_emple=new.informatico; 
END //
DELIMITER ;

-- Crear un trigger que guarde en la tabla “gastos altos” todos los gastos que 
-- se ingresaron en la tabla “gastos” y que pasan cierto límite de monto(15000).

DROP TRIGGER IF EXISTS gasto_alto;
DELIMITER // 
CREATE TRIGGER gasto_alto
AFTER INSERT ON Gasto 
FOR EACH ROW
BEGIN
    IF new.monto > 15000 THEN
        INSERT INTO Gastos_altos(codigo,proyecto,empleado,monto,fech_gasto)
        VALUES(new.codigo,new.proyecto,new.empleado,new.monto,new.fech_gasto);
    END IF;
END //
DELIMITER ;

-- SEGURIDAD

--ADMINISTRADOR
CREATE ROLE 'administrador';
GRANT ALL ON *.* TO 'administrador';
CREATE USER 'Martin_Lopez'@'%' IDENTIFIED BY 'cO*NT-ad156//roL+';
GRANT 'administrador' TO 'Martin_Lopez'@'%';
FLUSH PRIVILEGES;

-- Al momento de iniciar sesion para activar el rol
SET ROLE 'administrador';

--DISEÑADOR
CREATE ROLE 'disenador';
GRANT SELECT ON *.* TO 'disenador';
CREATE USER 'Roberto_Garcia'@'localhost' IDENTIFIED BY 'fgkIU--/45rl+gar*' 
WITH MAX_QUERIES_PER_HOUR 100 MAX_USER_CONNECTIONS 1;
GRANT 'disenador' TO 'Roberto_Garcia'@'localhost';
FLUSH PRIVILEGES;

-- Al momento de iniciar sesion para activar el rol
SET default ROLE 'disenador' to 'Roberto_Garcia'@'localhost';

--PROGRAMADOR
CREATE ROLE 'programador';
GRANT SELECT,UPDATE,INSERT ON *.* TO 'programador';
CREATE USER 'Mariela_Romero'@'localhost' IDENTIFIED BY 'ds5689*/rlOS}{Rom+' WITH MAX_QUERIES_PER_HOUR 450 MAX_UPDATES_PER_HOUR 200 MAX_USER_CONNECTIONS 2;
GRANT 'programador' TO 'Mariela_Romero'@'localhost';
FLUSH PRIVILEGES;

-- Al momento de iniciar sesion para activar el rol
SET default ROLE 'programador' to 'Mariela_Romero'@'localhost';

-- Consultas JSON
-- Para realizar las consultas primero agregamos una columna JSON a la tabla Empleado, 
-- luego cargamos los datos que se encuentran en el archivo Datos_JSON_Segunda_Etapa.sql

ALTER TABLE Empleado ADD datos_json JSON;

-- 1) Obtener el promedio de edad de los postulantes con nivel de estudio universitario.

SELECT AVG(JSON_EXTRACT(e.datos_json, '$.postulante.edad'))
FROM Empleado e
WHERE JSON_EXTRACT(e.datos_json, '$.postulante.nivel_de_estudio')="universitario";

-- 2) Listar los nombres de las aspiraciones de puesto a ocupar con mayor cantidad de interesados.

SELECT J.puestos, COUNT(J.puestos)
FROM Empleado e JOIN JSON_TABLE(e.datos_json, '$.postulante.aspiraciones[*].puestos[*]' COLUMNS (puestos VARCHAR(150) PATH'$')) J
GROUP BY J.puestos
ORDER BY COUNT(J.puestos) DESC

-- 3) Listar los nombres, edades, ciudad de residencia y los conocimientos que aspiran aprender
-- aquellos que tienen interes en aprender lenguaje:php.  

SELECT e.nombre AS Nombre,
	   JSON_EXTRACT(e.datos_json, '$.postulante.edad') AS Edad,
       JSON_EXTRACT(e.datos_json, '$.postulante.ciudad') AS Ciudad_residencia,
       JSON_EXTRACT(e.datos_json, '$.postulante.aspiraciones[2].conocimientos') AS Conocimientos_interesados
FROM Empleado e
WHERE JSON_SEARCH(e.datos_json, "one", "PHP", NULL, '$.postulante.aspiraciones[0].lenguajes') IS NOT NULL;

-- 4 Listar los nombres, edades y ciudad de residencia de quines solamente trabajaron de manera virtual (ninguna presencial). 
-- COMENTARIO: en el JSON_SEARCH pregunto por presencial y al final "IS NULL" porque solamente deben ser aquellos que trabajaron de forma virtual
-- y en el segundo JSON_SEARCH limpio los resultados null

SELECT e.nombre AS Nombre,
	   JSON_EXTRACT(e.datos_json, '$.postulante.edad') AS Edad,
       JSON_EXTRACT(e.datos_json, '$.postulante.ciudad') AS Ciudad_residencia
FROM Empleado e
WHERE JSON_SEARCH(e.datos_json, "ONE", "presencial",NULL, '$.postulante.experiencia_laboral[*].empresa.tipo') IS NULL AND
	  JSON_SEARCH(e.datos_json, "ONE", "virtual",NULL, '$.postulante.experiencia_laboral[*].empresa.tipo') IS NOT NULL;

-- 5 Listar los nombres y redes sociales de quienes estudiaron el lenguaje:java y les interesa aprender conocimiento:git.
-- COMENTARIO: En aspiraciones a conocimientos en vez de git puse Scrum Master porque si no no arroja resultados 

SELECT e.nombre AS Nombre,
	   JSON_EXTRACT(e.datos_json, '$.postulante.redes_sociales[*]') AS Redes_sociales
FROM Empleado e
WHERE JSON_SEARCH(e.datos_json, "one", "java", NULL, '$.postulante.educacion_formal[*].tema') IS NOT NULL AND
	  JSON_SEARCH(e.datos_json, "one", "Scrum Master", NULL, '$.postulante.aspiraciones[2].conocimientos') IS NOT NULL;

