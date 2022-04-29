DELIMITER $$
DROP FUNCTION IF EXISTS TieneLicencia $$ CREATE FUNCTION TieneLicencia(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE tiene_licencia BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM licencia l WHERE l.persona_cui = cui) INTO tiene_licencia
);
            
-- return the boolean  
RETURN (tiene_licencia);
END $$
DELIMITER $$
DROP FUNCTION IF EXISTS ExistePersona $$ CREATE FUNCTION ExistePersona(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE existe BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM persona p WHERE p.cui = cui) INTO existe
);
            
-- return the boolean  
RETURN (existe);
END $$
DELIMITER $$
DROP FUNCTION IF EXISTS PersonaViva $$ CREATE FUNCTION PersonaViva(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE vivo BOOLEAN;

(
    SELECT NOT EXISTS (SELECT 1 FROM acta_defuncion ad WHERE ad.persona_cui = cui) INTO vivo
);
            
-- return the boolean  
RETURN (vivo);
END $$
DELIMITER $$
DROP FUNCTION IF EXISTS TieneDPI $$ CREATE FUNCTION TieneDPI(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE tiene_dpi BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM persona p WHERE p.cui = cui AND p.dpi_generado = 1) INTO tiene_dpi
);
            
-- return the boolean  
RETURN (tiene_dpi);
END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS renewLicencia $$ CREATE PROCEDURE renewLicencia(
    IN no_licencia INTEGER,
    IN fecha_renovacion VARCHAR(10),
    IN cantidad_renovacion INTEGER,
    IN tipo_licencia VARCHAR(1)
)

renovlic_proc:BEGIN

DECLARE format_fecha, fecha_nac, fecha_pre_anulada DATE;
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

/* VALIDAR SI ESTÁ ANULADA */
(SELECT fecha_anulada INTO fecha_pre_anulada FROM licencia WHERE id_licencia = no_licencia);
IF (fecha_pre_anulada != NULL) THEN
    /* NO HAN PASADO LOS 2 AÑOS */
    IF (SELECT TIMESTAMPDIFF(YEAR, fecha_pre_anulada, CURDATE()) < 2) THEN
        SELECT 'NO HA CUMPLIDO LOS 2 AÑOS DE LICENCIA ANULADA.' AS ERROR;
        LEAVE renovlic_proc;
    END IF;
    /* VALIDAR LICENCIA DE NUEVO */
    UPDATE licencia
    SET fecha_anulada = NULL
    WHERE id_licencia = no_licencia;
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
DELIMITER $$

DROP PROCEDURE IF EXISTS getNacimiento $$ CREATE PROCEDURE getNacimiento(
    IN cui_persona BIGINT
)
getnac_proc:BEGIN


/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE getnac_proc;
END IF;

/* RESULTADO */
SELECT
	an.id_acta AS 'NoActa',
    an.persona_cui AS 'CUI',
    CONCAT(p.primer_apellido, ' ', p.segundo_apellido) AS 'Apellidos',
    CONCAT(p.primer_nombre, ' ', p.segundo_nombre, ' ', p.tercer_nombre) AS 'Nombres',
    padre.cui AS 'DpiPadre',
    padre.primer_nombre AS 'NombrePadre',
    padre.primer_apellido AS 'ApellidoPadre',
    madre.cui AS 'DpiMadre',
    madre.primer_nombre AS 'NombreMadre',
    madre.primer_apellido AS 'ApellidoMadre',
    an.fecha_nacimiento AS 'FechaNac',
    d.nombre AS 'Departamento',
    m.nombre AS 'Municipio',
    an.genero AS 'Genero'
FROM acta_nacimiento an
INNER JOIN persona p
	ON p.cui = an.persona_cui
INNER JOIN persona padre
	ON padre.cui = an.cui_padre
INNER JOIN persona madre
	ON madre.cui = an.cui_madre
INNER JOIN municipio m
	ON m.id_municipio = an.municipio_id_municipio
INNER JOIN departamento d
	ON d.id_departamento = m.departamento_id_departamento
WHERE an.persona_cui = cui_persona;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS getMatrimonio $$ CREATE PROCEDURE getMatrimonio(
    IN acta_matrimonio INTEGER
)
getmatr_proc:BEGIN


/* NO EXISTE */
IF (SELECT EXISTS (SELECT 1 FROM acta_matrimonio WHERE id_acta = acta_matrimonio) = 0) THEN
    SELECT 'ACTA DE MATRIMONIO NO SE ENCUENTRA.' AS ERROR;
    LEAVE getmatr_proc;
END IF;

/* RESULTADO */
SELECT
	am.id_acta AS 'NoMatrimonio',
    hombre.cui AS 'DPIHombre',
    CONCAT(hombre.primer_nombre, ' ', hombre.segundo_nombre, ' ', hombre.tercer_nombre, ' ', hombre.primer_apellido, ' ', hombre.segundo_apellido) AS 'NombreHombre',
    mujer.cui AS 'DPIMujer',
    CONCAT(mujer.primer_nombre, ' ', mujer.segundo_nombre, ' ', mujer.tercer_nombre, ' ', mujer.primer_apellido, ' ', mujer.segundo_apellido) AS 'NombreMujer',
    am.fecha_matrimonio AS 'FechaMatrimonio'
