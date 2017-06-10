%%%-------------------------------------------------------------------
%%% @author Piotr
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. kwi 2017 10:57
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("Piotr").

-include_lib("eunit/include/eunit.hrl").

simple_test() ->
  ?assert(true).


%% testy tylko dla 2 funkcji i siebie
%% goo.gl/kxShFQ

addStation_test()->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("MojaStacja",{20,10},P),
  P2 = pollution:addStation("MojaStacja",{20,10},P1),
  P3 = pollution:addStation("MojaStacja2",{20,10},P1),
  P4 = pollution:addStation("MojaStacja",{22,11},P1),
  {A,_} = P2,
  {B,_} = P3,
  {C,_} = P4,
  ?assertEqual(error,A),
  ?assertEqual(error,B),
  ?assertEqual(error,C).

addValue_doublyAddedByName_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Station 1", {10, 10}, P),
  P2 = pollution:addValue("Station 1", {{2017,5,4},{20,52,0}}, "PM10", 100.0, P1),
  {A,_} = pollution:addValue("Station 1", {{2017,5,4},{20,52,0}}, "PM10", 100.0, P2),
  ?assertEqual(error, A).

getOneValue_test() ->
  P = pollution:createMonitor(),
  P2 = pollution:addStation("Station 1", {52, 32}, P),
  P3 = pollution:addStation("Station 2", {55, 32}, P2),
  P4 = pollution:addValue("Station 1", {{2017,5,4},{21,22,39}}, "PM2", 10.0, P3),
  ?assertEqual(10.0, pollution:getOneValue("Station 1", {{2017,5,4},{21,22,39}}, "PM2", P4)),
  {A,_} = pollution:getOneValue("Station 2", {{2017,5,4},{21,22,39}}, "PM2", P4),
  ?assertEqual(error, A).

removeValue_removesExistingValueDiffDates_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation("Station1", {1, 2}, M1),
  M3 = pollution:addStation("Station2", {2, 3}, M2),
  M4 = pollution:addValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M3),
  M5 = pollution:addValue("Station1", {{2017, 04, 11},{19, 0, 0}}, "PM10", 6, M4),
  M6 = pollution:removeValue("Station1", {{2017, 04, 11},{19, 0, 0}}, "PM10", M5),
  ?assertEqual(M4, M6).

removeValue_removesExistingValueDiffTypes_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation("Station1", {1, 2}, M1),
  M3 = pollution:addStation("Station2", {2, 3}, M2),
  M4 = pollution:addValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M3),
  M5 = pollution:addValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM25", 6, M4),
  M6 = pollution:removeValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM25", M5),
  ?assertEqual(M4, M6).

removeValue_removesExistingValueDiffStations_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation("Station1", {1, 2}, M1),
  M3 = pollution:addStation("Station2", {2, 3}, M2),
  M4 = pollution:addValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M3),
  M5 = pollution:addValue("Station2", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M4),
  M6 = pollution:removeValue({2,3}, {{2017, 04, 11},{20, 0, 0}}, "PM10", M5),
  ?assertEqual(M4, M6).

removeValue_doesNotRemoveNotExistingValue_test() ->
  M1 = pollution:createMonitor(),
  M2 = pollution:addStation("Station1", {1, 2}, M1),
  M3 = pollution:addStation("Station2", {2, 3}, M2),
  M4 = pollution:addValue("Station1", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M3),
  M5 = pollution:addValue("Station2", {{2017, 04, 11},{20, 0, 0}}, "PM10", 6, M4),
  M6 = pollution:removeValue("Station1", {{2017, 04, 11},{19, 0, 0}}, "PM10", M5),
  ?assertEqual(M5, M6).

getStationMean_test() ->
  Date1 = {{2017, 5, 1}, {0, 0, 0}},
  Date2 = {{2017, 5, 1}, {8, 0, 0}},
  Date3 = {{2017, 5, 2}, {16, 0, 0}},
  Date4 = {{2017, 5, 3}, {16, 0, 0}},
  Monitor = pollution:createMonitor(),
  Monitor1 = pollution:addStation("Tadeusza Makowskiego 6", {1.0, 1.0}, Monitor),
  Monitor2 = pollution:addStation("Porucznika Halszki 15", {2.0, 2.0}, Monitor1),
  Monitor3 = pollution:addStation("Dietla 84", {3.0, 3.0}, Monitor2),
  Monitor4 = pollution:addValue("Tadeusza Makowskiego 6", Date1, "pm10", 100, Monitor3),
  Monitor5 = pollution:addValue("Tadeusza Makowskiego 6", Date2, "pm10", 200, Monitor4),
  Monitor6 = pollution:addValue("Tadeusza Makowskiego 6", Date3, "pm10", 300, Monitor5),
  Monitor7 = pollution:addValue("Tadeusza Makowskiego 6", Date3, "pm2.5", 300, Monitor6),
  Monitor8 = pollution:addValue("Porucznika Halszki 15", Date3, "pm2.5", 60, Monitor7),
  Monitor9 = pollution:addValue("Tadeusza Makowskiego 6", Date4, "pm10", -600, Monitor8),
  Monitor10 = pollution:addValue("Porucznika Halszki 15", Date3, "temp", -60, Monitor9),
  {A,_} = pollution:getStationMean("Porucznika Halszki 15","pm2.5", Monitor3),
  ?assertEqual(error, A),
  {B,_} = pollution:getStationMean("Tadeusza Makowskiego 6","pm2.5", Monitor3),
  ?assertEqual(error, B),
  {C,_} = pollution:getStationMean("Tadeusza Makowskiego 6","temp", Monitor3),
  ?assertEqual(error, C),
  {D,_} = pollution:getStationMean("Tadeusza Makowskiego 6","temp", Monitor3),
  ?assertEqual(error, D),
  ?assertEqual(100.0, pollution:getStationMean("Tadeusza Makowskiego 6","pm10", Monitor4)),
  ?assertEqual(200.0,pollution:getStationMean("Tadeusza Makowskiego 6","pm10", Monitor8)),
  ?assertEqual(0.0,pollution:getStationMean("Tadeusza Makowskiego 6","pm10", Monitor9)),
  ?assertEqual(-60.0,pollution:getStationMean("Porucznika Halszki 15","temp", Monitor10)).

