# NBA Player Analysis (1996–2022)

-------------

## 🏀 Project Overview  
Basketball debates often hinge on subjective opinions, especially when it comes to the GOAT conversation. This project brings data to the forefront. Using MySQL, I analyzed over 12,000 player-season records spanning 27 NBA seasons (1996 - 2022) to uncover performance trends, compare eras, and identify statistically driven MVPs. A fully commented SQL file is included for reproducibility.

-------------

## 🎯 Objectives  
1. Identify season leaders in scoring, rebounding, and playmaking and evaluate their efficiency.  
2. Compare player size, style, and performance across four eras: 1990s, 2000s, 2010s, and 2020s.  
3. Determine which teams, positions, or player profiles consistently produce top performers.  
4. Use a weighted performance index to crown MVPs and compare them to official NBA selections.

-------------

## 🧠 Skills Demonstrated  
- Data inspection and cleaning  
- SQL DQL and DML proficiency  
- Window functions (`RANK`, `LAG`, `PARTITION BY`)  
- CTEs and subqueries  
- Joins and aggregations  
- `CASE` statements for categorization  
- Views and temporary tables for modular analysis  
- Robust outlier handling 

-------------

## ⚙️ Methodology  

### 📥 Data Loading  
The dataset contained 12,844 player-season records across 27 seasons. I created a schema-aligned table and imported the data via MySQL Workbench.

### 🧹 Data Cleaning  
- Draft-related columns (`draft_year`, `draft_round`, `draft_number`) were cast to integers, with `"Undrafted"` entries set to `NULL`.  
- Season formats (e.g., `"1996-97"`) were standardized to starting year integers.  
- Outliers in `net_rating` and `true_shooting_pct` were replaced with player-specific averages from unaffected seasons, preserving data integrity.
- Duplicates were checked and none was found.

### 🔍 Exploratory Analysis  
Initial EDA included counts of unique teams, players, colleges, and countries, as well as range checks on numeric columns. This stage confirmed data quality and revealed key outliers.

Key facts from the data

> 2551 unique players out of which 84% hail from USA. There are other 81 different nationalities represented in the NBA. This is not surprising because basketball as a sport was invented in  1891 in the USA and besides, the NBA is played in USA.
It was also revealed that there are 36 unique teams, 353 unique colleges producing players for the NBA.

The main objectives were fulfiled by carrying out the analysis below:

**Player Performance Analysis**

    - Rank players in each season by points, rebounds, assists per game.

    - Compare efficiency stats (TS% vs usage%) - do volume scorers sacrifice efficiency?

    - Identify most improved players across seasons (biggest jump in points/rebounds/assists).

***Era & Team Comparisons**

    - Compare average player size (height/weight) between 1990s, 2000s, 2010s, and 2020s.

    - Identify which teams consistently produce top-performing players.

    - Look at rookies vs veterans - how do their contributions differ?

**MVP & Dream Team**

    - Use a weighted index (e.g., 40% points, 30% rebounds/assists, 30% efficiency) to find an MVP for a given season.

    - Build your dream starting 5 (PG, SG, SF, PF, C) using stats across all seasons.

    - Bonus: Compare your MVP pick with the actual NBA MVP that season.

-------------

## 📊 Key Findings  

### 1. Player Performance Trends  
- **Efficiency vs Volume**: Weak correlation between usage rate and true shooting percentage suggests volume scorers don’t necessarily sacrifice efficiency. Most players fall within 0.1–0.3 USG% and 0.4–0.6 TS%.  
- **Most Improved Players**:  
  - **Scoring**: MarShon Brooks (2017, +15.6 points_per_game), Louis King (2022, +15.5 points_pergame), JaKarr Sampson (2018, +15.3 points_per_game)  
  - **Rebounding**: Julius Randle (2015, +10.2 rebounds), Danny Fortson (2000, +9.6 rebounds), Jaylen Hoard (2021, +8.6 rebounds)  
  - **Playmaking**: Skylar Mays (2022, +7.7 assists_per_game), Derrick Walton Jr. (2021, +6.0 assists_per_game), Kendall Marshall (2013, +5.8 assists_per_game)

### 2. Era & Team Comparisons  
- **Size Evolution**:  
  - Average height and weight peaked in the 2000s (201.0 cm, 101.4 kg) and declined gradually to (198.9 cm, 97.8 kg) in the 2020s.  
