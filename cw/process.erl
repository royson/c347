%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(process).
-export([start/1]).

start(Num) ->
	receive
		{bind, Processes} ->
		%Maps - #{ProcessID => {Send,Receive}
		%Map = #{ P => {0,0} || P <- Processes },
		M = maps:new(),
		Map = [ M#{P => {0,0}} || P <- Processes ],
		
		%Debugging
		D = maps:to_list(Map),
		io:format("~p", [string:join(D, " ")]),

		next(Num, Processes, Map)
	end.
			
next(Num, Processes, Map) ->
	receive
		{task1, start, MaxM, T} ->

		%more efficient than timer:send_after
		erlang:send_after(T, self(), timeout),
		
		[ send(Processes, Map) || _ <- lists:seq(1,MaxM) ];
		
		{Pid, msg} ->
			{S, R} = maps:get(Pid, Map),
			maps:update(Pid, {S, R+1}, Map);

		timeout ->
			Values = maps:value(Map),
			io:format("~p: ~p~n", [Num, string:join(Values, " ")]),
			erlang:halt()
	end,
	next(Num, Processes, Map).			

send(Processes, Map) ->
	[ updateSend(P, Map) || P <- Processes ].

updateSend(P, Map) ->
	P ! {self(), msg},
	{S, R} = maps:get(P, Map),
	maps:update(P, {S+1, R}, Map).


