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