getDailyMean_1_test() ->
  M = pollution:createMonitor(),
  M1 = pollution:addStation("Station_1", {10, 20}, M),
  M2 = pollution:addStation("Station_2", {50, 20}, M1),
  M3 = pollution:addValue("Station_2", {{2017, 5, 5}, {10, 4, 30}}, temp, 20, M2),
  M4 = pollution:addValue("Station_2", {{2017, 5, 10}, {11, 4, 17}}, temp, 30, M3),
  M5 = pollution:addValue("Station_1", {{2017, 5, 5}, {12, 10, 31}}, temp, 15, M4),
  M6 = pollution:addValue("Station_1", {{2017, 5, 10}, {13, 14, 36}}, temp, 10, M5),

  M7 = pollution:addValue("Station_1", {{2017, 5, 5}, {10, 17, 16}}, pm10, 125, M6),
  M8 = pollution:addValue("Station_1", {{2017, 5, 10}, {17, 44, 32}}, pm10, 100, M7),
  M9 = pollution:addValue("Station_2", {{2017, 5, 10}, {15, 14, 56}}, pm10, 90, M8),
  M10 = pollution:addValue("Station_2", {{2017, 5, 5}, {9, 19, 26}}, pm10, 108, M9),

  Avg_1 = pollution:getDailyMean({2017, 5, 5}, temp, M10),
  Avg_2 = pollution:getDailyMean({2017, 5, 10}, temp, M10),
  Avg_3 = pollution:getDailyMean({2017, 5, 5}, pm10, M10),
  Avg_4 = pollution:getDailyMean({2017, 5, 10}, pm10, M10),

  ?assertEqual(Avg_1, 17.5),
  ?assertEqual(Avg_2, 20.0),
  ?assertEqual(Avg_3, 116.5),
  ?assertEqual(Avg_4, 95.0).

getDailyMean_2_test() ->
  M = pollution:createMonitor(),
  M1 = pollution:addStation("Station_1", {10, 20}, M),
  M2 = pollution:addStation("Station_2", {50, 20}, M1),
  M3 = pollution:addValue({50, 20}, {{2017, 5, 5}, {10, 4, 30}}, temp, 20, M2),
  M4 = pollution:addValue({50, 20}, {{2017, 5, 10}, {11, 4, 17}}, temp, 30, M3),
  M5 = pollution:addValue({10, 20}, {{2017, 5, 5}, {12, 10, 31}}, temp, 15, M4),
  M6 = pollution:addValue({10, 20}, {{2017, 5, 10}, {13, 14, 36}}, temp, 10, M5),

  M7 = pollution:addValue({10, 20}, {{2017, 5, 5}, {10, 17, 16}}, pm10, 125, M6),
  M8 = pollution:addValue({10, 20}, {{2017, 5, 10}, {17, 44, 32}}, pm10, 100, M7),
  M9 = pollution:addValue({50, 20}, {{2017, 5, 10}, {15, 14, 56}}, pm10, 90, M8),
  M10 = pollution:addValue({50, 20}, {{2017, 5, 5}, {9, 19, 26}}, pm10, 108, M9),

  Avg_1 = pollution:getDailyMean({2017, 5, 5}, temp, M10),
  Avg_2 = pollution:getDailyMean({2017, 5, 10}, temp, M10),
  Avg_3 = pollution:getDailyMean({2017, 5, 5}, pm10, M10),
  Avg_4 = pollution:getDailyMean({2017, 5, 10}, pm10, M10),

  ?assertEqual(Avg_1, 17.5),
  ?assertEqual(Avg_2, 20.0),
  ?assertEqual(Avg_3, 116.5),
  ?assertEqual(Avg_4, 95.0).



getMaximumGradientStations_test()->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("MojaStacja",{20,10},P),
  P2 = pollution:addStation("MojaStacja1",{30,10},P1),
  P3 = pollution:addValue("MojaStacja",calendar:local_time(),"PM10",0,P2),
  P4 = pollution:addValue("MojaStacja1",calendar:local_time(),"PM10",10,P3),
  {AStation,BStation,Value} = pollution:getMaximumGradientStations(calendar:local_time(),"PM10",P4),
  ?assertEqual(1.0,Value),
  ?assert({20,10} =:= AStation andalso {30,10} =:= BStation  orelse ({30,10} =:= AStation andalso {20,10} =:= BStation)),
  ?assertEqual({error,"empty"},pollution:getMaximumGradientStations(calendar:local_time(),"PM1",P4)),
  ?assertEqual({error,"empty"},pollution:getMaximumGradientStations(calendar:local_time(),"PM1",P1)),
  P5 = pollution:addStation("MojaStacja2",{36,18},P4),
  P6 = pollution:addValue("MojaStacja2",calendar:local_time(),"PM10",210,P5),
  {AStation1,BStation1,Value1} = pollution:getMaximumGradientStations(calendar:local_time(),"PM10",P6),
  ?assertEqual(20.0,Value1),
  ?assert({30,10} =:= AStation1 andalso {36,18} =:= BStation1  orelse ({36,18} =:= AStation1 andalso {30,10} =:= BStation1)).