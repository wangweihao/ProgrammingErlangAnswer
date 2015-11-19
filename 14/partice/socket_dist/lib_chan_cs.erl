-module(lib_chan_cs).
%% cs代表client_server
-export([start_raw_server/4, start_raw_client/3]).
-export([stop/1]).
-export([children/1]).

%% 建立客户端，发起连接
start_raw_client(Host, Port, PacketLength) ->
    gen_tcp:connect(Host, Port,
                   [binary, {active, true}, {packet, PacketLength}]).

%% 建立服务器，进行配置
start_raw_server(Port, Fun, Max, PacketLength) ->
    Name = port_name(Port),
    case whereis(Name) of
        undefined ->
            Self = self(),
            Pid = spawn_link(fun() ->
                                cold_start(Self, Port, Fun, Max, PacketLength)
                            end),
            receive 
                {Pid, ok} ->
                    register(Name, Pid),
                    {ok, self()};
                {Pid, Error} ->
                    Error
            end;
        _Pid ->
            {error, already_started}
    end.

stop(Port) when is_integer(Port) ->
    Name = port_name(Port),
    case whereis(Name) of
        undefined ->
            not_started;
        Pid ->
            exit(Pid, kill),
            (catch unregister(Name)),
            stopped
    end.

children(Port) when is_integer(Port) ->
    port_name(Port) ! {children, self()},
    receive
        {session_server, Reply} ->Reply
    end.

port_name(Port) when is_integer(Port) ->
    list_to_atom("portServer" ++ integer_to_list(Port)).

%% cold_start 做两件事情，
%% 一个是 start_accept，另一个是 socket_loop
%% start_accept 创建一个新进程去接受连接
cold_start(Master, Port, Fun, Max, PacketLength) ->
    process_flag(trap_exit, true),
    %% 现在我们准备好运行了
    %% 建立监听套接字
    case gen_tcp:listen(Port, [binary,
                               %% {dontroute, true},
                               {nodelay, true},
                               {packet, PacketLength},
                               {reuseaddr, true},
                               {active, true}]) of
        {ok, Listen} ->
            %% io:format("Listening to:~p~n", [Listen]),
            Master ! {self(), ok},
            New = start_accept(Listen, Fun),
            socket_loop(Listen, New, [], Fun, Max);
        Error ->
            Master ! {self(), Error}
    end.

%% socket_loop 是监听套接字的 loop，是服务器运行的 loop
%% 用来接受中间人发来的消息
socket_loop(Listen, New, Active, Fun, Max) ->
    receive 
        {istarted, New} ->
            Active1 = [New | Active],
            possibly_start_another(false, Listen, Active1, Fun, Max);
        {'EXIT', New, _Why} ->
            possibly_start_another(false, Listen, Active, Fun, Max);
        {'EXIT', Pid, _Why} ->
            Active1 = lists:delete(Pid, Active),
            possibly_start_another(New, Listen, Active1, Fun, Max);
        {children, From} ->
            From ! {session_server, Active},
            socket_loop(Listen, New, Active, Fun, Max);
        _Other ->
            socket_loop(Listen, New, Active, Fun, Max)
    end.


%% 判断连接是否达到最大限制
possibly_start_another(New, Listen, Active, Fun, Max) 
    when is_pid(New) ->
        socket_loop(Listen, New, Active, Fun, Max);
possibly_start_another(false, Listen, Active, Fun, Max) ->
    case length(Active) of
        N when N < Max ->
            New = start_accept(Listen, Fun),
            socket_loop(Listen, New, Active, Fun, Max);
        _ ->
            socket_loop(Listen, false, Active, Fun, Max)
    end.


%% 创建一个新进程去执行接收连接
start_accept(Listen, Fun) ->
    S = self(),
    spawn_link(fun() -> start_child(S, Listen, Fun) end).

%% 通过 Listen 监听套接字接受一个连接请求
%% Fun 为 lib_chan:start_port_instance
%% start_child 也为服务器建立中间人
%% start_child 将 Socket 传递给 lib_chan:start_port_instance 函数后，中间人通过获得的 Socket 进入 lib_chan_mm:loop 循环接受消息。
%% 注意：服务器和客户端只接受中间人的消息。
start_child(Parent, Listen, Fun) ->
    case gen_tcp:accept(Listen) of
        {ok, Socket} ->
            Parent ! {istarted, self()},
            inet:setopts(Socket, [{packet, 4},
                                 binary,
                                 {nodelay, true},
                                 {active, true}]),
            process_flag(trap_exit, true),
            case (catch Fun(Socket)) of
                {'EXIT', normal} ->
                    true;
                {'EXIT', Why} ->
                    io:format("Port process dies with exit:~p~n", [Why]),
                    true;
                _ ->
                    true
            end
    end.






