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

/* PERSONA */
INSERT INTO
    persona (cui, primer_nombre, segundo_nombre, tercer_nombre, primer_apellido, segundo_apellido, estado_civil_id_estado)
VALUES
    (3006240181101, 'Luis', 'Danniel', 'Ernesto', 'Castellanos', 'Galindo', 1);

