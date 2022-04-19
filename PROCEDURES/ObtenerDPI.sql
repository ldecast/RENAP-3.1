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