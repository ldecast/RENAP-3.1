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
    anulada            BOOLEAN NOT NULL DEFAULT 0,
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
