DELIMITER $$
DROP FUNCTION IF EXISTS ExistePersona $$ CREATE FUNCTION ExistePersona(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE existe BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM persona p WHERE p.cui = cui) INTO existe
);
            
-- return the boolean  
RETURN (existe);
END $$