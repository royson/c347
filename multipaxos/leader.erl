%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(leader).
-export([start/0]).

start() ->
  receive
    {bind, Acceptors, Replicas} ->
    spawn(scout, start, [self(), Acceptors, {0, self()}]),
    next(Acceptors, Replicas, {0, self()}, false, [])
  end.

next(Acceptors, Replicas, {Bnum, Bself}, Active, Proposals) ->
  receive
    {propose, S, C} ->
      case lists:member(S, [ Sp || {Sp , _}<-Proposals ]) of
        false -> Proposals2 = Proposals ++ [{S, C}],
          if Active ->
            spawn(commander, start, [self(), Acceptors, Replicas, {{Bnum, Bself}, S, C}]);
            true -> ok
          end,
          next(Acceptors, Replicas, {Bnum, Bself}, Active, Proposals2);
        true ->
          next(Acceptors, Replicas, {Bnum, Bself}, Active, Proposals)
      end;
    {adopted, {Bnum, Bself}, PVals} ->
      %PVals = [{B,S,C}]
      %Update Proposals
      if PVals /= [] ->
        Slots = [ Slot || {{_, _}, Slot, _} <- PVals ],
        SlotMax = pmax(Slots, PVals, []),

        ProposalsSub = update(SlotMax, Proposals),
        Proposals2 = ProposalsSub ++ SlotMax;
      true ->
        Proposals2 = Proposals
      end,
      [spawn(commander, start, [self(), Acceptors, Replicas, {{Bnum, Bself}, S, C}]) || 
        {S, C} <- Proposals2],
      Active2 = true,
      next(Acceptors, Replicas, {Bnum, Bself}, Active2, Proposals2);
    {preempted, {R, V}} ->
      if {R, V} > {Bnum, Bself} ->
        Active2 = false,
        {Bnum2, Bself2} = {Bnum+1, Bself},
        spawn(scout, start, [self(), Acceptors, {Bnum2, Bself2}]),
        next(Acceptors, Replicas, {Bnum2, Bself2}, Active2, Proposals);
      true ->
        next(Acceptors, Replicas, {Bnum, Bself}, Active, Proposals)
      end
  end.

pmax([], _, SlotMax) ->
  SlotMax;
pmax([S | T], PVals, SlotsMax) ->
  PValsSub = [ {{Bip, Bis}, St, Ct} || {{Bip, Bis}, St, Ct} <- PVals, St == S ],
  {{_,_}, Shigh, Chigh} = lists:max(PValsSub),
  SlotsMax2 = SlotsMax ++ [{Shigh, Chigh}],
  pmax(T, PVals, SlotsMax2).

update([], Proposals) ->
  Proposals;
update([{S, _} | T], Proposals) ->
  Proposals2 = [ {Sp, Cp} || {Sp, Cp} <- Proposals, Sp /= S],
  update(T, Proposals2).


