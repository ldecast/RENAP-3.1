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
