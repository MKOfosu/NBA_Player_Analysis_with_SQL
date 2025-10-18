-- ----------------Setting up ----------------
CREATE DATABASE nba_player_stats;
USE nba_player_stats;
DROP TABLE IF EXISTS all_seasons;

CREATE TABLE all_seasons (
	id INT AUTO_INCREMENT PRIMARY KEY UNIQUE,
	player_name VARCHAR(50),
	team_abbreviation VARCHAR(10),
	age INT,
	player_height INT,
	player_weight FLOAT,
	college VARCHAR(50),
	country VARCHAR(50),
	draft_year VARCHAR(20),
	draft_round VARCHAR(20),
	draft_number VARCHAR(20),
	games_played FLOAT,
	points_per_game FLOAT,
	rebound FLOAT,
	assist_per_game FLOAT,
	net_rating FLOAT,
	offensive_rebound_pct FLOAT,
	defensive_rebound_pct FLOAT,
	usage_pct FLOAT,
    true_shooting_pct FLOAT,
    assist_pct FLOAT,
	season VARCHAR(20)
);

-- Load the csv file
LOAD DATA LOCAL INFILE "C:/Users/AWENARE SUB 1/Desktop/Mathias SQL Practice/all_seasons.csv"
INTO TABLE all_seasons
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/* 
Data Cleaning Procedure
The following issues are being dealt with:
1. Trim all text/VARCHAR columns
2. The draft_year, draft_round and draft_number columns are originally strings because they have a "Undrafted".
	Plan is to set all "Undrafted" to NULL and CAST the affected columns as INT
3. The season column came in the format "1996-97"
	Plan is to extract the starting seasons "1996" according to NBA conventions and cast as INT
4. Modify the columns to relect changes in the data types
 */
 -- Check for datatypes
 DESCRIBE all_seasons;
 
SET SQL_SAFE_UPDATES = 0;

UPDATE all_seasons
SET 
	player_name = NULLIF(TRIM(player_name), ""),
    team_abbreviation = NULLIF(TRIM(team_abbreviation), ""),
    college = NULLIF(TRIM(college), ""),
    country = TRIM(country),
	draft_year = CAST(NULLIF(TRIM(draft_year), "Undrafted") AS UNSIGNED),
    draft_round = CAST(NULLIF(TRIM(draft_round), "Undrafted") AS UNSIGNED),
    draft_number = CAST(NULLIF(TRIM(draft_number), "Undrafted") AS UNSIGNED),
    season = CAST(LEFT(TRIM(season), 4) AS UNSIGNED);
    
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE all_seasons
MODIFY COLUMN draft_year YEAR,
MODIFY COLUMN draft_round INT,
MODIFY COLUMN draft_number INT,
MODIFY COLUMN season YEAR;

-- Check for the changes
DESCRIBE all_seasons;

-- Check for duplicates

-- Check for unrealistic values

-- CREATE A DUPLICATE TABLE
DROP TABLE IF EXISTS all_seasons_copy;
CREATE TABLE all_seasons_copy AS (
	SELECT *
	FROM all_seasons
);
-- THE Data is now ready for analysis

/* Questions to Answer
Which players lead their seasons in scoring, rebounding, and playmaking - and how efficient are they?

How do players from different eras (1990s, 2000s, 2010s, 2020s) compare in size, style, and performance?

Which teams, positions, or player types consistently produce top performers?

Based on the data, who deserves the MVP crown - and how does your pick compare to the official NBA MVP?
*/

-- Preliminary checks-- 

-- Check for duplicates
SELECT 
	player_name, team_abbreviation, 
    age, player_height, player_weight, 
    college, country, draft_year, draft_round, 
    draft_number, games_played, points_per_game, 
    rebound, assist_per_game, net_rating, 
    offensive_rebound_pct, defensive_rebound_pct, 
    usage_pct, true_shooting_pct, assist_pct, season
FROM 
	all_seasons
GROUP BY 
	player_name, team_abbreviation, 
    age, player_height, player_weight, college, 
    country, draft_year, draft_round, draft_number, 
    games_played, points_per_game, rebound, assist_per_game, 
    net_rating, offensive_rebound_pct, defensive_rebound_pct, 
    usage_pct, true_shooting_pct, assist_pct, season
HAVING COUNT(*) > 1;

-- There were no duplicate records found.

-- How many rows of data exists?
SELECT
	COUNT(*) AS num_of_records
