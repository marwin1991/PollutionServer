defmodule PollutionData do
  def parseLine(line,type \\ "PM10") do
    line = String.replace(line,"\r","")
    #IO.puts(line)
    [data,hour,x,y,value] = line |> String.split(",")
    parseData = data |> String.split("-") |> Enum.reverse() |> Enum.map(&Integer.parse/1) |> Enum.map(fn (x) -> elem(x,0) end) |>List.to_tuple()
    hour = hour <> ":00"
    parseHour = hour |> String.split(":") |>  Enum.map(&Integer.parse/1) |> Enum.map(fn (x) -> elem(x,0) end) |> List.to_tuple()
    {x,_} = Float.parse(x)
    {y,_} = Float.parse(y)
    {value,_} = Float.parse(value)
    {{x,y},{parseData,parseHour},type,value}
  end

  def  importLinesFromCSV(fileName \\ "pollution.csv")  do
    list = File.read!(fileName) |> String.split("\n")
    myFN = fn(arg1) -> parseLine(arg1) end
    list2 = Enum.map(list,myFN)
    IO.puts("Loaded #{length(list2)} lines")
    list2
  end

  def addStationWithFakeName(list) do
    list |> Enum.map(fn({x1,y1}) -> :pollution_otp_server.addStation("Station " <> Float.to_string(x1) <> " " <> Float.to_string(y1), {x1,y1}) end)
  end

  def load() do
    list = importLinesFromCSV()
    lista2 = for {coords, _, _, _}<-list, do: coords
    addStationWithFakeName(lista2)
    list |> Enum.map(fn ({coords2,data,type,value}) ->  :pollution_otp_server.addValue(coords2,data,type,value) end)
    :ok
  end
end