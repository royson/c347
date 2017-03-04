%%% Chu Lee (cyl113) an d Royson Lee (dsl114)

-module(scout).
-export([start/3]).

start(Leader, Acceptors, B) ->
  next(Leader, Acceptors, B, Acceptors, []).

next(Leader, Acceptors, B, WaitFor, PValues) ->
  [ A ! {p1a, self(), B} || A <- Acceptors],
  receive
    {p1b, Acc, Bacc, R} ->
      if B == Bacc ->
        PValues2 = PValues ++ R,
        WaitFor2 = WaitFor -- [Acc],
        if length(WaitFor2) < length(Acceptors)/2 ->
          Leader ! {adopted, B, PValues2},
          exit(ok);
        true -> ok
        end,
        next(Leader, Acceptors, B, WaitFor2, PValues2);
      true ->
        Leader ! {preempted, Bacc},
        exit(ok)
      end
  end.