FROM
	all_seasons;
-- There are 12844 records in the dataset
    
-- How many unique players are in the dataset?
SELECT
	COUNT(DISTINCT player_name) AS unique_players
FROM
	all_seasons;
-- There are 2551 unique players

-- How many unique teams are in the data
SELECT
	COUNT(DISTINCT team_abbreviation) AS num_of_teams
FROM
	all_seasons;
-- There are 36 unique teams in the dataset

-- How many NBA seasons are we looking at?
SELECT
	COUNT(DISTINCT season) AS num_of_seasons
FROM
	all_seasons;

SELECT
	MIN(season) AS start_season,
    MAX(season) AS last_season
FROM
	all_seasons;
-- There are 27 seasons of NBA in the dataset, spanning from 1996 to 2022.

-- How many countries are represented in the NBA?
SELECT
	COUNT(DISTINCT country) AS unique_countries
FROM
	all_seasons;
-- There are 82 different countries represented in the NBA

-- The top 5 countries
SELECT
 country,
 COUNT(DISTINCT player_name) AS num_players,
 COUNT(DISTINCT player_name) / (SELECT COUNT(DISTINCT player_name) FROM all_seasons) * 100 AS pct
FROM
	all_seasons
GROUP BY 
	country
ORDER BY num_players DESC
LIMIT 5;
-- The majority of NBA players, 83.9%, hail from the USA.

-- How many colleges are producing NBA players
SELECT DISTINCT
	COUNT(DISTINCT college) AS num_of_colleges
FROM
	all_seasons;
    
-- What are the top_10 producing colleges
SELECT
	college,
    COUNT(DISTINCT player_name) AS num_players
FROM
	all_seasons
GROUP BY
	college
ORDER BY
	num_players DESC;
-- It turned out that 361 of the players did not come out of any college. Kentucky, Duke and UCLA 
-- topped the colleges that has produced the highest number of NBA players

-- Check the maximum and minimums of the stats like game_played, pts, rebound, assist and net rating for possible outliers
SELECT
	MAX(games_played) AS max_gp,
    MIN(games_played) AS min_gp,
    MAX(points_per_game) AS max_pts,
    MIN(points_per_game) AS min_pts,
    MAX(rebound) AS max_rebd,
    MIN(rebound) AS min_rebd,
    MAX(assist_per_game) AS max_ast,
    MIN(assist_per_game) AS min_ast,
    MAX(net_rating) AS max_net,
    MIN(net_rating) AS min_net
FROM
	all_seasons;
    
-- It appears that net ratings have very extreme values; max: 300, min: -250
-- This needs further investigation since net ratings typically range from -30 to +30

-- Check the maximum and minimums of the advanced stats like orebd, drebd, usage_pct, ts_pct and ass_pct
SELECT
	MAX(offensive_rebound_pct) AS max_orebd,
    MIN(offensive_rebound_pct) AS min_orebd,
    MAX(defensive_rebound_pct) AS max_drebd,
    MIN(defensive_rebound_pct) AS min_drebd,
    MAX(usage_pct) AS max_usg_pct,
    MIN(usage_pct) AS min_usg_pct,
    MAX(true_shooting_pct) AS max_ts_pct,
    MIN(true_shooting_pct) AS min_ts_pct,
    MAX(assist_pct) AS max_ast_pct,
    MIN(assist_pct) AS min_ast_pct
FROM
	all_seasons;
-- the advanced stats in pct has ranges from  0-1 
-- excpet for true_shooting_pct which had a maximum of 1.5 which is impossible. Needs investigation and further action.

-- Checking for the outliers in net_ratings
SELECT
player_name,
games_played,
net_rating,
season
FROM
	all_seasons
WHERE
	net_rating > 30 OR net_rating < -30;

-- Checking for the outliers in true_shooting_pct
SELECT
	player_name,
	games_played,
	true_shooting_pct,
	season
FROM
	all_seasons
WHERE
	true_shooting_pct > 1.0;

/* 
Outliers handing
The strategy is to replace the values with outliers with the average values of the affected players for other seasons.
1. Get the players with outliers
2. Get the average of all players with ouliers exclusing the season with the outlier
2. Update the outliers with their individual averages.
*/

-- step 1: Get the players with outliers
CREATE TEMPORARY TABLE players_with_outliers AS
SELECT DISTINCT
	player_name
