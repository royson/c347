%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(p2p).
-export([start/1]).

start(Beb) ->
	receive
		{bind, PLS} ->
		Map = initializeMap(PLS, maps:new()),
		next(Beb, Map)
	end.

next(Beb, Map) ->
	receive
		{pl_deliver, task1, start, Max_messages, Timeout} ->
			Beb ! {pl_deliver, task1, start, Max_messages, Timeout};
		{pl_send, Q, Sender, msg} ->
			{_,SenderPl} = maps:find(Q, Map),
			SenderPl ! {pl_transmit, Sender, msg};
		{pl_transmit, Pid, msg} ->
			Beb ! {pl_deliver, Pid, msg}
	end,
	next(Beb, Map).

initializeMap([], Map) ->
	Map;
initializeMap([{Process, PL}|O], Map) ->
	NMap = maps:put(Process, PL, Map),
	initializeMap(O, NMap).
