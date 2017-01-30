
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
    {msg} ->
      if MCount == 0 ->
        io:format("Message is ~p~n for peer ~p~n", [msg, self()]),
        timer:sleep(1000),
        [Neighbour ! {msg} || Neighbour <- Neighbours];
        true -> ok
      end
  end,
  io:format("Count: ~p~n, ID: ~p~n", [MCount, self()]),
  next(Neighbours, MCount+1).
