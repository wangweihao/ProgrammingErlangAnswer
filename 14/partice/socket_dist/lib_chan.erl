%% ----------------------------------------------------------------------
%% 主模块
%% ----------------------------------------------------------------------



-module(lib_chan).
-export([cast/2, start_server/0, start_server/1,
         connect/5, disconnect/1, rpc/2]).
-import(lists, [map/2, member/2, foreach/2]).
-import(lib_chan_mm, [send/2, close/1]).

%%-----------------------------------------------------------------------
%% 服务器代码


%% os:getenv 获得环境变量，组装成配置文件的默认路径
start_server() ->
    case os:getenv("HOME") of
        false ->
            exit({ebanEnv, "HOME"});
        Home  -> 
            start_server(Home ++ "/.erlang_config/lib_chan.conf")
    end.


%% 若直接指明配置文件的路径，file:consult 读取配置文件
%% 接着提取出需要的信息 ConfigData，类型为 list
%% check_term 过滤并检测 ConfigData，若正确则传递给 start_server1
%% 错误则退出
start_server(ConfigFile) ->
    io:format("lib_chan starting:~p~n", [ConfigFile]),
    case file:consult(ConfigFile) of
        {ok, ConfigData} ->
            io:format("ConfigData=~p~n", [ConfigData]),
            case check_terms(ConfigData) of
                [] ->
                    start_server1(ConfigData);
                Errors ->
                    exit({eDaemonConfig, Errors})
            end;
        {error, Why} ->
            exit({eDaemonConfig, Why})
    end.

%% 过滤并检测配置文件
%% check_terms() -> [Error]
check_terms(ConfigData) ->
    L = map(fun check_term/1, ConfigData),
    [X || {error, X} <- L].
check_term({port, P}) when is_integer(P)     -> ok;
check_term({service, _, password, _, mfa, _, _, _})   ->ok;
check_term(X) -> {error, {badTerm, X}}.


%% start_server1 启动一个新的进程执行 start_server2，并且注册名字为 lib_chan
start_server1(ConfigData) ->
    register(lib_chan, spawn(fun() -> start_server2(ConfigData) end)).

%% 从 ConfigData 里提取出 Port端口，传递给 start_port_server
start_server2(ConfigData) ->
    [Port] = [P || {port, P} <- ConfigData],
    start_port_server(Port, ConfigData).

%% 启动 start_raw_server，start_raw_server 启动一个监视器来监听 Port 上的连接
%% fun(Socket) 会在连接开始时执行
start_port_server(Port, ConfigData) ->
    lib_chan_cs:start_raw_server(Port,
                                fun(Socket) ->
                                        start_port_instance(Socket, ConfigData) end,
                                100,
                                4).


start_port_instance(Socket, ConfigData) ->
    %% 这是处理底层连接的位置
    %% 但首先要分裂出一个连接处理进程，必须成为中间人
    
    % 获得当前进程的 Pid
    S = self(),
    % 成为中间人 Pid = S，并和新创建的进程连接
    % 创建进程处理连接 Pid = Controller。
    Controller = spawn_link(fun() -> start_erl_port_server(S, ConfigData) end),
    % loop 负责编码和解码，接受 Controller 发来的消息。
    % 注意 Erlang 的思想是这样的，如果我要给你发消息，消息内容中就会包含我的信息（Pid），
    % 否则没办法知道消息是谁发送的，并且回复给谁。
    lib_chan_mm:loop(Socket, Controller).

%% MM 就是上面的 S 中间人
%% 接受 MM 发来的请求，并且获取服务器 Mod，ArgC 等信息。
%% 获取信息后，回复 MM ok 表示收到，配合 config 文件里的内容执行函数调用，提供服务。
%% really_start 函数是真正执行功能调用的函数。也就是服务器提供给客户端的服务
start_erl_port_server(MM, ConfigData) ->
    receive 
        {chan, MM, {startService, Mod, ArgC}} ->
            % 接受到中间人 MM 发来的消息后判断是否认证
            case get_service_definition(Mod, ConfigData) of
                {yes, Pwd, MFA} ->
                    case Pwd of
                        none -> 
                            send(MM, ack),
                            % 提取配置信息，通过 MFA 提供服务（执行其中的函数）。
                            really_start(MM, ArgC, MFA);
                        _ ->
                            % 若未认证，则执行认证
                            do_authentication(Pwd, MM, ArgC, MFA)
                    end;
                no -> 
                    io:format("sending bad service~n"),
                    send(MM, badService),
                    close(MM)
            end;
        Any ->
            io:format("*** Erl port server got:~p ~p~n", [MM, Any]),
            exit({protocolViolation, Any})
    end.

