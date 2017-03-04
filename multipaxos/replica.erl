%%% 
%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} -> 
       next(Leaders, [], 1, 1, [], [], [])
  end.

next(Leaders, InitialState, SlotIn, SlotOut, Reqs, Proposals, Decisions) ->
  receive
    {request, C} ->      % request from client
      Reqs2 = Reqs ++ [C];
    {decision, S, C} ->  % decision from commander
      ... = decide (Decisions, S, C);
  end, % receive

  ... = propose(...),
  ...

propose(...) ->
  WINDOW = 5,
  ...
   
decide(Decisions, S, C) ->
  
       perform(...),
  ...

perform(...) ->
  ...
      Database ! {execute, Op},
      Client ! {response, Cid, ok}

