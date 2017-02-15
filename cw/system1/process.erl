%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes} ->
		%Maps - #{ProcessID => {Send,Receive}
		Map = initializeMap(Processes, maps:new()),

		next(Num,  Map)
	end.

next(Num, Map) ->
	receive
		{task1, start, MaxM, T} ->
		erlang:send_after(T, self(), timeout),
		init(Num, Map, MaxM)
	end.

init(Num, Map, Max) ->
	receive
		{Pid, msg} ->
			{S, R} = maps:get(Pid, Map),
			NMap = maps:update(Pid, {S, R+1}, Map),
			init(Num, NMap, Max);
		timeout ->
			timeout(Num, Map)
	after 0 ->
		broadcast(Num, Map, Max)
	end.

timeout(Num, Map) ->
	Values = maps:values(Map),
	SValues = [ toString(V) || V <- Values ],
	
	io:format("~p: ~s~n", [Num, string:join(SValues, " ")]),
		
	Pid = maps:keys(Map),
	NMap = initializeMap(Pid, maps:new()),
	next(Num, NMap).

broadcast(Num, Map, Max) ->
	Pid = maps:keys(Map),
	{_,{S,_}} = maps:find(self(),Map),
	if Max == 0 -> 
		NMap = updateMap(Pid, Map),
		init(Num, NMap, Max);
	   S < Max ->
		NMap = updateMap(Pid, Map),
		init(Num, NMap, Max);
	true -> 
		init(Num, Map, Max)
	end.

toString(Term) ->
	lists:flatten(io_lib:format("~p",[Term])).

%%% Map Functions %%%

initializeMap([], Map) ->
	Map;
initializeMap([P|O], Map) ->
	NMap = maps:put(P, {0,0}, Map),
	initializeMap(O, NMap).

updateMap([], Map) ->
	Map;
updateMap([P|O], Map) ->
	P ! {self(), msg},
	{S, R} = maps:get(P, Map),
	NMap = maps:update(P, {S+1, R}, Map),
	updateMap(O, NMap).


