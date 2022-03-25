-- 1 CONSULTAS

-- 1.1. Nombre de los proyectos que produjeron al menos 10 productos distintos.

SELECT pr.nombre
FROM Proyecto pr 
WHERE pr.cod_proy IN (SELECT pr2.cod_proy 
                      FROM Proyecto pr2 INNER JOIN Fase_Producto fp ON pr2.cod_proy=fp.proyecto
                      GROUP BY pr2.cod_proy
                      HAVING COUNT(DISTINCT(fp.producto))>9);


-- 1.2. Listar los pares (Producto 1,Producto 2) tales que Producto 1 fue producida por una fase que también produjo Producto 2.

SELECT distinct(p1.nombre), p2.nombre
FROM (Producto p1 INNER JOIN(SELECT fp1.producto AS cod_pr1, fp2.producto AS cod_pr2
               FROM Fase_Producto fp1 INNER JOIN Fase_Producto fp2 ON fp1.fase = fp2.fase
               WHERE fp1.producto <> fp2.producto and fp1.proyecto = fp2.proyecto) AS p ON p.cod_pr1=p1.cod_prod) INNER JOIN Producto p2 ON p.cod_pr2=p2.cod_prod


-- 1.3. Listar los nombres de los empleados involucrados en la fase que se haya asignado ningún recurso.

select e.nombre
from (Proyecto p inner join Trabaja t on p.cod_proy = t.proyecto) inner join Empleado e on e.cod_emple = t.informatico
where p.cod_proy not in (select py.cod_proy from Proyecto py inner join Se_asigna ag on ag.cod_proy  = py.cod_proy);


-- 1.4. Listar los nombres de los proyectos privadas que no lanzaron ningún producto del tipo prototipo 

SELECT p.nombre
FROM Proyecto p
WHERE p.descrip LIKE 'Privado' AND p.cod_proy IN(SELECT fpi.proyecto
                         FROM (Fase_Producto_Informatico fpi INNER JOIN Producto pr ON fpi.producto=pr.cod_prod) INNER JOIN Prototipo po ON pr.cod_prod=po.codigo_prod
                         WHERE pr.estado NOT LIKE 'Finalizada')


-- 1.5. Listar los empleados (Informáticos) que hayan trabajado en todos los proyectos.

SELECT e.nombre
FROM Empleado e INNER JOIN (SELECT i.cod_emple AS c_emple
                            FROM Informatico i
                            WHERE NOT EXISTS(SELECT p.cod_proy
                                             FROM Proyecto p
                                             WHERE NOT EXISTS(SELECT t.proyecto
                                                              FROM Trabaja t
                                                              WHERE p.cod_proy=t.proyecto AND i.cod_emple=t.informatico))) AS e2 ON e.cod_emple=e2.c_emple;

-- 2 Consultas con modificación de ER

-- Agregamos 3 columnas mas a la tabla Recurso para relfejar lo pedido en la consigna

ALTER TABLE Recurso ADD baja CHAR(2), ADD costo DECIMAL(7,2), ADD fecha_adq DATE;

-- Para poder relacionar recursos con otros recursos vamos a crear un relacion con la misma entidad

CREATE TABLE IF NOT EXISTS Recurso_parte_de(
    cod_recu INT UNSIGNED,
    rec_parte INT UNSIGNED,
    PRIMARY KEY(cod_recu,rec_parte),
    CONSTRAINT FOREIGN KEY (cod_recu) REFERENCES Recurso(cod_rec)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    CONSTRAINT FOREIGN KEY (rec_parte) REFERENCES Recurso(cod_rec)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)

-- Datos para resolver la consigna

