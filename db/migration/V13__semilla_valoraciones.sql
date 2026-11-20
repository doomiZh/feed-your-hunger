INSERT INTO usuario (correo, contrasena_hash, rol) VALUES
    ('lucia.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('carlos.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('maria.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('javier.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('ana.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('diego.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('sofia.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE'),
    ('pablo.demo@feedyourhunger.test', '$2b$12$xvRSm5DyBw5zDn7rRbo/QO4jAT1bEJZ1OkfDd64xvxX/OdHyHpnya', 'CLIENTE');

INSERT INTO cliente (id, nombre, nacionalidad_pais, residencia_pais, residencia_municipio_id, fecha_consentimiento)
SELECT u.id, v.nombre, 'ES', 'ES', m.id, now()
FROM (VALUES
    ('lucia.demo@feedyourhunger.test', 'Lucía Fernández'),
    ('carlos.demo@feedyourhunger.test', 'Carlos Ruiz'),
    ('maria.demo@feedyourhunger.test', 'María Gómez'),
    ('javier.demo@feedyourhunger.test', 'Javier López'),
    ('ana.demo@feedyourhunger.test', 'Ana Torres'),
    ('diego.demo@feedyourhunger.test', 'Diego Quispe'),
    ('sofia.demo@feedyourhunger.test', 'Sofía Martín'),
    ('pablo.demo@feedyourhunger.test', 'Pablo Navarro')
) AS v (correo, nombre)
JOIN usuario u ON u.correo = v.correo
JOIN municipio m ON m.nombre = 'Zaragoza' AND m.pais_codigo = 'ES';

INSERT INTO valoracion (cliente_id, receta_id, puntuacion, fecha)
SELECT u.id, r.id, v.puntuacion, now() - make_interval(days => v.dias)
FROM (VALUES
    ('sofia.demo@feedyourhunger.test', 'Gazpacho andaluz', 2, 53),
    ('maria.demo@feedyourhunger.test', 'Gazpacho andaluz', 2, 39),
    ('diego.demo@feedyourhunger.test', 'Gazpacho andaluz', 1, 36),
    ('ana.demo@feedyourhunger.test', 'Gazpacho andaluz', 4, 20),
    ('lucia.demo@feedyourhunger.test', 'Gazpacho andaluz', 2, 35),
    ('javier.demo@feedyourhunger.test', 'Gazpacho andaluz', 4, 7),
    ('pablo.demo@feedyourhunger.test', 'Gazpacho andaluz', 5, 30),
    ('carlos.demo@feedyourhunger.test', 'Gazpacho andaluz', 1, 55),
    ('pablo.demo@feedyourhunger.test', 'Tortilla de patatas', 5, 43),
    ('lucia.demo@feedyourhunger.test', 'Tortilla de patatas', 3, 17),
    ('diego.demo@feedyourhunger.test', 'Tortilla de patatas', 4, 23),
    ('javier.demo@feedyourhunger.test', 'Tortilla de patatas', 4, 60),
    ('ana.demo@feedyourhunger.test', 'Tortilla de patatas', 2, 21),
    ('lucia.demo@feedyourhunger.test', 'Lentejas con chorizo', 5, 34),
    ('ana.demo@feedyourhunger.test', 'Lentejas con chorizo', 2, 28),
    ('maria.demo@feedyourhunger.test', 'Lentejas con chorizo', 5, 7),
    ('carlos.demo@feedyourhunger.test', 'Paella de gambas', 4, 47),
    ('ana.demo@feedyourhunger.test', 'Paella de gambas', 1, 52),
    ('maria.demo@feedyourhunger.test', 'Paella de gambas', 1, 24),
    ('sofia.demo@feedyourhunger.test', 'Paella de gambas', 2, 17),
    ('diego.demo@feedyourhunger.test', 'Paella de gambas', 1, 9),
    ('pablo.demo@feedyourhunger.test', 'Paella de gambas', 1, 39),
    ('javier.demo@feedyourhunger.test', 'Paella de gambas', 5, 19),
    ('diego.demo@feedyourhunger.test', 'Merluza al horno con patatas', 4, 47),
    ('sofia.demo@feedyourhunger.test', 'Merluza al horno con patatas', 5, 18),
    ('sofia.demo@feedyourhunger.test', 'Ceviche de lubina', 5, 13),
    ('diego.demo@feedyourhunger.test', 'Ceviche de lubina', 2, 4),
    ('carlos.demo@feedyourhunger.test', 'Ceviche de lubina', 5, 2),
    ('lucia.demo@feedyourhunger.test', 'Lomo saltado', 5, 37),
    ('javier.demo@feedyourhunger.test', 'Lomo saltado', 3, 16),
    ('carlos.demo@feedyourhunger.test', 'Lomo saltado', 4, 16),
    ('ana.demo@feedyourhunger.test', 'Lomo saltado', 2, 55),
    ('diego.demo@feedyourhunger.test', 'Lomo saltado', 2, 6),
    ('diego.demo@feedyourhunger.test', 'Papa a la huancaína', 2, 10),
    ('carlos.demo@feedyourhunger.test', 'Papa a la huancaína', 2, 28),
    ('sofia.demo@feedyourhunger.test', 'Papa a la huancaína', 2, 20),
    ('maria.demo@feedyourhunger.test', 'Papa a la huancaína', 4, 37),
    ('diego.demo@feedyourhunger.test', 'Ensalada de quinua', 5, 5),
    ('pablo.demo@feedyourhunger.test', 'Ensalada de quinua', 4, 25),
    ('maria.demo@feedyourhunger.test', 'Ensalada de quinua', 2, 5),
    ('lucia.demo@feedyourhunger.test', 'Ensalada de quinua', 2, 37),
    ('javier.demo@feedyourhunger.test', 'Ensalada de quinua', 2, 13),
    ('carlos.demo@feedyourhunger.test', 'Ensalada de quinua', 4, 46),
    ('sofia.demo@feedyourhunger.test', 'Espaguetis a la carbonara', 5, 33),
    ('maria.demo@feedyourhunger.test', 'Espaguetis a la carbonara', 5, 45),
    ('diego.demo@feedyourhunger.test', 'Espaguetis a la carbonara', 2, 40),
    ('ana.demo@feedyourhunger.test', 'Espaguetis a la carbonara', 5, 52),
    ('javier.demo@feedyourhunger.test', 'Espaguetis a la carbonara', 1, 29),
    ('javier.demo@feedyourhunger.test', 'Risotto de champiñones', 4, 7),
    ('diego.demo@feedyourhunger.test', 'Risotto de champiñones', 5, 54),
    ('lucia.demo@feedyourhunger.test', 'Risotto de champiñones', 2, 52),
    ('sofia.demo@feedyourhunger.test', 'Risotto de champiñones', 5, 31),
    ('carlos.demo@feedyourhunger.test', 'Guacamole', 3, 12),
    ('pablo.demo@feedyourhunger.test', 'Guacamole', 3, 56),
    ('lucia.demo@feedyourhunger.test', 'Guacamole', 1, 60),
    ('carlos.demo@feedyourhunger.test', 'Tacos de pollo', 4, 5),
    ('ana.demo@feedyourhunger.test', 'Tacos de pollo', 4, 56),
    ('javier.demo@feedyourhunger.test', 'Tacos de pollo', 5, 37),
    ('pablo.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 3, 28),
    ('lucia.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 2, 27),
    ('maria.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 2, 52),
    ('ana.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 5, 26),
    ('carlos.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 3, 4),
    ('javier.demo@feedyourhunger.test', 'Tajín de pollo con aceitunas', 4, 60),
    ('lucia.demo@feedyourhunger.test', 'Cuscús con garbanzos y verduras', 4, 17),
    ('javier.demo@feedyourhunger.test', 'Cuscús con garbanzos y verduras', 2, 56),
    ('pablo.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 3, 50),
    ('lucia.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 2, 12),
    ('carlos.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 2, 2),
    ('ana.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 5, 43),
    ('maria.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 3, 19),
    ('javier.demo@feedyourhunger.test', 'Bol de arroz de sushi con aguacate y pepino', 2, 32),
    ('lucia.demo@feedyourhunger.test', 'Curry de garbanzos', 1, 16),
    ('ana.demo@feedyourhunger.test', 'Curry de garbanzos', 5, 27),
    ('javier.demo@feedyourhunger.test', 'Curry de garbanzos', 5, 30),
    ('sofia.demo@feedyourhunger.test', 'Curry de garbanzos', 3, 41),
    ('maria.demo@feedyourhunger.test', 'Curry de garbanzos', 1, 9),
    ('diego.demo@feedyourhunger.test', 'Curry de garbanzos', 4, 19),
    ('pablo.demo@feedyourhunger.test', 'Curry de garbanzos', 2, 5),
    ('diego.demo@feedyourhunger.test', 'Curry de pollo con leche de coco', 4, 38),
    ('pablo.demo@feedyourhunger.test', 'Curry de pollo con leche de coco', 2, 30),
    ('maria.demo@feedyourhunger.test', 'Curry de pollo con leche de coco', 4, 46)
) AS v (correo, receta, puntuacion, dias)
JOIN usuario u ON u.correo = v.correo
JOIN receta r ON r.nombre = v.receta;

UPDATE receta
SET valoracion_promedio = s.promedio,
    numero_valoraciones = s.total
FROM (
    SELECT receta_id, round(avg(puntuacion), 2) AS promedio, count(*)::int AS total
    FROM valoracion
    GROUP BY receta_id
) AS s
WHERE receta.id = s.receta_id;
