
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer5).
-export([start/0]).
 
start() ->
  receive
    {bind, Neighbours} ->
    next(Neighbours, 0, null, 0, length(Neighbours), 0, 0, 0)
  end.
 
next(Neighbours, MCount, Parent, Children, RepliesNeeded, 
CurrentReplies, NoOfValueReceived, TotalValue) ->

  %Initialize random value
  if TotalValue == 0 ->
	Value = rand:uniform(10);
  true -> 
	Value = TotalValue
  end,

  if RepliesNeeded == CurrentReplies ->
	%Established Peer. If leaf, send value

	io:format("Peer ~p Parent ~p Children ~p~n", [self(), Parent, Children]),
	Source = Parent,
	AddValue = 0,	

	io:format("Peer ~p Value ~p~n", [self(), Value]),
	
	if Children == 0 ->
		Parent ! {value, Value};
	true -> ok
	end,
	F = 5;
  true ->
    receive 
      {hello, Dist, Source} ->
        if MCount == 0 ->
          timer:sleep(1000),
          [Neighbour ! {hello, Dist+1, self()} || Neighbour <- Neighbours, Neighbour /= Source],
  	if Source /= null ->
  		Source ! {children};
  		true -> ok
  	end,
	AddValue = 0,
  	F = 1;
        true ->
  	Source ! {nope},
	AddValue = 0,
  	F = 2
        end;
      {children} ->
  	F = 3,
  	%dummy value%
	AddValue = 0,
  	Source = Parent;
      {nope} ->
  	F = 4,
  	%dummy value%
  	Source = Parent,
	AddValue = 0;
      {value, AddValue} ->
	Source = Parent,
	if (NoOfValueReceived+1) == Children ->
		Parent ! {value, Value+AddValue};
	true -> ok
	end, 
	F = 6
    end
  end,
	%F = 1 -> (first hello packet received)
	%F = 2 -> (more than 1 hello packet received)
	%F = 3 -> (children packet received)
	%F = 4 -> (nope packet received)
	%F = 5 -> (Peer Established)
	%F = 6 -> (Parent peer received value)
  if 
	F == 1 -> 
        	next(Neighbours, MCount+1, Source, Children, 
		RepliesNeeded-1, CurrentReplies, NoOfValueReceived, Value);
        F == 2 -> 
		next(Neighbours, MCount+1, Parent, Children, 
		RepliesNeeded, CurrentReplies, NoOfValueReceived, Value);
	F == 3 ->
		next(Neighbours, MCount, Parent, Children+1, 
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
	F == 4 ->
		next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
	F == 5 ->
		next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
	F == 6 ->
		next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies, NoOfValueReceived+1, Value+AddValue);
	true -> ok
  end.
        
