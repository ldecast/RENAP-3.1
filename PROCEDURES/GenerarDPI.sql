DELIMITER $$

DROP PROCEDURE IF EXISTS generarDPI $$ CREATE PROCEDURE generarDPI(
    IN cui_persona BIGINT,
    IN fecha_emision VARCHAR(10),
    IN codigo_municipio INTEGER
)

gendpi_proc:BEGIN

DECLARE format_fecha, fecha_nac DATE;

/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE gendpi_proc;
END IF;

/* FALLECIDO */
IF (PersonaViva(cui_persona) = 0) THEN
    SELECT 'LA PERSONA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE gendpi_proc;
END IF;

/* VALIDAR EDAD */
(SELECT fecha_nacimiento INTO fecha_nac FROM acta_nacimiento WHERE persona_cui = cui_persona);
IF (SELECT TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE()) < 18) THEN
    SELECT 'LA EDAD MÍNIMA PARA TRAMITAR DPI ES DE 18.' AS ERROR;
    LEAVE gendpi_proc;
END IF;

/* VALIDAR SI YA TIENE */
IF (SELECT dpi_generado FROM persona WHERE cui = cui_persona) THEN
    SELECT 'LA PERSONA YA POSEE DPI.' AS ERROR;
    LEAVE gendpi_proc;
END IF;

/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_emision, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE gendpi_proc;
END IF;


/* GENERAR DPI */
UPDATE persona
SET dpi_generado = 1, municipio_reside = codigo_municipio
WHERE cui = cui_persona;


/* MENSAJE */
SELECT 'DPI GENERADO' AS MENSAJE;

END $$