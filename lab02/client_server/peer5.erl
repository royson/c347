
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
  if TotalValue == 0 -> Value = rand:uniform(10);
  		true -> Value = TotalValue
  end,

  if RepliesNeeded == CurrentReplies ->
	%Established Peer. If leaf, send value

	io:format("Peer ~p Parent ~p Children ~p~n", [self(), Parent, Children]),
	io:format("Peer ~p Value ~p~n", [self(), Value]),
	
	if Children == 0 -> Parent ! {value, Value};
		    true -> ok
	end,
	next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
  true ->
    receive 
      {hello, Dist, Source} ->
        if MCount == 0 ->
	          timer:sleep(1000),
	          [Neighbour ! {hello, Dist+1, self()} || 
			Neighbour <- Neighbours, Neighbour /= Source],
	  	if Source /= null -> Source ! {children};
	  		     true -> ok
	  	end,
		next(Neighbours, MCount+1, Source, Children, 
			RepliesNeeded-1, CurrentReplies, NoOfValueReceived, Value);
	true ->
	  	Source ! {nope},
	  	next(Neighbours, MCount+1, Parent, Children, 
			RepliesNeeded, CurrentReplies, NoOfValueReceived, Value)
	        end;
      {children} ->
 	next(Neighbours, MCount, Parent, Children+1, 
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
      {nope} ->
  	next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies+1, NoOfValueReceived, Value);
      {value, AddValue} ->
	if (NoOfValueReceived+1) == Children -> Parent ! {value, Value+AddValue};
					true -> ok
	end, 
	next(Neighbours, MCount, Parent, Children,
		RepliesNeeded, CurrentReplies, NoOfValueReceived+1, Value+AddValue) 
    end
  end.
