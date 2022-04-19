DROP DATABASE IF EXISTS RENAP;
CREATE DATABASE RENAP;
USE RENAP;

CREATE TABLE acta_defuncion (
    id_acta                INTEGER NOT NULL AUTO_INCREMENT,
    fecha_fallecimiento    DATE NOT NULL,
    motivo                 VARCHAR(255) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INT(13) ZEROFILL NOT NULL,
    PRIMARY KEY(id_acta)
);

CREATE TABLE acta_divorcio (
    id_acta        INTEGER NOT NULL AUTO_INCREMENT,
    fecha_divorcio DATE NOT NULL,
    cui_hombre     INT(13) ZEROFILL NOT NULL,
    cui_mujer      INT(13) ZEROFILL NOT NULL,
    id_matrimonio  INTEGER NOT NULL,
    PRIMARY KEY(id_acta)
);

CREATE TABLE acta_matrimonio (
    id_acta          INTEGER NOT NULL AUTO_INCREMENT,
    fecha_matrimonio DATE NOT NULL,
    cui_hombre       INT(13) ZEROFILL NOT NULL,
    cui_mujer        INT(13) ZEROFILL NOT NULL,
    PRIMARY KEY(id_acta)
);

CREATE TABLE acta_nacimiento (
    id_acta                INTEGER NOT NULL AUTO_INCREMENT,
    cui_madre              INT(13) ZEROFILL NOT NULL,
    cui_padre              INT(13) ZEROFILL NOT NULL,
    fecha_nacimiento       DATE NOT NULL,
    genero                 VARCHAR(1) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INT(13) ZEROFILL NOT NULL,
    PRIMARY KEY(id_acta)
);

CREATE TABLE departamento (
    id_departamento INTEGER NOT NULL,
    nombre          VARCHAR(50) NOT NULL,
    PRIMARY KEY(id_departamento)
);

CREATE TABLE estado_civil (
    id_estado INTEGER NOT NULL,
    nombre    VARCHAR(25) NOT NULL,
    PRIMARY KEY(id_estado)
);

CREATE TABLE licencia (
    id_licencia        INTEGER NOT NULL AUTO_INCREMENT,
    fecha_emision      DATE NOT NULL,
    fecha_vencimiento  DATE NOT NULL,
    fecha_anulada      DATE,
    persona_cui        INT(13) ZEROFILL NOT NULL,
    tipo_licencia_tipo VARCHAR(1) NOT NULL,
    PRIMARY KEY(id_licencia)
);

CREATE TABLE municipio (
    id_municipio                 INTEGER NOT NULL,
    nombre                       VARCHAR(50) NOT NULL,
    departamento_id_departamento INTEGER NOT NULL,
    PRIMARY KEY(id_municipio)
);

CREATE TABLE persona (
    no_registro INT(9) ZEROFILL NOT NULL AUTO_INCREMENT,
    cui                    INT(13) ZEROFILL NOT NULL UNIQUE,
    primer_nombre          VARCHAR(50) NOT NULL,
    segundo_nombre         VARCHAR(50),
    tercer_nombre          VARCHAR(50),
    primer_apellido        VARCHAR(50) NOT NULL,
    segundo_apellido       VARCHAR(50),
    estado_civil_id_estado INTEGER NOT NULL DEFAULT 1,
    dpi_generado           BOOLEAN NOT NULL DEFAULT 0,
    cui_conyuge            INT(13) ZEROFILL,
    municipio_reside       INTEGER,
    PRIMARY KEY(no_registro)
);

CREATE TABLE tipo_licencia (
    tipo        VARCHAR(1) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    PRIMARY KEY(tipo)
);

ALTER TABLE acta_defuncion
    ADD FOREIGN KEY (municipio_id_municipio)
        REFERENCES municipio (id_municipio);

ALTER TABLE acta_defuncion
    ADD FOREIGN KEY (persona_cui)
        REFERENCES persona (cui);

ALTER TABLE acta_divorcio
    ADD FOREIGN KEY (cui_hombre)
        REFERENCES persona (cui);

ALTER TABLE acta_divorcio
    ADD FOREIGN KEY (cui_mujer)
        REFERENCES persona (cui);

ALTER TABLE acta_matrimonio
    ADD FOREIGN KEY (cui_hombre)
        REFERENCES persona (cui);

ALTER TABLE acta_matrimonio
    ADD FOREIGN KEY (cui_mujer)
        REFERENCES persona (cui);