USE TPI_BDA;
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3001,'Nom_rec1','Descrip_rec1','Tipo_ rec1','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3002,'Nom_rec2','Descrip_rec2','Tipo_ rec2','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3003,'Nom_rec3','Descrip_rec3','Tipo_ rec3','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3004,'Nom_rec4','Descrip_rec4','Tipo_ rec4','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3005,'Nom_rec5','Descrip_rec5','Tipo_ rec5','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3006,'Nom_rec6','Descrip_rec6','Tipo_ rec6','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3007,'Nom_rec7','Descrip_rec7','Tipo_ rec7','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3008,'Nom_rec8','Descrip_rec8','Tipo_ rec8','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3009,'Nom_rec9','Descrip_rec9','Tipo_ rec9','NO',111.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3010,'Nom_rec10','Descrip_rec10','Tipo_ rec10','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3011,'Nom_rec11','Descrip_rec11','Tipo_ rec11','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3012,'Nom_rec12','Descrip_rec12','Tipo_ rec12','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3013,'Nom_rec13','Descrip_rec13','Tipo_ rec13','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3014,'Nom_rec14','Descrip_rec14','Tipo_ rec14','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3015,'Nom_rec15','Descrip_rec15','Tipo_ rec15','SI',222.12,CURDATE());
INSERT INTO Recurso(cod_rec,nombre,descrip,tipo,baja,costo,fecha_adq) VALUES(3016,'Nom_rec16','Descrip_rec16','Tipo_ rec16','SI',222.12,CURDATE());

INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(1,2);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(1,3);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(1,4);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(1,16);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(5,6);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(5,7);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(6,8);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(7,15);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(8,14);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(9,10);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(9,11);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(12,11);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(12,13);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(13,11);
INSERT INTO Recurso_parte_de(cod_recu,rec_parte) VALUES(11,12);


-- 2.1 Nombre de los recursos que forman parte de al menos dos recursos distintos.

SELECT r.cod_rec
FROM Recurso r INNER JOIN (SELECT rp.rec_parte AS recurso
                           FROM Recurso_parte_de rp
                           GROUP BY rp.rec_parte
                           HAVING COUNT(rp.cod_recu) > 1) AS r2 ON r.cod_rec=r2.recurso;


-- 2.2 Idem (a), pero listando de qué Recurso forman parte.

SELECT r.cod_rec AS Recurso, r3.cod_rec AS Forma_parte
FROM ((Recurso r INNER JOIN (SELECT rp.rec_parte AS recurso
                             FROM Recurso_parte_de rp
                             GROUP BY rp.rec_parte
                             HAVING COUNT(rp.cod_recu) > 1) AS r2 ON r.cod_rec=r2.recurso) INNER JOIN Recurso_parte_de rp2 ON rp2.rec_parte=r2.recurso) 
                                                                                         INNER JOIN Recurso r3 ON r3.cod_rec=rp2.cod_recu;
                                                                                         
-- 2.3 Listar los pares (Recurso1,Recurso2), donde Recurso1 y Recurso2 son tales que Recurso1 forma parte de otro que a su vez depende de Recurso2.

SELECT r1.cod_rec, r2.cod_rec
FROM (Recurso r1 INNER JOIN (SELECT rp.cod_recu AS recurso1,rp2.rec_parte AS recurso2
              FROM Recurso_parte_de rp,Recurso_parte_de rp2 
              WHERE rp.rec_parte LIKE rp2.cod_recu) AS rr ON rr.recurso1=r1.cod_rec) INNER JOIN Recurso r2 ON rr.recurso2=r2.cod_rec


-- 2.4 Inserte la tupla ParteDe(11,12). Ejecute la consulta anterior nuevamente. ¿Qué ocurre? ¿Cómo resuelve el problema?

INSERT INTO Recurso_parte_de(cod_recu,forma_parte) VALUES(11,12);

-- Al insertar la tupla (11,12) se produce una dependencia "en cadena" de varios recursos, ya que al decir que el recurso 11 está formado por
-- el recurso 12, podemos ver que el recurso 12 esta formado por el recurso 13 y el recurso 13 está formado por el recurso 11 y es ahí donde se
-- vuelve al principio.

-- 2.5 Listar los recursos que no forman parte de ningún otro (en forma directa)

SELECT r.nombre AS Recurso
FROM Recurso r
WHERE r.cod_rec NOT IN(SELECT rp.forma_parte
						FROM Recurso_parte_de rp)

-- 3 Para usar funciones de agregación, funciones de ventana y CTE 

-- 3.1 Listar los Jefes de proyectos y el total de sus horas dedicadas, y promedio de horas por proyectos.

