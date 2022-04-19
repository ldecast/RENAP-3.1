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