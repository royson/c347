%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(system1).
-export([start/1]).

start([N|_]) ->
	%A is the number of processes
	{A, _} = string:to_integer(atom_to_list(N)),
	Processes = [spawn(process, start, [Num]) || Num <- lists:seq(1,A)],
	
	[P ! {bind, Processes} || P <- Processes],
	[Process ! {task1, start, 0, 3000} || Process <- Processes].	
