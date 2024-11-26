-module(factory).
-export([start/2, sendPackages/3]).

start(Conveyors, PackagesPerConveyor) ->
    lists:foreach(fun(Conveyor) ->
        spawn(factory, sendPackages, [Conveyor, 1, PackagesPerConveyor])
    end, Conveyors).

sendPackages(Conveyor, Counter, Packages_limit) ->
    if
        Counter > Packages_limit ->
            io:format("Factory has reached the package limit: ~p packages sent~n", [Packages_limit]),
            Conveyor ! {factory_terminated},
            ok;
        true ->
            Conveyor ! {check_capacity, self()},
            receive
                {capacity_status, true} ->
                    Package = {20, Counter},
                    Conveyor ! {factory_delivery, Package},
                    io:format("Factory sent package ~p to conveyor ~p~n", [Package, Conveyor]),
                    timer:sleep(1000),
                    sendPackages(Conveyor, Counter + 1, Packages_limit);

                {capacity_status, false} ->
                    io:format("Conveyor ~p is full, waiting for capacity to be available~n", [Conveyor]),
                    timer:sleep(1000),
                    sendPackages(Conveyor, Counter, Packages_limit)
            after 1000 ->
                io:format("Conveyor ~p timed out, assuming it is full~n", [Conveyor]),
                sendPackages(Conveyor, Counter, Packages_limit)
            end
    end.