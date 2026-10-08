-- ============================================
-- Q7 : Comment s'accumule notre CA mois après mois ?
-- Techniques : SUM() OVER (ORDER BY ...)
-- ============================================
USE adventureworks;

SELECT
    YEAR(OrderDate) AS annee,
    MONTH(OrderDate) AS mois,
    ROUND(SUM(SubTotal), 0) AS ca,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SUM(SubTotal)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)), 0) AS ca_cumule
FROM salesorderheader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY annee, mois;

-- CONCLUSIONS Q7
-- Les données commencent fin mai 2022 (mois partiel : 47 commandes seulement).
-- Attention : grouper par mois seul mélange les années ;
-- il faut grouper par année ET mois.
-- Deux ORDER BY : celui dans OVER() fixe l'ordre du calcul du cumul,
-- celui de la fin fixe l'ordre d'affichage.
-- CA cumulé total à la fin de la période : 109,8 M (identique au total de Q5).
-- Anomalie en juin 2025 : 905 commandes mais seulement 47 492 de CA
-- (panier moyen ≈ 52, contre plusieurs milliers les autres mois), alors que
-- les données vont jusqu'au 29/06. Probable effet de fin de jeu de données :
-- à vérifier avant d'en tirer une conclusion commerciale.
