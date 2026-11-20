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

CREATE PROCEDURE pg_temp.verificar(p_prueba TEXT, p_condicion TEXT) AS $f$
DECLARE
    v_ok BOOLEAN;
BEGIN
    EXECUTE 'SELECT ' || p_condicion INTO v_ok;
    INSERT INTO resultado_pruebas (prueba, esperado, obtenido, estado)
    VALUES (p_prueba, 'true', COALESCE(v_ok::TEXT, 'null'),
            CASE WHEN v_ok IS TRUE THEN 'PASA' ELSE 'FALLA' END);
END;
$f$ LANGUAGE plpgsql;

CALL pg_temp.probar('pais: continente inválido', $$INSERT INTO pais VALUES ('ZZ','Zeta','MARTE')$$, '23514');
CALL pg_temp.probar('pais: nombre repetido', $$INSERT INTO pais VALUES ('ZZ','España','EUROPA')$$, '23505');
CALL pg_temp.verificar('V7: países cargados (más de 190)', $$(SELECT count(*) FROM pais) > 190$$);
CALL pg_temp.probar('municipio: Zaragoza (ES)', $$INSERT INTO municipio (pais_codigo, nombre, ubicacion) VALUES ('ES','Municipio Prueba ES', ST_SetSRID(ST_MakePoint(-0.8773, 41.6488), 4326)::geography)$$, 'OK');
CALL pg_temp.probar('municipio: Lisboa (PT)', $$INSERT INTO municipio (pais_codigo, nombre, ubicacion) VALUES ('PT','Municipio Prueba PT', ST_SetSRID(ST_MakePoint(-9.1393, 38.7223), 4326)::geography)$$, 'OK');
CALL pg_temp.probar('municipio: duplicado en el mismo país', $$INSERT INTO municipio (pais_codigo, nombre, ubicacion) VALUES ('ES','Municipio Prueba ES', ST_SetSRID(ST_MakePoint(0, 0), 4326)::geography)$$, '23505');
CALL pg_temp.probar('municipio: país inexistente', $$INSERT INTO municipio (pais_codigo, nombre, ubicacion) VALUES ('QQ','Nada', ST_SetSRID(ST_MakePoint(0, 0), 4326)::geography)$$, '23503');
CALL pg_temp.verificar('PostGIS: Zaragoza-Lisboa entre 700 y 800 km',
  $$(SELECT ST_Distance(a.ubicacion, b.ubicacion) BETWEEN 700000 AND 800000 FROM municipio a, municipio b WHERE a.nombre='Municipio Prueba ES' AND b.nombre='Municipio Prueba PT')$$);

CALL pg_temp.probar('usuario: correo con mayúsculas', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('Ana@Test.com','h','CLIENTE')$$, '23514');
CALL pg_temp.probar('usuario: rol inválido', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('x@test.com','h','DIOS')$$, '23514');
CALL pg_temp.probar('usuario: cliente válido', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('ana@test.com','h','CLIENTE')$$, 'OK');
CALL pg_temp.probar('usuario: correo repetido', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('ana@test.com','h','CLIENTE')$$, '23505');
CALL pg_temp.probar('usuario: comercio válido', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('tienda@test.com','h','COMERCIO')$$, 'OK');
CALL pg_temp.probar('usuario: administrador válido', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('admin@test.com','h','ADMINISTRADOR')$$, 'OK');
CALL pg_temp.probar('usuario: segundo cliente', $$INSERT INTO usuario (correo, contrasena_hash, rol) VALUES ('luis@test.com','h','CLIENTE')$$, 'OK');

