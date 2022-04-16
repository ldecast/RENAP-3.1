DELIMITER $$

DROP PROCEDURE IF EXISTS AddDefuncion $$ CREATE PROCEDURE AddDefuncion(
    IN cui_fallecido BIGINT,
    IN fecha_defuncion VARCHAR(10),
    IN motivo_fallecimiento VARCHAR(255),
    IN codigo_municipio INTEGER
)

def_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE fecha_nac DATE;
DECLARE estado_civil INTEGER;

/* NO EXISTE */
IF (ExistePersona(cui_fallecido) = 0) THEN
    LEAVE def_proc;
END IF;

/* YA FALLECIDO */
IF (PersonaViva(cui_fallecido) = 0) THEN
    LEAVE def_proc;
END IF;

(
    SELECT STR_TO_DATE(fecha_defuncion, '%d-%m-%Y') INTO format_fecha
);

(
    SELECT fecha_nacimiento
    INTO fecha_nac
    FROM acta_nacimiento
    WHERE persona_cui = cui_fallecido
);

/* FECHA INCONGRUENTE */
IF (format_fecha > CURDATE() OR format_fecha < fecha_nac) THEN
    LEAVE def_proc;
END IF;

(
    SELECT estado_civil_id_estado
    INTO estado_civil
    FROM persona
    WHERE cui = cui_fallecido
);

/* SI ESTÁ CASADO, ENVIUDAR CONYUGE */
IF (estado_civil = 2) THEN
    /* SELECT IF(cui_hombre=0000000011101, cui_hombre, cui_mujer)
    FROM acta_matrimonio
    WHERE cui_hombre = 0000000011101 OR cui_mujer = 0000000011101 */
END IF;

/* ACTA DE DEFUNCIÓN */
INSERT INTO acta_defuncion (
        fecha_fallecimiento,
        motivo,
        municipio_id_municipio,
        persona_cui
    )
VALUES (
        format_fecha,
        motivo_fallecimiento,
        codigo_municipio,
        cui_fallecido
    );

END $$