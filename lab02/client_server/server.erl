
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(server).
-export([start/0]).
 
start() ->  
  next(). 
 
next() ->
  receive
    {circle, Radius, C} ->  C ! {result, 3.14159 * Radius * Radius};
    {square, Side, C}   ->  C ! {result, Side * Side}
  end,
  next().