- **Performance Evolution**:  
  - Despite smaller physiques, players in the 2020s outperformed earlier eras in scoring (8.75 PPG vs 7.83 in the 1990s), assists (1.97 APG vs 1.78), and efficiency (TS% rose from 0.49 to 0.54).  
  - This shift suggests a league-wide emphasis on skill-based metrics over raw size.

- **Team Contributions to top-5 scorers over the seasons**:  
  - **Scoring Leaders:**
    - Los Angeles Lakers (LAL): 21 top-5 scorers  
    - Philadelphia 76ers (PHI): 12  
    - Oklahoma City Thunder (OKC): 12  
  - **Rebounding Leaders:**
    - Minnesota Timberwolves (MIN): 13  
    - Detroit Pistons (DET): 12  
  - **Assist Leaders:**  
    - Phoenix Suns (PHX): 19  
    - Washington Wizards (WAS): 11  
  - **Usage Rate Leaders:**  
    - Los Angeles Lakers (LAL): 19  
    - Philadelphia 76ers (PHI): 11  
  - **Efficiency Leaders (TS%):**  
    - Boston Celtics (BOS): 9  
    - Portland Trail Blazers (POR): 7

- **Rookies vs Veterans**:  
  Veterans consistently outperform rookies across all eras, reflecting the value of experience and system familiarity.

### 3. MVP & Dream Team Selection  
- **MVP Index Formula**:  
  ```sql
  ROUND((0.4 * points_per_game) + 0.3 * (0.4 * rebound + 0.6 * assist_per_game) + (0.3 * true_shooting_pct), 2)
```

- Top MVPs (1996–2023):
    - Per the analysis, there has been 13 different MVPs from 1996 to 2022.

	- LeBron James (4 MVPs) led the pack with Shaquille O’Neal, Allen Iverson, and James Harden having 3 MVPs each.

**Official vs Analytical MVPs:**

Comparing the MVPs derived from the analysis to the official MVPs showed that matches only occurred in 1996 (Michael Jordan), 1999 (Shaquille O’Neal), and 2011 (LeBron James).

These discrepancies highlight the influence of narrative, team success, and voter sentiment in official MVP selections. These factors were not taken into account in this analysis. This analysis only focused on player performance.

----------------

## 🏁 Conclusion

The analysis further reveals a compelling evolution in NBA player profiles and performance. While the average player has become shorter and lighter over time, efficiency and output have steadily improved underscoring the league’s shift toward skill and performance. Meanwhile, veterans outperform rookies emphasing the impacr of experience and longevity on performance. Teams like the Los Angeles Lakers, Phoenix Suns, and Philadelphia 76ers have consistently developed elite talent. The MVP model offers a data-driven lens on player impact. The results were often different from official selections due to intangible factors like narratives,team success, leadership and storyline. Ultimately, the numbers tell a rich story but they’re only part of the game.

------------------

## 🔍 Further Analysis Opportunities

This project opens several avenues for deeper exploration and advanced analytics within the NBA dataset.
Future analyses could include the following:

🧠 **Player Performance**

- Track efficiency trends across players’ careers to identify peak and decline periods.

- Evaluate two-way impact by combining offensive and defensive contributions.


📈 **Era and Style Evolution**

- Examine how positional roles (PG–C) have evolved across decades.

- Build player similarity indexes to find modern equivalents of past legends.

- Investigate international player growth and their impact on the league.

🧮 **Team-Level Insights**

- Identify teams that develop players who show consistent statistical improvement.

- Cluster teams based on offensive vs defensive profiles across seasons.

🔮 **Predictive Modeling**

- Develop a data-driven MVP prediction model using performance and team success factors.

- Build player similarity indexes to find modern equivalents of past legends.

- Predict career longevity using early-career performance and efficiency indicators.

📊 **Visualization and Reporting**

- Create radar charts comparing all-time greats across key metrics.

- Generate heatmaps of player origins (countries, colleges).

-------------

📬 Contact
If you'd like to connect, collaborate, or discuss this project further:

📧 Email: mathiasofosu2@gmail.com

💼 LinkedIn: [Mathias Ofosu](https://linkedin.com/in/mathias-ofosu)

🧠 GitHub Profile: [Mathias Ofosu](https://github.com/MKOfosu)

 Twitter/X: [Mathias Ofosu](https://x.com/MKOfosu)

Feel free to reach out. I’m always open to data-driven conversations.