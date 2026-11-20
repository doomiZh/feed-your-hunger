UPDATE receta r
SET imagen_url = '/img/recetas/' || v.archivo || '.webp'
FROM (VALUES
    ('Gazpacho andaluz', 'receta-gazpacho-andaluz'),
    ('Tortilla de patatas', 'receta-tortilla-de-patatas'),
    ('Lentejas con chorizo', 'receta-lentejas-con-chorizo'),
    ('Paella de gambas', 'receta-paella-de-gambas'),
    ('Merluza al horno con patatas', 'receta-merluza-horno-patatas'),
    ('Ceviche de lubina', 'receta-ceviche-de-lubina'),
    ('Lomo saltado', 'receta-lomo-saltado'),
    ('Papa a la huancaína', 'receta-papa-a-la-huancaina'),
    ('Ensalada de quinua', 'receta-ensalada-de-quinoa'),
    ('Espaguetis a la carbonara', 'receta-espagueti-a-la-carbonara'),
    ('Risotto de champiñones', 'receta-risotto-de-champiniones'),
    ('Ensalada caprese', 'receta-ensalada-caprese'),
    ('Guacamole', 'receta-crema-de-guacamole'),
    ('Tacos de pollo', 'receta-tacos-de-pollo'),
    ('Tajín de pollo con aceitunas', 'receta-tajin-de-pollo-con-aceitunas'),
    ('Cuscús con garbanzos y verduras', 'receta-cuscus-con-garbanzos-y-verduras'),
    ('Sopa de miso con tofu', 'receta-sopa-de-miso-con-tofu'),
    ('Bol de arroz de sushi con aguacate y pepino', 'receta-bol-arroz-sushi-con-aguacate-y-pepinos'),
    ('Curry de garbanzos', 'receta-curry-de-garbanzos'),
    ('Curry de pollo con leche de coco', 'receta-pollo-al-curry-con-leche-de-coco')
) AS v (nombre, archivo)
WHERE r.nombre = v.nombre;
