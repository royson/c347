%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(system3).
-export([start/1]).

start([N|_]) ->
	%A is the number of processes
	{A, _} = string:to_integer(atom_to_list(N)),
	Processes = [spawn(process, start, [Num]) || Num <- lists:seq(1,A)],

	[P ! {bind, self(), Processes} || P <- Processes],
	%[Process ! {task1, start, 0, 3000} || Process <- Processes].	
	init_pl(0, [], A).

init_pl(C, PLS, T) ->
	receive
		{p2p, Process, PL} ->
		PLS2 = lists:append([{Process,PL}], PLS),
		if C+1 == T ->
			%send each PL a list of {process, PL}
			[ PPL ! {bind, PLS2} || {_,PPL} <- PLS2 ],
			[ PPL ! {pl_deliver, task1, start, 0, 1000} || {_,PPL} <- PLS2];	
		true -> 
			init_pl(C+1, PLS2, T)
		end
	end.
