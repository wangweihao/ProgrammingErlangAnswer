-module(job_centre).

-behaviour(gen_server).
-export([start/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
        terminate/2, code_change/3]).

-compile(export_all).
-define(SERVER, ?MODULE).


start() -> 
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []),
           true.

add_job(F) ->
    gen_server:call(?MODULE, {add, F}).

work_wanted() ->
    case gen_server:call(?MODULE, {want_work}) of
        {QueueSize, _Queue} -> 
            job_done(QueueSize);
        {stop, Str, _Queue} ->
            io:format("已经没有任务啦~n  ~p", [Str])
    end.

job_done(JobNumber) ->
    io:format("我完成了任务!!~n"),
    {JobNumber}.

statistic() ->
    gen_server:call(?MODULE, {queue_info}).

init([]) -> 
    {ok, []}.

handle_call({add, Task}, _From, TaskQueue) ->
    NewTaskQueue = [Task | TaskQueue],
    {reply, erlang:length(NewTaskQueue), NewTaskQueue};

handle_call({want_work}, _From, []) ->
    io:format("queue is empty~n"),
    {reply, "queue is empty", []};
handle_call({want_work}, _From, TaskQueue) ->
    io:format("queue   ~p~n", [TaskQueue]),
    io:format("queue   ~p~n", [erlang:length(TaskQueue)]),
    Reply = case erlang:length(TaskQueue) of
                QueueSize when QueueSize > 2 ->
                    [Task | Queue] = TaskQueue,
                    spawn(fun() -> Task() end),
                    {QueueSize-1, Queue};
                QueueSize when QueueSize =:= 2 ->
                    [Task | Queue] = TaskQueue,
                    spawn(fun() -> Task() end),
                    {QueueSize-1, [Queue]};
                QueueSize when QueueSize =:= 1 ->
                    [Queue] = TaskQueue,
                    spawn(fun() -> Queue() end),
                    {QueueSize-1, []}
            end,
    {reply, Reply, Queue};

handle_call({queue_info}, _From, TaskQueue) ->
    {reply, erlang:length(TaskQueue), TaskQueue};

handle_call({stop}, _From, TaskQueue) ->
    {stop, normal, stopped, TaskQueue}.
handle_cast(_Msg, State) ->
    {noreply, State}.
handle_info(_Info, State) ->
    {noreply, State}.
terminate(_Reason, _State) ->
    ok.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
