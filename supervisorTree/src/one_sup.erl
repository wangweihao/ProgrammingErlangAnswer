-module(one_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, { {one_for_one, 5, 10}, 
           [
            %% 子督程
            {son_sup, {son_sup, start_link, []},
             temporary,
             brutal_kill,
             supervisor,
             [son_sup]
            },
            %% 子拥程
            {son_work, {son_work, start_link, []},
             temporary,
             brutal_kill,
             worker,
             [son_work]
            },
            %% 子拥程
            {son_work2, {son_work, start_link, []},
             temporary,
             brutal_kill,
             worker,
             [son_work]
            }
           ]
         } }.

