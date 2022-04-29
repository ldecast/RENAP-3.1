DELIMITER $$

DROP PROCEDURE IF EXISTS AddDivorcio $$ CREATE PROCEDURE AddDivorcio(
    IN acta_matrimonio INTEGER,
    IN fecha_divorcio VARCHAR(10)
)

divor_proc:BEGIN

DECLARE format_fecha DATE;
DECLARE dpi_hombre, dpi_mujer BIGINT;
DECLARE estado_civil_hombre, estado_civil_mujer INTEGER;

/* OBTENER DPI DE AMBOS */
(SELECT cui_hombre, cui_mujer INTO dpi_hombre, dpi_mujer FROM acta_matrimonio WHERE id_acta = acta_matrimonio);


/* YA FALLECIDO */
IF (PersonaViva(dpi_hombre) = 0 OR PersonaViva(dpi_mujer) = 0) THEN
    SELECT 'LA PERSONA YA SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE divor_proc;
END IF;

/* OBTENER ESTADOS CIVILES ACTUALES */
(SELECT estado_civil_id_estado INTO estado_civil_hombre FROM persona WHERE cui = dpi_hombre);
(SELECT estado_civil_id_estado INTO estado_civil_mujer FROM persona WHERE cui = dpi_mujer);

/* VALIDAR ESTADO CIVIL */
IF (estado_civil_hombre != 2 OR estado_civil_mujer != 2) THEN
    SELECT 'NO APARECE ESTADO CIVIL CASADO.' AS ERROR;
    LEAVE divor_proc;
END IF;

/* VALIDAR QUE ESTÉN CASADOS ENTRE ELLOS */
IF (
    ((SELECT cui_conyuge FROM persona WHERE cui = dpi_hombre) != dpi_mujer)
    OR
    ((SELECT cui_conyuge FROM persona WHERE cui = dpi_mujer) != dpi_hombre)
) THEN
    SELECT 'LA PAREJA TIENE OTRO MATRIMONIO ACTIVO.' AS ERROR;
    LEAVE divor_proc;
END IF;


/* VALIDAR FECHA */
(SELECT STR_TO_DATE(fecha_divorcio, '%d-%m-%Y') INTO format_fecha);
IF (format_fecha > CURDATE()) THEN
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
    LEAVE divor_proc;
END IF;


/* ACTA DE DIVORCIO */
INSERT INTO acta_divorcio (
        fecha_divorcio,
        id_matrimonio
    )
VALUES (
        format_fecha,
        acta_matrimonio
    );

/* ACTUALIZAR ESTADO CIVIL */
UPDATE persona
SET estado_civil_id_estado = 3, cui_conyuge = NULL
WHERE cui = dpi_hombre;

UPDATE persona
SET estado_civil_id_estado = 3, cui_conyuge = NULL
WHERE cui = dpi_mujer;


/* MENSAJE */
SELECT 'DIVORCIO REGISTRADO' AS MENSAJE;

END $$