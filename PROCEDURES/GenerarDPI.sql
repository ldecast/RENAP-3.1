DELIMITER $$

DROP PROCEDURE IF EXISTS generarDPI $$ CREATE PROCEDURE generarDPI(
    IN cui_persona BIGINT,
    IN fecha_emision VARCHAR(10),
    IN codigo_municipio INTEGER
)

gendpi_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE cui_persona BIGINT;

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