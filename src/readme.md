
# SIL Source Code

This directory contains the source code for the SIL. 

## Setup

This directory must be on the Matlab path while using the SIL. The sfunctions supporting the SIL library blocks must also be compiled before use, which can be done by calling
```
compileSilSfcn()
```
found in the `util/`.

## Organization 

The [+cfsPackage](+cfsPackage/) directory contains the definitions of the custom object types and storage classes that the SIL uses to identify the application interfaces.

The [mex](mex/) directory contains the sfunction implementations of the Simulink blocks provided as part of the SIL block library. It also contains the TLC files which generate the required custom code for each of these blocks. 

The [util](util/) directory contains an assortment of utility functions which are useful for setting up a simulation utilizing the SIL. See the function help for each utility for purpose and usage information.