CALL pg_temp.probar('cliente: sin consentimiento', $$INSERT INTO cliente (id, nombre) SELECT id, 'Ana' FROM usuario WHERE correo='ana@test.com'$$, '23502');
CALL pg_temp.probar('cliente: municipio de otro país', $$INSERT INTO cliente (id, nombre, residencia_pais, residencia_municipio_id, fecha_consentimiento) SELECT u.id, 'Luis', 'ES', m.id, now() FROM usuario u, municipio m WHERE u.correo='luis@test.com' AND m.nombre='Municipio Prueba PT'$$, '23503');
CALL pg_temp.probar('cliente: municipio sin país', $$INSERT INTO cliente (id, nombre, residencia_municipio_id, fecha_consentimiento) SELECT u.id, 'Luis', m.id, now() FROM usuario u, municipio m WHERE u.correo='luis@test.com' AND m.nombre='Municipio Prueba ES'$$, '23514');
CALL pg_temp.probar('cliente: válido con residencia en Zaragoza', $$INSERT INTO cliente (id, nombre, nacionalidad_pais, residencia_pais, residencia_municipio_id, fecha_consentimiento) SELECT u.id, 'Ana', 'PE', 'ES', m.id, now() FROM usuario u, municipio m WHERE u.correo='ana@test.com' AND m.nombre='Municipio Prueba ES'$$, 'OK');
CALL pg_temp.probar('cliente: válido sin residencia', $$INSERT INTO cliente (id, nombre, fecha_consentimiento) SELECT id, 'Luis', now() FROM usuario WHERE correo='luis@test.com'$$, 'OK');
CALL pg_temp.probar('comercio: usuario con rol CLIENTE no puede ser comercio', $$INSERT INTO comercio (id, nombre_comercio, direccion, ubicacion) SELECT id, 'X', 'Calle 1', ST_SetSRID(ST_MakePoint(-0.88, 41.65), 4326)::geography FROM usuario WHERE correo='ana@test.com'$$, '23503');
CALL pg_temp.probar('comercio: estado inválido', $$INSERT INTO comercio (id, nombre_comercio, direccion, ubicacion, estado) SELECT id, 'Tienda', 'Calle 1', ST_SetSRID(ST_MakePoint(-0.88, 41.65), 4326)::geography, 'CERRADO' FROM usuario WHERE correo='tienda@test.com'$$, '23514');
CALL pg_temp.probar('comercio: válido', $$INSERT INTO comercio (id, nombre_comercio, direccion, ubicacion) SELECT id, 'Tienda Centro', 'Calle 1, Zaragoza', ST_SetSRID(ST_MakePoint(-0.88, 41.65), 4326)::geography FROM usuario WHERE correo='tienda@test.com'$$, 'OK');
CALL pg_temp.verificar('comercio: estado por omisión ACTIVO', $$(SELECT estado = 'ACTIVO' FROM comercio WHERE nombre_comercio='Tienda Centro')$$);
CALL pg_temp.probar('administrador: usuario con rol COMERCIO no puede ser admin', $$INSERT INTO administrador (id) SELECT id FROM usuario WHERE correo='tienda@test.com'$$, '23503');
CALL pg_temp.probar('administrador: válido', $$INSERT INTO administrador (id) SELECT id FROM usuario WHERE correo='admin@test.com'$$, 'OK');

