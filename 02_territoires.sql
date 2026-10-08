-- ============================================
-- Q2 : Quels territoires rapportent le plus, et quelle part du CA représente chacun ?
-- Techniques : jointures, SUM() OVER ()
-- ============================================
USE adventureworks;
SELECT * FROM salesterritory;
-- nous notons ici que ModifiedDate contient des dates de 2019 donc attention
-- Q:2a : le CA par territoire
SELECT
    Name AS territoire,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SubTotal), 0) AS ca
FROM salesterritory
JOIN salesorderheader USING (TerritoryID)
GROUP BY Name
ORDER BY ca DESC;
-- Q 2b : la part de chaque territoire dans le CA total
SELECT
    Name AS territoire,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SubTotal), 0) AS ca,
    ROUND(SUM(SubTotal) / SUM(SUM(SubTotal)) OVER () * 100, 1) AS part_ca_pct
FROM salesterritory
JOIN salesorderheader USING (TerritoryID)
GROUP BY Name
ORDER BY ca DESC;
-- l'entreprise dépend fortement de l'Amérique du Nord. Si ce marché ralentit, 
-- tout le CA est touché. On pourrait d'ailleurs vérifier si la chute du T2 2025 vient de là
-- 2c : par grande zone
SELECT `Group` AS zone,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SubTotal), 0) AS ca,
    ROUND(SUM(SubTotal) / SUM(SUM(SubTotal)) OVER () * 100, 1) AS part_ca_pct
FROM salesterritory
JOIN salesorderheader USING (TerritoryID)
GROUP BY  `Group`
ORDER BY ca DESC;

-- CONCLUSION Q2 :
-- Southwest est le 1er territoire (22 % du CA). Le top 3 (Southwest, Canada, Northwest) = 51,5 %.
-- Par zone : Amérique du Nord 72 %, Europe 18 %, Pacifique 10 %.
-- Forte dépendance à l'Amérique du Nord : un risque si ce marché ralentit.
-- Paniers moyens très différents selon les territoires (Central ≈ 20 500 vs Australie ≈ 1 560) :
-- les modèles de vente (magasins vs en ligne) varient selon les régions.
-- Les colonnes SalesYTD/SalesLastYear de salesterritory (2019) ne sont pas utilisées : non à jour.
