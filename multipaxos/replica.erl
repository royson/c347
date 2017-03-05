%%% Chu Lee (cyl113) and Royson Lee (dsl114)
%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} -> 
       next(Leaders, 1, 1, 1, [], [], [], Database)
  end.

next(Leaders, State, SlotIn, SlotOut, Reqs, Proposals, Decisions, Database) ->
  receive
    {request, C} ->      % request from client
      Reqs2 = Reqs ++ [C],
      propose(Leaders, State, SlotIn, SlotOut, Reqs2, Proposals, Decisions, Database);
    {decision, S, C} ->  % decision from commander
      Decisions2 = Decisions ++ [{S, C}],
      {Proposals2, Reqs2, SlotOut2, State2} = decide (Decisions2, Proposals, Reqs, SlotOut, State, Decisions2, Database),
      propose(Leaders, State2, SlotIn, SlotOut2, Reqs2, Proposals2, Decisions2, Database)
  end.

propose(Leaders, State, SlotIn, SlotOut, [], Proposals, Decisions, Database) ->
  next(Leaders, State, SlotIn, SlotOut, [], Proposals, Decisions, Database);
propose(Leaders, State, SlotIn, SlotOut, [C | T], Proposals, Decisions, Database) ->
  WINDOW = 5,
  if SlotIn < SlotOut + WINDOW ->
    case isMemberOf(SlotIn, Decisions) of
    %case lists:member(SlotIn, [ SO || {SO, _} <- Decisions ]) of
      false ->
        Proposals2 = Proposals ++ [{SlotIn, C}],
        [ L ! {propose, SlotIn, C} || L <- Leaders ],
        SlotIn2 = SlotIn + 1,
        propose(Leaders, State, SlotIn2, SlotOut, T, Proposals2, Decisions, Database);
      true -> 
        SlotIn2 = SlotIn + 1,
        propose(Leaders, State, SlotIn2, SlotOut, [C | T], Proposals, Decisions, Database)
    end;
  true -> 
    next(Leaders, State, SlotIn, SlotOut, [C | T], Proposals, Decisions, Database)
  end.
  
   
decide([], Proposals, Reqs, SlotOut, State, _, _) ->
  {Proposals, Reqs, SlotOut, State};
decide([{SO, C2} | T], Proposals, Reqs, SlotOut, State, Decisions, Database) ->
  case isMemberOf(SO, Proposals) of
  %case lists:member(SO, [ SO2 || {SO2 , _} <- Proposals ]) of
    true ->
      {SO2, C3} = lists:last([ {_SO2, _C3} || {_SO2, _C3} <- Proposals, SO == _SO2 ]),
      Proposals2 = Proposals -- [{SO2, C3}],
      if C2 /= C3 ->
        Reqs2 = Reqs ++ [C3],
        perform(C2, T, Proposals2, Reqs2, SlotOut, State, Decisions, Database);
      true ->
        perform(C2, T, Proposals2, Reqs, SlotOut, State, Decisions, Database)
      end;
    false ->
      perform(C2, T, Proposals, Reqs, SlotOut, State, Decisions, Database)
  end.
  
perform({K, Cid, Op}, T, Proposals, Reqs, SlotOut, State, Decisions, Database) ->
  Cond = [ {S, {K2, Cid2, Op2}} || {S,{K2, Cid2, Op2}} <- Decisions, S < SlotOut, K == K2, Cid == Cid2, Op == Op2],
  if Cond /= [] ->
    SlotOut2 = SlotOut + 1,
    decide(T, Proposals, Reqs, SlotOut2, State, Decisions, Database);
  true ->
    if erlang:element(1, Op) == move ->
      State2 = State + 1,
      SlotOut2 = SlotOut + 1,
      io:format("Decisions: ~p~n", [Decisions]),
      io:format("Executing.. Op: ~p~n", [Op]),
      Database ! {execute, Op},
      K ! {response, Cid, ok},
      decide(T, Proposals, Reqs, SlotOut2, State2, Decisions, Database);
    true ->
      decide(T, Proposals, Reqs, SlotOut, State, Decisions, Database)
    end
  end.

isMemberOf(Query, TupleList) ->
  lists:member(Query, [ S || {S, _} <- TupleList]).



