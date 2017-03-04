%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(leader).
-export([start/2]).

start(Acceptors, Replicas) ->
  spawn(scout, start, [self(), Acceptors, {0, self()}]),
  next(Acceptors, Replicas, {0, self()}, false, []).

next(Acceptors, Replicas, {Bnum, Bself}, Active, Proposals) ->
  receive
    {propose, S, C} ->
      case lists:member({S, C}, Proposals) of
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
      {{_, _}, Shigh, Chigh} = lists:max(PVals),
      Proposals2 = [{Shigh, Chigh}] ++ [P || P <- Proposals, P /= {Shigh, Chigh}],
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