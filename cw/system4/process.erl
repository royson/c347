%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/2]).

start(Num, R) ->
	receive
		{bind, Server, Processes} ->
		App = spawn(app, start, [Num]),
		Beb = spawn(beb, start, []),
		PL = spawn(lossyp2plinks, start, [Beb, R]),
		App ! {bind, Processes, Beb, self()},
		Beb ! {bind, PL, App, Processes},
		Server ! {p2p, self(), PL}
	end.
