DELIMITER $$

DROP PROCEDURE IF EXISTS renewLicencia $$ CREATE PROCEDURE renewLicencia(
    IN no_licencia INTEGER,
    IN fecha_renovacion VARCHAR(10),
    IN cantidad_renovacion INTEGER,
    IN tipo_licencia VARCHAR(1)
)

renovlic_proc:BEGIN

DECLARE format_fecha, fecha_nac DATE;
DECLARE cui_persona BIGINT;
DECLARE pre_lic INTEGER DEFAULT 0;

/* NO EXISTE */
IF (SELECT NOT EXISTS (SELECT 1 FROM licencia l WHERE l.id_licencia = no_licencia)) THEN
    SELECT 'NÚMERO DE LICENCIA NO VÁLIDO.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

/* OBTENER CUI */
(SELECT persona_cui INTO cui_persona FROM licencia WHERE id_licencia = no_licencia);

/* FALLECIDO */
IF (PersonaViva(cui_persona) = 0) THEN
    SELECT 'LA PERSONA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

/* ESTÁ ANULADA */
IF (SELECT anulada FROM licencia WHERE id_licencia = no_licencia) THEN
    SELECT 'LA LICENCIA SE ENCUENTRA ANULADA.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_renovacion, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

/* VALIDAR RENOVACIÓN */
IF (cantidad_renovacion < 1 OR cantidad_renovacion > 5) THEN
    SELECT 'LA RENOVACIÓN PUEDE SER DE 1 A 5 AÑOS.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

/* VALIDAR LETRA */
IF (tipo_licencia != 'A' AND tipo_licencia != 'B' AND tipo_licencia != 'C' AND tipo_licencia != 'M' AND tipo_licencia != 'E') THEN
    SELECT 'TIPO DE LICENCIA NO VÁLIDO.' AS ERROR;
    LEAVE renovlic_proc;
END IF;

(SELECT fecha_nacimiento INTO fecha_nac FROM acta_nacimiento WHERE persona_cui = cui_persona);

/* VALIDAR SI ES OTRO TIPO DE LICENCIA */
IF ((SELECT tipo_licencia_tipo FROM licencia WHERE id_licencia = no_licencia) != tipo_licencia) THEN
    /* VALIDAR SI NO TIENE OTRA LICENCIA YA CON ESE TIPO Y RENOVAR ESA */
    (SELECT id_licencia INTO pre_lic FROM licencia WHERE tipo_licencia_tipo = tipo_licencia AND persona_cui = cui_persona);
    IF (pre_lic != 0) THEN
        CALL renewLicencia(pre_lic, fecha_renovacion, cantidad_renovacion, tipo_licencia);
        LEAVE renovlic_proc;
    END IF;
    /* VALIDAR SI CUMPLE LAS CONDICIONES */
    CASE tipo_licencia
        WHEN 'A' THEN
            IF (SELECT TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE()) < 25) THEN
                SELECT 'LA EDAD MÍNIMA PARA LICENCIA TIPO A ES DE 25.' AS ERROR;
                LEAVE renovlic_proc;
            END IF;
            IF ((
                SELECT SUM(TIMESTAMPDIFF(YEAR, fecha_emision, CURDATE()))
                FROM licencia
                WHERE persona_cui = cui_persona AND (tipo_licencia_tipo = 'B' OR tipo_licencia_tipo = 'C')
            ) < 3) THEN
                SELECT 'DEBE TENER AL MENOS 3 AÑOS CON LICENCIA TIPO B/C.' AS ERROR;
                LEAVE renovlic_proc;
            END IF;

        WHEN 'B' THEN
            IF (SELECT TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE()) < 23) THEN
                SELECT 'LA EDAD MÍNIMA PARA LICENCIA TIPO B ES DE 23.' AS ERROR;
                LEAVE renovlic_proc;
            END IF;
            IF ((
                SELECT SUM(TIMESTAMPDIFF(YEAR, fecha_emision, CURDATE()))
                FROM licencia
                WHERE persona_cui = cui_persona AND tipo_licencia_tipo = 'C'
            ) < 2) THEN
                SELECT 'DEBE TENER AL MENOS 2 AÑOS CON LICENCIA TIPO C.' AS ERROR;
                LEAVE renovlic_proc;
            END IF;
            ELSE 
                BEGIN
                END;
    END CASE;
    /* REGISTRAR NUEVA LICENCIA */
    INSERT INTO licencia (
            fecha_emision,
            fecha_vencimiento,
            persona_cui,
            tipo_licencia_tipo
        )
    VALUES (
            format_fecha,
            DATE_ADD(format_fecha, INTERVAL cantidad_renovacion YEAR),
            cui_persona,
            tipo_licencia
        );
    SELECT 'LICENCIA DE NUEVO TIPO REGISTRADA' AS MENSAJE;
    LEAVE renovlic_proc;
END IF;


/* RENOVAR EXPIRACIÓN */
CASE
    /* LA RENUEVA ANTES DEL VENCIMIENTO */
    WHEN (
        (SELECT TIMESTAMPDIFF(DAY, fecha_vencimiento, format_fecha)
        FROM licencia
        WHERE id_licencia = no_licencia) <= 0
    ) THEN
        UPDATE licencia
        SET fecha_vencimiento = DATE_ADD(fecha_vencimiento, INTERVAL cantidad_renovacion YEAR)
        WHERE id_licencia = no_licencia;
    /* LA RENUEVA YA EXPIRADA */
    ELSE
        UPDATE licencia
        SET fecha_vencimiento = DATE_ADD(format_fecha, INTERVAL cantidad_renovacion YEAR)
        WHERE id_licencia = no_licencia;
END CASE;


/* MENSAJE */
SELECT 'LICENCIA RENOVADA' AS MENSAJE;

END $$