
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system5).
-export([start/1]).

start([N|_]) ->
  {A, _} = string:to_integer(atom_to_list(N)),
  List = lists:seq(1,A),
  Peers = [ spawn(peer5, start, []) || _ <- List],

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

  FirstPeer = lists:nth(5,Peers),
  FirstPeer ! {hello, 0, self()},

  receive
	{value, Value} ->
		io:format("Total Value: ~p~n",[Value])
  end.

neighbours(Peers, X, Neighbours) ->
  NeighboursPID = [ lists:nth(Neighbour,Peers) || Neighbour <- Neighbours ],
  %add PID of system4 into neighbour list of root
 
  if X == 5 ->
	NeighboursPIDAndSource = lists:append(NeighboursPID, [self()]),
	lists:nth(X, Peers) ! {bind, NeighboursPIDAndSource};
        true ->
  	lists:nth(X, Peers) ! {bind, NeighboursPID}
  end.
