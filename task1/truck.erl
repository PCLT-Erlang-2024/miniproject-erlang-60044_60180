-module(truck).
-export([start/1, loop/2]).

start(Capacity) ->
    spawn(truck, loop, [Capacity, []]).

loop(Capacity, LoadedPackages) ->
    receive
        {deliver, Package} ->
            io:format("Truck received package: ~p~n", [Package]),
            Size = element(1, Package),
            case Capacity >= Size of
                true ->
                    NewCapacity = Capacity - Size,
                    io:format("Truck loaded package: ~p, Remaining capacity: ~p~n", [Package, NewCapacity]),
                    loop(NewCapacity, [Package | LoadedPackages]);
                false ->
                    io:format("Truck is full, requesting replacement...~n"),
                    R = whereis(conveyor),
                    io:format("R: ~p~n", [R]),
                    whereis(conveyor) ! {truck_full},
                    %exit(self(), normal)
                    loop(Capacity, [])
            end
    end.