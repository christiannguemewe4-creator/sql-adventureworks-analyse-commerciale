-- ============================================
-- Q3 : Mes vendeurs atteignent-ils leurs objectifs ? Qui est au-dessus de la moyenne ?
-- Techniques : jointures multiples, sous-requêtes, CTE, CASE
-- ============================================
USE adventureworks;

-- Q3a: qui sont les vendeurs ?
SELECT  FirstName as prenom, LastName as Nom
FROM salesperson
JOIN person USING (BusinessEntityID)
where Territoryid is null ;
-- qui sont ces 3
SELECT 
    FirstName AS prenom, 
    LastName AS nom,
    JobTitle AS poste
FROM salesperson
JOIN person USING (BusinessEntityID)
JOIN employee USING (BusinessEntityID)
WHERE TerritoryID IS NULL;
-- effectivement ils sont 3 managers
-- donc en fait nous avons 17 vendeurs dont 3 managers (Stephen Jiang, Syed Abbas, Amy Alberts) :
-- pas de territoire ni d'objectif. Restent 14 vendeurs terrain.

-- Q3b : le CA de chaque vendeur
SELECT  FirstName as prenom, LastName as Nom,
ROUND(SUM(SubTotal), 0) as ca , 
 COUNT(*) as nb_commandes
FROM salesperson as sp
JOIN person USING (BusinessEntityID)
 JOIN salesorderheader as sa on sa.SalesPersonID = sp.BusinessEntityID
WHERE sp.TerritoryID IS NOT NULL
 group by nom,prenom 
 order by ca desc;
 
 -- Q3c : qui est au-dessus de la moyenne de l'équipe ?
 WITH ca_vendeur AS (
   SELECT  FirstName as prenom, LastName as Nom,
ROUND(SUM(SubTotal), 0) as ca , 
 COUNT(*) as nb_commandes
FROM salesperson as sp
JOIN person USING (BusinessEntityID)
 JOIN salesorderheader as sa on sa.SalesPersonID = sp.BusinessEntityID
WHERE sp.TerritoryID IS NOT NULL
 group by nom,prenom 
)
SELECT
    prenom,
    nom,
    ca,
    ROUND((SELECT AVG(ca) FROM ca_vendeur), 0) AS moyenne_equipe,
    ROUND(ca - (SELECT AVG(ca) FROM ca_vendeur), 0) AS ecart_moyenne,
    CASE 
        WHEN ca > (SELECT AVG(ca) FROM ca_vendeur) THEN 'Au-dessus'
        ELSE 'En dessous'
    END AS statut
FROM ca_vendeur
ORDER BY ca DESC;
-- CONCLUSION Q3c :
-- 14 vendeurs terrain (3 managers exclus). Moyenne de l'équipe : 5,6 M de CA.
-- 7 vendeurs au-dessus, 7 en dessous. Écart très large : de +4,8 M (L. Mitchell) à -4,2 M (L. Tsoflias).
-- Attention : ce classement ne tient pas compte de la taille des territoires ni de l'ancienneté.

-- Q3d: Comparaison de chaque vendeur à son propre objectif 
SELECT * FROM salespersonquotahistory
WHERE BusinessEntityID = 279
ORDER BY QuotaDate;
SELECT
BusinessEntityID,
SUM(SalesQuota) AS objectif_2024
FROM salespersonquotahistory
WHERE YEAR(QuotaDate) = 2024
GROUP BY BusinessEntityID;

-- Q3d-3 :  CA 2024 par vendeur en suivant le tableau
SELECT 
    SalesPersonID,
    SUM(SubTotal) AS ca_2024
FROM salesorderheader
WHERE YEAR(OrderDate) = 2024
  AND SalesPersonID IS NOT NULL
GROUP BY SalesPersonID;

-- Q3d-4 : réunir les deux et calculer le taux d'atteinte
-- Q3d-4 : taux d'atteinte des objectifs 2024
WITH objectifs AS (
    SELECT
        BusinessEntityID,
        SUM(SalesQuota) AS objectif_2024
    FROM salespersonquotahistory
    WHERE YEAR(QuotaDate) = 2024
    GROUP BY BusinessEntityID
),
ventes AS (
    SELECT
        SalesPersonID,
        SUM(SubTotal) AS ca_2024
    FROM salesorderheader
    WHERE YEAR(OrderDate) = 2024
      AND SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
)
SELECT
    p.FirstName AS prenom,
    p.LastName AS nom,
    ROUND(v.ca_2024, 0) AS ca_2024,
    ROUND(o.objectif_2024, 0) AS objectif_2024,
    ROUND(v.ca_2024 / o.objectif_2024 * 100, 1) AS taux_atteinte_pct
FROM objectifs AS o
JOIN ventes AS v ON v.SalesPersonID = o.BusinessEntityID
JOIN person AS p ON p.BusinessEntityID = o.BusinessEntityID
JOIN salesperson AS sp ON sp.BusinessEntityID = o.BusinessEntityID
WHERE sp.TerritoryID IS NOT NULL
ORDER BY taux_atteinte_pct DESC;

-- CONCLUSION FINALE Q3 :
-- Aucun des 14 vendeurs n'atteint son objectif 2024 (taux de 66 % à 89 %, équipe ≈ 80 %).
-- Le classement par objectif diffère du classement par CA : D. Campbell, sous la moyenne en CA,
-- est le plus proche de son objectif (88,9 %). Le CA brut ne suffit pas à juger un vendeur.
-- Écart général → soit sous-performance, soit objectifs trop ambitieux : à discuter avec la direction.
-- Hypothèse : objectifs trimestriels décalés d'un mois, comparés par année.