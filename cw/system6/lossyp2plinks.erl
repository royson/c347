%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(lossyp2plinks).
-export([start/2]).

start(Beb, R) ->
	receive
		{bind, PLS} ->
		Map = initializeMap(PLS, maps:new()),
		next(Beb, Map, R)
	end.

next(Beb, Map, R) ->
	receive
		{pl_deliver, task1, start, Max_messages, Timeout} ->
			Beb ! {pl_deliver, task1, start, Max_messages, Timeout};
		{pl_send, Q, Sender, M} ->
			No = rand:uniform(100),
 
			if R >= No -> 
				{_,SenderPl} = maps:find(Q, Map),
				SenderPl ! {pl_transmit, Sender, M};
			true -> ok
			end;
		{pl_transmit, Pid, M} ->
			Beb ! {pl_deliver, Pid, M}
	end,
	next(Beb, Map, R).

initializeMap([], Map) ->
	Map;
initializeMap([{Process, PL}|O], Map) ->
	NMap = maps:put(Process, PL, Map),
	initializeMap(O, NMap).