SELECT e.nombre, hs.horas_totales, hs.promedio_hs
FROM Empleado e INNER JOIN (SELECT p.jefe AS jefe , SUM(horas_jefe) AS horas_totales , SUM(horas_jefe)/COUNT(p.cod_proy) AS promedio_hs
                            FROM Jefe jp INNER JOIN Proyecto p ON p.jefe=jp.cod_emple
                            GROUP BY p.jefe) AS hs ON e.cod_emple=hs.jefe


-- 3.2  Listar los tres jefes de proyectos que obtuvieron el mayor gasto acumulado.

SELECT e1.nombre,emm.gasto_acumulado
FROM Empleado e1 INNER JOIN (SELECT jp.cod_emple AS empleado,SUM(g.monto) AS gasto_acumulado
                             FROM (Jefe jp INNER JOIN Empleado e ON e.cod_emple=jp.cod_emple) INNER JOIN Gasto g ON g.empleado=e.cod_emple
                             GROUP BY jp.cod_emple
                             ORDER BY gasto_acumulado DESC LIMIT 3) AS emm ON emm.empleado=e1.cod_emple



-- 3.3 El Jefe de proyecto cubre el 3% del total del los gastos generados en el proyecto. Obtener el listado de cuanto deberá pagar por jefe y por proyecto

SELECT p1.nombre, gsto.gasto_jefe, gsto.gasto_proyecto
FROM Proyecto p1 INNER JOIN (SELECT p.cod_proy AS proyecto, SUM(g.monto)*0.03 AS gasto_jefe, SUM(g.monto) AS gasto_proyecto
                             FROM Proyecto p INNER JOIN Gasto g ON p.cod_proy=g.proyecto 
                             GROUP BY p.cod_proy) AS gsto ON p1.cod_proy=gsto.proyecto;


-- 3.4 Listar el gasto total del Proyecto, número de productos generados y suma de las cantidades de fases.

SELECT p1.nombre, cs.cant_productos, cs.cant_fases
FROM Proyecto p1 INNER JOIN (SELECT p.cod_proy AS proyecto, COUNT(fp.producto) AS cant_productos, COUNT(f.cod_fase) AS cant_fases
                             FROM (Proyecto p INNER JOIN Fase f ON p.cod_proy=f.cod_proy) INNER JOIN Fase_Producto fp ON fp.proyecto=f.cod_proy AND fp.fase=f.cod_fase
                             GROUP BY p.cod_proy) AS cs ON p1.cod_proy = cs.proyecto;


-- 3.5 Para cada mes y año, número total de gastos, costo total y monto promedio por proyecto.

CREATE OR REPLACE VIEW estadistica_xmes AS
SELECT p.nombre AS nom_proy, date_format(g.fech_gasto, '%Y/%m') AS año_mes, SUM(g.gasto) AS gasto_totalxmes, AVG(g.gasto) AS gasto_promxmes, COUNT(g.gasto) AS cant_gastoxmes
FROM Gasto g INNER JOIN Proyecto p ON p.cod_proy=g.proyecto
GROUP BY p.nombre,date_format(g.fech_gasto, '%Y/%m')
ORDER BY p.nombre ASC;

CREATE OR REPLACE VIEW estadistica_xaño AS
SELECT p.nombre AS nom_proy, date_format(g.fech_gasto, '%Y') AS año,SUM(g.gasto) AS gasto_totalxaño, AVG(g.gasto) AS gasto_promxaño, COUNT(g.gasto) AS cant_gastoxaño
FROM Gasto g INNER JOIN Proyecto p ON p.cod_proy=g.proyecto
GROUP BY p.nombre,date_format(g.fech_gasto, '%Y')
ORDER BY p.nombre ASC;


-- 4.1

-- Consulta a ejecutar: Obtener el empleado con el maximo gasto
 
SELECT g2.empleado AS Empleado_con_gasto_maximo
FROM Gasto g2
GROUP BY g2.empleado
HAVING COUNT(g2.monto) = (SELECT MAX(ca.cantidad)
					      FROM(SELECT COUNT(g1.monto) AS cantidad
							   FROM Gasto g1
							   GROUP BY g1.empleado) AS ca);
 -- Crear un índice sobre cod_empleados en gastos.

 CREATE INDEX idx_empleados ON Gasto(empleado);

 -- HACER LAS PRUEBAS CON EL INDICE