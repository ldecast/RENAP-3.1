DELIMITER $$

DROP PROCEDURE IF EXISTS AddMatrimonio $$ CREATE PROCEDURE AddMatrimonio(
    IN dpi_hombre BIGINT,
    IN dpi_mujer BIGINT,
    IN fecha_matrimonio VARCHAR(10)
)

matr_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE genero_hombre, genero_mujer VARCHAR(1);
DECLARE estado_civil_hombre, estado_civil_mujer INTEGER;

/* NO EXISTE */
IF (ExistePersona(dpi_hombre) = 0 OR ExistePersona(dpi_mujer) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE matr_proc;
END IF;

/* YA FALLECIDO */
IF (PersonaViva(dpi_hombre) = 0 OR PersonaViva(dpi_mujer) = 0) THEN
    SELECT 'LA PERSONA YA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE matr_proc;
END IF;

/* NO TIENE DPI */
IF (TieneDPI(dpi_hombre) = 0 OR TieneDPI(dpi_mujer) = 0) THEN
    SELECT 'AMBAS PERSONAS DEBEN DE CONTAR CON DPI Y TENER 18 AÑOS.' AS ERROR;
    LEAVE matr_proc;
END IF;

/* OBTENER ESTADOS CIVILES ACTUALES */
(SELECT estado_civil_id_estado INTO estado_civil_hombre FROM persona WHERE cui = dpi_hombre);
(SELECT estado_civil_id_estado INTO estado_civil_mujer FROM persona WHERE cui = dpi_mujer);

/* SI ALGUNO YA ESTÁ CASADO */
IF (estado_civil_hombre = 2 OR estado_civil_mujer = 2) THEN
    SELECT 'NO PUEDE HABER UN MATRIMONIO VIGENTE.' AS ERROR;
    LEAVE matr_proc;
END IF;

/* OBTENER GÉNEROS */
(SELECT genero INTO genero_hombre FROM acta_nacimiento WHERE persona_cui = dpi_hombre);
(SELECT genero INTO genero_mujer FROM acta_nacimiento WHERE persona_cui = dpi_mujer);

/* VALIDAR GÉNEROS */
IF (genero_hombre != 'M' OR genero_mujer != 'F') THEN
    SELECT 'LOS GÉNEROS DEBEN CORRESPONDER.' AS ERROR;
    LEAVE matr_proc;
END IF;

/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_matrimonio, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE matr_proc;
END IF;


/* ACTA DE MATRIMINOIO */
INSERT INTO acta_matrimonio (
        fecha_matrimonio,
        cui_hombre,
        cui_mujer
    )
VALUES (
        format_fecha,
        dpi_hombre,
        dpi_mujer
    );

/* MENSAJE */
SELECT 'MATRIMONIO REGISTRADO' AS MENSAJE;

END $$