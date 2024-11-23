-module(conveyor).

-export([start/3, process_packages/4]).

%% Falta colocar size no conveyor
start(Truck, Id, Capacity) ->
    spawn(conveyor, process_packages, [Truck, [], Id, Capacity]).

process_packages(Truck, Queue, Id, Capacity) ->
    receive
        {factory_delivery, Package} ->
            io:format("Conveyor ~p received package: ~p~n", [Id, Package]),
            process_packages(Truck, Queue ++ [Package], Id, Capacity);
        {load_to_truck} ->
            case Queue of
                [Package | Rest] ->
                    Truck ! {deliver, Package},
                    io:format("Conveyor ~p sent package ~p to truck~n", [Id, Package]),
                    process_packages(Truck, Rest, Id, Capacity);
                [] ->
                    io:format("Conveyor ~p has no packages to load~n", [Id]),
                    process_packages(Truck, Queue, Id, Capacity)
            end;
        {check_capacity, Factory} ->
            res = length(Queue) < Capacity,
            Factory ! {capacity_status, res},
            process_packages(Truck, Queue, Id, Capacity);
        {truck_full} ->
            io:format("Truck full, waiting for replacement~n"),
            timer:sleep(2000),
            process_packages(Truck, Queue, Id, Capacity)
    after 1000 ->
        self() ! {load_to_truck},
        process_packages(Truck, Queue, Id, Capacity)
    end.
