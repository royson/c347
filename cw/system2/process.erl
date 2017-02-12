%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/1]).

start(Num) ->
	receive
		{bind, Server, Processes} ->
		App = spawn(app, start, [Num]),
		PL = spawn(p2p, start, [App]),
		App ! {bind, Processes, PL, self()},
		Server ! {p2p, self(), PL}
	end.
