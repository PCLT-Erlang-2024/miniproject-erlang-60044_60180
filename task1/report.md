# Task 1 Report

In our implementation, we've created three different modules, each one representing each part of the system (factory, conveyor and truck).

The factory is responsible for sending the packages to the conveyors concurrently. This is done with the use of processes. The factory has a limit of packages to send to the conveyors. When that limit is reached, the process ends and notifies the conveyors that it will not be sending any more packages. When sending a package to some conveyor, it sends a message to check the conveyor's capacity. If the conveyor is full, it retries to send the package until the conveyor has capacity to receive it.

The conveyor receives packages from the factory and sends them to the trucks. Each conveyor has a capacity. When loading a truck, if the truck has no more capacity, the conveyor simulates the switching of trucks, where is created a new truck to be filled with packages. If the factory notifies if the package production has terminated, the conveyor will send the rest of the packages present in the queue (the process_remaining function). After that, the conveyor process is terminated.

The truck also has a capacity. Until the truck isn't full, the conveyor keeps sending packages to the truck. After reaching full capacity and the conveyos tries to send more packages, the truck notifies the conveyor that it is full and the truck switching process starts in the conveyor. If notified about the conveyor process termination, the truck process will also terminate.

With this structure we guarantee an expected behaviour and flow of the system: a package being created by the factory, then sended through a conveyor belt to a truck. We also guarantee that all the created packages are delivered to a truck before the system ends.