FROM acta_matrimonio am
INNER JOIN persona hombre
    ON hombre.cui = am.cui_hombre
INNER JOIN persona mujer
    ON mujer.cui = am.cui_mujer
WHERE am.id_acta = acta_matrimonio;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS getLicencias $$ CREATE PROCEDURE getLicencias(
    IN cui_persona BIGINT
)
getlic_proc:BEGIN


/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE getlic_proc;
END IF;

/* RESULTADO */
SELECT
	l.id_licencia AS 'NoLicencia',
    CONCAT(p.primer_nombre, ' ', p.segundo_nombre, ' ', p.tercer_nombre) AS 'Nombres',
    CONCAT(p.primer_apellido, ' ', p.segundo_apellido) AS 'Apellidos',
    l.fecha_emision AS 'FechaEmisión',
    l.fecha_vencimiento AS 'FechaVencimiento',
    l.tipo_licencia_tipo AS 'TipoLicencia'
FROM persona p
INNER JOIN licencia l
	ON l.persona_cui = p.cui
WHERE p.cui = cui_persona;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS getDPI $$ CREATE PROCEDURE getDPI(
    IN cui_persona BIGINT
)
getDPI_proc:BEGIN


/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE getDPI_proc;
END IF;

/* RESULTADO */
SELECT
	p.cui AS 'CUI',
    CONCAT(p.primer_apellido, ' ', p.segundo_apellido) AS 'Apellidos',
    CONCAT(p.primer_nombre, ' ', p.segundo_nombre, ' ', p.tercer_nombre) AS 'Nombres',
    an.fecha_nacimiento AS 'FechaNac',
    dnac.nombre AS 'DepartamentoNac',
    mnac.nombre AS 'MunicipioNac',
    dres.nombre AS 'DeptVecindad',
    mres.nombre AS 'MuniVecindad',
    an.genero AS 'Genero'
FROM persona p
INNER JOIN acta_nacimiento an
	ON an.persona_cui = p.cui
INNER JOIN municipio mnac
	ON mnac.id_municipio = an.municipio_id_municipio
INNER JOIN departamento dnac
	ON dnac.id_departamento = mnac.departamento_id_departamento
INNER JOIN municipio mres
	ON mres.id_municipio = p.municipio_reside
INNER JOIN departamento dres
	ON dres.id_departamento = mres.departamento_id_departamento
WHERE p.cui = cui_persona;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS getDivorcio $$ CREATE PROCEDURE getDivorcio(
    IN acta_matrimonio INTEGER
)
getdiv_proc:BEGIN


/* NO EXISTE */
IF (SELECT EXISTS (SELECT 1 FROM acta_divorcio WHERE id_matrimonio = acta_matrimonio) = 0) THEN
    SELECT 'ACTA DE DIVORCIO NO SE ENCUENTRA.' AS ERROR;
    LEAVE getdiv_proc;
END IF;

/* RESULTADO */
SELECT
	ad.id_acta AS 'NoDivorcio',
    hombre.cui AS 'DPIHombre',
    CONCAT(hombre.primer_nombre, ' ', hombre.segundo_nombre, ' ', hombre.tercer_nombre, ' ', hombre.primer_apellido, ' ', hombre.segundo_apellido) AS 'NombreHombre',
    mujer.cui AS 'DPIMujer',
    CONCAT(mujer.primer_nombre, ' ', mujer.segundo_nombre, ' ', mujer.tercer_nombre, ' ', mujer.primer_apellido, ' ', mujer.segundo_apellido) AS 'NombreMujer',
    am.fecha_matrimonio AS 'FechaMatrimonio',
    ad.fecha_divorcio AS 'FechaDivorcio'
FROM acta_divorcio ad
INNER JOIN acta_matrimonio am
	ON am.id_acta = ad.id_matrimonio
INNER JOIN persona hombre
    ON hombre.cui = am.cui_hombre
INNER JOIN persona mujer
    ON mujer.cui = am.cui_mujer
WHERE ad.id_matrimonio = acta_matrimonio;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS getDefuncion $$ CREATE PROCEDURE getDefuncion(
    IN cui_persona BIGINT
)
getdef_proc:BEGIN

/* NO EXISTE */
IF (ExistePersona(cui_persona) = 0) THEN
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE getdef_proc;
END IF;

/* NO FALLECIDO */
IF (PersonaViva(cui_persona) = 1) THEN
    SELECT 'LA PERSONA NO SE ENCUENTRA FALLECIDA.' AS ERROR;
    LEAVE getdef_proc;
END IF;

