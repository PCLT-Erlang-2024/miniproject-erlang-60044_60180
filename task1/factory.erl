-module(factory).
-export([start/1, sendPackages/2]).

start(Conveyors) ->
    lists:foreach(fun(Conveyor) ->
        spawn(factory, sendPackages, [Conveyor, 1])
    end, Conveyors).
    

sendPackages(Conveyor, Counter) ->
    Package = {20, Counter},
    Conveyor ! {factory_delivery, Package},
    io:format("factory sent package ~p to conveyor ~p~n", [Package, Conveyor]),
    timer:sleep(1000),
    sendPackages(Conveyor, Counter + 1).
    