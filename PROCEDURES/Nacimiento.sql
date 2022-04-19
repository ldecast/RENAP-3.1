DELIMITER $$
DROP PROCEDURE IF EXISTS AddNacimiento $$ CREATE PROCEDURE AddNacimiento(
    IN dpi_padre BIGINT,
    IN dpi_madre BIGINT,
    IN primer_nombre VARCHAR(50),
    IN segundo_nombre VARCHAR(50),
    IN tercer_nombre VARCHAR(50),
    IN fecha_nacimiento VARCHAR(10),
    IN codigo_municipio INTEGER,
    IN genero VARCHAR(1)
)
nac_proc:BEGIN

DECLARE cui BIGINT;
DECLARE fecha DATE;
DECLARE genero_padre, genero_madre VARCHAR(1);

/* NO EXISTE */
IF (ExistePersona(dpi_padre) = 0 OR ExistePersona(dpi_madre) = 0) THEN
    SELECT 'DPI PADRE O MADRE INCORRECTOS.' AS ERROR;
    LEAVE nac_proc;
END IF;

/* OBTENER GÉNEROS */
(SELECT genero INTO genero_padre FROM acta_nacimiento WHERE persona_cui = dpi_padre);
(SELECT genero INTO genero_madre FROM acta_nacimiento WHERE persona_cui = dpi_madre);

/* VALIDAR GÉNEROS */
IF (genero_padre != 'M' OR genero_madre != 'F') THEN
    SELECT 'LOS GÉNEROS DE LOS PADRES NO CORRESPONDEN.' AS ERROR;
    LEAVE nac_proc;
END IF;

/* FECHA INCONGRUENTE */
(SELECT STR_TO_DATE(fecha_nacimiento, '%d-%m-%Y') INTO fecha);
IF (fecha > CURDATE()) THEN
    SELECT 'FECHA POSTERIOR A LA FECHA DE REGISTRO.' AS ERROR;
    LEAVE nac_proc;
END IF;

(
    SELECT CONCAT(
            (
                SELECT MAX(no_registro) + 1
                FROM persona
            ),
            (
                SELECT m.departamento_id_departamento
                FROM municipio m
                WHERE m.id_municipio = codigo_municipio
            ),
            codigo_municipio
        ) INTO cui
    FROM persona
    WHERE (
            SELECT MAX(no_registro)
            FROM persona
        ) = no_registro
);

/* PERSONA */
INSERT INTO persona (
        cui,
        primer_nombre,
        segundo_nombre,
        tercer_nombre,
        primer_apellido,
        segundo_apellido
    )
VALUES (
        cui,
        primer_nombre,
        segundo_nombre,
        tercer_nombre,
        (
            SELECT p.primer_apellido
            FROM persona p
            WHERE p.cui = dpi_padre
        ),
        (
            SELECT p.primer_apellido
            FROM persona p
            WHERE p.cui = dpi_madre
        )
    );

/* ACTA DE NACIMIENTO */
INSERT INTO acta_nacimiento (
        cui_padre,
        cui_madre,
        fecha_nacimiento,
        genero,
        municipio_id_municipio,
        persona_cui
    )
VALUES (
        dpi_padre,
        dpi_madre,
        fecha,
        genero,
        codigo_municipio,
        cui
    );

/* MENSAJE */
SELECT 'NACIMIENTO REGISTRADO' AS MENSAJE;

END $$