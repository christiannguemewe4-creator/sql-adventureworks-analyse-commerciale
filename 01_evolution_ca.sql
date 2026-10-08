-- ============================================
-- Q1 : Comment évolue notre CA d'une année et d'un trimestre à l'autre ?
-- Techniques : fonctions de date, LAG, CTE
-- ============================================
USE adventureworks;

 -- Q1a : Évolution du CA par année
SELECT year(orderdate) as annee , ROUND(SUM(SubTotal), 0) as ca, count(*) as nb_commandes
FROM salesorderheader
GROUP BY  year(orderdate)
ORDER BY annee;
-- CONCLUSION Q1a : oui, on grandit, +38 % entre 2023 et 2024
-- 2022 (7 mois) et 2025 (6 mois) affichent un CA plus faible car ce sont des années
-- incomplètes : elles ne peuvent pas être comparées aux années pleines.
-- Comparaison valable 2023 vs 2024 : le CA passe de 31,6 M à 43,7 M (+38 %).
-- Le nombre de commandes est multiplié par 3,7 alors que le CA n'augmente que de 38 % :
-- la croissance vient de nombreuses petites commandes (panier moyen en forte baisse).

-- Q1b : le CA par trimestre
SELECT year(orderdate)as annee, 
quarter(orderdate) as trimestre , 
ROUND(SUM(SubTotal), 0) as ca, 
count(*) as nb_commandes
FROM salesorderheader
GROUP BY quarter(orderdate), year(orderdate)
ORDER BY annee, trimestre;
-- Panier moyen
SELECT year(orderdate)as annee, 
quarter(orderdate) as trimestre , 
ROUND(SUM(SubTotal), 0) as ca, 
count(*) as nb_commandes,
ROUND(AVG(SubTotal), 0) AS panier_moyen
FROM salesorderheader
GROUP BY quarter(orderdate), year(orderdate)
ORDER BY annee, trimestre;
-- Panier moyen : ~9 000 en 2022-2023, ~6 700 début 2024, ~2 000 depuis T3 2024 (÷3).

-- Qc:Evolution du ca
SELECT 
    YEAR(OrderDate) AS annee,
    QUARTER(OrderDate) AS trimestre,
    ROUND(SUM(SubTotal), 0) AS ca,
    COUNT(*) AS nb_commandes,
    ROUND(LAG(SUM(SubTotal)) OVER (ORDER BY YEAR(OrderDate), 
    QUARTER(OrderDate)), 0) AS ca_precedent
FROM salesorderheader
GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
ORDER BY annee, trimestre;

-- Q1c : Taux de croissance trimestriel

WITH ca_trimestre AS (
    SELECT
        YEAR(OrderDate) AS annee,
        QUARTER(OrderDate) AS trimestre,
        ROUND(SUM(SubTotal), 0) AS ca,
        COUNT(*) AS nb_commandes,
        ROUND(LAG(SUM(SubTotal)) OVER (ORDER BY YEAR(OrderDate), QUARTER(OrderDate)), 0) AS ca_precedent
    FROM salesorderheader
    GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
)
SELECT
    annee,
    trimestre,
    ca,
    ca_precedent,
    ROUND((ca - ca_precedent) / ca_precedent * 100, 1) AS croissance_pct
FROM ca_trimestre
ORDER BY annee, trimestre;
-- À cause de la saisonnalité, comparer un trimestre au précédent peut tromper.

-- Q1d on compare le trimestre au mme trimestre de l annee d avant
WITH ca_trimestre AS (
    SELECT
        YEAR(OrderDate) AS annee,
        QUARTER(OrderDate) AS trimestre,
        ROUND(SUM(SubTotal), 0) AS ca,
        ROUND(LAG(SUM(SubTotal)) OVER (PARTITION BY QUARTER(OrderDate) ORDER BY YEAR(OrderDate)), 0) AS ca_annee_precedente
    FROM salesorderheader
    GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
)
SELECT
    annee,
    trimestre,
    ca,
    ca_annee_precedente,
    ROUND((ca - ca_annee_precedente) / ca_annee_precedente * 100, 1) AS croissance_n_n1
FROM ca_trimestre
ORDER BY annee, trimestre;


