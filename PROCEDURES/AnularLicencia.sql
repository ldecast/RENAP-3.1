DELIMITER $$

DROP PROCEDURE IF EXISTS anularLicencia $$ CREATE PROCEDURE anularLicencia(
    IN no_licencia INTEGER,
    IN fecha_anulacion VARCHAR(10),
    IN motivo VARCHAR(255)
)

anulic_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE cui_persona BIGINT;

/* NO EXISTE */
IF (SELECT NOT EXISTS (SELECT 1 FROM licencia l WHERE l.id_licencia = no_licencia)) THEN
    SELECT 'NÚMERO DE LICENCIA NO VÁLIDO.' AS ERROR;
    LEAVE anulic_proc;
END IF;

/* OBTENER CUI */
(SELECT persona_cui INTO cui_persona FROM licencia WHERE id_licencia = no_licencia);

/* FALLECIDO */
IF (PersonaViva(cui_persona) = 0) THEN
    SELECT 'LA PERSONA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE anulic_proc;
END IF;

/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_anulacion, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE anulic_proc;
END IF;


/* ANULAR */
UPDATE licencia
SET fecha_anulada = format_fecha
WHERE id_licencia = no_licencia;


/* MENSAJE */
SELECT 'LICENCIA ANULADA' AS MENSAJE;

END $$