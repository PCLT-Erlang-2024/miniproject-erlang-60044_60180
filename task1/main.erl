-module(main).
-export([start/0]).

start() ->
    Truck1 = truck:start(100),
    Truck2 = truck:start(100),
    % Truck3 = truck:start(25),
    % Truck4 = truck:start(10),
    % Truck5 = truck:start(30),
    % Truck6 = truck:start(20),

    Conveyor1 = conveyor:start(Truck1, 1, 100),
    Conveyor2 = conveyor:start(Truck2, 2, 100),
    % Conveyor3 = conveyor:start(Truck3),
    % Conveyor4 = conveyor:start(Truck4),
    % Conveyor5 = conveyor:start(Truck5),
    % Conveyor6 = conveyor:start(Truck6),

    factory:start([Conveyor1, Conveyor2]),

    io:format("System started!~n").