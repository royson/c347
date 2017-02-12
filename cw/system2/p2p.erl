%%% Chu Lee (cyl113) and Royson Lee (dsl114)

-module(p2p).
-export([start/1]).

start(AppID) ->
	receive
		{bind, PLS} ->
		Map = initializeMap(PLS, maps:new()),
		next(AppID, Map)
	end.

next(AppID, Map) ->
	receive
		{pl_deliver, task1, start, Max_messages, Timeout} ->
			AppID ! {pl_deliver, task1, start, Max_messages, Timeout};
		{pl_send, ProcessID, msg} ->
			[ PL ! {pl_deliver, ProcessID, msg} || PL <- maps:values(Map)];
		{pl_deliver, Pid, msg} ->
			AppID ! {pl_deliver, Pid, msg}
	end.

initializeMap([], Map) ->
	Map;
initializeMap([{Process, PL}|O], Map) ->
	NMap = maps:put(Process, PL, Map),
	initializeMap(O, NMap).
