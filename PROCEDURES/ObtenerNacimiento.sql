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