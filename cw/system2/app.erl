%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(app).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes, PL, ProcessID} ->
		%Maps - #{ProcessID => {Send,Receive}
		Map = initializeMap(Processes, maps:new()),

		next(Num, Map, PL, ProcessID)
	end.

next(Num, Map, PL, ProcessID) ->
	receive
		{pl_deliver, task1, start, MaxM, T} ->
		erlang:send_after(T, self(), timeout),
		init(Num, Map, MaxM, PL, ProcessID)
	end.

init(Num, Map, Max, PL, ProcessID) ->
	receive
		{pl_deliver, Pid, msg} ->
			{S, R} = maps:get(Pid, Map),
			NMap = maps:update(Pid, {S, R+1}, Map),
			init(Num, NMap, Max, PL, ProcessID);
		timeout ->
			timeout(Num, Map, PL, ProcessID)
	after 0 ->
		broadcast(Num, Map, Max, PL, ProcessID)
	end.

timeout(Num, Map, PL, ProcessID) ->
	Values = maps:values(Map),
	SValues = [ toString(V) || V <- Values ],
	
	io:format("~p: ~s~n", [Num, string:join(SValues, " ")]),
		
	Pid = [ P || P <- maps:keys(Map)],
	NMap = initializeMap(Pid, maps:new()),
	next(Num, NMap, PL, ProcessID).

broadcast(Num, Map, Max, PL, ProcessID) ->
	Pid = [ P || P <- maps:keys(Map)],
	{_,{S,_}} = maps:find(ProcessID,Map),
	if Max == 0 -> 
		NMap = updateMap(Pid, Map, PL, ProcessID),
		init(Num, NMap, Max, PL, ProcessID);
	   S < Max ->
		NMap = updateMap(Pid, Map, PL, ProcessID),
		init(Num, NMap, Max, PL, ProcessID);
	true -> 
		init(Num, Map, Max, PL, ProcessID)
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
updateMap([P|O], Map, PL, ProcessID) ->
	PL ! {pl_send, ProcessID, msg},
	{S, R} = maps:get(P, Map),
	NMap = maps:update(P, {S+1, R}, Map),
	updateMap(O, NMap, PL, ProcessID).


