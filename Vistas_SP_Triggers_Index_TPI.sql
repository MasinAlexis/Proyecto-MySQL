CREATE OR REPLACE VIEW estadistica_xmes AS
SELECT p.nombre AS nom_proy, date_format(g.fech_gasto, '%Y/%m') AS año_mes, SUM(g.monto) AS gasto_totalxmes, AVG(g.monto) AS gasto_promxmes, COUNT(g.monto) AS cant_gastoxmes
FROM Gasto g INNER JOIN Proyecto p ON p.cod_proy=g.proyecto
GROUP BY p.nombre,date_format(g.fech_gasto, '%Y/%m')
ORDER BY p.nombre ASC;

CREATE OR REPLACE VIEW estadistica_xaño AS
SELECT p.nombre AS nom_proy, date_format(g.fech_gasto, '%Y') AS año,SUM(g.monto) AS gasto_totalxaño, AVG(g.monto) AS gasto_promxaño, COUNT(g.monto) AS cant_gastoxaño
FROM Gasto g INNER JOIN Proyecto p ON p.cod_proy=g.proyecto
GROUP BY p.nombre,date_format(g.fech_gasto, '%Y')
ORDER BY p.nombre ASC;

CREATE INDEX idx_empleados ON Gasto(empleado);

delimiter //
create function gasto_avg (desde tinyint, hasta tinyint) returns real not deterministic
READS SQL DATA
DETERMINISTIC
    begin
        declare salida int;
        set salida = (  select avg(g.monto) 
                        from Gasto g inner join Empleado e on g.empleado = e.cod_emple
                        where (desde <= e.experiencia) and ((desde >= e.experiencia)));
        return salida;
    end;
//
delimiter ;

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