CALL pg_temp.probar('categoria: combinación inválida', $$INSERT INTO categoria (nombre, permite_varias_opciones, es_obligatoria, combinacion_filtro) VALUES ('Categoria Prueba', true, true, 'NINGUNA')$$, '23514');
CALL pg_temp.probar('categoria: Dieta', $$INSERT INTO categoria (nombre, permite_varias_opciones, es_obligatoria, combinacion_filtro) VALUES ('Categoria Prueba', true, true, 'TODAS')$$, 'OK');
CALL pg_temp.probar('opcion: Vegana en Dieta', $$INSERT INTO opcion_categoria (categoria_id, nombre) SELECT id, 'Opcion Prueba' FROM categoria WHERE nombre='Categoria Prueba'$$, 'OK');
CALL pg_temp.probar('opcion: Vegana repetida en Dieta', $$INSERT INTO opcion_categoria (categoria_id, nombre) SELECT id, 'Opcion Prueba' FROM categoria WHERE nombre='Categoria Prueba'$$, '23505');
CALL pg_temp.probar('ingrediente: unidad de venta inválida', $$INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 1','CAJA')$$, '23514');
CALL pg_temp.probar('ingrediente: Tomate', $$INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 1','KILOGRAMO')$$, 'OK');
CALL pg_temp.probar('ingrediente: Sal', $$INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 2','KILOGRAMO')$$, 'OK');
CALL pg_temp.probar('ingrediente: nombre repetido', $$INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 1','KILOGRAMO')$$, '23505');
CALL pg_temp.probar('receta: municipio que no es del país de origen', $$INSERT INTO receta (nombre, procedimiento, origen_pais, origen_municipio_id) SELECT 'Receta Prueba','Mezclar','ES', id FROM municipio WHERE nombre='Municipio Prueba PT'$$, '23503');
CALL pg_temp.probar('receta: raciones cero', $$INSERT INTO receta (nombre, procedimiento, origen_pais, raciones) VALUES ('Receta Prueba','Mezclar','ES',0)$$, '23514');
CALL pg_temp.probar('receta: Gazpacho válido', $$INSERT INTO receta (nombre, procedimiento, origen_pais, origen_municipio_id, raciones, tiempo_preparacion_min) SELECT 'Receta Prueba','Mezclar y enfriar','ES', id, 4, 15 FROM municipio WHERE nombre='Municipio Prueba ES'$$, 'OK');
CALL pg_temp.verificar('receta: valores por omisión de los derivados', $$(SELECT numero_valoraciones = 0 AND valoracion_promedio IS NULL AND costo_estimado IS NULL FROM receta WHERE nombre='Receta Prueba')$$);
CALL pg_temp.probar('receta_opcion: clasificar receta', $$INSERT INTO receta_opcion SELECT r.id, o.id FROM receta r, opcion_categoria o WHERE r.nombre='Receta Prueba' AND o.nombre='Opcion Prueba'$$, 'OK');
CALL pg_temp.probar('receta_ingrediente: unidad inválida', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, 2, 'LATA' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('receta_ingrediente: cantidad vacía sin AL_GUSTO', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, NULL, 'GRAMO' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('receta_ingrediente: cantidad cero', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, 0, 'GRAMO' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('receta_ingrediente: 500 g de tomate', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, 500, 'GRAMO' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 1'$$, 'OK');
CALL pg_temp.probar('receta_ingrediente: sal al gusto', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, NULL, 'AL_GUSTO' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 2'$$, 'OK');
CALL pg_temp.probar('receta_ingrediente: ingrediente repetido', $$INSERT INTO receta_ingrediente SELECT r.id, i.id, 100, 'GRAMO' FROM receta r, ingrediente i WHERE r.nombre='Receta Prueba' AND i.nombre='Ingrediente Prueba 1'$$, '23505');
CALL pg_temp.probar('ingrediente en uso: no se puede borrar', $$DELETE FROM ingrediente WHERE nombre='Ingrediente Prueba 1'$$, '23503');

CALL pg_temp.probar('disponibilidad: disponible sin precio', $$INSERT INTO disponibilidad_comercio (comercio_id, ingrediente_id, disponible) SELECT c.id, i.id, true FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('disponibilidad: precio negativo', $$INSERT INTO disponibilidad_comercio (comercio_id, ingrediente_id, disponible, precio) SELECT c.id, i.id, true, -1 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('disponibilidad: Tomate a 2,50', $$INSERT INTO disponibilidad_comercio (comercio_id, ingrediente_id, disponible, precio) SELECT c.id, i.id, true, 2.50 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, 'OK');
CALL pg_temp.probar('disponibilidad: Sal no disponible sin precio', $$INSERT INTO disponibilidad_comercio (comercio_id, ingrediente_id, disponible) SELECT c.id, i.id, false FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 2'$$, 'OK');
CALL pg_temp.probar('disponibilidad: declarar dos veces', $$INSERT INTO disponibilidad_comercio (comercio_id, ingrediente_id, disponible, precio) SELECT c.id, i.id, true, 3 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, '23505');
CALL pg_temp.probar('ingrediente: Pimiento (el comercio no lo declara)', $$INSERT INTO ingrediente (nombre, unidad_venta_referencia) VALUES ('Ingrediente Prueba 3','KILOGRAMO')$$, 'OK');
CALL pg_temp.probar('oferta: sobre ingrediente sin disponibilidad declarada', $$INSERT INTO oferta (comercio_id, ingrediente_id, precio_ofertado, fecha_fin) SELECT c.id, i.id, 1.99, current_date + 7 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 3'$$, '23503');
CALL pg_temp.probar('oferta: precio cero', $$INSERT INTO oferta (comercio_id, ingrediente_id, precio_ofertado, fecha_fin) SELECT c.id, i.id, 0, current_date + 7 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('oferta: estado inválido', $$INSERT INTO oferta (comercio_id, ingrediente_id, precio_ofertado, fecha_fin, estado) SELECT c.id, i.id, 1.99, current_date + 7, 'CADUCA' FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, '23514');
CALL pg_temp.probar('oferta: Tomate a 1,99', $$INSERT INTO oferta (comercio_id, ingrediente_id, precio_ofertado, fecha_fin) SELECT c.id, i.id, 1.99, current_date + 7 FROM comercio c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, 'OK');
CALL pg_temp.verificar('oferta: estado por omisión VIGENTE', $$(SELECT estado = 'VIGENTE' FROM oferta LIMIT 1)$$);
CALL pg_temp.probar('valoracion: puntuación 6', $$INSERT INTO valoracion SELECT c.id, r.id, 6 FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, '23514');
CALL pg_temp.probar('valoracion: puntuación 0', $$INSERT INTO valoracion SELECT c.id, r.id, 0 FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, '23514');
CALL pg_temp.probar('valoracion: 5 estrellas', $$INSERT INTO valoracion (cliente_id, receta_id, puntuacion) SELECT c.id, r.id, 5 FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, 'OK');
CALL pg_temp.probar('valoracion: votar dos veces la misma receta', $$INSERT INTO valoracion (cliente_id, receta_id, puntuacion) SELECT c.id, r.id, 3 FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, '23505');

CALL pg_temp.probar('copia: Gazpacho de Ana', $$INSERT INTO copia_personal_receta (cliente_id, receta_origen_id, nombre, procedimiento_personalizado, raciones) SELECT c.id, r.id, 'Mi gazpacho', 'Con menos ajo', 2 FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, 'OK');
CALL pg_temp.probar('copia: segunda copia de la misma receta', $$INSERT INTO copia_personal_receta (cliente_id, receta_origen_id, nombre, procedimiento_personalizado) SELECT c.id, r.id, 'Otra', 'x' FROM cliente c JOIN usuario u ON u.id = c.id, receta r WHERE u.correo='ana@test.com' AND r.nombre='Receta Prueba'$$, '23505');
CALL pg_temp.probar('copia_ingrediente: ingrediente fuera del catálogo', $$INSERT INTO copia_ingrediente (copia_id, ingrediente_id, cantidad, unidad) SELECT id, 999999, 1, 'UNIDAD' FROM copia_personal_receta$$, '23503');
CALL pg_temp.probar('copia_ingrediente: tomate', $$INSERT INTO copia_ingrediente (copia_id, ingrediente_id, cantidad, unidad) SELECT c.id, i.id, 300, 'GRAMO' FROM copia_personal_receta c, ingrediente i WHERE i.nombre='Ingrediente Prueba 1'$$, 'OK');
CALL pg_temp.probar('entrada_calendario: estado de aviso inválido', $$INSERT INTO entrada_calendario (copia_id, fecha, aviso_estado) SELECT id, current_date + 1, 'MAYBE' FROM copia_personal_receta$$, '23514');
CALL pg_temp.probar('entrada_calendario: mañana', $$INSERT INTO entrada_calendario (copia_id, fecha) SELECT id, current_date + 1 FROM copia_personal_receta$$, 'OK');
CALL pg_temp.probar('entrada_calendario: misma receta el mismo día', $$INSERT INTO entrada_calendario (copia_id, fecha) SELECT id, current_date + 1 FROM copia_personal_receta$$, '23505');
CALL pg_temp.probar('entrada_calendario: otra fecha para la misma copia', $$INSERT INTO entrada_calendario (copia_id, fecha) SELECT id, current_date + 2 FROM copia_personal_receta$$, 'OK');
CALL pg_temp.probar('incidencia: estado inválido', $$INSERT INTO incidencia (comercio_id, asunto, estado) SELECT id, 'Ayuda', 'ABIERTA' FROM comercio$$, '23514');
CALL pg_temp.probar('incidencia: nueva del comercio', $$INSERT INTO incidencia (comercio_id, asunto) SELECT id, 'No puedo subir precios' FROM comercio$$, 'OK');
CALL pg_temp.verificar('incidencia: nace PENDIENTE y sin administrador', $$(SELECT estado = 'PENDIENTE' AND administrador_id IS NULL FROM incidencia LIMIT 1)$$);
CALL pg_temp.probar('mensaje: autor inválido', $$INSERT INTO mensaje_incidencia (incidencia_id, autor, cuerpo) SELECT id, 'CLIENTE', 'Hola' FROM incidencia$$, '23514');
CALL pg_temp.probar('mensaje: del comercio', $$INSERT INTO mensaje_incidencia (incidencia_id, autor, autor_usuario_id, cuerpo) SELECT i.id, 'COMERCIO', u.id, 'No puedo subir precios' FROM incidencia i, usuario u WHERE u.correo='tienda@test.com'$$, 'OK');
CALL pg_temp.probar('incidencia: la atiende el administrador', $$UPDATE incidencia SET administrador_id = (SELECT a.id FROM administrador a JOIN usuario u ON u.id = a.id WHERE u.correo='admin@test.com'), estado = 'ESPERANDO_COMERCIO'$$, 'OK');
CALL pg_temp.probar('mensaje: respuesta del administrador', $$INSERT INTO mensaje_incidencia (incidencia_id, autor, autor_usuario_id, cuerpo) SELECT i.id, 'ADMINISTRADOR', u.id, 'Prueba ahora' FROM incidencia i, usuario u WHERE u.correo='admin@test.com'$$, 'OK');
CALL pg_temp.probar('suscripcion_push: alta', $$INSERT INTO suscripcion_push (cliente_id, endpoint, clave_p256dh, clave_auth) SELECT c.id, 'https://push.example/abc', 'k1', 'k2' FROM cliente c JOIN usuario u ON u.id = c.id WHERE u.correo='ana@test.com'$$, 'OK');
CALL pg_temp.probar('suscripcion_push: endpoint repetido', $$INSERT INTO suscripcion_push (cliente_id, endpoint, clave_p256dh, clave_auth) SELECT c.id, 'https://push.example/abc', 'k1', 'k2' FROM cliente c JOIN usuario u ON u.id = c.id WHERE u.correo='luis@test.com'$$, '23505');
CALL pg_temp.probar('token_recuperacion: caduca antes de crearse', $$INSERT INTO token_recuperacion (usuario_id, token_hash, fecha_creacion, fecha_expiracion) SELECT id, 'hash1', now(), now() - interval '1 hour' FROM usuario WHERE correo='ana@test.com'$$, '23514');
CALL pg_temp.probar('token_recuperacion: válido', $$INSERT INTO token_recuperacion (usuario_id, token_hash, fecha_expiracion) SELECT id, 'hash1', now() + interval '1 hour' FROM usuario WHERE correo='ana@test.com'$$, 'OK');
CALL pg_temp.probar('token_recuperacion: hash repetido', $$INSERT INTO token_recuperacion (usuario_id, token_hash, fecha_expiracion) SELECT id, 'hash1', now() + interval '1 hour' FROM usuario WHERE correo='luis@test.com'$$, '23505');

CALL pg_temp.probar('evento_uso: sin token ni cliente', $$INSERT INTO evento_uso (tipo) VALUES ('BUSQUEDA_INICIADA')$$, '23514');
CALL pg_temp.probar('evento_uso: tipo inválido', $$INSERT INTO evento_uso (tipo, token_sesion) VALUES ('CLIC_RARO', gen_random_uuid())$$, '23514');
CALL pg_temp.probar('evento_uso: resultado en un tipo que no es MAPA_CONSULTADO', $$INSERT INTO evento_uso (tipo, token_sesion, resultado) VALUES ('BUSQUEDA_INICIADA', gen_random_uuid(), true)$$, '23514');
CALL pg_temp.probar('evento_uso: receta seleccionada (anónimo)', $$INSERT INTO evento_uso (tipo, token_sesion, receta_id) SELECT 'RECETA_SELECCIONADA', gen_random_uuid(), id FROM receta$$, 'OK');
CALL pg_temp.probar('evento_uso: mapa consultado con resultado', $$INSERT INTO evento_uso (tipo, token_sesion, resultado) VALUES ('MAPA_CONSULTADO', gen_random_uuid(), true)$$, 'OK');
CALL pg_temp.probar('evento_uso: biblioteca abierta (cliente)', $$INSERT INTO evento_uso (tipo, cliente_id) SELECT 'BIBLIOTECA_ABIERTA', c.id FROM cliente c JOIN usuario u ON u.id = c.id WHERE u.correo='ana@test.com'$$, 'OK');

CALL pg_temp.probar('borrar municipio en uso: se rechaza', $$DELETE FROM municipio WHERE nombre='Municipio Prueba ES'$$, '23503');
CALL pg_temp.probar('borrar país en uso: se rechaza', $$DELETE FROM pais WHERE codigo='ES'$$, '23503');
CALL pg_temp.probar('borrar la receta original', $$DELETE FROM receta WHERE nombre='Receta Prueba'$$, 'OK');
CALL pg_temp.verificar('la copia sobrevive con procedencia nula (RN-002)', $$(SELECT count(*) = 1 AND bool_and(receta_origen_id IS NULL) FROM copia_personal_receta)$$);
CALL pg_temp.verificar('se borraron las valoraciones de la receta', $$(SELECT count(*) = 0 FROM valoracion v JOIN usuario u ON u.id = v.cliente_id WHERE u.correo LIKE '%@test.com')$$);
CALL pg_temp.verificar('el evento sobrevive con receta nula', $$(SELECT count(*) = 1 FROM evento_uso WHERE tipo='RECETA_SELECCIONADA' AND receta_id IS NULL)$$);
CALL pg_temp.probar('borrar las ofertas', $$DELETE FROM oferta$$, 'OK');
CALL pg_temp.probar('eliminar cuenta de Ana (cascada RF-008)', $$DELETE FROM usuario WHERE correo='ana@test.com'$$, 'OK');
CALL pg_temp.verificar('cascada: sin cliente, copias, calendario, push, token ni eventos de Ana',
  $$(SELECT NOT EXISTS (SELECT 1 FROM cliente c JOIN usuario u USING (id) WHERE u.correo='ana@test.com')
       AND (SELECT count(*) FROM copia_personal_receta) = 0
       AND (SELECT count(*) FROM copia_ingrediente) = 0
       AND (SELECT count(*) FROM entrada_calendario) = 0
       AND (SELECT count(*) FROM suscripcion_push) = 0
       AND (SELECT count(*) FROM token_recuperacion) = 0
       AND (SELECT count(*) FROM evento_uso WHERE tipo='BIBLIOTECA_ABIERTA') = 0)$$);
CALL pg_temp.probar('ascenso: cambiar rol con la fila de cliente aún presente', $$UPDATE usuario SET rol='ADMINISTRADOR' WHERE correo='luis@test.com'$$, '23503');
CALL pg_temp.probar('eliminar cuenta del administrador', $$DELETE FROM usuario WHERE correo='admin@test.com'$$, 'OK');
CALL pg_temp.verificar('SET NULL: la incidencia y su mensaje conservan el historial',
  $$(SELECT (SELECT administrador_id IS NULL FROM incidencia LIMIT 1)
        AND (SELECT count(*) = 1 FROM mensaje_incidencia WHERE autor = 'ADMINISTRADOR' AND autor_usuario_id IS NULL))$$);
CALL pg_temp.probar('preparación: quitar el mensaje del comercio', $$DELETE FROM mensaje_incidencia WHERE autor = 'COMERCIO'$$, 'OK');
CALL pg_temp.probar('eliminar cuenta del comercio (cascada)', $$DELETE FROM usuario WHERE correo='tienda@test.com'$$, 'OK');
CALL pg_temp.verificar('cascada del comercio: sin incidencias ni disponibilidad', $$(SELECT (SELECT count(*) FROM incidencia) = 0 AND (SELECT count(*) FROM disponibilidad_comercio) = 0)$$);

SELECT n, prueba, esperado, obtenido, estado, detalle FROM resultado_pruebas ORDER BY n;
SELECT estado, count(*) AS total FROM resultado_pruebas GROUP BY estado ORDER BY estado;

ROLLBACK;
