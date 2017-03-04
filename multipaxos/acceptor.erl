%%% Chu Lee (cyl113) an d Royson Lee (dsl114)

-module(acceptor).
-export([start/0]).

start() ->
  next(0, []).

next(Ballot_num, Accepted) ->
  receive
    {p1a, Sc, B} ->
      if B > Ballot_num ->
        Ballot_num2 = B;
      true ->
        Ballot_num2 = Ballot_num
      end,
      Sc ! {p1b, self(), Ballot_num2, Accepted},
      next(Ballot_num2, Accepted);
    {p2a, Co, {B, S, C}} ->
      if B == Ballot_num ->
        Accepted2 = [{B, S, C}] ++ Accepted;
      true ->
        Accepted2 = Accepted
      end,
      Co ! {p2b, self(), Ballot_num},
      next(Ballot_num, Accepted2)
  end.