-module(factory).
-export([start/1, sendPackages/2]).

start(Conveyors) ->
    lists:foreach(fun(Conveyor) ->
        spawn(factory, sendPackages, [Conveyor, 1])
    end, Conveyors).
    

sendPackages(Conveyor, Counter) ->
    Conveyor ! {check_capacity, self()},
    receive
      {capacity_status, true} ->
        Package = {20, Counter},
        Conveyor ! {factory_delivery, Package},
        io:format("Factory sent package ~p to conveyor ~p~n", [Package, Conveyor]),
        timer:sleep(1000),
        sendPackages(Conveyor, Counter + 1);

      {capacity_status, false} ->
        io:format("Conveyor ~p is full, waiting for capacity to be available~n", [Conveyor]),
        timer:sleep(1000),
        sendPackages(Conveyor, Counter)
    after 1000 ->
        io:format("Conveyor ~p timed out, assuming it is full~n", [Conveyor]),
        sendPackages(Conveyor, Counter)
    end.


   