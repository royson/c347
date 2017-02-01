
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
	Source ! {children},
        io:format("Peer ~p, Parent ~p, Children = ~p~n", [self(), Source, Children]),
        next(Neighbours, MCount+1, Source, Children);
        true -> io:format("Peer ~p, Parent ~p, Children = ~p~n", [self(), Parent, Children]),
        next(Neighbours, MCount+1, Parent, Children)	
      end;
    {children} ->
	next(Neighbours, MCount, Parent, Children+1)
  end.
        
