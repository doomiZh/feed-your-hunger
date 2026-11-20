CREATE PROCEDURE recalcular_valoraciones()
LANGUAGE sql
AS $$
    UPDATE receta r
    SET valoracion_promedio = s.promedio,
        numero_valoraciones = coalesce(s.total, 0)
    FROM receta r2
    LEFT JOIN (
        SELECT receta_id, round(avg(puntuacion), 2) AS promedio, count(*)::int AS total
        FROM valoracion
        GROUP BY receta_id
    ) s ON s.receta_id = r2.id
    WHERE r.id = r2.id;
$$;

CREATE PROCEDURE recalcular_precio_promedio()
LANGUAGE sql
AS $$
    UPDATE ingrediente i
    SET precio_promedio = p.promedio,
        fecha_calculo_precio = now()
    FROM ingrediente i2
    LEFT JOIN (
        SELECT d.ingrediente_id, round(avg(d.precio), 2) AS promedio
        FROM disponibilidad_comercio d
        JOIN comercio c ON c.id = d.comercio_id AND c.estado = 'ACTIVO'
        WHERE d.disponible AND d.precio IS NOT NULL
        GROUP BY d.ingrediente_id
    ) p ON p.ingrediente_id = i2.id
    WHERE i.id = i2.id;
$$;

CREATE PROCEDURE recalcular_costo_estimado()
LANGUAGE sql
AS $$
    UPDATE receta r
    SET costo_estimado = c.costo
    FROM receta r2
    LEFT JOIN (
        SELECT ri.receta_id,
               CASE WHEN count(*) = count(i.precio_promedio) THEN sum(i.precio_promedio) END AS costo
        FROM receta_ingrediente ri
        JOIN ingrediente i ON i.id = ri.ingrediente_id
        GROUP BY ri.receta_id
    ) c ON c.receta_id = r2.id
    WHERE r.id = r2.id;
$$;

CREATE PROCEDURE recalcular_tendencia(p_ventana_dias INTEGER DEFAULT 30)
LANGUAGE sql
AS $$
    UPDATE receta r
    SET tendencia = round(coalesce(e.aperturas, 0) + coalesce(v.media, 0) / 10.0, 4),
        fecha_calculo_tendencia = now()
    FROM receta r2
    LEFT JOIN (
        SELECT receta_id, count(*) AS aperturas
        FROM evento_uso
        WHERE tipo = 'RECETA_SELECCIONADA'
          AND receta_id IS NOT NULL
          AND instante >= now() - make_interval(days => p_ventana_dias)
        GROUP BY receta_id
    ) e ON e.receta_id = r2.id
    LEFT JOIN (
        SELECT receta_id, avg(puntuacion) AS media
        FROM valoracion
        WHERE fecha >= now() - make_interval(days => p_ventana_dias)
        GROUP BY receta_id
    ) v ON v.receta_id = r2.id
    WHERE r.id = r2.id;
$$;

CREATE PROCEDURE recalcular_derivados(p_ventana_dias INTEGER DEFAULT 30)
LANGUAGE sql
AS $$
    CALL recalcular_valoraciones();
    CALL recalcular_precio_promedio();
    CALL recalcular_costo_estimado();
    CALL recalcular_tendencia(p_ventana_dias);
$$;
