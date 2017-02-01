
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer5).
-export([start/0]).
 
start() ->
  receive
    {bind, Neighbours} ->
    next(Neighbours, 0, null, 0, length(Neighbours), 0)
  end.
 
next(Neighbours, MCount, Parent, Children, RepliesNeeded, CurrentReplies) ->
  if RepliesNeeded /= CurrentReplies ->
    receive 
      {hello, Dist, Source} ->
        if MCount == 0 ->
          timer:sleep(1000),
          [Neighbour ! {hello, Dist+1, self()} || Neighbour <- Neighbours, Neighbour /= Source],
  	if Source /= null ->
  		Source ! {children};
  		true -> ok
  	end,
  	F = 1;
        true ->
  	Source ! {nope},
  	F = 2
        end;
      {children} ->
  	F = 3,
  	%dummy value%
  	Source = Parent;
      {nope} ->
  	F = 4,
  	%dummy value%
  	Source = Parent
    end;
  true -> 
	%Peer is established

	io:format("Peer ~p Parent ~p Children ~p~n", [self(), Parent, Children]),
	F = 5,
	Source = Parent

	%Generate value
%	Value = 1,
%	io:format("Peer ~p Value ~p~n", [self(), Value],
	
%	if Children == 0 ->
		
  end,
	%F = 1 -> (first hello packet received)
	%F = 2 -> (more than 1 hello packet received)
	%F = 3 -> (children packet received)
	%F = 4 -> (nope packet received)
  if 
	F == 1 -> 
        	next(Neighbours, MCount+1, Source, Children, RepliesNeeded-1, CurrentReplies);
        F == 2 -> 
		next(Neighbours, MCount+1, Parent, Children, RepliesNeeded, CurrentReplies);
	F == 3 ->
		next(Neighbours, MCount, Parent, Children+1, RepliesNeeded, CurrentReplies+1);
	F == 4 ->
		next(Neighbours, MCount, Parent, Children, RepliesNeeded, CurrentReplies+1);
	true -> ok
  end.
        
