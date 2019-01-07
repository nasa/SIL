/**
 * cfs_conditional_msg.c
 *
 * Description:
 *  This S-function implements the CFS Target Conditional Msg block
 *      This block serves to purpose during simulation.  Instead,
 *      DWork is used as persistent data that can be addressed
 *      in the CFS Message Table.  This is so that this block can
 *      be used in reusable subsystem configurations.
 */

/* Must specify the S_FUNCTION_NAME as the name of the S-function */
#define S_FUNCTION_NAME  cfs_conditional_msg
#define S_FUNCTION_LEVEL 2

/**
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define FLAG_IN_IDX        0
#define BUS_IN_IDX         1

#define MSGBUS_IDX 0
#define MSGBUS(S)       (ssGetSFcnParam(S,MSGBUS_IDX))
#define MSGBUS_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,MSGBUS_IDX)))

#define SIDVAL_IDX 1
#define SIDVAL(S)       (ssGetSFcnParam(S,SIDVAL_IDX))
#define SIDVAL_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,SIDVAL_IDX)))

#define NPARAMS 2

#define IS_REAL(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))

#define IS_INT(pVal) (mxIsNumeric(pVal) && !mxIsEmpty(pVal) && !mxIsDouble(pVal) && !mxIsSingle(pVal) )

#define IS_LOGICAL(pVal) (!mxIsNumeric(pVal) && mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && !mxIsDouble(pVal))

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)

/* Function: mdlCheckParameters ===========================================
 * Abstract:
 *   mdlCheckParameters verifies new parameter settings whenever parameter
 *   change or are re-evaluated during a simulation. When a simulation is
 *   running, changes to S-function parameters can occur at any time during
 *   the simulation loop.
 */
static void mdlCheckParameters(SimStruct *S)
{
    /* no parameter checking needed */
}
#endif

#undef MDL_PROCESS_PARAMETERS
#if defined(MDL_PROCESS_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlProcessParameters =========================================
 * Abstract:
 *   Update run-time parameters.
 */
static void mdlProcessParameters(SimStruct *S)
{
    ssUpdateAllTunableParamsAsRunTimeParams(S);
}
#endif

