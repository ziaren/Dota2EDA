# Dota 2 Match Data

This folder contains 2024 Dota 2 Pro League Matches data used for exploratory data analysis (EDA). 

## EDA questions:
1. What helps Radiant win.
   - `main_metadata$radiant_team_id`: some teams are better than others.
   - `main_metadata$radiant_score`: the common sense goes like, the more one kills, the more likely one wins.
   - Half way performance: predict game results based on half way data. Half-way adventage to what extent guarentees success.
     - `radiant_exp_adv$exp` when `minute == 15`: the half way performance in terms of the experience earned.
     - `radiant_gold_adv$exp` when `minute == 15`: the half way performance in terms of the wealth earned.
   - Collaboration: does high frequency or long period collaboration increase the likelihood of success.
     - count teamfights per match
     - cumulate teamfights length
  ...
2. What makes a game long. 
   - A correlation between certain heroes and the game length?
   - Number of teamfights vs game length?
   - region
  ... 

## Dota 2 intro:

Dota 2 is a free-to-play multiplayer online battle arena (MOBA) game. In Dota 2, two teams of five players each control powerful characters called heroes, each with unique abilities. The main objective is to destroy the enemy’s Ancient, a structure located deep within their base, while defending your own. In Dota 2, the Radiant is one of the two opposing factions on the game map—the other being the Dire. Games are played on a large map divided into three lanes, with players battling each other and computer-controlled units to gain gold and experience. Strategy, teamwork, and quick decision-making are key to winning.

## Source:

The data are sourced from [Kaggle](https://www.kaggle.com/datasets/bwandowando/dota-2-pro-league-matches-2023), which in turn uses [OpenDota's API](https://api.opendota.com/) as its primary source.

## Large data:

Please also download the following files from [Google Drive](https://drive.google.com/drive/folders/1EY2Mdo0SbFQVW-ZwG_I84EC_EmrUE51I?usp=share_link)

## Files:
- `main_metadata.csv`: Basic match metadata, including match ID, win/loss results, duration, etc.
- `picks_bans.csv`: Heros that were picked/banned in the matches.
- `teams.csv`: Teams involved in the matches, their IDs, names, etc.
- `teamfights.csv`: Team fights metadata, including start and end time, last death time, etc.
- `players.csv`: Player data, including account id, assists, etc.

## Explanation of factors:

### Categorical response:
- `main_metadata$radiant_win`: whether Radiant win or lose in a match. *True* means Radiant won, *False* means Radiant lost, *null* means a tie.
  
### Continuous response:
- `main_metadata$duration`: The total time of the match (in seconds). 

### Categorial factors:
- `main_metadata$radiant_team_id`: Each team has a unique id. Which team played Radiant (Stronger teams tend to win).
- `main_metadata$dire_team_id`: Each team has a unique id. Which team was against Radiant (Stronger opponents make Radiant more likely to lose). 
- `main_metadata$region`: Where the game took place. (Certain regions may have longer games)
- Heroes picked: Which heroes are involved in the match. Data processing required here. `picks_bans$is_picked == TRUE`, group by `picks_bans$match_id`
- Heroes banned: Which heroes are banned in the match. Data processing required here. `picks_bans$is_picked == FALSE`, group by `picks_bans$match_id`

### Continuous factors:
- `main_metadata$first_blood_time`: First Blood Time refers to the game time (in seconds) when the first kill of the match happens — that is, when one hero kills another for the first time in the game. Notice that in some observations, `main_metadata$first_blood_time == 0`. This is because in some rare cases, first kill happens during the preparation period, when the match was not officially started. We will probably filter out `main_metadata$first_blood_time == 0` data as 0 is not numeric here. 
- `main_metadata$radiant_score`: The total score of Radiant in a match. Each kill in the match +1 score. Note that a higher Radiant score compared to Dire score does not necessarily means Radiant won. For instance, in `main_metadata$match_id == 7517444274`, `main_metadata$radiant_score == 42`, `main_metadata$dire_score == 30`, yet `main_metadata$radiant_win == FALSE`. This is a comeback scenario where Dire was originally behind, but won finally.
- `main_metadata$dire_score`: The total score of Dire in a match. The score equals to the total deaths of Radiant. The common sense is that the more deaths, the lower likelihood of winning. 
- Numbers of team fights. Data processing is required here. Count the total observations for each match in `teamfights$match_id`.
- Total length of team fights. Data processing is required here. First group by `teamfights$match_id`, then `sum(end-start)`. The team fight data probe the question "whether collaboration increases the chance to win". For instance, if more and longer teamfights are correlated with higher winning probability, this enourages collboration vs. more independent oriented strategies.
- `radiant_exp_adv$exp` when `minute == 15`. People want to know whether Radiant will win BEFORE the game ends. The experience value at 15 mins shows how Radiant is performing at half way. It will be interesting to see whether halfway performance predict anything about the final result. Similarly, we can check half way gold:
- `radiant_gold_adv$exp` when `minute == 15`.

### TBD

There are four very interesting values: Throw, Loss, Comeback, Stomp. I'm trying to understand how the values are fixed. Let me know if you find any source. So far what I noticed is that in the case of Radiant won, there will be values for Throw and Loss; in the case of Radiant Loss, there will be values for Comeback and Stomp.
  





