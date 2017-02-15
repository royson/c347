%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(beb).
-export([start/0]).

start() ->
	receive
		{bind, PL, App, Processes} ->
		next(PL, App, Processes)
	end.

next(PL, App, Processes) ->
	receive
		{pl_deliver, task1, start, Max_messages, Timeout} ->
			App ! {beb_deliver, task1, start, Max_messages, Timeout};
		{beb_broadcast, Sender, msg} ->
			[ PL ! {pl_send, Q, Sender, msg} || Q <- Processes ];
		{pl_deliver, P, msg} ->
			App ! {beb_deliver, P, msg} 
	end,
	next(PL, App, Processes).
