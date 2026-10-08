-- ============================================
-- Q4 : Qui est le meilleur vendeur dans chaque territoire ?
-- Techniques : RANK() OVER (PARTITION BY ...), CTE
-- ============================================
USE adventureworks;

-- meilleur vendeur dans chaque territoire
with classement as (
    select salespersonid, territoryid, 
        round(sum(subtotal), 0) as ca,
        rank() over (partition by territoryid order by sum(subtotal) desc) as rang
from salesorderheader as sa
where salespersonid is not null
group by salespersonid, territoryid
)
select territoryid,Name as territoire , FirstName as Prenom , LastName as Nom, ca 
from classement
join person as pe on pe.BusinessEntityID = classement.salespersonid
join salesterritory as te using(territoryid)
where rang = 1
order by territoryid;
-- CONCLUSIONS Q4
-- Jillian Carson est n°1 dans 2 territoires (Northeast et Central).
-- Jae Pak (Canada) est la meilleure en valeur : 8,5 M.
-- Lynn Tsoflias est n°1 de son territoire avec 1,4 M seulement :
-- être 1er localement ne veut pas dire être un gros vendeur.
-- Aucun des 3 managers n'est n°1 d'un territoire.
