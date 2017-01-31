
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer1).
-export([start/0]).
 
start() ->
  receive
    {bind, Neighbours} ->
    next(Neighbours, 0)
  end.
 
next(Neighbours, MCount) ->
  receive 
    {hello} ->
      if MCount == 0 ->
        io:format("Message is ~p~n for peer ~p~n", [hello, self()]),
        timer:sleep(1000),
        [Neighbour ! {hello} || Neighbour <- Neighbours];
        true -> ok
      end
  end,
  io:format("Peer ~p~n, Messages seen = ~p~n", [self(), MCount]),
  next(Neighbours, MCount+1).
