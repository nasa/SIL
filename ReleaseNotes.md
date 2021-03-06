# Simulink Interface Layer Release Notes

## Version 2.0.5 Jan 4 2019
- Refactored TLCs to conform to new ECI naming (file names, macros, 
  variable names all affected).
- Added test suite.
- Updated readme's and documentation.
- Renamed some library blocks to match intended use and fixed block masks 
  to properly display SIL labels.
- Various minor bugfixes.

## Version 2.0.4 Mar 12 2018
- Modified Conditional Message Block to examine only output port of the
  block to ensure either cfsTlmMessage or cfsCmdMessage custom storage
  classes are used for the output signal.  
- Improvements to Conditional Message block S-function error checking and 
  CSC TLC error checking for proper usage of CFS custom storage classes.
- Fixed intermittent MATLAB crash caused by improper string handling in 
  Conditional Message block S-function.
  
## Version 2.0.3 Mar 1 2018
- The Conditional Message block was refactored to prperly handle global
  memory required for reusable context.  Block TLC is also now made 
  compatible with class 2 custom storage classes required of the cfsPackage.
- The block TLC will now generate a warning if these are blocks are used
  in a Model Reference.  The warning explains that there will be no code
  generated in this context for the CFS tables.

## Version 2.0.2  Feb 22 2018
- Corrected instances where Parameter Table definitions were not being
  including the correct header files when more than one C definition file
  is used.
- Corrected CFS Target blocks so that block masks are treating numbers as 
  integers where necessary rather than double.  
- In SL_Events in csc_sl_interface.h, The case of the text for ID entry 
  was corrected.  
- The Event, FDC, and Conditional Message blocks now incorporate state
  data to create static storage that can be addressed in the various CFS
  tables regardless of the context of block instance (reusable, non-reusable).
- Various minor bugfixes.

## Version 2.0.1  Feb 12 2018

- Bugfixes and additions. 
- Refactored TLC implementation from version 1.13.1
  o Modularized and cleaned up dead TLC code.
  o Eliminated non-standard TLC API calls where possible.
- Added cfs_ert.tlc System Target
- Removed dependency on bus names for Message and Command Message 
  identification.
- Added +cfsPackage package to contain new Custom Storage Classes:
  o cfsMessage    - Used on a bus signal to designate a Message structure
                    to be generated in the csc_sl_interface.h file.  May be
                    used on input or output signals but must be signals 
                    routed directly to/from an external port.
  o cfsCmdMessage - Used on a bus signal to designate a Command Message
                    structure to be generated in the csc_sl_interface.h
                    file.  May only be used for input signals directly 
                    connected to an external input port.
  o cfsParmTable  - Used to designate a parameter structure that shall 
                    be placed into the CFE Parameter Table in 
                    csc_sl_interface.h.  May only be used on a 
                    cfsPackage.Parameter object.
- All blocks in the CFS_library are now implemented as S-functions.  The
  Message block mask now allows a user to set the number of inputs for data,
  whereas previous implementations had individual blocks for each possible
  number of parameters.


	
	
	
	
	


