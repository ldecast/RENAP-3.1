DELIMITER $$
DROP FUNCTION IF EXISTS FechaFutura $$ CREATE FUNCTION FechaFutura(
    fecha DATE
)
RETURNS BOOLEAN
DETERMINISTIC

BEGIN

DECLARE fecha_futura BOOLEAN;

(
    SELECT (fecha > CURDATE()) INTO fecha_futura
);


-- return the boolean  
RETURN (fecha_futura);
END $$