/* Function: mdlInitializeSizes ===========================================
 * Abstract:
 *   The sizes information is used by Simulink to determine the S-function
 *   block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    size_t             busNameLen = 0;
    char_T            *busName;

    int_T              buflen = 0;
    
    char_T            *buf;
    char_T            *flagDwBuf;
    char_T            *flagDwName = "cmsgFlag_";
    
    /* Number of expected parameters */
    ssSetNumSFcnParams(S, 2);

    #if defined(MATLAB_MEX_FILE) 
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        /**
         * If the number of expected input parameters is not equal
         * to the number of parameters entered in the dialog box return.
         * Simulink will generate an error indicating that there is a
         * parameter mismatch.
         */
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    } 
    else {
        /* Return if number of expected != number of actual parameters */
        return;
    } /* if */
    #endif 

    /* Set the parameter's tunability */
    ssSetSFcnParamTunable(S, MSGBUS_IDX, SS_PRM_NOT_TUNABLE);
    ssSetSFcnParamTunable(S, SIDVAL_IDX, SS_PRM_NOT_TUNABLE);     

    /* Set the number of work vectors */
    ssSetNumPWork(S, 0);
    if (!ssSetNumDWork(S, 2)) return;  /* number of integer work vector elements */  
    /*
     * Configure the dwork 0 (busSize)
     */
    ssSetDWorkDataType(S, 0, SS_INT32);
    ssSetDWorkName(S, 0, "busSize");
    ssSetDWorkWidth(S, 0, 1);

    /* Set up DWork for persistent storage of Conditional flag 
     * This is needed when this block is used in reusable systems.
     */
    ssSetDWorkDataType(S, 1, SS_BOOLEAN);    
    ssSetDWorkName(S, 1, "cmsgFlag");    
    ssSetDWorkWidth(S, 1, 1);    
        
    /* create a unique global Dwork name using this
     * block's SID. Must be unique since this will
     * be global data.
     */  
    buflen = (int_T)mxGetNumberOfElements(SIDVAL(S)); /* SID value len */
    if ((buf = (char_T*)malloc(80)) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error for SID string suffix");
        return;
    }
    if (mxGetString(SIDVAL(S), buf, buflen+1) != 0) {
        free(buf);
        ssSetErrorStatus(S, "mdlInitializeSizes: Could not convert SID suffix");
    } 

    /* Identifier; free any old setting and update */
    flagDwBuf = ssGetDWorkRTWIdentifier(S, 1);
    if (flagDwBuf != NULL) {
        free(flagDwBuf);
    }
    if ((flagDwBuf = (char_T*)malloc(80)) == NULL) { /* 10 is sizeof flagDwName + 1 */
        ssSetErrorStatus(S,"Memory allocation error for flag name string");
        return;
    }
    
    /* append SID to global variable names */
    sprintf(flagDwBuf,"%s%s",flagDwName,buf);

    /* make dwork to store the flag input for this
     * block, and make it global so it is persistent
     * to store address in CFS Event Table. */
    ssSetDWorkRTWIdentifier(S, 1, flagDwBuf);    
    
    /* This Dwork is must be exported global to satisy the 
     * ability to access its address for CFS data structures.
     */
    ssSetDWorkRTWStorageClass(S, 1, SS_RTW_STORAGE_EXPORTED_GLOBAL); 
    free(buf);  /* other malloc'd mem freed in mdlTeminate() */
           
    /* Set the number of input ports  */
    if (!ssSetNumInputPorts(S,2)) return;
    
    /* Configure the Flag input port */
    ssSetInputPortDataType(S, FLAG_IN_IDX, SS_BOOLEAN);
    ssSetInputPortWidth(S, FLAG_IN_IDX, 1);
    ssSetInputPortComplexSignal(S, FLAG_IN_IDX, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough(S, FLAG_IN_IDX, 1);  
    ssSetInputPortAcceptExprInRTW(S, FLAG_IN_IDX, 1);
    ssSetInputPortRequiredContiguous(S, FLAG_IN_IDX, 1);
    ssSetInputPortOptimOpts(S, FLAG_IN_IDX, SS_NOT_REUSABLE_AND_GLOBAL);  
    
    /* Configure the Bus (Message) input port */
    ssSetInputPortWidth(S, BUS_IN_IDX, 1);
    ssSetInputPortComplexSignal(S, BUS_IN_IDX, 0);
    ssSetInputPortDirectFeedThrough(S, BUS_IN_IDX, 1);
    ssSetInputPortRequiredContiguous(S, BUS_IN_IDX, 1); /*direct input signal access*/
    ssSetBusInputAsStruct(S, BUS_IN_IDX,1);
    ssSetInputPortBusMode(S, BUS_IN_IDX, SL_BUS_MODE);    /*Input Port 1 */

    /* Set the number of output ports */
    if (!ssSetNumOutputPorts(S, 1)) return;

    /* ssSetBusOutputObjectName(S, 0, (void *) busName); */
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortComplexSignal(S, 0, 0);
    ssSetOutputPortBusMode(S, 0, SL_BUS_MODE);    

    busNameLen = (int_T)mxGetNumberOfElements(MSGBUS(S));
    busName = (char_T*)malloc((busNameLen+1)*sizeof(char_T));
    if (mxGetString(MSGBUS(S), busName, busNameLen+1) != 0) {
        free(busName);
        ssSetErrorStatus(S, "mdlInitializeSizes: Could not convert bus name");
    }
    
    #if defined(MATLAB_MEX_FILE)
    DTypeId dataTypeIdReg;
    ssRegisterTypeFromNamedObject(S, busName, &dataTypeIdReg);
    if(dataTypeIdReg == INVALID_DTYPE_ID) {
        free(busName);
        ssSetErrorStatus(S,"Invalid bus data type");
    }
    ssSetInputPortDataType(S,1, dataTypeIdReg);
    ssSetOutputPortDataType(S,0, dataTypeIdReg);  
    ssSetBusOutputObjectName(S, 0, (void *) busName);
      
    ssSetBusOutputAsStruct(S, 0, 1);
    #endif
    
    free(busName);
       
    /* This S-function can be used in referenced model simulating in normal mode */
    ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);

    /* Set the number of sample time */
    ssSetNumSampleTimes(S, 1);

    /* Set the compliance with the SimState feature */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    /* Set the Simulink version this S-Function has been generated in */
    /* This is good practice, but is necessary in this case because   */
    /* this s-function will fail in top-level rapid acceleration mode */
    /* without it.  This is due to checks for bus padding issues in   */
    /* Raccel with Simulink.  We still need this even though we dont  */
    /* need to worry about padding for this s-function.               */
    ssSetSimulinkVersionGeneratedIn(S, "9.0");

    /**
     * All options have the form SS_OPTION_<name> and are documented in
     * matlabroot/simulink/include/simstruc.h. The options should be
     * bitwise or'd together as in
     *    ssSetOptions(S, (SS_OPTION_name1 | SS_OPTION_name2))
     */
    ssSetOptions(S,
        SS_OPTION_USE_TLC_WITH_ACCELERATOR |
        SS_OPTION_CAN_BE_CALLED_CONDITIONALLY |
        SS_OPTION_EXCEPTION_FREE_CODE |
        SS_OPTION_WORKS_WITH_CODE_REUSE |
        SS_OPTION_SFUNCTION_INLINED_FOR_RTW |
        SS_OPTION_DISALLOW_CONSTANT_SAMPLE_TIME
    );

}

