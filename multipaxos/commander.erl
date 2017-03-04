%%% Chu Lee (cyl113) an d Royson Lee (dsl114)

-module(commander).
-export([start/4]).

start(Leader, Acceptors, Replicas, {B, S ,C}) ->
  next(Leader, Acceptors, Replicas, Acceptors, {B, S, C}).

next(Leader, Acceptors, Replicas, WaitFor, {B, S, C}) ->
  [ A ! {p2a, self(), {B, S, C}} || A <- Acceptors],
  receive
    {p2b, Acc, Bnum} ->
      if B == Bnum ->
        WaitFor2 = WaitFor -- [Acc],
        if length(WaitFor2) < length(Acceptors)/2 ->
          [ R ! {decision, S, C} || R <- Replicas ],
          exit(ok);
        true -> ok
        end,
        next(Leader, Acceptors, Replicas, WaitFor2, {B, S, C});
      true ->
        Leader ! {preempted, Bnum},
        exit(ok)
      end
  end.
