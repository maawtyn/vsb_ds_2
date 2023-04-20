create or replace trigger T_Update_Skater_Stats before update of goals on Game_Skater_Stats for each row
declare
    v_team_id Game_Skater_Stats.team_id%TYPE;
    v_game_id Game_Skater_Stats.game_id%TYPE;
    v_old_goals Game_Skater_Stats.goals%TYPE;
    v_new_goals Game_Skater_Stats.goals%TYPE;
    v_goals_diff NUMBER;

    v_home_team_id Game.home_team_id%TYPE;
    v_away_team_id Game.away_team_id%TYPE;
    v_home_goals Game.home_goals%TYPE;
    v_away_goals Game.away_goals%TYPE;
begin
    v_old_goals := :old.goals;
    v_new_goals := :new.goals;
    v_team_id := :new.team_id;
    v_game_id := :new.game_id;

    select home_team_id, away_team_id, home_goals, away_goals
    into v_home_team_id, v_away_team_id, v_home_goals, v_away_goals
    from game
    where game_id = v_game_id;

    if v_home_team_id = v_team_id then
        v_goals_diff := v_new_goals - v_old_goals;
        update Game set home_goals = home_goals + v_goals_diff
                    where game_id = v_game_id;
    elsif v_away_team_id = v_team_id then
        v_goals_diff := v_new_goals - v_old_goals;
        update Game set away_goals = away_goals + v_goals_diff
                    where game_id = v_game_id;
    end if;

end;
