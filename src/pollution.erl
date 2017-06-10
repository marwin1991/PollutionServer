%%%-------------------------------------------------------------------
%%% @author Piotr
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. kwi 2017 15:45
%%%-------------------------------------------------------------------
-module(pollution).
-author("Piotr").

%% date and time {{2017,4,20},{18,59,30}} - > {{year,month,day},{hour,minutes,seconds}}
%% geographical coordinates  {50.2345, 18.3445}
%% {"Aleje Slowackiego", {50.2345, 18.3445}}
%% date, pollution type and value {{{2017,4,20},{18,59,30}}, "PM10", 20}
%% {{"Aleje Slowackiego", {50.2345, 18.3445}},[]}
%% #{"Aleje Slowackiego" => {{50.2345,18.3445}, #{"PM10" => [{{{2017,4,20},{18,59,30}}, 20}]   }}}

%% ====================================================================
%% API functions
%% ====================================================================

%% Name == StationName
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3,
  getStationDailyMean/4, getDailyMean/3, getMaximumGradientStations/3, createTestMonitor/0]).

createMonitor() -> #{}.

createTestMonitor() -> #{
  "S1" =>
  {{3,3},
    #{"PM1" =>
      [
        {{{2017,4,20},{18,59,30}}, 20},
        {{{2017,4,20},{19,59,30}},  5},
        {{{2017,4,21},{20,59,30}}, 18},
        {{{2017,4,21},{16,59,30}},  5},
        {{{2017,4,21},{18,59,30}}, 13}
      ]
    }
  },
  "S2" =>
  {{5,7},
   #{"PM1" =>
      [
        {{{2017,4,20},{18,59,30}}, 25},
        {{{2017,4,20},{19,59,30}},  3},
        {{{2017,4,21},{20,59,30}}, 17},
        {{{2017,4,21},{16,59,30}},  8},
        {{{2017,4,21},{18,59,30}}, 11}
      ]
     }
  },
  "S3" =>
  {{1,7},
    #{"PM1" =>
       [
          {{{2017,4,20},{18,59,30}}, 32},
          {{{2017,4,20},{19,59,30}}, 15},
          {{{2017,4,21},{20,59,30}}, 24},
          {{{2017,4,21},{16,59,30}}, 18},
          {{{2017,4,21},{18,59,30}}, 17}
       ]
     }
  }
}.

addStation(Name,{X,Y},Poll_monitor) when is_map(Poll_monitor) ->
  case maps:is_key(Name, Poll_monitor) or containsStationWithCoords({X,Y},Poll_monitor) of
    true -> {error,"There is already such a station!"};
    false -> Poll_monitor#{Name => {{X,Y},#{}}}
  end.

addValue({X,Y},{{A,B,C},{D,E,F}},Type, Value, Poll_monitor) ->
  addValue(coordsToName({X,Y},Poll_monitor),{{A,B,C},{D,E,F}},Type, Value, Poll_monitor);
