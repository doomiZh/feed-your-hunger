WITH candidatas AS (
    SELECT d.comercio_id,
        d.ingrediente_id,
        d.precio,
        row_number() OVER (
            PARTITION BY d.comercio_id
            ORDER BY md5(
                    d.comercio_id::text || ':' || d.ingrediente_id::text
                )
        ) AS orden
    FROM disponibilidad_comercio d
        JOIN comercio c ON c.id = d.comercio_id
        AND c.estado = 'ACTIVO'
        JOIN ingrediente i ON i.id = d.ingrediente_id
        AND i.estado = 'ACTIVO'
    WHERE d.disponible
        AND d.precio IS NOT NULL
        AND d.precio > 0
)
INSERT INTO oferta (
        comercio_id,
        ingrediente_id,
        precio_ofertado,
        fecha_fin,
        estado
    )
SELECT ca.comercio_id,
    ca.ingrediente_id,
    greatest(round(ca.precio * 0.80, 2), 0.01),
    CASE
        ca.orden
        WHEN 4 THEN current_date - 3
        ELSE current_date + (3 + ca.orden * 4)::integer
    END,
    CASE
        ca.orden
        WHEN 4 THEN 'VENCIDA'
        WHEN 5 THEN 'RETIRADA'
        ELSE 'VIGENTE'
    END
FROM candidatas ca
WHERE ca.orden <= 5
    AND NOT EXISTS (
        SELECT 1
        FROM oferta o
        WHERE o.comercio_id = ca.comercio_id
            AND o.ingrediente_id = ca.ingrediente_id
    );
SELECT u.correo AS comercio,
    i.nombre AS ingrediente,
    d.precio AS precio_normal,
    o.precio_ofertado,
    o.fecha_fin,
    o.estado
FROM oferta o
    JOIN usuario u ON u.id = o.comercio_id
    JOIN ingrediente i ON i.id = o.ingrediente_id
    JOIN disponibilidad_comercio d ON d.comercio_id = o.comercio_id
    AND d.ingrediente_id = o.ingrediente_id
ORDER BY u.correo,
    o.estado,
    i.nombre;