DELIMITER $$

DROP PROCEDURE IF EXISTS getDivorcio $$ CREATE PROCEDURE getDivorcio(
    IN acta_matrimonio INTEGER
)
getdiv_proc:BEGIN


/* NO EXISTE */
IF (SELECT EXISTS (SELECT 1 FROM acta_divorcio WHERE id_matrimonio = acta_matrimonio) = 0) THEN
    SELECT 'ACTA DE DIVORCIO NO SE ENCUENTRA.' AS ERROR;
    LEAVE getdiv_proc;
END IF;

/* RESULTADO */
SELECT
	ad.id_acta AS 'NoDivorcio',
    hombre.cui AS 'DPIHombre',
    CONCAT(hombre.primer_nombre, ' ', hombre.segundo_nombre, ' ', hombre.tercer_nombre, ' ', hombre.primer_apellido, ' ', hombre.segundo_apellido) AS 'NombreHombre',
    mujer.cui AS 'DPIMujer',
    CONCAT(mujer.primer_nombre, ' ', mujer.segundo_nombre, ' ', mujer.tercer_nombre, ' ', mujer.primer_apellido, ' ', mujer.segundo_apellido) AS 'NombreMujer',
    am.fecha_matrimonio AS 'FechaMatrimonio',
    ad.fecha_divorcio AS 'FechaDivorcio'
FROM acta_divorcio ad
INNER JOIN acta_matrimonio am
	ON am.id_acta = ad.id_matrimonio
INNER JOIN persona hombre
    ON hombre.cui = am.cui_hombre
INNER JOIN persona mujer
    ON mujer.cui = am.cui_mujer
WHERE ad.id_matrimonio = acta_matrimonio;


END $$