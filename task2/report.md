In order to load truck in an uneven way, we load each conveyor belt with fixed size packages and, when loading each truck, we calculate a random number between 1 and the size of the head of the queue list that contains all fixed size packages.

This way, we guarantee that the trucks are loading with a random uniform distribution of packages.

One problem that we did not solve is when trucks capacity and factory packages have different sizes. In this case, it is possible that a package with value X is sent to a truck that only has a capacity of Y, where Y < X. In this case, the truck would load to its full capacity, but the rest of the package cargo (X-Y) would be lost. If the trucks' capacity equals the factory packages size, this problem does not occur.