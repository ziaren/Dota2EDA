# Outcomes
- Continuous: total game length (in seconds)
- Categorical: Radiant win or lose

# Factors
- Categorical factors
  - `region`: Location of the game, each number corresponds to a different region.
  - `Strength_picked_r`: Whether Radiant selected any Strength heroes. 1 for True, 0 for False.
  - `Strength_picked_d`: Whether Dire selected any Strength heroes. 1 for True, 0 for False.
  - `Agility_picked_r`: Whether Radiant selected any Agility heroes. 1 for True, 0 for False.
  - `Agility_picked_d`: Whether Dire selected any Agility heroes. 1 for True, 0 for False.
  - `Intelligence_picked_r`: Whether Radiant selected any Intelligence heroes. 1 for True, 0 for False.
  - `Intelligence_picked_d`: Whether Dire selected any Intelligence heroes. 1 for True, 0 for False.
  - `Universal_picked_r`: Whether Radiant selected any Universal heroes. 1 for True, 0 for False.
  - `Universal_picked_d`: Whether Dire selected any Universal heroes. 1 for True, 0 for False.
- Continuous factors
  - `first_blood_time`: First blood time
  - `dire_score`: Dire final score
  - `radiant_score`: Radiant final score
  - `exp_15min`: Experience points gained by Raint at 15 min of the match
  - `teamfight_duration`: Total duration of the teamfights in a match
  - `Tteamfight_deaths`: Total number of deaths of Radiant in a match
  - `teamfight_frequency`: Total number of teamfights in a match
    
