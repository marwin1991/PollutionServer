%%%-------------------------------------------------------------------
%%% @author Piotr
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. maj 2017 11:35
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Piotr").

%% API
-export([start/0, stop/0, init/0, getMonitor/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMaximumGradientStations/2, loop/1]).

start()->
  register(server,spawn(?MODULE,init,[])).

init()->
  State = pollution:createMonitor(),
  loop(State).

stop()->
  server ! stop.

call(Message) ->
  server ! Message,
  receive
    ok -> ok;
    {ok, M} -> M;
    {error, M} -> M
  end.

getMonitor()->call({self(),getMonit}).
addStation(Name,{X,Y})-> call({self(),addStat,Name,{X,Y}}).
addValue(Id,Time,Type, Value)-> call({self(),addVal, Id, Time, Type, Value}).
removeValue(Id,Time,Type)-> call({self(),removeVal, Id, Time,Type}).
getOneValue(Id,Time,Type)-> call({self(),getOneVal,Id,Time,Type}).
getStationMean(Id,Type)-> call({self(),getStatMean, Id, Type}).
getDailyMean(Time,Type)->call({self(),getDailyServMean,Time,Type}).
getMaximumGradientStations(Time,Type)-> call({self(),getMaxGradStat, Time, Type}).

loop(Monitor) ->
  receive
    stop -> {ok, "Server has been stopped."};
    {Pid,getMonit} -> Pid ! {ok, Monitor}, loop(Monitor);
    {Pid, addStat,Name,{X,Y}} ->
      Return = pollution:addStation(Name,{X,Y},Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes}, loop(Monitor);
        _ -> Pid ! ok, loop(Return)
      end;
    {Pid, addVal, Id, Time, Type, Value} ->
      Return = pollution:addValue(Id,Time,Type,Value,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes}, loop(Monitor);
        _ -> Pid ! ok, loop(Return)
      end;
    {Pid, removeVal, Id, Time,Type} ->
      Return = pollution:removeValue(Id,Time,Type,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes}, loop(Monitor);
        _ -> Pid ! ok, loop(Return)
      end;
    {Pid, getOneVal,Id,Time,Type} ->
      Return = pollution:getOneValue(Id,Time,Type,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes};
        Some -> Pid ! {ok,Some}
      end,
      loop(Monitor);
    {Pid, getStatMean, Id, Type} ->
      Return = pollution:getStationMean(Id,Type,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes};
        Some -> Pid ! {ok,Some}
      end,
      loop(Monitor);
    {Pid, getDailyServMean,Time,Type} -> Return = pollution:getDailyMean(Time,Type,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes};
        Some -> Pid ! {ok,Some}
      end,
      loop(Monitor);
    {Pid, getMaxGradStat, Time, Type} -> Return = pollution:getMaximumGradientStations(Time,Type,Monitor),
      case Return of
        {error,Mes} -> Pid ! {error,Mes};
        Some -> Pid ! {ok,Some}
      end,
      loop(Monitor)
  end.