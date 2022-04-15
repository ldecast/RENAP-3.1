-- Generado por Oracle SQL Developer Data Modeler 21.4.1.349.1605
--   en:        2022-04-14 21:05:38 CST
--   sitio:      Oracle Database 21c
--   tipo:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE acta_defuncion (
    id_acta                INTEGER NOT NULL,
    fecha_fallecimiento    DATE NOT NULL,
    motivo                 NVARCHAR2(255) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INTEGER NOT NULL
);

CREATE UNIQUE INDEX acta_defuncion__idx ON
    acta_defuncion (
        persona_cui
    ASC );

ALTER TABLE acta_defuncion ADD CONSTRAINT acta_defuncion_pk PRIMARY KEY ( id_acta );

CREATE TABLE acta_divorcio (
    id_acta        INTEGER NOT NULL,
    fecha_divorcio DATE NOT NULL,
    cui_hombre     INTEGER NOT NULL,
    cui_mujer      INTEGER NOT NULL
);

ALTER TABLE acta_divorcio ADD CONSTRAINT acta_divorcio_pk PRIMARY KEY ( id_acta );

CREATE TABLE acta_matrimonio (
    id_acta          INTEGER NOT NULL,
    fecha_matrimonio DATE NOT NULL,
    cui_hombre       INTEGER NOT NULL,
    cui_mujer        INTEGER NOT NULL
);

ALTER TABLE acta_matrimonio ADD CONSTRAINT acta_matrimonio_pk PRIMARY KEY ( id_acta );

CREATE TABLE acta_nacimiento (
    id_acta                INTEGER NOT NULL,
    cui_madre              INTEGER NOT NULL,
    cui_padre              INTEGER NOT NULL,
    fecha_nacimiento       DATE NOT NULL,
    genero                 NVARCHAR2(1) NOT NULL,
    municipio_id_municipio INTEGER NOT NULL,
    persona_cui            INTEGER NOT NULL
);

CREATE UNIQUE INDEX acta_nacimiento__idx ON
    acta_nacimiento (
        persona_cui
    ASC );

ALTER TABLE acta_nacimiento ADD CONSTRAINT acta_nacimiento_pk PRIMARY KEY ( id_acta );

CREATE TABLE departamento (
    id_departamento INTEGER NOT NULL,
    nombre          NVARCHAR2(50) NOT NULL
);

ALTER TABLE departamento ADD CONSTRAINT departamento_pk PRIMARY KEY ( id_departamento );

CREATE TABLE estado_civil (
    id_estado INTEGER NOT NULL,
    nombre    NVARCHAR2(25) NOT NULL
);

ALTER TABLE estado_civil ADD CONSTRAINT estado_civil_pk PRIMARY KEY ( id_estado );

CREATE TABLE licencia (
    id_licencia        INTEGER NOT NULL,
    fecha_emision      DATE NOT NULL,
    fecha_vencimiento  DATE NOT NULL,
    anulada            NUMBER NOT NULL,
    persona_cui        INTEGER NOT NULL,
    tipo_licencia_tipo NVARCHAR2(1) NOT NULL
);

CREATE UNIQUE INDEX licencia__idx ON
    licencia (
        tipo_licencia_tipo
    ASC );

ALTER TABLE licencia ADD CONSTRAINT licencia_pk PRIMARY KEY ( id_licencia );

CREATE TABLE municipio (
    id_municipio                 INTEGER NOT NULL,
    nombre                       NVARCHAR2(50) NOT NULL,
    departamento_id_departamento INTEGER NOT NULL
);

ALTER TABLE municipio ADD CONSTRAINT municipio_pk PRIMARY KEY ( id_municipio );

CREATE TABLE persona (
    cui                    INTEGER NOT NULL,
    primer_nombre          NVARCHAR2(1) NOT NULL,
    segundo_nombre         NVARCHAR2(50),
    tercer_nombre          NVARCHAR2(50),
    primer_apellido        NVARCHAR2(50) NOT NULL,
    segundo_apellido       NVARCHAR2(50),
    estado_civil_id_estado INTEGER NOT NULL
);

ALTER TABLE persona ADD CONSTRAINT persona_pk PRIMARY KEY ( cui );

CREATE TABLE tipo_licencia (
    tipo        NVARCHAR2(1) NOT NULL,
    descripcion NVARCHAR2(255) NOT NULL
);

ALTER TABLE tipo_licencia ADD CONSTRAINT tipo_licencia_pk PRIMARY KEY ( tipo );

ALTER TABLE acta_defuncion
    ADD CONSTRAINT acta_defuncion_municipio_fk FOREIGN KEY ( municipio_id_municipio )
        REFERENCES municipio ( id_municipio );

ALTER TABLE acta_defuncion
    ADD CONSTRAINT acta_defuncion_persona_fk FOREIGN KEY ( persona_cui )
        REFERENCES persona ( cui );

ALTER TABLE acta_divorcio
    ADD CONSTRAINT acta_divorcio_persona_fk FOREIGN KEY ( cui_hombre )
        REFERENCES persona ( cui );

ALTER TABLE acta_divorcio
    ADD CONSTRAINT acta_divorcio_persona_fkv2 FOREIGN KEY ( cui_mujer )
        REFERENCES persona ( cui );

ALTER TABLE acta_matrimonio
    ADD CONSTRAINT acta_matrimonio_persona_fk FOREIGN KEY ( cui_hombre )
        REFERENCES persona ( cui );

ALTER TABLE acta_matrimonio
    ADD CONSTRAINT acta_matrimonio_persona_fkv2 FOREIGN KEY ( cui_mujer )
        REFERENCES persona ( cui );

ALTER TABLE acta_nacimiento
    ADD CONSTRAINT acta_nacimiento_municipio_fk FOREIGN KEY ( municipio_id_municipio )
        REFERENCES municipio ( id_municipio );

ALTER TABLE acta_nacimiento
    ADD CONSTRAINT acta_nacimiento_persona_fk FOREIGN KEY ( persona_cui )
        REFERENCES persona ( cui );

ALTER TABLE licencia
    ADD CONSTRAINT licencia_persona_fk FOREIGN KEY ( persona_cui )
        REFERENCES persona ( cui );

ALTER TABLE licencia
    ADD CONSTRAINT licencia_tipo_licencia_fk FOREIGN KEY ( tipo_licencia_tipo )
        REFERENCES tipo_licencia ( tipo );

ALTER TABLE municipio
    ADD CONSTRAINT municipio_departamento_fk FOREIGN KEY ( departamento_id_departamento )
        REFERENCES departamento ( id_departamento );

ALTER TABLE persona
    ADD CONSTRAINT persona_estado_civil_fk FOREIGN KEY ( estado_civil_id_estado )
        REFERENCES estado_civil ( id_estado );



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            10
-- CREATE INDEX                             3
-- ALTER TABLE                             22
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
