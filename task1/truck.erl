-module(truck).
-export([start/1, loop/2]).

start(Capacity) ->
    spawn(truck, loop, [Capacity, []]).

loop(Capacity, LoadedPackages) ->
    receive
        {deliver, Package} ->
            Size = element(1, Package),
            case Capacity >= Size of
                true ->
                    NewCapacity = Capacity - Size,
                    io:format("Truck loaded package: ~p, Remaining capacity: ~p~n", [Package, NewCapacity]),
                    loop(NewCapacity, [Package | LoadedPackages]);
                false ->
                    io:format("Truck is full, requesting replacement...~n"),
                    whereis(conveyor) ! {truck_full},
                    exit(self(), normal)
            end
    end.