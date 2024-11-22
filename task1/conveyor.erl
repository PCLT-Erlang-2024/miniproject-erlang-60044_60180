-module(conveyor).
-export([start/2, loop/3]).

start(Truck, Id) ->
    spawn(conveyor, loop, [Truck, [], Id]).

loop(Truck, Queue, Id) ->
    receive
        {factory_delivery, Package} ->
            io:format("Conveyor ~p received package: ~p~n", [Id, Package]),
            loop(Truck, Queue ++ [Package], Id);

        {load_to_truck} ->
            case Queue of
                [Package | Rest] ->
                    Truck ! {deliver, Package},
                    io:format("Conveyor ~p sent package ~p to truck~n", [Id, Package]),
                    loop(Truck, Rest, Id);
                [] ->
                    io:format("Conveyor ~p has no packages to load~n", [Id]),
                    loop(Truck, Queue, Id)
            end;

        {truck_full} ->
            io:format("Truck full, waiting for replacement~n"),
            timer:sleep(2000),
            loop(Truck, Queue, Id)
    after 1000 ->
        self() ! {load_to_truck},
        loop(Truck, Queue, Id)
    end.