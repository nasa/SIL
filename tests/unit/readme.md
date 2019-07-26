# SIL Test Suite

The test suite in this directory is designed to exercise the customizations provided by the SIL and ensure that they generate valid code.

## Overview

This test framework utilizes the Matlab unit test framework to implement a series of tests for the extra code generation functionality provided by the SIL. Each test is implemented as a matlab class which inherits from the cfetargettester package, which implements common utilities and validations for testing generated code.

Generally, each test utilizes a corresponding Simulink model (which is specified as a parameter of the test class) which exercises a feature of the SIL and for which code will be generated and validated. 

Some tests leverage stubbed C source and header files (to allow compilation) and auxiliary matlab data definitions and scripts/functions where needed.

Generally, each test consists of two phases... 

First the corresponding model is run in various simulation modes to verify that the SIL feature is compatible with typical Simulink usage scenarios. These are validated qualitatively... a successful simulation run with no warnings or errors is generally considered passing... the numerical output of the models is not assessed. 

Secondly, code is generated for the model and then validated. Generally validations focus on the contents of the eci_interface header that the SIL generates and ensuring that it contains the correct contents (via regex and string matching) and is compilable. Ocassionally tests may validate certain parts of the standard generated code where appropriate. 

## Running the tests

1. Ensure that the SIL's [`src`](../../src) directory is on your matlab path, so that the tests have access to the code.
1. Ensure that SIL sfunctions have been compiled. The utility function [`compileSilSfcn()`](../../src/util/compileSilSfcn.m) has been provided to do this.
1. Within this directory, run the command `runtests`

## Status

This test suite is a work in progress and not all SIL functionality is currently tested. Please review the [test plan](../doc/TestPlan.xlsx) for information on current test coverage.

These tests are currently run by hand on 2018b on Windows and Linux. The SIL is intended to be compatible with 2017b+ on all platforms.

