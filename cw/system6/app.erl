%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(app).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes, Rb, ProcessID} ->
		%Maps - #{ProcessID => {Send,Receive}
		Map = initializeMap(Processes, maps:new()),

		next(Num, Map, Rb, ProcessID, 0)
	end.

next(Num, Map, Rb, ProcessID, Seq) ->
	receive
		{rb_deliver, task1, start, MaxM, T} ->
		Rb ! {meow},
		if Num == 3 ->
			timer:kill_after(5);
		true ->
			erlang:send_after(T, self(), timeout)
		end,
		init(Num, Map, MaxM, Rb, ProcessID, Seq)
	end.

init(Num, Map, Max, Rb, ProcessID, Seq) ->
	receive
		{rb_deliver, Pid, _} ->
			{S, R} = maps:get(Pid, Map),
		%	io:format("In Process: ~p , {PID,R} ~p~n", [ProcessID,{Pid, R+1}]),
			NMap = maps:update(Pid, {S, R+1}, Map),
			init(Num, NMap, Max, Rb, ProcessID, Seq);
		timeout ->
			timeout(Num, Map, Rb, ProcessID, Seq)
	after 0 ->
		broadcast(Num, Map, Max, Rb, ProcessID, Seq)
	end.

timeout(Num, Map, Rb, ProcessID, Seq) ->
	Values = maps:values(Map),
	SValues = [ toString(V) || V <- Values ],
	
	io:format("~p: ~s~n", [Num, string:join(SValues, " ")]),
		
	Pid = [ P || P <- maps:keys(Map)],
	NMap = initializeMap(Pid, maps:new()),
	next(Num, NMap, Rb, ProcessID, Seq).

broadcast(Num, Map, Max, Rb, ProcessID, Seq) ->
	Pid = [ P || P <- maps:keys(Map)],
	{_,{S,_}} = maps:find(ProcessID,Map),
	if Max == 0 ->
		Rb ! {rb_broadcast, ProcessID, {ProcessID, Seq}},
		NMap = updateMap(Pid, Map, Rb, ProcessID),

	%	if Num == 2 ->
	%		io:format("Rb.~p~n",[Rb]);
	%	true -> ok
	%	end, 
		init(Num, NMap, Max, Rb, ProcessID, Seq+1);
	   S < Max ->
		Rb ! {rb_broadcast, ProcessID, {ProcessID, Seq}},
		NMap = updateMap(Pid, Map, Rb, ProcessID),
		%if Num == 3 ->
		%	io:format("BROADCASTING.~n",[]);
		%true -> ok
		%end, 
		init(Num, NMap, Max, Rb, ProcessID, Seq+1);
	true -> 
		init(Num, Map, Max, Rb, ProcessID, Seq)
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
updateMap([P|O], Map, Rb, ProcessID) ->
	{S, R} = maps:get(P, Map),
	NMap = maps:update(P, {S+1, R}, Map),
	updateMap(O, NMap, Rb, ProcessID).