#define MDL_START
#if defined(MDL_START)
/* Function: mdlStart =====================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{   
    
    /* Get stored size of Message bus from DWork */
    size_t   buflen   = (size_t)mxGetNumberOfElements(MSGBUS(S));
    char_T  *buf      = (char_T*)malloc(80);
    int32_T *busSize  = (int32_T *) ssGetDWork(S, 0);    
    DTypeId  busId;
  
    /* Copy the string data from string_array_ptr and place it into buf. */ 
    if (mxGetString(MSGBUS(S), buf, buflen+1) != 0) {
        free(buf);
        ssSetErrorStatus(S, "Could not convert string data.");
    }

    /* Set the bus data size for memcpy in mdlOutputs */
    busId      = ssGetDataTypeId(S, buf);
    busSize[0] = ssGetDataTypeSize(S, busId);
    free(buf);
}

#endif /*  MDL_START */

/* Function: mdlInitializeSampleTimes =====================================
 * Abstract:
 *   This function is used to specify the sample time(s) for your
 *   S-function. You must register the same number of sample times as
 *   specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);

    #if defined(ssSetModelReferenceSampleTimeDefaultInheritance)
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
    #endif
    
}

#undef MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
/* Function: mdlSetWorkWidths =============================================
 * Abstract:
 *   The optional method, mdlSetWorkWidths is called after input port
 *   width, output port width, and sample times of the S-function have
 *   been determined to set any state and work vector sizes which are
 *   a function of the input, output, and/or sample times. 
 *   Run-time parameters are registered in this method using methods 
 *   ssSetNumRunTimeParams, ssSetRunTimeParamInfo, and related methods.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    /* Set the paramters as run-time so we can get this information in 
     * block TLC.
     */
    /* Set number of run-time parameters */
    if (!ssSetNumRunTimeParams(S, 0)) return;       
}
#endif

#define MDL_INITIALIZE_CONDITIONS   /*Change to #undef to remove function*/
#if defined(MDL_INITIALIZE_CONDITIONS)
/*  
 * mdlInitializeConditions - initialize the states  
 *  
 * In this function, you should initialize the continuous and discrete  
 * states for your S-function block.  The initial states are placed  
 * in the x0 variable.  You can also perform any other initialization  
 * activities that your S-function may require.  
 */ 
static void mdlInitializeConditions(SimStruct *S) 
{  
    char      *y       = (char *)ssGetOutputPortSignal(S,0);
    int32_T   *busSize = (int32_T *) ssGetDWork(S, 0);
   
    /* Bus is only passed thru.  Flag input is used in TLC */
    (void) memset(y, 0, busSize[0]); 
}  
#endif

/* Function: mdlOutputs ===================================================
 * Abstract:
 *   In this function, you compute the outputs of your S-function
 *   block. Generally outputs are placed in the output vector(s),
 *   ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    char      *flag    = (char *)ssGetInputPortSignal(S,0);
    char      *u       = (char *)ssGetInputPortSignal(S,1);    
    char      *y       = (char *)ssGetOutputPortSignal(S,0);
    int32_T   *busSize = (int32_T *) ssGetDWork(S, 0);
   
    /* Bus is only passed thru.  Flag input is used in TLC */
    if (*flag) {
        (void) memcpy(y, u, busSize[0]);
    }
}

/* Function: mdlTerminate =================================================
 * Abstract:
 *   In this function, you should perform any actions that are necessary
 *   at the termination of a simulation.
 */
static void mdlTerminate(SimStruct *S)
{
    char  *id1;
    
    /* Identifiers; free any old setting and update */
    id1 = ssGetDWorkRTWIdentifier(S, 1);
    if (id1 != NULL) {
        free(id1);
    }
    ssSetDWorkRTWIdentifier(S, 1, NULL);  
}

/* Required S-function trailer */
#ifdef    MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif

