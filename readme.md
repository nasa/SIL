# Overview

The Simulink Interface Layer (SIL) is an extention of the Simulink Coder generation tool which allows it to generate code which is compatible with the cFS ECI (External Code Interface). The ECI is a software abstraction layer which allows the interfacing of task/mission-specific code generated from Simulink (or other sources) to the Core Flight System (cFS) via a generic set of wrapper code. The SIL and ECI combined enables direct integration of code from the Simulink autocoding pipeline into the cFS without the need for interface code and allows access to cFS API's including table services, time services, the software bus, event services, and fault reporting. 

The SIL accomplishes this by extending Simulink's code generation pipeline to produce a description of the model's interfaces which is utilized by generic wrapper code to initialize the model and the appropriate cFS interfaces. The SIL simplifies the integration of code as a CFS application and eliminates the need for hand edits to generated code, allowing quicker integration of code and reducing the probability of human error in the integration process.

# Getting Started

The SIL is intended to be compatible with Matlab/Simulink 2017b and above on all Matlab-supported platforms. 

Usage of the SIL requires the following Matlab Toolboxes:

- Simulink
- Embedded Coder
- Simulink Coder
- Matlab Coder

Please see the Simulink integration guide (located in the [doc](doc/) directory) for specific instructions on generating and integrating SIL-compatible code.

# Testing

The SIL has been used with 2017b and 2018b and is currently tested with 2018b on Windows and Ubuntu. There are no known incompatibilities with supported versions or platforms, but they are not actively tested. 

# Feedback

Please submit bug reports and feature requests via Github issues. Feature requests will be considered as they align with the requirements of NASA missions which are using the SIL and to the extent that they minimize deviation from standard Matlab/Simulink analysis/development workflows and features.