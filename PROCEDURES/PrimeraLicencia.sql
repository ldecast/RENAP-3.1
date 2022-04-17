DELIMITER $$

DROP PROCEDURE IF EXISTS AddLicencia $$ CREATE PROCEDURE AddLicencia(
    IN cui_persona INTEGER,
    IN fecha_emision VARCHAR(10),
    IN tipo_licencia VARCHAR(1)
)

primerlic_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE estado_civil_hombre, estado_civil_mujer INTEGER;


/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE primerlic_proc;
END IF;

/* FALLECIDO */
IF (PersonaViva(cui_persona) = 0) THEN
    SELECT 'LA PERSONA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE primerlic_proc;
END IF;

/* YA TIENE LICENCIA */
IF (TieneLicencia(cui_persona) = 1) THEN
    SELECT 'LA PERSONA YA POSEE LICENCIA.' AS ERROR;
    LEAVE primerlic_proc;
END IF;

/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_emision, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE primerlic_proc;
END IF;

/* VALIDAR EDAD */
IF (SELECT TIMESTAMPDIFF(YEAR, format_fecha, CURDATE()) < 16) THEN
    SELECT 'LA EDAD MÍNIMA PARA LICENCIA ES DE 16.' AS ERROR;
    LEAVE primerlic_proc;
END IF;

/* VALIDAR TIPO LICENCIA */
IF (tipo_licencia != 'E' AND tipo_licencia != 'C' AND tipo_licencia != 'M') THEN
    SELECT 'PRIMER LICENCIA DEBE SER TIPO E/C/M.' AS ERROR;
    LEAVE primerlic_proc;
END IF;


/* NUEVA LICENCIA */
INSERT INTO licencia (
        fecha_emision,
        fecha_vencimiento,
        persona_cui,
        tipo_licencia_tipo
    )
VALUES (
        format_fecha,
        DATE_ADD(format_fecha, INTERVAL 1 YEAR),
        cui_persona,
        tipo_licencia
    );

/* MENSAJE */
SELECT 'LICENCIA REGISTRADA' AS MENSAJE;

END $$