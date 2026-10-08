-- ============================================
-- Q5 : Qui sont nos petits, moyens et gros clients ?
-- Techniques : CASE WHEN, CTE, SUM() OVER ()
-- ============================================
USE adventureworks;

WITH clients AS (
    SELECT
        CustomerID,
        ROUND(SUM(SubTotal), 0) AS ca,
        CASE
            WHEN SUM(SubTotal) < 1000  THEN 'Petit'
            WHEN SUM(SubTotal) < 10000 THEN 'Moyen'
            ELSE 'Gros'
        END AS niveau
    FROM salesorderheader
    GROUP BY CustomerID
)
SELECT niveau,
    COUNT(CustomerID) AS nb_clients,
    ROUND(COUNT(CustomerID) / SUM(COUNT(CustomerID)) OVER () * 100, 1) AS pct_clients,
    SUM(ca) AS ca_total,
    ROUND(SUM(ca) / SUM(SUM(ca)) OVER () * 100, 1) AS pct_ca
FROM clients
GROUP BY niveau;

-- CONCLUSIONS Q5
-- Seuils choisis : Petit < 1 000 ; Moyen 1 000 - 10 000 ; Gros >= 10 000.
-- 477 gros clients (2,5 % des clients) font 72,9 % du CA.
-- 10 824 petits clients (56,6 %) ne font que 1,4 % du CA.
-- Le CA des gros clients (80,1 M) est proche du CA du canal vendeurs (80,5 M) :
-- les gros clients sont probablement les magasins, servis par les vendeurs.
-- Recommandation : un suivi commercial dédié pour les gros clients,
-- des actions en ligne automatisées pour les petits.