%% 进行身份认证，认证成功进行调用，失败则退出关闭
do_authentication(Pwd, MM, ArgC, MFA) ->
    C = lib_chan_auth:make_challenge(),
    send(MM, {challenge, C}),
    receive
        {chan, MM, {response, R}} ->
            case lib_chan_auth:is_response_correct(C, R, Pwd) of
                true ->
                    send(MM, ack),
                    really_start(MM, ArgC, MFA);
                false ->
                    send(MM, authFail),
                    close(MM)
            end
    end.


%% really_start 是真正的执行服务器上的功能函数
%% MM是中间人，功能执行完毕后得到结果然后发送给中间人
%% Mod是我们想要执行的模块。ArgC和ArgS分别来自客户端和服务器

really_start(MM, ArgC, {Mod, Func, ArgS}) ->
    %% 认证成功，现在开始工作
    case (catch apply(Mod, Func, [MM, ArgC, ArgS])) of
        {'EXIT', normal} ->
            true;
        {'EXIT', Why} ->
            io:format("server error:~p~n", [Why]);
        Why ->
            io:format("server error should dir with exit(normal) was:~p~n", 
                     [Why])
    end.

%% get_service_definition(Name, ConfigData)
%% 获得服务器的配置，包括模块，调用函数及参数。
get_service_definition(Mod, [{service, Mod, password, Pwd, mfa, M, F, A}|_]) ->
    {yes, Pwd, {M, F, A}};
get_service_definition(Name, [_|T]) ->
    get_service_definition(Name, T);
get_service_definition(_, []) ->
    no.

%% --------------------------------------
%% 客户端连接代码
%% connect(...) -> [ok, MM] | Error

%% 客户端连接代码。
%% 连接后获得 Socket，接着进行认证
%% 从下面 rpc 函数代码可以看出客户端没有直接进行 Socket 通信，而是将消息发送给了中间人 MM，中间人 MM 将消息进行编码等，发送给服务器。服务器那边也通过中间人进行接收，接收后进行解码然后发送给服务器。
connect(Host, Port, Service, Secret, ArgC) ->
    S = self(),
    MM = spawn(fun() -> connect(S, Host, Port) end),
    receive
        {MM, ok} ->
            case authenticate(MM, Service, Secret, ArgC) of
                ok    -> {ok, MM};
                Error -> Error
            end;
        {MM, Error} ->
            Error
    end.

%% 客户端连接，连接成功进入 loop 循环，等待消息。
connect(Parent, Host, Port) ->
    case lib_chan_cs:start_raw_client(Host, Port, 4) of
        {ok, Socket} ->
            Parent ! {self(), ok},
            lib_chan_mm:loop(Socket, Parent);
        Error ->
            Parent ! {self(), Error}
    end.


%% 双方进行认证
authenticate(MM, Service, Secret, ArgC) ->
    send(MM, {startService, Service, ArgC}),
    %% 应该会接收到质询、ack或者套接字已关闭的消息
    receive
        {chan, MM, ack} ->
            ok;
        {chan, MM, {challenge, C}} ->
            R = lib_chan_auth:make_response(C, Secret),
            send(MM, {response, R}),
            receive
                {chan, MM, ack} ->
                    ok;
                {chan, MM, authFail} ->
                    wait_close(MM),
                    {error, authFail};
                Other ->
                    {error, Other}
            end;
        {chan, MM, badService} ->
            wait_close(MM),
            {error, badService};
        Other ->
            {error, Other}
    end.

%% 关闭
wait_close(MM) ->
    receive
        {chan_closed, MM} ->
            true
    after 5000 ->
              io:format("**error lib_chan~n"),
              true
    end.

disconnect(MM) -> close(MM).

%% 客户端调用，用来发送请求
rpc(MM, Q) ->
    send(MM, Q),
    receive
        {chan, MM, Reply} ->
            Reply
    end.

cast(MM, Q) ->
    send(MM, Q).