FROM
	all_seasons
WHERE
	true_shooting_pct > 1.0 OR 
    net_rating > 30 OR 
    net_rating < -30;
    
-- Step 2: Get the average of all players with ouliers exclusing the season with the outlier
CREATE TEMPORARY TABLE player_with_outliers_avg_metrics AS
SELECT
	a_s.player_name,
    AVG(CASE WHEN net_rating BETWEEN -30 AND 30 THEN net_rating END) AS avg_net_rating,
    AVG(CASE WHEN true_shooting_pct <= 1 THEN true_shooting_pct END) AS avg_ts_pct
FROM 
	all_seasons AS a_s
JOIN players_with_outliers AS pwo
	ON a_s.player_name = pwo.player_name
GROUP BY
	player_name;
    
-- Step 3: Update the outliers with their individual averages using left_join
UPDATE all_seasons a_s
LEFT JOIN
	player_with_outliers_avg_metrics pwo_avg
    ON a_s.player_name = pwo_avg.player_name
SET
	a_s.net_rating = 
		CASE WHEN a_s.net_rating > 30 OR a_s.net_rating < -30 THEN pwo_avg.avg_net_rating 
			ELSE a_s.net_rating END,
    a_s.true_shooting_pct = 
		CASE WHEN a_s.true_shooting_pct > 1 THEN pwo_avg.avg_ts_pct 
        ELSE a_s.true_shooting_pct END;

-- DROP TEMPORARY TABLE players_with_outliers;
-- DROP TEMPORARY TABLE player_with_outliers_avg_metrics;

-- Check if the changes worked
SELECT DISTINCT
	player_name
FROM
	all_seasons
WHERE
	true_shooting_pct > 1.0 OR 
    net_rating > 30 OR 
    net_rating < -30;
    
-- Now that the data is cleaned and outliers are handled
-- We are ready to carry out the tasks
/* 1. Player Performance Analysis

	Rank players in each season by points, rebounds, assists per game.

	Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?

	Identify most improved players across seasons (biggest jump in points/rebounds/assists).
*/

-- Ranking by points
SELECT
	season,
	RANK() OVER (PARTITION BY season ORDER BY points_per_game DESC) AS pts_ranking_per_season,
	player_name,
    points_per_game    
FROM 
	all_seasons;
 
 -- Ranking by rebounds
 SELECT
	season,
	RANK() OVER (PARTITION BY season ORDER BY rebound DESC) AS rbd_ranking_per_season,
	player_name,
    rebound    
FROM 
	all_seasons;
    
 -- Ranking by assist_per_game
 SELECT
	season,
	RANK() OVER (PARTITION BY season ORDER BY assist_per_game DESC) AS asst_ranking_per_season,
	player_name,
    assist_per_game    
FROM 
	all_seasons;
    
-- 	Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?
SELECT
	player_name,
    AVG(true_shooting_pct) AS avg_ts_pct,
    AVG(usage_pct) AS avg_usage_pct
FROM
	all_seasons
GROUP BY
	player_name
ORDER BY avg_ts_pct DESC, avg_usage_pct DESC;

-- Identify most improved players across seasons (biggest jump in points/rebounds/assists). Using CTE
CREATE TEMPORARY TABLE stat_diff AS (
SELECT
	player_name,
    season,
    ROUND(points_per_game - LAG(points_per_game) OVER (PARTITION BY player_name ORDER BY season), 3) AS point_diff,
    ROUND(rebound - LAG(rebound) OVER (PARTITION BY player_name ORDER BY season), 3) AS rebound_diff,
    ROUND(assist_per_game - LAG(assist_per_game) OVER (PARTITION BY player_name ORDER BY season), 3) AS assist_diff
FROM
	all_seasons
);
-- Biggest improvement in point
SELECT 
	player_name,
    season,
    point_diff
FROM
	stat_diff
WHERE
	point_diff > 0
ORDER BY point_diff DESC
LIMIT 10;

/*  MarShon Brooks in 2017 improved on his previous points by 15.6, He was closely followed by Louis King, 
	who in 2022 improved his previous points by 15.5
	JaKarr Sampson in 2018 improved his points by 15.3 .
*/

-- Biggest improvement in rebound
SELECT 
	player_name,
    season,
    rebound_diff
FROM
	stat_diff
WHERE
	rebound_diff > 0
ORDER BY rebound_diff DESC
LIMIT 10;

