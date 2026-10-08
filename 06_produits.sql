-- ============================================
-- Q6 : Quels sont nos 10 produits stars, et quels produits ne se vendent jamais ?
-- Techniques : LIMIT, LEFT JOIN ... IS NULL
-- ============================================
USE adventureworks;

-- Aperçu de la table des lignes de commande
SELECT * FROM salesorderdetail LIMIT 5;

-- Q6a : les 10 produits stars (par CA)
SELECT ProductID, Name AS nomproduit, ROUND(SUM(LineTotal), 0) AS ca
FROM salesorderdetail
JOIN product USING (ProductID)
GROUP BY ProductID, nomproduit
ORDER BY ca DESC
LIMIT 10;

-- Q6b : les produits qui ne se vendent jamais
SELECT ProductID, Name AS nomproduit
FROM product
LEFT JOIN salesorderdetail USING (ProductID)
WHERE SalesOrderID IS NULL;

-- Nombre de produits jamais vendus
SELECT COUNT(*) AS nb_produits_jamais_vendus
FROM product
LEFT JOIN salesorderdetail USING (ProductID)
WHERE SalesOrderID IS NULL;

-- Nombre total de produits du catalogue
SELECT COUNT(*) AS nb_produits_total
FROM product;

-- CONCLUSIONS Q6
-- Top produits : le VTT Mountain-200 (noir et argent, plusieurs tailles)
-- occupe les premières places (de 3,4 M à 4,4 M chacun) : c'est le vrai produit star.
-- 238 produits sur 504 (47 %) ne se sont jamais vendus.
-- Attention : beaucoup sont des pièces de fabrication (Crown Race, Down Tube, Decal...)
-- utilisées en interne, pas des articles destinés à la vente.
-- À vérifier avant de conclure que ces produits encombrent le catalogue.
-- Leçon : LEFT JOIN garde toute la table de gauche (product) ; on teste IS NULL
-- sur une colonne de la table de droite (SalesOrderID), pas sur la clé de jointure.
