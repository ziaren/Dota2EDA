library(dplyr)
library(tidyr)
library(tidyverse)
library(ggplot2)
library(plotly)
library(leaps)


#-- EDA
#-- QUANTITATIVE OUTCOMES
#-- QUALITATIVE OUTCOMES

(years <- seq(from=2016,to=2025,by=1))

# In my directory, I have folder for the various years so I point to the year 2024. from years variable above.
path_tofiles <- file.path("C:/Users/Jerry Bodman/Desktop/Homework files/Project", years[length(years)-1])
file_name<- c("main_metadata.csv","radiant_exp_adv.csv","teams.csv","teamfights.csv","players.csv","picks_bans.csv")

#df1  is for main_metadata.csv
df1 <- read.csv(str_c(path_tofiles,file_name[1],sep = "/"))
nrow(df1)
#View(df1)

#df2 is for radiant_exp_adv.csv
df2 <- read.csv(str_c(path_tofiles,file_name[2],sep = "/"))
nrow(df2)
head(df2)

#df3 is for teams.csv
df3 <- read.csv(str_c(path_tofiles,file_name[3],sep = "/"))
nrow(df3)
head(df3)

#df4 is for teamfights.csv
df4 <- read.csv(str_c(path_tofiles,file_name[4],sep = "/"))
nrow(df4)
head(df4)

#df5 is for players.csv
df5 <- read.csv(str_c(path_tofiles,file_name[5],sep = "/"))
nrow(df5)
head(df5)

#df6 is for picks_bans.csv
df6 <- read.csv(str_c(path_tofiles,file_name[6],sep = "/"))
nrow(df6)
head(df6)


#checking distinct match and league ids not necessary-- Done whilst studying the data to extract useful details
#nrow(df6)
#n_distinct(df6$match_id)
#n_distinct(df1$leagueid)


#side notes ::: df1 has 30012 records with 30012 distinct match ids... same for df3
## df2 has 1001055 records with 29971 unique match ids -- requires studying the data and picking a good statistic to represent varibles
## df3 has 30012 records with 30012 unique ids -- would not require much thinking to extract useful info
## df4 has 214459 records with 29745 distinct match ids -- means studying and picking a good statistic
## df5 has 299595 records with 30012 distinct ids as well -- studying and picking best statistic
## df6 has 710387records with 29707 unique matchids -- same as above



# -- cleaning and extraction process    NOTE:: matchid is common to all
# -- match_id & leagueid combo gives rise to a composite key for selecting some important details..
# -- df1 -- main_metadata.csv   | -- radiant_teamid, dire_teamid, region, first_blood_time, radiant_score, dire_score, radiant_win
# -- df2 -- radiant_exp_adv.csv | -- exp
# -- df3 -- teams.csv           | -- 
# -- df4 -- teamfights.csv      | -- start, end +(match & league ids) , death , last_death_time
# -- df5 -- players.csv         | --
# -- df6 -- picks_bans.csv      | -- is_picked + (match & league ids)


# selecting the important columns in df1 main data::
colnames(df1)
df1_vars <- df1 %>%
  drop_na() %>%
  filter(first_blood_time != 0) %>%
  select(match_id, leagueid, region, duration, first_blood_time, dire_score, radiant_score,
         radiant_team_id, dire_team_id, radiant_win)

head(df1_vars)
nrow(df1_vars)

# Here,we group by match_id and leagueid and extract experience.. vars -- mean extracted variables
df2_vars <- df2 %>%
  drop_na() %>%
  filter(minute=="15") %>%
  select(match_id,leagueid,exp_15min = exp)

head(df2_vars)
nrow(df2_vars)

#joining selected variables from df1 and df2
df12_vars <- inner_join(df1_vars, df2_vars, by = c("match_id","leagueid"))


#perform summary for df4 on the deaths and last deaths:: here's what happens -- for a specific match in a specific league, a team might fight a number of times 
#and so we find the total duration used by the team for the fight by sum(end-start) for the match and league as well as the sum(deaths) - the number of deaths recorded.
df4_vars <- df4 %>%
  drop_na() %>%
  group_by(match_id, leagueid) %>%
  summarise(
    teamfight_duration = sum(end - start, na.rm = TRUE),
    teamfight_frequency = n(),
    Tteamfight_deaths = sum(deaths),
    .groups = "drop"
  ) %>%
  select(match_id,leagueid,teamfight_duration,Tteamfight_deaths, teamfight_frequency)

head(df4_vars)
nrow(df4_vars)

# joining selected variables from df1,df2 and df4
df124_vars <- inner_join(df12_vars, df4_vars, by = c("match_id","leagueid"))


head(df6)
df6_ext1 <- df6 %>%
drop_na() %>%
  mutate(
    radiant_pick = ifelse(is_pick == "True" & team == "1", hero_id, NA),
    radiant_ban  = ifelse(is_pick == "False" & team == "1", hero_id, NA),
    dire_pick    = ifelse(is_pick == "True" & team == "0", hero_id, NA),
    dire_ban     = ifelse(is_pick == "False" & team == "0", hero_id, NA)
  )


df6_vars <- df6_ext1 %>%
  group_by(match_id, leagueid) %>%
  summarise(
    radiant_pick = paste(na.omit(radiant_pick), collapse = ","),
    radiant_ban  = paste(na.omit(radiant_ban), collapse = ","),
    dire_pick    = paste(na.omit(dire_pick), collapse = ","),
    dire_ban     = paste(na.omit(dire_ban), collapse = ","),
    .groups = "drop"
  ) %>%
  select(match_id, leagueid, radiant_pick, radiant_ban, dire_pick, dire_ban)

# joining selected variables from df1,df2,df4 and df6
df1246_vars <- inner_join(df124_vars, df6_vars, by = c("match_id","leagueid"))
nrow(df1246_vars)
View(df1246_vars)

## final data:: some things can be dropped 
write.csv(df1246_vars,"C:/Users/Jerry Bodman/Desktop/Homework files/final_selected_data.csv",row.names = FALSE)

