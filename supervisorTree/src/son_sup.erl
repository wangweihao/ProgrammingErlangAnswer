-module(son_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, son_sup}, ?MODULE, []).

init([]) ->
    {ok, { {simple_one_for_one, 5, 10},
            [
             {
              grandson_work, {grandson_work, start_link, []},
              permanent,
              brutal_kill,
              worker,
              [grandson_work]
             }
            ]
         } }.
