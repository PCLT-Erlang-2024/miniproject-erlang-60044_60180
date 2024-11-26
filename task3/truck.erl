-module(truck).
-export([start/1, loop/2]).

start(Capacity) ->
    spawn(truck, loop, [Capacity, []]).

loop(Capacity, LoadedPackages) ->
    receive
        {deliver, Package, Conveyor} ->
            Size = element(1, Package),
            case Capacity >= Size of
                true ->
                    NewCapacity = Capacity - Size,
                    io:format("Truck loaded package: ~p, Remaining capacity: ~p~n", [Size, NewCapacity]),
                    loop(NewCapacity, [Package | LoadedPackages]);
                false ->
                    io:format("Truck is full, requesting replacement...~n"),
                    Conveyor ! {truck_full},
                    exit(self(), normal)
            end;
        {conveyor_terminated} ->
            io:format("Truck ~p leaving~n", [self()]),
            ok
    end.