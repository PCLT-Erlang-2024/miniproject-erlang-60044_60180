-module(conveyor).

-export([start/1, process_packages/3, process_remaining/2]).

%% Falta colocar size no conveyor
start(Capacity) ->
    Truck = truck:start(20),
    spawn(conveyor, process_packages, [Truck, [], Capacity]).

process_packages(Truck, Queue, Capacity) ->
    receive
        {factory_terminated} ->
            io:format("Factory terminated~n"),
            process_remaining(Truck, Queue),
            io:format("Conveyor ~p cleared all its packages~n", [self()]),
            ok;
        {factory_delivery, Package} ->
            io:format("Conveyor ~p received package: ~p~n", [self(), Package]),
            process_packages(Truck, Queue ++ [Package], Capacity);
        {load_to_truck} ->
            case Queue of
                [Package | Rest] ->
                    Size = element(1, Package),
                    if 
                        Size =< 5 ->
                            Truck ! {deliver, Package, self()},
                            io:format("Conveyor ~p sent remaining package ~p to truck~p~n", [self(), Package, Truck]),
                            process_packages(Truck, Rest, Capacity);
                        true ->
                            Rnd = rand:uniform(Size),
                            Remaining = Size - Rnd,
                            NewPackage = {Remaining, element(2, Package)},
                            Truck ! {deliver, {Rnd, element(2, Package)}, self()},
                            io:format("Conveyor ~p sent package ~p~n", [self(), {Rnd, element(2, Package)}]),
                            process_packages(Truck, [NewPackage | Rest], Capacity)
                    end;
                [] ->
                    io:format("Conveyor ~p has no packages to load~n", [self()]),
                    process_packages(Truck, Queue, Capacity)
            end;
        {check_capacity, Factory} ->
            Res = length(Queue) < Capacity,
            Factory ! {capacity_status, Res},
            process_packages(Truck, Queue, Capacity);
        {truck_full} ->
            io:format("Truck full, waiting for replacement~n"),
            NewTruck = truck:start(20),
            io:format("Truck ~p replaced by Truck~p~n", [Truck, NewTruck]),
            process_packages(NewTruck, Queue, Capacity)
    after 1000 ->
        self() ! {load_to_truck},
        process_packages(Truck, Queue, Capacity)
    end.

    process_remaining(Truck, Queue) ->
        receive
            {truck_full} ->
                io:format("Truck full while delivering remaining packages. Requesting replacement...~n"),
                NewTruck = truck:start(20),
                io:format("Truck ~p replaced by Truck ~p~n", [Truck, NewTruck]),
                process_remaining(NewTruck, Queue);
    
            {load_to_truck} ->
                case Queue of
                    [Package | Rest] ->
                        Size = element(1, Package),
                        if 
                            Size =< 5 ->
                                Truck ! {deliver, Package, self()},
                                io:format("Conveyor ~p sent remaining package ~p to truck~p~n", [self(), Package, Truck]),
                                process_remaining(Truck, Rest);
                            true ->
                                Rnd = rand:uniform(Size),
                                Remaining = Size - Rnd,
                                NewPackage = {Remaining, element(2, Package)},
                                Truck ! {deliver, {Rnd, element(2, Package)}, self()},
                                io:format("Conveyor ~p sent package ~p~n", [self(), {Rnd, element(2, Package)}]),
                                process_remaining(Truck, [NewPackage | Rest])
                        end;
                    [] ->
                        io:format("Conveyor ~p has no packages to load~n", [self()]),
                        Truck ! {conveyor_terminated},
                        ok
                    end
            after 1000 ->
                self() ! {load_to_truck},
                process_remaining(Truck, Queue)
        end.