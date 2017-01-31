
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(client).
-export([start/0]).
 
start() -> 
  receive 
    {bind, S} -> next(S) 
  end.
 
next(S) ->
  S ! {circle, 1.0, self()},
  receive 
    {result, Area} -> 
      io:format("Area is ~p~n , pid is ~p~n", [Area, self()]) 
  end,
  timer:sleep(1000),      % pause one second before next request
  next(S).

