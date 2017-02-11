%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes} ->
		%Maps - #{ProcessID => {Send,Receive}
		%Map = #{ P => {0,0} || P <- Processes },
		Map = initializeMap(Processes, maps:new()),
		
		%Debugging
		%io:format("~p ~p~n",[self(), Map]),

		next(Num, Processes, 0,  Map, 0, 0)
	end.
			
next(Num, Processes, MCount, Map, Broadcast, Max) ->
	receive
		{task1, start, MaxM, T} ->

		%more efficient than timer:send_after
		erlang:send_after(T, self(), timeout),
		
		%enable broadcast
		next(Num, Processes, MCount, Map, 1, MaxM);
		
		%NMap = send(Processes, Map, MCount, MaxM);

		{Pid, msg} ->
			{S, R} = maps:get(Pid, Map),
			NMap = maps:update(Pid, {S, R+1}, Map),
			next(Num, Processes, MCount, NMap, Broadcast, Max);
	
		timeout ->
			Values = maps:values(Map),
			SValues = [ toString(V) || V <- Values ],
			
			io:format("~p: ~s~n", [Num, string:join(SValues, " ")]),
		
			NMap = initializeMap(Processes, maps:new()),
			next(Num, Processes, 0, NMap, 0, 0)

	after 0 ->
		if Broadcast == 1 ->
			if Max == 0 -> 
				%keep broadcast
				NMap = updateMap(Processes, Map),
				next(Num, Processes, MCount+1, NMap, Broadcast, Max);
			  MCount < Max ->
				%send a broadcast 
				NMap = updateMap(Processes, Map),
				next(Num, Processes, MCount+1, NMap, Broadcast, Max);
			  
			true -> ok
			end;
		true -> ok
		end,
		next(Num, Processes, MCount, Map, Broadcast, Max)
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


