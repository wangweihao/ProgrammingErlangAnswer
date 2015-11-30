%% 这是应用程序资源文件(.app文件)，
%% 它用于'base' 应用程序

{application, sellaprime,
[{description, "The prime Number Shop"},
 {vsn, "1.0"},
 {modules, [sellaprime_app, sellaprime_supervisor, area_server,
            prime_server, lib_lin, lib_primes, my_alarm_handler]},
 {registered, [area_server, prime_server, sellaprime_super]},
 {applications, [kernel, stdlib]},
 {mod, {sellaprime_app, []}},
 {start_phases, []}
]}.
