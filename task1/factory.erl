-module(factory).
-export([start/0]).

start() -> 
    F = ( fun () ->
        io:format("hello from process ~p", [self()])
    end
    ),
    spawn(F).