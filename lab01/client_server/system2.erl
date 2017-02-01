
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system2).
-export([start/1]).

neighbours(Peers, 1, [2, 7]),
neighbours(Peers, 2, [1, 3, 4]),
neighbours(Peers, 3, [2, 4, 5]),
neighbours(Peers, 4, [2, 3, 6]),
neighbours(Peers, 5, [3]),
neighbours(Peers, 6, [4]),
neighbours(Peers, 7, [1, 8]),
neighbours(Peers, 8, [7, 9, 10]),
neighbours(Peers, 9, [8, 10]),
neighbours(Peers, 10, [8, 9]),

start([N|_]) ->
  {A, _} = string:to_integer(atom_to_list(N)),
  L = lists:seq(1,A),
  [H|T] = [spawn(peer1, start, []) || _ <- L],
  [f(Q,[H|T], L) || Q <- [H|T]],
  H ! {hello}.
  
f(Q, LP, L) ->
  [ Neighbours || X <- L, neighbour(Peers, X, Neighbours)],
  NeighboursPID = [lists:nth(N, LP) || N <- Neighbours],
  Q ! {bind, NeighboursPID}.

