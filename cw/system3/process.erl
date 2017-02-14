%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/1]).

start(Num) ->
	receive
		{bind, Server, Processes} ->
		App = spawn(app, start, [Num]),
		Beb = spawn(beb, start, []),
		PL = spawn(p2p, start, [Beb]),
		App ! {bind, Processes, Beb, self()},
		Beb ! {bind, PL, App, Processes},
		Server ! {p2p, self(), PL}
	end.
