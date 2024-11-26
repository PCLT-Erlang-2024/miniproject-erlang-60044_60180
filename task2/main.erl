-module(main).
-export([start/1]).

start(NumConveyors) ->

    Conveyors = create_conveyors(NumConveyors, []),

    factory:start(Conveyors, 5),

    io:format("System started!~n").

create_conveyors(0, Conveyors) ->
        lists:reverse(Conveyors);
create_conveyors(N, Conveyors) ->
        Conveyor = conveyor:start(200),  % Adjust the capacity as needed
        create_conveyors(N - 1, [Conveyor | Conveyors]).