/*  On reboud improvers, Julius Randle in 2015 improved on his previous rebound by 10.2.
	He was closely followed by Louis King, 
	Danny Fortson in 2000 improved his previous rebound by 9.6
	Jaylen Hoard in 2021 improved his rebound by 8.6.
*/

-- Biggest improvement in assist_per_game
SELECT 
	player_name,
    season,
    assist_diff
FROM
	stat_diff
WHERE
	assist_diff > 0
ORDER BY assist_diff DESC
LIMIT 10;

/* Skylar Mays in 2022 improved his assist by 7.7
   Derrick Walton Jr. in 2021 improved by 6
   Kendall Marshall in 2013 improved by 5.8
*/


/* 
Era & Team Comparisons
- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
- Identify which teams consistently produce top-performing players.
- Look at rookies vs veterans - how do their contributions differ?
*/

-- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
SELECT
	CONCAT(FLOOR(season / 10) * 10, "s") AS era,
	ROUND(AVG(player_height), 3) AS avg_height,
    ROUND(AVG(player_weight), 3) AS avg_weight
FROM
	all_seasons
GROUP BY 
	era;
/*
There has been a decline in the average height and weight of players from the 1990s to the 2020s.
The 2000s saw the highest averages in both weight and height.
The current crop of players (2020s) are the shortest and lightest when compared to the previous eras
*/

-- Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.
SELECT
	CONCAT(FLOOR(season / 10) * 10, "s") AS era,
	ROUND(AVG(points_per_game), 3) AS avg_pts,
    ROUND(AVG(rebound), 3) AS avg_rbd,
    ROUND(AVG(assist_per_game), 3) AS avg_ass,
    ROUND(AVG(offensive_rebound_pct), 3) AS avg_orbd,
    ROUND(AVG(defensive_rebound_pct), 3) AS avg_drbd,
    ROUND(AVG(net_rating), 3) AS avg_net_rating,
    ROUND(AVG(usage_pct), 3) AS avg_us_pct,
	ROUND(AVG(true_shooting_pct), 3) AS avg_ts_pct,
    ROUND(AVG(assist_pct), 3) AS avg_ass_pct    
FROM
	all_seasons
GROUP BY 
	era;
/*
Contrary to the decline in physique across the eras, performance indices such as avg points has increased
from an average of 7.83 in the 90s to 8.75 in the 2020s.
average assists per game has also increased from 1.787 in the 1990s to 1.97 in the 2020s
avg net_rating also saw an improvement of a low of -1.722 in the 2000s to -1.57 in the 2020s.
avg_us_pct has seen a steady decline from 0.188 in the 1990s to 0.178 in the 2020s.
avg_ts_pct has also_increased from 0.49 in 1990s steadily to 0.54 in the 2020s.
*/
-- Identify which teams consistently produce top-performing players.
-- Top performers will be the top 5 performers in a category accross the seasons
DROP VIEW IF EXISTS seasonal_performance_ranking;
CREATE VIEW  seasonal_performance_ranking AS(
	SELECT
		season,
		player_name,
        team_abbreviation AS team,
		points_per_game,
		rebound,
		assist_per_game,
		net_rating,
		offensive_rebound_pct,
		defensive_rebound_pct,
		usage_pct,
		true_shooting_pct,
		assist_pct,
		RANK() OVER (PARTITION BY season ORDER BY points_per_game DESC) AS pts_ranking,
		RANK() OVER (PARTITION BY season ORDER BY rebound DESC) AS reb_ranking,
		RANK() OVER (PARTITION BY season ORDER BY assist_per_game DESC) AS ass_ranking,
		RANK() OVER (PARTITION BY season ORDER BY net_rating DESC) AS net_rate_ranking,
        RANK() OVER (PARTITION BY season ORDER BY offensive_rebound_pct DESC) AS oreb_ranking,
        RANK() OVER (PARTITION BY season ORDER BY defensive_rebound_pct DESC) AS dreb_ranking,
        RANK() OVER (PARTITION BY season ORDER BY usage_pct DESC) AS us_pct_ranking,
        RANK() OVER (PARTITION BY season ORDER BY true_shooting_pct DESC) AS ts_pct_ranking,
        RANK() OVER (PARTITION BY season ORDER BY assist_pct DESC) AS ass_pct_ranking
	FROM 
		all_seasons
);

-- Checking the view
SELECT  
	*
