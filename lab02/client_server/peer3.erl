
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer3).
-export([start/0]).
 
start() ->
  receive
    {bind, Neighbours} ->
    next(Neighbours, 0, null)
  end.
 
next(Neighbours, MCount, Parent) ->
  receive 
    {hello, Dist, Source} ->
      if MCount == 0 ->
%        io:format("Message is ~p for peer ~p, Dist: ~p~n", [hello, self(), Dist]),
        timer:sleep(1000),
        [Neighbour ! {hello, Dist+1, self()} || Neighbour <- Neighbours, Neighbour /= Source];
        true -> ok
      end
  end,
  if MCount == 0 ->
  	io:format("Peer ~p, Parent ~p, Messages seen = ~p~n", [self(), Source, MCount+1]),
  	next(Neighbours, MCount+1, Source);
  	true -> io:format("Peer ~p, Parent ~p, Messages seen = ~p~n", [self(), Parent, MCount+1]),
  	next(Neighbours, MCount+1, Parent)
  end.
        