ALTER TABLE acta_nacimiento
    ADD FOREIGN KEY (municipio_id_municipio)
        REFERENCES municipio (id_municipio);

ALTER TABLE acta_nacimiento
    ADD FOREIGN KEY (persona_cui)
        REFERENCES persona (cui);

ALTER TABLE licencia
    ADD FOREIGN KEY (persona_cui)
        REFERENCES persona (cui);

ALTER TABLE licencia
    ADD FOREIGN KEY (tipo_licencia_tipo)
        REFERENCES tipo_licencia (tipo);

ALTER TABLE municipio
    ADD FOREIGN KEY (departamento_id_departamento)
        REFERENCES departamento (id_departamento);

ALTER TABLE persona
    ADD FOREIGN KEY (estado_civil_id_estado)
        REFERENCES estado_civil (id_estado);

ALTER TABLE persona
    ADD FOREIGN KEY (municipio_reside)
        REFERENCES municipio (id_municipio);

ALTER TABLE persona
    ADD FOREIGN KEY (cui_conyuge)
        REFERENCES persona (cui);
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
        cui_hombre,
        cui_mujer,
        id_matrimonio
    )
VALUES (
        format_fecha,
        dpi_hombre,
        dpi_mujer,
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
/* DEPARTAMENTOS */
INSERT INTO
    departamento (id_departamento, nombre)
VALUES
    (1, 'GUATEMALA'), (2, 'EL PROGRESO'), (3, 'SACATEPEQUEZ'), (4, 'CHIMALTENANGO'),
    (5, 'ESCUINTLA'), (6, 'SANTA ROSA'), (7, 'SOLOLA'), (8, 'TOTONICAPAN'),
    (9, 'QUETZALTENANGO'), (10, 'SUCHITEPEQUEZ'), (11, 'RETALHULEU'), (12, 'SAN MARCOS'),
    (13, 'HUEHUETENANGO'), (14, 'EL QUICHE'), (15, 'BAJA VERAPAZ'), (16, 'ALTA VERAPAZ'),
    (17, 'EL PETEN'), (18, 'IZABAL'), (19, 'ZACAPA'), (20, 'CHIQUIMULA'),
    (21, 'JALAPA'), (22, 'JUTIAPA');

/* MUNICIPIOS */
LOAD DATA INFILE '/var/lib/mysql-files/municipios.csv'
INTO TABLE municipio
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/* ESTADO CIVIL */
INSERT INTO
    estado_civil (id_estado, nombre)
VALUES
    (1, 'SOLTERO'), (2, 'CASADO'), (3, 'DIVORCIADO'), (4, 'VIUDO');

/* TIPO DE LICENCIA */
INSERT INTO
    tipo_licencia (tipo, descripcion)
VALUES
    ('A', 'Vehículos de transporte que tenga una carga de más de 3.5 toneladas métricas, incluyendo transporte escolar, colectivo, urbano y extraurbano. Tiene que ser mayor de 25 años y haber tenido licencia tipo B o C por más de 3 años.'),
    ('B', 'Toda clase de automóviles de hasta 3.5 toneladas métricas de peso bruto y pueden recibir remuneración o pago por conducir. Para obtener esta licencia, es necesario ser mayor de 23 años y haber tenido 2 años la licencia tipo C.'),
    ('C', 'Es la más común y es la que se otorga al sacar la primera licencia. No necesita ninguna edad mínima ni haber tenido otro tipo de licencia. Permite, sin recibir remuneración, manejar un peso máximo de 3.5 toneladas métricas de peso.'),
    ('M', 'Este tipo de licencia únicamente permite manejar motocicletas o moto bicicletas.'),
    ('E', 'La licencia tipo E permite a la persona conducir maquinaria agrícola e industrial, únicamente. Con este tipo de licencia, no se puede manejar cualquier otro vehículo.');

/* PERSONAS BASE PARA PODER REGISTRAR LOS NACIMIENTOS */
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (11101,'Reagan', 'Omar', 'Reese', 'Gerretsen', 'Zarb',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (21101,'Jackson', 'Steffen', '', 'Mumford', 'Challen',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (31101,'Claudius', 'Page', '', 'Jakoviljevic', 'Selcraig',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (41101,'Jerrome', 'Shelby', '', 'Catcheside', 'Rolles',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (51101,'Baudoin', 'Georgie', 'Neils', 'Trubshawe', 'Kleeman',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (61101,'Werner', 'Curr', 'Theodor', 'Busher', 'Le Noury',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (71101,'Alford', 'Everett', 'Kennett', 'Brunroth', 'Toone',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (81101,'Glendon', 'Bryant', 'Smitty', 'OHoey', 'Thompsett',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (91101,'Temp', 'Tull', '', 'Daye', 'Strothers',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (101101,'Amory', 'Reynolds', 'Augustine', 'Hynde', 'Costy',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (111101,'Albie', 'Stanislaw', 'Daven', 'Leatherborrow', 'Ellerington',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (121101,'Amos', 'Ring', 'Elton', 'Pedrocco', 'Nelsey',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (131101,'Torrey', 'Lindsay', '', 'Falconar', 'Ianizzi',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (141101,'Jasen', 'Mal', '', 'Martinson', 'Deem',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (151101,'Lawrence', 'Basile', 'Claus', 'Florence', 'Wilbor',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (161101,'Alric', 'Reagan', 'Yul', 'Chellingworth', 'Jentin',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (171101,'Aldridge', 'Collin', 'Blaine', 'Piggins', 'Emm',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (181101,'Ambrosius', 'Preston', '', 'Andryushin', 'Crosby',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (191101,'Randolf', 'Ellary', '', 'Greguol', 'Allsup',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (201101,'Germaine', 'Kristo', 'Bengt', 'Seamer', 'Chipperfield',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (211101,'Ernst', 'Thibaud', 'Emmanuel', 'Kiddell', 'Roscamp',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (221101,'Tedie', 'Hasty', 'Onfroi', 'Upchurch', 'Keal',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (231101,'Cy', 'Denver', 'Germain', 'Dunbabin', 'Bonafacino',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (241101,'Adriano', 'Hayes', 'Oren', 'Giovannacc@i', 'Dewis',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (251101,'Fremont', 'Gibbie', 'Shayne', 'Campanelli', 'Mayler',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (261101,'Sumner', 'Stavro', 'Timotheus', 'Wisbey', 'Piercy',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (271101,'Rurik', 'Robby', 'Laughton', 'Sammes', 'OClery',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (281101,'Arnuad', 'Duffy', 'Chancey', 'Pocock', 'Block',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (291101,'Chrisse', 'Clement', 'Dew', 'Murrigans', 'Arrault',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (301101,'Trueman', 'Alex', '', 'Drakard', 'Klawi',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (311101,'Leonid', 'Delmor', 'Roddy', 'Itzhaiek', 'Stilly',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (321101,'Alfredo', 'Ted', 'Sim', 'Aldham', 'MacManus',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (331101,'Alistair', 'David', '', 'Micklem', 'Avis',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (341101,'Nickolas', 'Shelton', 'Agosto', 'Phibb', 'Geratt',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (351101,'Estevan', 'Saul', 'Inigo', 'Ladbury', 'Kempster',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (361101,'Doy', 'Jarred', 'Allie', 'Lawler', 'Chappelle',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (371101,'Rutter', 'Cecilius', '', 'Losemann', 'Ierland',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (381101,'Kristo', 'Durante', 'Orv', 'Manshaw', 'Bearsmore',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (391101,'Inigo', 'Layton', 'Riobard', 'Blurton', 'Cattermoul',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (401101,'Fran', 'Halsy', 'Burtie', 'Gocke', 'Petrelli',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (411101,'Ford', 'Sonny', 'Wade', 'Tatem', 'Machan',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (421101,'Mortie', 'Jerome', 'Ernest', 'Langmuir', 'Horrod',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (431101,'Tito', 'Davis', '', 'Bourgaize', 'Smurfit',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (441101,'Lionel', 'Karlis', 'Egor', 'Jahnke', 'Coop',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (451101,'Hartley', 'Lalo', 'Neill', 'Costard', 'Brunger',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (461101,'Thornie', 'Jackson', 'Skippie', 'Grace', 'Gillyett',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (471101,'Nichole', 'Rafaello', 'Angel', 'Tender', 'Misk',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (481101,'Roy', 'Rex', 'Fairfax', 'Pindar', 'Drillingcourt',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (491101,'Lockwood', 'Clerc', 'Mac', 'Seyers', 'Petzolt',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (501101,'Jackie', 'Ase', 'Simmonds', 'Grebert', 'Rosencrantz',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (511101,'Giralda', 'Carena', 'Saba', 'Ast', 'Borland',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (521101,'Jeannine', 'Edithe', 'Nerta', 'Martinson', 'Connikie',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (531101,'Elie', 'Raynell', '', 'Rickerby', 'Daley',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (541101,'Gwendolin', 'Sissy', 'Ettie', 'Sawle', 'Rooms',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (551101,'Kailey', 'Marj', 'Vania', 'Slemming', 'Girone',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (561101,'Nan', 'Trixy', '', 'Grunwall', 'Schiementz',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (571101,'Jobi', 'Lanna', 'Blinni', 'Jotcham', 'Deme',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (581101,'Samara', 'Jeri', 'Gabriel', 'Wichard', 'Slocom',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (591101,'Netti', 'Ursula', 'Glennie', 'Yushkov', 'Lukesch',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (601101,'Audie', 'Ceciley', 'Pegeen', 'Celiz', 'Bogey',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (611101,'Latia', 'Camella', 'Darleen', 'Hordle', 'Pheby',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (621101,'Gates', 'Amanda', 'Amaleta', 'Longo', 'Sherratt',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (631101,'Cristine', 'Tera', 'Lotti', 'Mulliss', 'Le Grand',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (641101,'Verna', 'Rahal', 'Janice', 'Canadine', 'Callam',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (651101,'Stacy', 'Dianemarie', 'Alice', 'MacEllen', 'Mather',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (661101,'Alys', 'Eva', '', 'Pech', 'Henworth',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (671101,'Gerda', 'Haley', 'Dona', 'Loncaster', 'Piercey',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (681101,'Minne', 'Cacilia', '', 'Simoncello', 'Beccera',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (691101,'Demetris', 'Cyndie', '', 'Bum', 'Warlaw',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (701101,'Inga', 'Dale', 'Zitella', 'Dike', 'Hessle',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (711101,'Janel', 'Ardene', 'Francisca', 'Exrol', 'Luckhurst',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (721101,'Sashenka', 'Teirtza', 'Bianca', 'Andrzejewski', 'Tourville',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (731101,'Magdalena', 'Dorthea', '', 'Birkhead', 'Dulwitch',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (741101,'Miriam', 'Lenette', 'Libbi', 'DAulby', 'Kleinhaut',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (751101,'Vinita', 'Flossi', 'Lelah', 'Skyner', 'Casement',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (761101,'Enid', 'Phillie', 'Krystal', 'Benne', 'Statefield',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (771101,'Bianca', 'Grissel', 'Katheryn', 'Huckel', 'McAlister',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (781101,'Josephina', 'Ansley', 'Olga', 'Tuffin', 'Banbridge',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (791101,'Paulita', 'Brittney', 'Marianne', 'Tefft', 'Dorking',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (801101,'Carmelle', 'Shaine', 'Vivia', 'Joannidi', 'Harp',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (811101,'Antonina', 'Sarine', 'Serene', 'Blazic', 'Goathrop',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (821101,'Karry', 'Aura', 'Gustie', 'Berns', 'Setter',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (831101,'Jodee', 'Chris', '', 'Kopke', 'Kobelt',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (841101,'Ginny', 'Gracia', 'Mame', 'Penton', 'Tomsen',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (851101,'Jsandye', 'Berty', 'Cherise', 'Sybry', 'Rouchy',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (861101,'Edita', 'Cathyleen', 'Christen', 'Wontner', 'Moxson',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (871101,'Elaina', 'Gilly', 'Ermentrude', 'Osbourn', 'Quaintance',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (881101,'Ruthann', 'Adelina', 'Concordia', 'Bonds', 'Appleton',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (891101,'Gwendolin', 'Tuesday', 'Valaria', 'Tallman', 'De Angelis',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (901101,'Lia', 'Henka', '', 'Mussard', 'Twizell',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (911101,'Lorrayne', 'Georgina', '', 'Bischoff', 'Struys',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (921101,'Lilian', 'Lurleen', 'Rica', 'Spaule', 'Crighten',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (931101,'Jeni', 'Happy', 'Kizzee', 'Rossborough', 'Hollows',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (941101,'Noemi', 'Cory', 'Vera', 'Hilldrup', 'Durbin',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (951101,'Lida', 'Davita', '', 'Cicutto', 'Keningley',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (961101,'Lea', 'Georgiana', '', 'Bogace', 'Axtell',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (971101,'Ariela', 'Clare', '', 'Howie', 'Lambeth',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (981101,'Josefa', 'Alica', '', 'Lote', 'Beinke',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (991101,'Veronica', 'Aarika', '', 'Harsant', 'Eveque',1,101);
INSERT INTO persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, dpi_generado, municipio_reside) VALUES (1001101,'Erena', 'Beatrisa', 'Harley', 'Bulluck', 'Warwick',1,101);
