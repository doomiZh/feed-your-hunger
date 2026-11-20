INSERT INTO evento_uso (tipo, token_sesion, receta_id, instante)
SELECT 'RECETA_SELECCIONADA',
       gen_random_uuid(),
       r.id,
       now() - make_interval(
           days => CASE WHEN g.n <= v.recientes THEN (g.n * 7 + length(v.receta)) % 30 ELSE 31 + (g.n * 5) % 14 END,
           hours => (g.n * 5) % 24
       )
FROM (VALUES
    ('Paella de gambas', 28, 6),
    ('Tortilla de patatas', 28, 9),
    ('Lomo saltado', 24, 5),
    ('Ceviche de lubina', 24, 7),
    ('Tacos de pollo', 19, 4),
    ('Guacamole', 16, 3),
    ('Gazpacho andaluz', 14, 6),
    ('Curry de garbanzos', 12, 2),
    ('Espaguetis a la carbonara', 31, 8),
    ('Risotto de champiñones', 9, 3),
    ('Papa a la huancaína', 11, 4),
    ('Lentejas con chorizo', 7, 5),
    ('Merluza al horno con patatas', 6, 2),
    ('Ensalada de quinua', 5, 1),
    ('Tajín de pollo con aceitunas', 8, 3),
    ('Cuscús con garbanzos y verduras', 4, 2),
    ('Curry de pollo con leche de coco', 13, 5),
    ('Bol de arroz de sushi con aguacate y pepino', 3, 1),
    ('Ensalada caprese', 2, 0),
    ('Sopa de miso con tofu', 0, 2)
) AS v (receta, recientes, anteriores)
JOIN receta r ON r.nombre = v.receta
CROSS JOIN LATERAL generate_series(1, v.recientes + v.anteriores) AS g (n);

CALL recalcular_derivados(30);
