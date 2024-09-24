Create database Paris_Olympic;

drop table if exists teams;

Create table Teams (
Name varchar(50) not null,
Discipline Varchar (50) not null,
NOC varchar (50) not null,
Event varchar(50) not null
);

drop table if exists Medals;

Create table Medals (
Ranks integer not null,
Team_NOC varchar (50) not null,
Gold integer not null,
Silver integer not null,
Bronze integer not null,
Total integer not null,	
Rank_by_Total integer not null
);

drop table if exists Entries_Gender;

Create Table Entries_Gender (
Discipline varchar (50) not null,
Female integer not null,
Male integer not null,
Total integer not null
);

drop table if exists Coaches;

create Table Coaches(
Name Varchar (50) not null,
NOC varchar (50) not null,
Discipline varchar (50) not null,
Event varchar (50)
);

drop table if exists Athelets;

Create Table athelets(
Name Varchar (50),
NOC varchar (50),
Discipline varchar (50)
);

--  Query 1: - Total count of participants across all disciplines according to the fields --

select discipline, Total as Participants
from entries_gender
order by participants desc;

--  Query 2: - Most Medals won by each country, top 3 ranks --

select Team_Noc, Total as Most_medals, Rank_by_total
from Medals 
order by Rank_by_total
limit 3;

 -- Query 3: - Most Bronze,silver and gold --
 
(select 'Gold' as MEDAL_TYPE, gold as Medal_Count, Team_NOC from medals order by Gold desc limit 1 )
Union all
(select 'Silver' as MEDAL_TYPE, silver as Medal_Count, Team_NOC from medals order by Silver desc  limit 1)
union all
(select 'Bronze' as MEDAL_TYPE, bronze as Medal_Count, Team_NOC from medals order by Bronze desc limit 1);

-- Query 4: - Particpants at across countries --

select NOC, count(Name) as Total_participants
from athelets
group by NOC
order by Total_participants desc;

--  Total Events, countries, Athelets, Medals --

(select count(distinct discipline) as Total , 'Total Events' as 'Total' 
from athelets) union 
(select count(distinct NOC)  as Total , 'Total Countries' as 'Total' 
from athelets)
union all
(select sum(female) as total, 'total Female' as 'Total'
from entries_gender)
union all
(select sum(male) as total, 'total Male' as 'Total'
from entries_gender)
union all
(select sum(Total) as total, 'Total Athelets' as 'Total'
from entries_gender)
union all
(select sum(gold) as total, 'Gold Medals' as 'Total' from medals) 
union all
(select sum(silver) as total, 'Silver Medals' as 'Total' from medals)
union all
(select sum(bronze) as total, 'Bronze Medals' as 'Total'from medals)
union all
(select sum(total) as total, 'Total Medals' as 'Total' from medals);

-- Query 6: - Coaches produced by the countries --

select NOC, count(Name) as Coaches_by_Nations
from coaches
group by NOC
order by NOC;

-- Query 7: - Coaches vs Player Ratio --

select  c.noc, 
		count(distinct a.name) as Total_atheletes, 
        count(distinct c.name) as Total_Coaches, 
        round(count(distinct a.name)/count(distinct c.name), 2) as player_vs_coach_Ratio
from coaches c
join athelets a 
on c.noc = a.noc
group by c.noc
order by Total_atheletes desc;

-- Query 8: - Show how much medals does a Country wins with their Players and Coaches --

select a.NOC as Country,  m.total as Medals, count(distinct c.NAME) as Coaches, count(distinct a.NAME) as Athletes
from athelets a 
join coaches c
on a.NOC = c.NOC
join medals m
on c.NOC = m.Team_NOC
group by a.NOC, m.total
order by medals desc;

-- Query 9: - Sports with Highes female participation --

select Discipline, Female, Total, Round((female/total),2)*100 as Female_Participation
from entries_gender
order by Female_Participation desc;

-- Query 10: - Sports with Highes male participation --

select Discipline, Male, Total, Round((Male/total),2)*100 as Male_Participation
from entries_gender
order by Male_Participation desc;

-- Query 11: - Get the Top 5 NOCs by Total Medal Count --

SELECT Team_NOC, Total 
FROM Medals 
WHERE Total in (SELECT Total FROM Medals ORDER BY Total DESC)
limit 5;

-- Query 12: - Find Coaches Who Have Coached for NOCs with at Least 5 Gold Medals --

SELECT c.Name, c.NOC, c.Discipline
FROM Coaches c
INNER JOIN (
   SELECT Team_NOC, SUM(Gold) AS TotalGold
   FROM Medals
   GROUP BY Team_NOC
   HAVING SUM(Gold) >= 5
) AS MedalWinners
ON c.NOC = MedalWinners.Team_NOC;

-- Query 13: - List All Teams That Participated in Disciplines with More than 200 Total Participants (Across Male and Female) --

SELECT t.Name, t.NOC, t.Discipline
FROM Teams t
INNER JOIN (
   SELECT Discipline FROM entries_gender WHERE Total > 200
) AS PopularDisciplines
ON t.Discipline = PopularDisciplines.Discipline;

-- Query 14: - Find the Average Number of Gold Medals per NOC and Only Return Those with More Than the Average

WITH AvgGold AS (
   SELECT AVG(Gold) AS AvgGoldMedals 
   FROM Medals
)
SELECT Team_NOC, Gold 
FROM Medals, AvgGold 
WHERE Gold > AvgGoldMedals;

-- Query 15: - List All Coaches Who Have Coached Athletes in More Than One Discipline

WITH CoachDisciplines AS (
   SELECT Name, COUNT(DISTINCT Discipline) AS DisciplineCount 
   FROM Coaches 
   GROUP BY Name
)
SELECT Name 
FROM CoachDisciplines 
WHERE DisciplineCount > 1;

-- Query 16: - Find the NOCs with the Highest Average Number of Medals per Discipline --

WITH AvgMedalsPerDiscipline AS (
   SELECT m.Team_NOC, t.Discipline, Round(AVG(m.Total)) AS AvgTotalMedals
   FROM Medals m
   INNER JOIN Teams t ON m.Team_NOC = t.NOC
   GROUP BY m.Team_noc, t.Discipline
)
SELECT Discipline, Team_Noc,  AvgTotalMedals
FROM AvgMedalsPerDiscipline
order by Discipline;
















