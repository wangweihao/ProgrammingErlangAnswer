%% 负责编码和解码消息
%% 发送和接收消息都要通过中间人进行编码和解码

-module(lib_chan_mm).

-export([loop/2, send/2, close/1, controller/2, set_trace/2, trace_with_tag/2]).

send(Pid, Term)          -> Pid ! {send, Term}.
close(Pid)               -> Pid ! close.
controller(Pid, Pid1)    -> Pid ! {setController, Pid1}.
set_trace(Pid, X)        -> Pid ! {trace, X}.
trace_with_tag(Pid, Tag) -> 
    set_trace(Pid, {true,
                    fun(Msg) ->
                            io:format("MM:~p ~p~n", [Tag, Msg])
                    end}).

%% 设置为系统进程后进入 loop()。
loop(Socket, Pid) ->
    process_flag(trap_exit, true),
    loop1(Socket, Pid, false).


%% loop 是套接字 Socket 和 Erlang 中消息传递的桥梁。
%% 中间人执行 loop 接受消息后进行编码/解码，然后传递给对应的服务器或客户端。
loop1(Socket, Pid, Trace) ->
    receive
        {tcp, Socket, Bin} ->
            Term = binary_to_term(Bin),
            trace_it(Trace, {socketReceived, Term}),
            Pid ! {chan, self(), Term},
            loop1(Socket, Pid, Trace);
        {tcp_closed, Socket} ->
            trace_it(Trace, socketClosed),
            Pid ! {chan_closed, self()};
        {'EXIT', Pid, Why} ->
            trace_it(Trace, {controllingProcessExit, Why}),
            gen_tcp:close(Socket);
        {setController, Pid1} ->
            trace_it(Trace, {changedController, Pid}),
            loop1(Socket, Pid1, Trace);
        {trace, Trace1} ->
            trace_it(Trace, {setTrace, Trace1}),
            loop1(Socket, Pid, Trace1);
        close ->
            trace_it(Trace, closedByClient),
            gen_tcp:close(Socket);
        {send, Term} ->
            trace_it(Trace, {sendingMessage, Term}),
            gen_tcp:send(Socket, term_to_binary(Term)),
            loop1(Socket, Pid, Trace);
        UUg ->
            io:format("lib_chan_mm:protocol error:~p~n", [UUg]),
            loop1(Socket, Pid, Trace)
    end.

trace_it(false, _)        -> void;
trace_it({true, F}, M) -> F(M). 
