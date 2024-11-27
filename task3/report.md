# Task 3 Report

In order to wait for trucks to exchange we add a 'sleep' after creating a truck, to allow the thread to start, but we halt the conveyor before starting interacting with the new truck.

This way we can guarantee that the conveyor will not be feeding packages to a truck that is being replaced, assuming that starting a Truck will take less time than the 'sleep'.