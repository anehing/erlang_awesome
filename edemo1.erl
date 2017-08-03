%%%------------------------------------------------------------------- 
%%% @author Ahan 
%%% @copyright (C) 2014,  
%%% @doc 
%%% 
%%% @end 
%%%------------------------------------------------------------------- 
-module(edemo1). 
-author("Ahan"). 
 
%% API 
-export([start/2]). 
 
%%-------------------------------------------------------------------- 
%% 这个程序会启动3个进程：A、B和C。然后会把A链接到B,把B链接到C。这样A可以监视来自B的退出信号并且捕获它们。当Bool为true， 
%% 同时当C消亡的原因是M时，B也可以捕获退出信号。 
%%-------------------------------------------------------------------- 
start(Bool, M) -> 
  A = spawn(fun() -> a() end), 
  B = spawn(fun() -> b(A, Bool) end), 
  C = spawn(fun() -> c(B, M) end), 
  %% sleep的作用是当C消亡时，在检查3个进程的状态前，可以让进程把收到的消息打印出来，正式场合应该用显式的同步 
  sleep(2000), 
  status(a, A), 
  status(b, B), 
  status(c, C). 
   
a() -> 
  process_flag(trap_exit, true), 
  wait(a). 
   
b(A, Bool) -> 
  process_flag(trap_exit, Bool), 
  link(A), 
  wait(b). 
   
c(B, M) -> 
  link(B), 
  case M of 
    {die, Reason} -> 
    exit(Reason); 
  {divide, N} -> 
    1 / N, 
    wait(c); 
  normal -> 
    true 
  end. 
   
wait(Prog) -> 
  receive 
    Any -> 
    io:format("process ~p received ~p~n", [Prog, Any]), 
    wait(Prog) 
  end. 
 
sleep(T) -> 
  receive 
  after T -> true 
  end. 
   
status(Name, Pid) -> 
  case erlang:is_process_alive(Pid) of 
    true -> 
    io:format("process ~p(~p) is alive~n", [Name, Pid]); 
  false -> 
    io:format("process ~p(~p) is dead~n", [Name, Pid]) 
  end. 