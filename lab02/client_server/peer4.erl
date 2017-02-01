
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer4).
-export([start/0]).
 
start() ->
  receive
    {bind, Neighbours} ->
    next(Neighbours, 0, null, 0)
  end.
 
next(Neighbours, MCount, Parent, Children) ->
  receive 
    {hello, Dist, Source} ->
      if MCount == 0 ->
%        io:format("Message is ~p for peer ~p, Dist: ~p~n", [hello, self(), Dist]),
        timer:sleep(1000),
        [Neighbour ! {hello, Dist+1, self()} || Neighbour <- Neighbours, Neighbour /= Source],
	if Source /= null ->
		Source ! {children};
		true -> ok
	end,
	F = 1;
	true ->
	F = 2
      end;
    {children} ->
	F = 3,
	%dummy value%
	Source = Parent
  end,
	%F = 1 -> (first hello packet received)
	%F = 2 -> (more than 1 hello packet received)
	%F = 3 -> (children packet received)
  if 
	F == 1 -> 
		io:format("Peer ~p Parent ~p Children ~p~n", [self(), Source, Children]), 
        	next(Neighbours, MCount+1, Source, Children);
        F == 2 -> 
		next(Neighbours, MCount+1, Parent, Children);
	F == 3 ->
		io:format("Peer ~p Parent ~p Children ~p~n", [self(), Parent, Children+1]), 
		next(Neighbours, MCount, Parent, Children+1);
	true -> ok
  end.
        
