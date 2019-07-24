
# Compatibility Tests

The SIL is designed to be compatible with the ECI and the tests in this directory are designed to demonstrate that is true within a CI pipeline.

## Test Requirements

These tests require the generation of code and so depend upon the following licenses being available in your development environment:

* Matlab
* Simulink
* Embedded Coder

Because of the difficulties of setting up an instance of Matlab in a CI environment, this test depends upon the developer generating code locally after they've made their changes and committing the generated code with their changes (which will then be used in the CI pipeline).

## Test Outline

In order to demonstrate compatibility with the ECI, code is generated from a sample model, integrated with the ECI, and run in a CFS environment. 

## Running the test

1. Open Matlab and run the following:
```
cd <SIL_repo_root>\tests\eci\models
genCode
```
1. Commit the modified generateCode.zip and push to github.
1. Monitor the results of the Travis pipeline to verify code is compatible with ECI

### Limitations

Currently, errors are only detected if they occur during the compilation process. Errors in the initialization of the CFS must be identified manually.