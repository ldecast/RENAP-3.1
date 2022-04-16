DELIMITER $$
DROP FUNCTION IF EXISTS TieneDPI $$ CREATE FUNCTION TieneDPI(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE tiene_dpi BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM persona p WHERE p.cui = cui AND p.dpi_generado = 1) INTO tiene_dpi
);
            
-- return the boolean  
RETURN (tiene_dpi);
END $$