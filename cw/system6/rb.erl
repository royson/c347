-module(rb).
-export([start/0]).

start() ->
	receive {bind, App, BEB} -> next(App, BEB, []) end.

next(App, BEB, Delivered) ->
	receive
		{beb_deliver, task1, start, Max_messages, Timeout} ->
		App ! {rb_deliver, task1, start, Max_messages, Timeout};
		{rb_broadcast, Source, M} ->
		io:format("RB",[]),
		BEB ! {beb_broadcast, Source, M},
		next(App, BEB, Delivered);
		{beb_deliver, S, M} ->
		Condition = lists:member(M, Delivered), 
		io:format("Condition, List: ~p~n", [{Condition, Delivered}]),
		if Condition -> next(App, BEB, Delivered);
		true ->
			App ! {rb_deliver, S, M},
			BEB ! {beb_broadcast, S, M},
			next(App, BEB, Delivered++[M])
		end
	end.
