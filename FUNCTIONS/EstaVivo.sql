DELIMITER $$
DROP FUNCTION IF EXISTS PersonaViva $$ CREATE FUNCTION PersonaViva(
    cui BIGINT
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE vivo BOOLEAN;

(
    SELECT EXISTS (SELECT 1 FROM acta_defuncion ad WHERE ad.persona_cui = cui) INTO vivo
);
            
-- return the boolean  
RETURN (vivo);
END $$