FROM 
	seasonal_performance_ranking
LIMIT 5;
-- it works fine.

-- Which teams have been producing the top players with points_per_game_for each season
SELECT
	season,
	team,
    player_name,
    points_per_game,
    pts_ranking
FROM
	seasonal_performance_ranking
WHERE
	pts_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS num_pt_ranks
FROM
	seasonal_performance_ranking
WHERE 
	pts_ranking <= 5
GROUP BY 
	team
ORDER BY 
	num_pt_ranks DESC;

-- LAL has produced 21 top 5 performers over the years. They are followed PHI and OKC each having 12

-- Which teams have been producing the top players with rebound each season
SELECT
	season,
	team,
    player_name,
    rebound,
    reb_ranking
FROM
	seasonal_performance_ranking
WHERE
	reb_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(*) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	reb_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- DET (12) AND MIN (13) have both produced 5 top rebounders over the years

-- top playmakers
-- Which teams have been producing the top players with assist_per_game each season
SELECT
	season,
	team,
    player_name,
    assist_per_game,
    ass_ranking
FROM
	seasonal_performance_ranking
WHERE
	ass_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	ass_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
    
-- PHX is lonely at the top with  19 of player topping the assist per game across the years. Followed by WAS with 11

-- Which teams have been producing the net_rated players each season
SELECT
	season,
	team,
    player_name,
    net_rating,
    net_rate_ranking
FROM
	seasonal_performance_ranking
WHERE
	net_rate_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	net_rate_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
--  CHI and GSW leads 10 players over the seasons

-- Which teams have been producing the top offensive rebounder each season?
SELECT
	season,
	team,
    player_name,
    offensive_rebound_pct,
    oreb_ranking
FROM
	seasonal_performance_ranking
WHERE
	oreb_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	oreb_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- MEM, NYK AND DEN respectively have 10,9 and 8 players in the top 5 over the years

-- Which teams have been producing the top defensive rebounders each season
SELECT
	season,
	team,
    player_name,
    defensive_rebound_pct,
    dreb_ranking
FROM
	seasonal_performance_ranking
WHERE
	dreb_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	dreb_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- DEN, CLE, LAC AND DET leads with 10, 8, 7, 7 respectively

-- Which teams have been producing the top players with usg_pct each season
SELECT
	season,
	team,
    player_name,
    usage_pct,
    us_pct_ranking
FROM
	seasonal_performance_ranking
WHERE
	us_pct_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	us_pct_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- LAL (19) AND PHI (11) leads. LAL has produced almost twice as many (19) usg_pct performers than PHI(11)

-- Which teams have been producing the top players with ts_pct each season
SELECT
	season,
	team,
    player_name,
    true_shooting_pct,
    ts_pct_ranking
FROM
	seasonal_performance_ranking
WHERE
	ts_pct_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	ts_pct_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- BOS (9) and POR (7) has both produced top true_shooting_pct over the years

-- Which teams have been producing the top players with ass_pct each season
SELECT
	season,
	team,
    player_name,
    assist_pct,
    ass_pct_ranking
FROM
	seasonal_performance_ranking
WHERE
	ass_pct_ranking <= 5;
    
-- Grouped by teams
SELECT
	team,
    COUNT(team) AS numbers
FROM
	seasonal_performance_ranking
WHERE 
	ass_pct_ranking <= 5
GROUP BY 
	team
ORDER BY 
	numbers DESC;
-- UTA (11),  WAS, PHX, LAC have 10 players in the top 5 over the years

-- Look at rookies vs veterans - how do their contributions differ?
/*
In NBA terms:
A rookie is a player in their first season.
A veteran is any player with multiple seasons of experience.
*/

-- Find the debut season for each player
CREATE TEMPORARY TABLE debut_season AS
SELECT
	player_name,
    MIN(season) AS rookie_season
FROM
	all_seasons
GROUP BY
	player_name;
    
-- Flag the Rookie and veteran years
DROP TEMPORARY TABLE IF EXISTS experience_level_stat;
CREATE TEMPORARY TABLE experience_level_stat AS (
SELECT
	a_s.player_name,
    a_s.age,
    a_s.games_played,
    a_s.points_per_game,
    a_s.assist_per_game,
    a_s.rebound,
    a_s.net_rating,
    a_s.offensive_rebound_pct,
    a_s.defensive_rebound_pct,
    a_s.usage_pct,
    a_s.true_shooting_pct,
    a_s.assist_pct,
    a_s.season,
    CASE WHEN a_s.season = b_s.rookie_season THEN "Rookie" ELSE "Veteran" END AS experience_level
FROM
	all_seasons a_s
JOIN 
	debut_season b_s
    ON a_s.player_name = b_s.player_name
);