addValue(Name,{{A,B,C},{D,E,F}},Type, Value, Poll_monitor) when is_map(Poll_monitor)->
  case maps:is_key(Name, Poll_monitor) of
    true -> case containsMeasurement(Name,{{A,B,C},{D,E,F}},Type, Value, Poll_monitor) of
              true -> {error,"There is such a mesermunet on this date, value and type!"};
              false -> {Coords,Types_map} = maps:get(Name, Poll_monitor, #{}),
                case maps:is_key(Type, Types_map) of
                  true -> Poll_monitor#{Name => {Coords, Types_map#{ Type => maps:get(Type, Types_map) ++ [{{{A,B,C},{D,E,F}}, Value}]}}};
                  false -> Poll_monitor#{Name => {Coords, Types_map#{ Type => [{{{A,B,C},{D,E,F}}, Value}]}}}
                end
            end;
    false -> {error,"There is no such a station!"}
  end.

removeValue({X,Y},{{A,B,C},{D,E,F}},Type, Poll_monitor) ->
  removeValue(coordsToName({X,Y},Poll_monitor),{{A,B,C},{D,E,F}},Type, Poll_monitor);
removeValue(Name,{{A,B,C},{D,E,F}},Type, Poll_monitor) when is_map(Poll_monitor) ->
  case maps:is_key(Name, Poll_monitor) of
    true ->
      {Coords,Types_map} = maps:get(Name, Poll_monitor, #{}),
      case maps:is_key(Type, Types_map) of
        true -> M =[{{{A1,B1,C1},{D1,E1,F1}}, V} || {{{A1,B1,C1},{D1,E1,F1}}, V}<-maps:get(Type, Types_map),
          {{A1,B1,C1},{D1,E1,F1}} /= {{A,B,C},{D,E,F}} ],
          case length(M) of
            0 -> Poll_monitor#{Name => {Coords, maps:remove(Type,Types_map)}};
            _ -> Poll_monitor#{Name => {Coords, Types_map#{ Type => M}}}
          end;
        false -> {error,"There is no such a mesermunet with this type!"}
      end;
      false -> {error,"There is no such a station!"}
end.


getOneValue({X,Y},{{A,B,C},{D,E,F}},Type, Poll_monitor) ->
  getOneValue(coordsToName({X,Y},Poll_monitor),{{A,B,C},{D,E,F}},Type, Poll_monitor);
getOneValue(Name,{{A,B,C},{D,E,F}},Type, Poll_monitor) when is_map(Poll_monitor) ->
  case maps:is_key(Name, Poll_monitor) of
    true ->
      {_,Types_map} = maps:get(Name, Poll_monitor, #{}),
      case maps:is_key(Type, Types_map) of
        true -> listToElem([ V || {{{A1,B1,C1},{D1,E1,F1}}, V}<-maps:get(Type, Types_map),
          {{A1,B1,C1},{D1,E1,F1}} == {{A,B,C},{D,E,F}} ]);
        false -> {error,"There is no such a Type"}
      end;
    false -> {error,"There is no such a station"}
  end.

getStationMean({X,Y}, Type, Poll_monitor) ->
  getStationMean(coordsToName({X,Y},Poll_monitor), Type, Poll_monitor);
getStationMean(Name, Type, Poll_monitor) when is_map(Poll_monitor) ->
  case maps:is_key(Name, Poll_monitor) of
    true ->
      {_,Types_map} = maps:get(Name, Poll_monitor, #{}),
      case maps:is_key(Type, Types_map) of
        true ->
          ListOfValues = [ V || {_, V}<-maps:get(Type, Types_map)],
          case length(ListOfValues) > 0 of
            true -> lists:foldl(fun (X, Y) -> X + Y end,0,ListOfValues) / length(ListOfValues);
            false -> {error,"There is no values"}
          end;
        false -> {error,"There is no such a Type"}
      end;
    false -> {error,"There is no such a station"}
  end.

getDailyMean({A,B,C}, Type, Poll_monitor) ->
  getDailyMean({{A,B,C},{0,0,0}}, Type, Poll_monitor);
getDailyMean({{A,B,C},Time},Type, Poll_monitor) when is_map(Poll_monitor) ->
  List = [ getStationDailyMean({X,Y},{{A,B,C},Time}, Type, Poll_monitor) || {X,Y} <- stationsCoords(Poll_monitor)],
  ListOfValues = [ Val || Val <- List, Val >= 0],
  case length(ListOfValues) > 0 of
    true -> lists:foldl(fun (X, Y) -> X + Y end,0,ListOfValues) / length(ListOfValues);
    false -> nothig
  end.

%% 53. Dodaj do modułu pollution funkcję getMaximumGradientStations, która wyszuka parę stacji,
%% na których wystapił największy gradient zanieczyszczen w kontekście odległości.
getMaximumGradientStations({A,B,C}, Type, Poll_monitor) ->
  getMaximumGradientStations({{A,B,C},{0,0,0}}, Type, Poll_monitor);
getMaximumGradientStations({{A,B,C},Time},Type, Poll_monitor) ->
  List = [ {{X,Y},getStationDailyMean({X,Y},{{A,B,C},Time}, Type, Poll_monitor)} || {X,Y} <- stationsCoords(Poll_monitor)],
  ListOfValues = [ {Coords,Val} || {Coords,Val} <- List, Val /= -1],
  ListOfGradients = [ {{X1,Y1},{X2,Y2}, abs( (Val1 - Val2) / (getDistant({X1,Y1},{X2,Y2})))}
  || {{X1,Y1},Val1} <- ListOfValues, {{X2,Y2}, Val2} <- ListOfValues, {X1,Y1} /= {X2,Y2}],
  list_max(ListOfGradients).


%% ====================================================================
%% Internal functions
%% ====================================================================

list_max([]   ) -> {error,"empty"};
list_max([H|T]) -> list_max(H, T).

list_max(X, []   )            -> X;
list_max({_,_,V1}, [{C3,C4,V2}|T]) when V1 < V2 -> list_max({C3,C4,V2}, T);
list_max(X, [_|T])            -> list_max(X, T).

getDistant({X1,Y1},{X2,Y2})->math:sqrt(power(X2-X1,2) + power(Y1-Y2,2)).

power(_,0) -> 1;
power(A,N) -> A*power(A,N-1).

getStationDailyMean({X,Y},{{A,B,C},Time}, Type, Poll_monitor) ->
  getStationDailyMean(coordsToName({X,Y},Poll_monitor),{{A,B,C},Time}, Type, Poll_monitor);
getStationDailyMean(Name,{{A,B,C},_}, Type, Poll_monitor) when is_map(Poll_monitor) ->
  case maps:is_key(Name, Poll_monitor) of
    true ->
      {_,Types_map} = maps:get(Name, Poll_monitor, #{}),
      case maps:is_key(Type, Types_map) of
        true ->
          ListOfValues = [ V || {{{A1,B1,C1},_}, V}<-maps:get(Type, Types_map), {A1,B1,C1} == {A,B,C}],
          case length(ListOfValues) > 0 of
            true -> lists:foldl(fun (X, Y) -> X + Y end,0,ListOfValues) / length(ListOfValues);
            false -> -1
          end;
          false -> -1 %% it means that this stations does not have this type of pollutions
      end;
    false -> nothing
  end.

listToElem([]) -> nothing;
listToElem(List) -> lists:last(List).

containsStationWithCoords({X,Y},Poll_monitor) -> lists:member({X,Y},stationsCoords(Poll_monitor)).

stationsCoords(Poll_monitor) -> [{X,Y} || {{X,Y}, _}<-maps:values(Poll_monitor)].

containsMeasurement(Name,{{A,B,C},{D,E,F}},Type, Value, Poll_monitor) ->
  {_,Types_map} = maps:get(Name, Poll_monitor, #{}),
  case maps:is_key(Type, Types_map) of
    true -> lists:member( {{{A,B,C},{D,E,F}}, Value}, maps:get(Type, Types_map));
    false -> false
  end.


%% depends if i will check in all functions if there is a key = Name i can delete whole case and return
%% it finds out there have to be because i cant do lists:last([]) maybe i will change it
coordsToName({X,Y},Poll_monitor) ->
  case containsStationWithCoords({X,Y},Poll_monitor) of
    true -> lists:last([Name1 || {Name1,{{X1,Y1}, _}}<-maps:to_list(Poll_monitor), {X1,Y1} == {X,Y}]);
    false -> {error,"There is no such a station2!"}
  end.