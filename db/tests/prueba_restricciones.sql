BEGIN;

CREATE TEMP TABLE resultado_pruebas (
    n        SERIAL PRIMARY KEY,
    prueba   TEXT,
    esperado TEXT,
    obtenido TEXT,
    estado   TEXT,
    detalle  TEXT
);

CREATE PROCEDURE pg_temp.probar(p_prueba TEXT, p_sentencia TEXT, p_esperado TEXT) AS $f$
DECLARE
    v_obtenido TEXT := 'OK';
    v_detalle  TEXT := '';
BEGIN
    BEGIN
        EXECUTE p_sentencia;
    EXCEPTION WHEN OTHERS THEN
        v_obtenido := SQLSTATE;
        v_detalle  := SQLERRM;
    END;
    INSERT INTO resultado_pruebas (prueba, esperado, obtenido, estado, detalle)
    VALUES (p_prueba, p_esperado, v_obtenido,
            CASE WHEN v_obtenido = p_esperado THEN 'PASA' ELSE 'FALLA' END, v_detalle);
END;
$f$ LANGUAGE plpgsql;

INSERT INTO municipio (pais_codigo, nombre, ubicacion)
VALUES ('ES', 'Municipio Prueba ES', ST_SetSRID(ST_MakePoint(-0.8773, 41.6488), 4326)::geography);

INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('ana@test.com', 'h', 'CLIENTE');

INSERT INTO cliente (id, nombre, residencia_pais, residencia_municipio_id, fecha_consentimiento)
SELECT u.id, 'Ana', 'ES', m.id, now()
FROM usuario u, municipio m
WHERE u.correo = 'ana@test.com' AND m.nombre = 'Municipio Prueba ES';

INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 1', 'KILOGRAMO');

INSERT INTO receta (nombre, procedimiento, origen_pais) VALUES ('Receta Prueba', 'Mezclar', 'ES');

INSERT INTO receta_ingrediente (receta_id, ingrediente_id, cantidad, unidad)
SELECT r.id, i.id, 500, 'GRAMO'
FROM receta r, ingrediente i
WHERE r.nombre = 'Receta Prueba' AND i.nombre = 'Ingrediente Prueba 1';

CALL pg_temp.probar('ingrediente en uso: no se puede borrar', $$DELETE FROM ingrediente WHERE nombre='Ingrediente Prueba 1'$$, '23503');
CALL pg_temp.probar('borrar municipio en uso: se rechaza', $$DELETE FROM municipio WHERE nombre='Municipio Prueba ES'$$, '23503');
CALL pg_temp.probar('borrar país en uso: se rechaza', $$DELETE FROM pais WHERE codigo='ES'$$, '23503');

SELECT n, prueba, esperado, obtenido, estado, detalle FROM resultado_pruebas ORDER BY n;

ROLLBACK;
