%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(app).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes, Beb, ProcessID} ->
		%Maps - #{ProcessID => {Send,Receive}
		Map = initializeMap(Processes, maps:new()),

		next(Num, Map, Beb, ProcessID)
	end.

next(Num, Map, Beb, ProcessID) ->
	receive
		{beb_deliver, task1, start, MaxM, T} ->
		erlang:send_after(T, self(), timeout),
		init(Num, Map, MaxM, Beb, ProcessID)
	end.

init(Num, Map, Max, Beb, ProcessID) ->
	receive
		{beb_deliver, Pid, msg} ->
			{S, R} = maps:get(Pid, Map),
			NMap = maps:update(Pid, {S, R+1}, Map),
			init(Num, NMap, Max, Beb, ProcessID);
		timeout ->
			timeout(Num, Map, Beb, ProcessID)
	after 0 ->
		broadcast(Num, Map, Max, Beb, ProcessID)
	end.

timeout(Num, Map, Beb, ProcessID) ->
	Values = maps:values(Map),
	SValues = [ toString(V) || V <- Values ],
	
	io:format("~p: ~s~n", [Num, string:join(SValues, " ")]),
		
	Pid = maps:keys(Map),
	NMap = initializeMap(Pid, maps:new()),
	next(Num, NMap, Beb, ProcessID).

broadcast(Num, Map, Max, Beb, ProcessID) ->
	Pid = maps:keys(Map),
	{_,{S,_}} = maps:find(ProcessID,Map),
	if Max == 0 -> 
		Beb ! {beb_broadcast, ProcessID, msg},
		NMap = updateMap(Pid, Map, Beb, ProcessID),
		init(Num, NMap, Max, Beb, ProcessID);
	   S < Max ->
		Beb ! {beb_broadcast, ProcessID, msg},
		NMap = updateMap(Pid, Map, Beb, ProcessID),
		init(Num, NMap, Max, Beb, ProcessID);
	true -> 
		init(Num, Map, Max, Beb, ProcessID)
	end.

toString(Term) ->
	lists:flatten(io_lib:format("~p",[Term])).

%%% Map Functions %%%

initializeMap([], Map) ->
	Map;
initializeMap([P|O], Map) ->
	NMap = maps:put(P, {0,0}, Map),
	initializeMap(O, NMap).

updateMap([], Map, _, _) ->
	Map;
updateMap([P|O], Map, Beb, ProcessID) ->
	{S, R} = maps:get(P, Map),
	NMap = maps:update(P, {S+1, R}, Map),
	updateMap(O, NMap, Beb, ProcessID).


