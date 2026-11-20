INSERT INTO usuario (correo, contrasena_hash, rol)
VALUES (
        'admin@feedyourhunger.test',
        '$2b$12$TGGgOoHyo84Kh8VgrdOSS.N5E1xwKZsy8FUPSEmiuCPP3ahQ5iRUq',
        'ADMINISTRADOR'
    );
INSERT INTO administrador (id)
SELECT id
FROM usuario
WHERE correo = 'admin@feedyourhunger.test'
    AND rol = 'ADMINISTRADOR';