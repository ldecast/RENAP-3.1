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
    l.fecha_vencimiento AS 'FechaVencimiento'
FROM persona p
INNER JOIN licencia l
	ON l.persona_cui = p.cui
WHERE p.cui = cui_persona;


END $$