-module(area_server).
-behaviour(gen_server).

-export([area/1, start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

area(Thing) ->
    gen_server:call(?MODULE, {area, Thing}).

init([]) ->
    process_flag(trap_exit, true),
    io:format("~p starting ~n", [?MODULE]),
    {ok, 0}.

handle_call({area, Thing}, _From, N) ->
    {reply, compute_area(Thing), N+1}.

handle_cast(_Msg, N) -> {noreply, N}.

handle_info(_Info, N) -> {noreply, N}.

terminate(_Reason, _N) ->
    io:format("~p stopping ~n", [?MODULE]),
    ok.

code_change(_OldVsn, N, _Extra) ->
    {ok, N}.

compute_area({square, X})       -> X*X;
compute_area({rectangle, X, Y}) -> X*Y.
