%%% Chu Lee (cyl113) and Royson Lee (dsl114)
%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} -> 
       next(Leaders, 1, 1, 1, sets:new(), sets:new(), sets:new(), Database)
  end.

next(Leaders, State, SlotIn, SlotOut, Reqs, Proposals, Decisions, Database) ->
  receive
    {request, C} ->      % request from client
      %Reqs2 = Reqs ++ [C],
      Reqs2 = sets:add_element(C, Reqs),
      Decisions2 = sets:to_list(Decisions),
      ReqsList = sets:to_list(Reqs2),
      ProposalsList = sets:to_list(Proposals),
      propose(Leaders, State, SlotIn, SlotOut, ReqsList, ProposalsList, Decisions2, Database);
    {decision, S, C} ->  % decision from commander
      DecisionsSet = sets:add_element({S,C}, Decisions),
      Decisions2 = sets:to_list(DecisionsSet),
      ReqsList = sets:to_list(Reqs),
      ProposalsList = sets:to_list(Proposals),
      {Proposals2, Reqs2, SlotOut2, State2} = decide (Decisions2, ProposalsList, ReqsList, SlotOut, State, Decisions2, Database),
      propose(Leaders, State2, SlotIn, SlotOut2, Reqs2, Proposals2, Decisions2, Database)
  end.

propose(Leaders, State, SlotIn, SlotOut, [], Proposals, Decisions, Database) ->
  DecisionsSet = sets:from_list(Decisions),
  ProposalsSet = sets:from_list(Proposals),
  ReqsSet = sets:from_list([]),
  next(Leaders, State, SlotIn, SlotOut, ReqsSet, ProposalsSet, DecisionsSet, Database);
propose(Leaders, State, SlotIn, SlotOut, [C | T], Proposals, Decisions, Database) ->
  WINDOW = 5,
  if SlotIn < SlotOut + WINDOW ->
    case isMemberOf(SlotIn, Decisions) of
    %case lists:member(SlotIn, [ SO || {SO, _} <- Decisions ]) of
      false ->
        %Proposals2 = Proposals ++ [{SlotIn, C}],
        ProposalsSet = sets:from_list(Proposals),
        ProposalsT = sets:add_element({SlotIn, C}, ProposalsSet),
        Proposals2 = sets:to_list(ProposalsT),
        [ L ! {propose, SlotIn, C} || L <- Leaders ],
        SlotIn2 = SlotIn + 1,
        propose(Leaders, State, SlotIn2, SlotOut, T, Proposals2, Decisions, Database);
      true -> 
        SlotIn2 = SlotIn + 1,
        propose(Leaders, State, SlotIn2, SlotOut, [C | T], Proposals, Decisions, Database)
    end;
  true -> 
    DecisionsSet = sets:from_list(Decisions),
    ProposalsSet = sets:from_list(Proposals),
    ReqsSet = sets:from_list([C | T]),
    next(Leaders, State, SlotIn, SlotOut, ReqsSet, ProposalsSet, DecisionsSet, Database)
  end.
  
   
decide([], Proposals, Reqs, SlotOut, State, _, _) ->
  {Proposals, Reqs, SlotOut, State};
decide([{SO, C2} | T], Proposals, Reqs, SlotOut, State, Decisions, Database) ->
  case isMemberOf(SO, Proposals) of
    true ->
      {SO2, C3} = lists:last([ {_SO2, _C3} || {_SO2, _C3} <- Proposals, SO == _SO2 ]),
      %Proposals2 = Proposals -- [{SO2, C3}],
      ProposalsSet = sets:from_list(Proposals),
      ProposalsT = sets:del_element({SO2, C3}, ProposalsSet),
      Proposals2 = sets:to_list(ProposalsT),
      if C2 /= C3 ->
        %Reqs2 = Reqs ++ [C3],
        ReqsSet = sets:from_list(Reqs),
        ReqsT = sets:add_element(C3, ReqsSet),
        Reqs2 = sets:to_list(ReqsT),
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



