%%% Chu Lee (cyl113) and Royson Lee (dsl114)
-module(beb).
-export([start/0]).

start() ->
	receive
		{bind, PL, Rb, Processes} ->
		next(PL, Rb, Processes)
	end.

next(PL, Rb, Processes) ->
	receive
		{pl_deliver, task1, start, Max_messages, Timeout} ->
			Rb ! {beb_deliver, task1, start, Max_messages, Timeout};
		{beb_broadcast, Sender, M} ->
			[ PL ! {pl_send, Q, Sender, M} || Q <- Processes ];
		{pl_deliver, P, M} ->
			Rb ! {beb_deliver, P, M} 
	end,
	next(PL, Rb, Processes).
