-- ============================================
-- 00 : Exploration et contrôle des données
-- ============================================
USE adventureworks;

DESCRIBE salesorderheader;

-- Nombre total de commandes
SELECT COUNT(*) AS nb_commandes FROM salesorderheader;

-- Période couverte par les données
SELECT
    MIN(OrderDate) AS premiere_commande,
    MAX(OrderDate) AS derniere_commande
FROM salesorderheader;
-- Période : 30/05/2022 au 29/06/2025, donc 2022 et 2025 sont des années incomplètes.

-- Nombre de commandes sans vendeur
SELECT COUNT(*) AS nb_sans_vendeur
FROM salesorderheader
WHERE SalesPersonID IS NULL;
-- 27 659 commandes sans vendeur (88 %) = ventes en ligne aux particuliers
-- 3 806 commandes avec vendeur (12 %) = ventes aux magasins revendeurs

-- Comparaison des deux canaux de vente
SELECT OnlineOrderFlag,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SubTotal), 0) AS ca
FROM salesorderheader
GROUP BY OnlineOrderFlag;
-- Canal vendeurs : 12 % des commandes, 73 % du CA (panier moyen ≈ 21 148)
-- Canal en ligne : 88 % des commandes, 27 % du CA (panier moyen ≈ 1 061)
-- Une commande passée par un vendeur rapporte en moyenne 20 fois plus qu'une commande en ligne.

-- Contrôle de cohérence entre l'en-tête et le détail d'une commande
SELECT COUNT(*) AS nb_lignes
FROM salesorderdetail
WHERE SalesOrderID = 43659;

SELECT SubTotal
FROM salesorderheader
WHERE SalesOrderID = 43659;

SELECT SUM(LineTotal) AS somme_lignes
FROM salesorderdetail
WHERE SalesOrderID = 43659;
-- Contrôle de cohérence : SubTotal (en-tête) = SUM(LineTotal) (détail) → OK
