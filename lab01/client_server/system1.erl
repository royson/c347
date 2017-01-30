
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system1).
-export([start/1]).

start([N|_]) ->
  {A, _} = string:to_integer(atom_to_list(N)),
  L = lists:seq(1,A),
  [H|T] = [spawn(peer1, start, []) || _ <- L],
  [f(Q,[H|T]) || Q <- [H|T]],
  H ! {msg}.
  
f(Q,LP) ->
  Neighbours = [X || X <- LP, Q /= X ],
  Q ! {bind, Neighbours}.

