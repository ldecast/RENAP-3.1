DROP DATABASE IF EXISTS RENAP;
CREATE DATABASE RENAP;
USE RENAP;

CREATE TABLE acta_defuncion (
    id_acta                INTEGER NOT NULL,
    fecha_fallecimiento    DATE NOT NULL,
    motivo                 VARCHAR(255) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INTEGER NOT NULL
);

ALTER TABLE acta_defuncion ADD PRIMARY KEY (id_acta);

CREATE TABLE acta_divorcio (
    id_acta        INTEGER NOT NULL,
    fecha_divorcio DATE NOT NULL,
    cui_hombre     INTEGER NOT NULL,
    cui_mujer      INTEGER NOT NULL
);

ALTER TABLE acta_divorcio ADD PRIMARY KEY (id_acta);

CREATE TABLE acta_matrimonio (
    id_acta          INTEGER NOT NULL,
    fecha_matrimonio DATE NOT NULL,
    cui_hombre       INTEGER NOT NULL,
    cui_mujer        INTEGER NOT NULL
);

ALTER TABLE acta_matrimonio ADD PRIMARY KEY (id_acta);

CREATE TABLE acta_nacimiento (
    id_acta                INTEGER NOT NULL,
    cui_madre              INTEGER NOT NULL,
    cui_padre              INTEGER NOT NULL,
    fecha_nacimiento       DATE NOT NULL,
    genero                 VARCHAR(1) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INTEGER NOT NULL
);

ALTER TABLE acta_nacimiento ADD PRIMARY KEY (id_acta);

CREATE TABLE departamento (
    id_departamento INTEGER NOT NULL,
    nombre          VARCHAR(50) NOT NULL
);

ALTER TABLE departamento ADD PRIMARY KEY (id_departamento);

CREATE TABLE estado_civil (
    id_estado INTEGER NOT NULL,
    nombre    VARCHAR(25) NOT NULL
);

ALTER TABLE estado_civil ADD PRIMARY KEY (id_estado);

CREATE TABLE licencia (
    id_licencia        INTEGER NOT NULL,
    fecha_emision      DATE NOT NULL,
    fecha_vencimiento  DATE NOT NULL,
    anulada            BOOLEAN NOT NULL,
    persona_cui        INTEGER NOT NULL,
    tipo_licencia_tipo VARCHAR(1) NOT NULL
);

ALTER TABLE licencia ADD PRIMARY KEY (id_licencia);

CREATE TABLE municipio (
    id_municipio                 INTEGER NOT NULL,
    nombre                       VARCHAR(50) NOT NULL,
    departamento_id_departamento INTEGER NOT NULL
);

ALTER TABLE municipio ADD PRIMARY KEY (id_municipio);

CREATE TABLE persona (
    cui                    INTEGER NOT NULL,
    primer_nombre          VARCHAR(1) NOT NULL,
    segundo_nombre         VARCHAR(50),
    tercer_nombre          VARCHAR(50),
    primer_apellido        VARCHAR(50) NOT NULL,
    segundo_apellido       VARCHAR(50),
    estado_civil_id_estado INTEGER NOT NULL
);

ALTER TABLE persona ADD PRIMARY KEY (cui);

CREATE TABLE tipo_licencia (
    tipo        VARCHAR(1) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

ALTER TABLE tipo_licencia ADD PRIMARY KEY (tipo);

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
