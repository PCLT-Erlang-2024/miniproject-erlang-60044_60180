-module(conveyor).

-export([start/2, process_packages/3, process_remaining/2]).

%% Falta colocar size no conveyor
start(Truck, Capacity) ->
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
                    Truck ! {deliver, Package, self()},
                    io:format("Conveyor ~p sent package ~p to truck~p~n", [self(), Package, Truck]),
                    process_packages(Truck, Rest, Capacity);
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
            timer:sleep(2000),
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
                timer:sleep(2000),
                io:format("Truck ~p replaced by Truck ~p~n", [Truck, NewTruck]),
                process_remaining(NewTruck, Queue);
    
            {load_to_truck} ->
                case Queue of
                    [Package | Rest] ->
                        Truck ! {deliver, Package, self()},
                        io:format("Conveyor ~p sent package ~p to truck~p~n", [self(), Package, Truck]),
                        process_remaining(Truck, Rest);
                    [] ->
                        io:format("Conveyor ~p has no packages to load~n", [self()]),
                        Truck ! {conveyor_terminated},
                        ok
                    end
            after 1000 ->
                self() ! {load_to_truck},
                process_remaining(Truck, Queue)
        end.