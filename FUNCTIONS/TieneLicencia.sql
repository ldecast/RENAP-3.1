DELIMITER $$
DROP FUNCTION IF EXISTS TieneLicencia $$ CREATE FUNCTION TieneLicencia(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE tiene_licencia BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM licencia l WHERE l.persona_cui = cui) INTO tiene_licencia
);
            
-- return the boolean  
RETURN (tiene_licencia);
END $$