SELECT
	experience_level,
	ROUND(AVG(points_per_game), 3) AS avg_pts,
    ROUND(AVG(rebound), 3) AS avg_rebd,
    ROUND(AVG(assist_per_game), 3) as avg_ass,
    ROUND(AVG(net_rating), 3) as avg_net_rating,
    ROUND(AVG(offensive_rebound_pct), 3) as avg_oreb,
    ROUND(AVG(defensive_rebound_pct), 3) as avg_dreb,
    ROUND(AVG(usage_pct), 3) as avg_usg_pct,
    ROUND(AVG(true_shooting_pct), 3) as avg_ts_pct,
    ROUND(AVG(assist_pct), 3) as avg_ass_pct
FROM
	experience_level_stat
GROUP BY
	experience_level;
-- Veterans have better contributions in all levels than rookies

-- Check the experience levl by eras 1990, 20002, 20102 and 2020s
SELECT
    CONCAT(FLOOR(season / 10) * 10, "s") as era,
    experience_level,
	ROUND(AVG(points_per_game), 3) AS avg_pts,
    ROUND(AVG(rebound), 3) AS avg_rebd,
    ROUND(AVG(assist_per_game), 3) as avg_ass,
    ROUND(AVG(net_rating), 3) as avg_net_rating,
    ROUND(AVG(offensive_rebound_pct), 3) as avg_oreb,
    ROUND(AVG(defensive_rebound_pct), 3) as avg_dreb,
    ROUND(AVG(usage_pct), 3) as avg_usg_pct,
    ROUND(AVG(true_shooting_pct), 3) as avg_ts_pct,
    ROUND(AVG(assist_pct), 3) as avg_ass_pct
FROM
	experience_level_stat
GROUP BY
	era, experience_level;
-- When checked the contributions accross the various era, veterans have always outperformed rookies.
-- This is not surprising because veterans are more experienced than rookies


/*
MVP & Dream Team
- Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.

- Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.

- Bonus: Compare your MVP pick with the actual NBA MVP that season.
*/

-- Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.
DROP VIEW IF EXISTS MVP_seasonal_rankings;

CREATE VIEW MVP_seasonal_rankings AS (
	SELECT
		player_name,
		season,
		wt_performance,
		RANK() OVER (PARTITION BY season ORDER BY wt_performance DESC) AS MVP_ranK
	FROM (
		SELECT
			player_name,
			season,
			ROUND((0.4 * points_per_game) + 0.3 * (0.4 * rebound + 0.6 * assist_per_game) + (0.3 * true_shooting_pct), 2) AS wt_performance 
		FROM 
			all_seasons
	) AS MVP_rankings
);

-- The NBA MVP Hall of fame - 
SELECT
	season,
	player_name,
	wt_performance
FROM 
	MVP_seasonal_rankings
WHERE
	MVP_rank = 1;

-- View the official NBA MVP winners
SELECT
	*
FROM
	nba_official_mvps_1996_2022;
    
-- Compare MVPS from this analysis to the offical MVPs
SELECT
	msr.season,
	msr.player_name,
    omvp.Finals_MVP as official_MVP
FROM 
	MVP_seasonal_rankings AS msr
JOIN
	nba_official_mvps_1996_2022 AS omvp
    ON msr.season = omvp.season
WHERE
	msr.MVP_rank = 1;
-- the MVPs matached in 1996, Michael Jordan, Shaquille O'Neal in 1999 and LeBron James in 2011.
-- How many unique MVP winners do we have?
SELECT
	COUNT(DISTINCT player_name) AS unique_winners
FROM
	mvp_seasonal_rankings
WHERE
	MVP_rank = 1;
-- There are been 13 unique MVPs from 1996 to 2022

-- How many times has each of the 13 winners won?
SELECT
	player_name,
    COUNT(*) AS num_times_won
FROM
	mvp_seasonal_rankings
WHERE
	MVP_rank = 1
GROUP BY
	player_name
ORDER BY 
	num_times_won DESC;
    
-- LeBron James have won 4 MVPs and can be considered as the GOAT for the period under review.
