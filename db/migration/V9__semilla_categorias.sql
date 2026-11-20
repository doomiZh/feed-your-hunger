INSERT INTO categoria (
        nombre,
        permite_varias_opciones,
        es_obligatoria,
        combinacion_filtro
    )
VALUES ('Dieta', TRUE, FALSE, 'TODAS'),
    ('Ingrediente principal', FALSE, TRUE, 'ALGUNA'),
    ('Nivel de preparación', FALSE, TRUE, 'ALGUNA');
INSERT INTO opcion_categoria (categoria_id, nombre)
SELECT c.id,
    v.opcion
FROM (
        VALUES ('Dieta', 'Vegana'),
            ('Dieta', 'Vegetariana'),
            ('Dieta', 'Sin gluten'),
            ('Dieta', 'Sin lactosa'),
            ('Dieta', 'Keto'),
            ('Dieta', 'Paleo'),
            ('Dieta', 'Hipocalórica'),
            ('Dieta', 'Mediterránea'),
            ('Dieta', 'Alta en proteína'),
            ('Dieta', 'Sin azúcar añadido'),
            ('Ingrediente principal', 'Cereales y harinas'),
            ('Ingrediente principal', 'Legumbres'),
            ('Ingrediente principal', 'Verduras y hortalizas'),
            ('Ingrediente principal', 'Frutas'),
            ('Ingrediente principal', 'Proteínas animales'),
            ('Ingrediente principal', 'Lácteos'),
            ('Ingrediente principal', 'Grasas y aceites'),
            ('Ingrediente principal', 'Especias'),
            ('Ingrediente principal', 'Edulcorantes'),
            ('Ingrediente principal', 'Líquidos base'),
            ('Nivel de preparación', 'Fácil'),
            ('Nivel de preparación', 'Medio'),
            ('Nivel de preparación', 'Difícil')
    ) AS v (categoria, opcion)
    JOIN categoria c ON c.nombre = v.categoria;