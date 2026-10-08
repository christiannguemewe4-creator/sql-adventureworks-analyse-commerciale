-- ============================================
-- Q8 : Permettre au directeur de consulter les chiffres chaque mois
-- Technique : CREATE VIEW
-- ============================================
USE adventureworks;

CREATE OR REPLACE VIEW ca_mensuel AS
SELECT
    YEAR(OrderDate) AS annee,
    MONTH(OrderDate) AS mois,
    ROUND(SUM(SubTotal), 0) AS ca,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(SUM(SubTotal)) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)), 0) AS ca_cumule
FROM salesorderheader
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

-- Consultation par le directeur
SELECT * FROM ca_mensuel
ORDER BY annee, mois;

-- CONCLUSIONS Q8
-- Vue créée : ca_mensuel (CA, nombre de commandes et CA cumulé par mois).
-- Utilisation : SELECT * FROM ca_mensuel ORDER BY annee, mois;
-- La vue stocke la requête, pas les chiffres : elle se met à jour
-- automatiquement avec les nouvelles commandes.
-- CREATE OR REPLACE évite l'erreur 1050 (« already exists ») si on relance le script.
