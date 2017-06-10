%%%-------------------------------------------------------------------
%%% @author Piotr
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. maj 2017 09:56
%%%-------------------------------------------------------------------
-module(pollution_otp_server).
-author("Piotr").

-behaviour(gen_server).

%% API
-export([start_link/1, getMonitor/0, addStation/2, addValue/4, removeValue/3, getOneValue/3,  getStationMean/2, getDailyMean/2,getMaximumGradientStations/2]).

%% gen_server callbacks
-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================

start_link(Init) ->
  InitialValue2 = pollution:createMonitor(),
  gen_server:start_link({local, ?SERVER}, ?MODULE, InitialValue2, [Init]).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
getMonitor()->gen_server:call(?SERVER,{getMonitor}).
addStation(Name,{X,Y})-> gen_server:call(?SERVER,{addStat,Name,{X,Y}}).
addValue(Id,Time,Type, Value)-> gen_server:call(?SERVER,{addVal, Id, Time, Type, Value}).
removeValue(Id,Time,Type)-> gen_server:call(?SERVER,{removeVal, Id, Time,Type}).
getOneValue(Id,Time,Type)-> gen_server:call(?SERVER,{getOneVal,Id,Time,Type}).
getStationMean(Id,Type)-> gen_server:call(?SERVER,{getStatMean, Id, Type},infinity).
getDailyMean(Time,Type)->gen_server:call(?SERVER,{getDailyServMean,Time,Type}).
getMaximumGradientStations(Time,Type)-> gen_server:call(?SERVER,{getMaxGradStat, Time, Type}).

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State,  Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init(InitialMonitor) ->
  {ok, InitialMonitor}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
handle_call({getMonitor},_From, State) -> {reply, State, State};
handle_call({addStat,Name,{X,Y}}, _From, State) ->
  case pollution:addStation(Name,{X,Y},State) of
    {error,Mes} -> {reply,{error,Mes},State};
    NewState -> {reply,ok,NewState}
  end;
handle_call({addVal, Id, Time, Type, Value},_From, State) ->
  case pollution:addValue(Id,Time,Type,Value,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    NewState -> {reply,ok,NewState}
  end;
handle_call({removeVal, Id, Time,Type},_From, State)->
  case pollution:removeValue(Id,Time,Type,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    NewState -> {reply,ok,NewState}
  end;
handle_call({getOneVal,Id,Time,Type},_From, State)->
  case pollution:getOneValue(Id,Time,Type,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    Return -> {reply,Return,State}
  end;
handle_call({getStatMean, Id, Type},_From, State)->
  case pollution:getStationMean(Id,Type,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    Return -> {reply,Return,State}
  end;
handle_call({getDailyServMean,Time,Type},_From, State)->
  case pollution:getDailyMean(Time,Type,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    Return -> {reply,Return,State}
  end;
handle_call({getMaxGradStat, Time, Type},_From, State)->
  case pollution:getMaximumGradientStations(Time,Type,State) of
    {error,Mes} -> {reply,{error,Mes},State};
    Return -> {reply,Return,State}
  end;
handle_call(_Request,_From, State)-> {reply,unknown_call,State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------

handle_cast(_Request,State) -> {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