/* RESULTADO */
SELECT
	ad.id_acta AS 'NoActa',
    ad.persona_cui AS 'CUI',
    CONCAT(p.primer_apellido, ' ', p.segundo_apellido) AS 'Apellidos',
    CONCAT(p.primer_nombre, ' ', p.segundo_nombre, ' ', p.tercer_nombre) AS 'Nombres',
    ad.fecha_fallecimiento AS 'FechaFallecimiento',
    d.nombre AS 'Departamento',
    m.nombre AS 'Municipio',
    ad.motivo AS 'MotivoFallecimiento'
FROM acta_defuncion ad
INNER JOIN persona p
	ON p.cui = ad.persona_cui
INNER JOIN municipio m
	ON m.id_municipio = ad.municipio_id_municipio
INNER JOIN departamento d
	ON d.id_departamento = m.departamento_id_departamento
WHERE ad.persona_cui = cui_persona;


END $$
DELIMITER $$

DROP PROCEDURE IF EXISTS AddLicencia $$ CREATE PROCEDURE AddLicencia(
    IN cui_persona BIGINT,
    IN fecha_emision VARCHAR(10),
    IN tipo_licencia VARCHAR(1)
)

primerlic_proc:BEGIN

DECLARE format_fecha, fecha_nac DATE;


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
(SELECT fecha_nacimiento INTO fecha_nac FROM acta_nacimiento WHERE persona_cui = cui_persona);
IF (SELECT TIMESTAMPDIFF(YEAR, fecha_nac, CURDATE()) < 16) THEN
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
DELIMITER $$
DROP PROCEDURE IF EXISTS AddNacimiento $$ CREATE PROCEDURE AddNacimiento(
    IN dpi_padre BIGINT,
    IN dpi_madre BIGINT,
    IN primer_nombre VARCHAR(50),
    IN segundo_nombre VARCHAR(50),
    IN tercer_nombre VARCHAR(50),
    IN in_fecha_nac VARCHAR(10),
    IN codigo_municipio INTEGER,
    IN in_genero VARCHAR(1)
)
nac_proc:BEGIN

DECLARE cui BIGINT;
DECLARE fecha, fecha_nac_padre, fecha_nac_madre DATE;
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

/* VALIDAR EDADES */
(SELECT fecha_nacimiento INTO fecha_nac_padre FROM acta_nacimiento WHERE persona_cui = dpi_padre);
(SELECT fecha_nacimiento INTO fecha_nac_madre FROM acta_nacimiento WHERE persona_cui = dpi_madre);
IF ((SELECT TIMESTAMPDIFF(YEAR, fecha_nac_padre, CURDATE()) < 18) OR (SELECT TIMESTAMPDIFF(YEAR, fecha_nac_madre, CURDATE()) < 18)) THEN
    SELECT 'LOS PADRES NO PUEDEN SER MENORES DE EDAD.' AS ERROR;
    LEAVE nac_proc;
END IF;

/* VALIDAR NOMBRES */
IF (
    (SELECT REGEXP_INSTR(primer_nombre, '[^a-zA-Z]') != 0) OR
    (SELECT REGEXP_INSTR(segundo_nombre, '[^a-zA-Z]') != 0) OR
    (SELECT REGEXP_INSTR(tercer_nombre, '[^a-zA-Z]') != 0)
) THEN
SELECT 'LOS NOMBRES SOLO PUEDEN CONTENER LETRAS.' AS ERROR;
    LEAVE nac_proc;
END IF;

/* FECHA INCONGRUENTE */
(SELECT STR_TO_DATE(in_fecha_nac, '%d-%m-%Y') INTO fecha);
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
        in_genero,
        codigo_municipio,
        cui
    );

/* MENSAJE */
SELECT 'NACIMIENTO REGISTRADO' AS MENSAJE;

END $$
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

/* ACTUALIZAR ESTADO CIVIL */
UPDATE persona
SET estado_civil_id_estado = 2, cui_conyuge = dpi_mujer
WHERE cui = dpi_hombre;

UPDATE persona
SET estado_civil_id_estado = 2, cui_conyuge = dpi_hombre
WHERE cui = dpi_mujer;


/* MENSAJE */
SELECT 'MATRIMONIO REGISTRADO' AS MENSAJE;

END $$
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
    SELECT 'LA PERSONA NO EXISTE.' AS ERROR;
    LEAVE def_proc;
END IF;

/* YA FALLECIDO */
IF (PersonaViva(cui_fallecido) = 0) THEN
    SELECT 'LA PERSONA YA SE ENCUENTRA FALLECIDA.' AS ERROR;
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
    SELECT 'LA FECHA ES INCONGRUENTE.' AS ERROR;
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
    UPDATE persona
    SET estado_civil_id_estado = 4, cui_conyuge = NULL
    WHERE cui_conyuge = cui_fallecido;
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

/* MENSAJE */
SELECT 'DEFUNCIÓN REGISTRADA' AS MENSAJE;

END $$
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