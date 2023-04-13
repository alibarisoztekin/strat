% Tire degradation per lap (soft, medium, hard)
tire_degradation(soft, 2).
tire_degradation(medium, 1).
tire_degradation(hard, 0.5).

% Pit stop time
pit_stop_time(5).

% Lap time difference for tire compounds (base_time, soft_diff, medium_diff, hard_diff)
lap_time(90, -2, 0, 2).

% Calculate the lap time based on tire compound and current degradation
lap_time_with_degradation(Tire, Lap, Degradation, Time) :-
    lap_time(BaseTime, SoftDiff, MediumDiff, HardDiff),
    (
        (Tire = soft, Time is BaseTime + SoftDiff + Degradation * Lap);
        (Tire = medium, Time is BaseTime + MediumDiff + Degradation * Lap);
        (Tire = hard, Time is BaseTime + HardDiff + Degradation * Lap)
    ).

% Calculate the total race time
race_time(Tire1, Laps1, Tire2, Laps2, Time) :-
    tire_degradation(Tire1, Degradation1),
    tire_degradation(Tire2, Degradation2),
    pit_stop_time(PitStop),
    findall(LapTime1, (between(1, Laps1, Lap), lap_time_with_degradation(Tire1, Lap, Degradation1, LapTime1)), LapTimes1),
    findall(LapTime2, (between(1, Laps2, Lap), lap_time_with_degradation(Tire2, Lap, Degradation2, LapTime2)), LapTimes2),
    sum_list(LapTimes1, Time1),
    sum_list(LapTimes2, Time2),
    Time is Time1 + Time2 + PitStop.

% Optimize the race strategy
optimize_race_strategy(Tire1, Laps1, Tire2, Laps2, MinTime) :-
    setof(Time - (Tire1, Laps1, Tire2, Laps2), (
        between(1, 5, Laps1),
        Laps2 is 6 - Laps1,
        member(Tire1, [soft, medium, hard]),
        member(Tire2, [soft, medium, hard]),
        Tire1 \= Tire2,
        race_time(Tire1, Laps1, Tire2, Laps2, Time)
    ), Strategies),
    keysort(Strategies, SortedStrategies),
    SortedStrategies = [(MinTime - (Tire1, Laps1, Tire2, Laps2))|_].