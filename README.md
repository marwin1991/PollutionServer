# Sollution for Erlang Course at AGH WIEiT 2017
# Erlang PollutionServer with Elixir data's loader

### This erlang module can be run using this commands:

First compile/load pollution.erl to provide functions
iex(1)> c("pollution.erl")
[:pollution]

Using server

Erlang command interpreter:
- when you are in this directory
1> c("pollution_otp_server").
{ok,pollution_otp_server}
2> c("pollution_otp_supervisor").
{ok,pollution_otp_supervisor}
3> pollution_otp_supervisor:start_link().
{ok,<0.85.0>}
4> pollution_otp_server:getMonitor().    
#{}

If you are testing it in the shell:
https://stackoverflow.com/questions/12096308/why-my-supervisor-terminating
use "catch" phrase, f.e. catch pollution_otp_server:getMonitorssssss().

Elixir command interpreter:
- when you are in this directory
iex(1)> c("pollution_otp_server.erl")
[:pollution_otp_server]
iex(2)> c("pollution_otp_supervisor.erl")
[:pollution_otp_supervisor]
iex(3)> :pollution_otp_supervisor.start_link()
{:ok, #PID<0.92.0>}
iex(4)> :pollution_otp_server.getMonitor()    
%{}


Load data
iex(5)> c("pollution_data.ex")
[PollutionData]
iex(6)> PollutionData.load()              
Loaded 5904 lines
:ok

Funcjonality:
 
Time - {{YEAR,MONTH,DAY},{HOUR,MINUT,SECONDS}} or {YEAR,MONTH,DAY} - depends where its needed
getMonitor()
addStation(Name,{X,Y})
addValue(Name/{X,Y},Time,Type, Value)
removeValue(Name/{X,Y},Time,Type)
getOneValue(Name/{X,Y},Time,Type)

iex(24)> :pollution_otp_server.getStationMean("Station 20.123 50.101","PM10")   
43.083333333333336

iex(26)> :pollution_otp_server.getDailyMean({2017,5,3},"PM10")       
67.57440476190477

iex(37)> :pollution_otp_server.getMaximumGradientStations({2017,5,3},"PM10")
{{19.914, 50.117}, {19.914, 50.116}, 70166.66666683019}


