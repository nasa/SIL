/**
 * cfs_fdc.c
 *
 *    ABSTRACT:
 *      This S-function implements the CSL Target FDC block
 *
 *
 */

/* Must specify the S_FUNCTION_NAME as the name of the S-function */
#define S_FUNCTION_NAME  cfs_fdc
#define S_FUNCTION_LEVEL 2

/**
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#define FLAG_IDX        0

/* FDC ID Parm */
#define FDCID_IDX 0
#define FDCID(S)       (ssGetSFcnParam(S,FDCID_IDX))
#define FDCID_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,FDCID_IDX)))
/* Block SID value (hidden parm) */
#define SIDVAL_IDX 1
#define SIDVAL(S)      (ssGetSFcnParam(S,SIDVAL_IDX))
#define SIDVAL_VAL(S)  (mxGetScalar(ssGetSFcnParam(S,SIDVAL_IDX)))


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
    int prm;
    
    if ((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY)) {
        /* Check the parameter 1: FDC ID */
        if ( IS_INT(FDCID(S)) ) {
            prm = (int)FDCID_VAL(S);
            if (prm < 0 || prm > 255) {
                ssSetErrorStatus(S,"FDC Block mask value must be an integer in range 0-255");
                return;
            }
        }
        else {
            ssSetErrorStatus(S,"FDC Block mask value must be an integer");
            return;
        }      
    }
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
    int                buflen = 0;
    
    char              *buf;
    char              *flagDwBuf;
    char              *flagDwName = "fdcFlag_";
      
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
    } else {
        /* Return if number of expected != number of actual parameters */
        return;
    } /* if */
    #endif 

    /* Set the parameter's tunability */
    ssSetSFcnParamTunable(S, FDCID_IDX,      0);
    ssSetSFcnParamTunable(S, SIDVAL_IDX,     0);
    
    /* Set the number of work vectors */
    if (!ssSetNumDWork(S, 0)) return;

    /* Set the number of input ports */
    if (!ssSetNumInputPorts(S,1)) return;
    
    /* Configure the Flag input port */
    ssSetInputPortDataType(S, FLAG_IDX, SS_BOOLEAN);
    ssSetInputPortWidth(S, FLAG_IDX, 1);
    ssSetInputPortComplexSignal(S, FLAG_IDX, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough(S, FLAG_IDX, 1); 
    ssSetInputPortAcceptExprInRTW(S, FLAG_IDX, 1);
    ssSetInputPortRequiredContiguous(S, FLAG_IDX, 1);
    ssSetInputPortOptimOpts(S, FLAG_IDX, SS_NOT_REUSABLE_AND_GLOBAL);  

    /* Set the number of output ports */
    if (!ssSetNumOutputPorts(S, 0)) return;

    /* Set up DWork for persistent storage of FDC flag.
     * This is needed when this block is used in reusable systems.
     */
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, 1);      
    ssSetDWorkDataType(S, 0, SS_BOOLEAN);
    ssSetDWorkName(S, 0, "fdcFlag");
    
    /* create a unique global Dwork name using this
     * block's SID. Must be unique since this will
     * be global data.
     */  
    buflen = mxGetN(SIDVAL(S)) + 1; /* SID value len */
    if ((buf = malloc(buflen)) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error for SID string suffix");
        return;
    }

    if ((flagDwBuf = malloc(buflen+sizeof(flagDwName))) == NULL) { /* sizeof already has null */
        ssSetErrorStatus(S,"Memory allocation error for flag name string");
        return;
    }
    mxGetString(SIDVAL(S), buf, buflen); /* Get the SID string */
    
    /* append SID to global variable names */
    strcpy(flagDwBuf,flagDwName);
    strcat(flagDwBuf,buf); /* add SID as suffix */

    /* make dwork to store the flag input for this
     * block, and make it global so it is persistent
     * to store address in CFS Event Table. */
    ssSetDWorkRTWIdentifier(S, 0, flagDwBuf);    
    
    /* This Dwork is must be exported global to satisy the 
     * ability to access its address for CFS data structures.
     */
    ssSetDWorkRTWStorageClass(S, 0, SS_RTW_STORAGE_EXPORTED_GLOBAL);  
    
    free(buf);  /* other malloc'd mem freed in mdlTeminate() */    

    /* This S-function can be used in referenced model simulating in normal mode */
    ssSetModelReferenceNormalModeSupport(S, MDL_START_AND_MDL_PROCESS_PARAMS_OK);

    /* Set the number of sample time */
    ssSetNumSampleTimes(S, 1);

    /* Set the compliance with the SimState feature */
    ssSetSimStateCompliance(S, USE_DEFAULT_SIM_STATE);

    /* Set the Simulink version this S-Function has been generated in */
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

#define MDL_SET_WORK_WIDTHS
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
    if (!ssSetNumRunTimeParams(S, 1)) return;

    ssRegDlgParamAsRunTimeParam(S, FDCID_IDX, 0, "fdc_id", ssGetDataTypeId(S, "uint8"));
       
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
    /* No outputs required for this block during simulation.
     * (Block TLC does update this block's DWork persistent
     * data which is stored as pointers in CFS FDC table.
     */     
}

/* Function: mdlTerminate =================================================
 * Abstract:
 *   In this function, you should perform any actions that are necessary
 *   at the termination of a simulation.
 */
static void mdlTerminate(SimStruct *S)
{
    char  *id;
    
    /* Identifier; free any old setting and update */
    id = ssGetDWorkRTWIdentifier(S, 0);
    if (id != NULL) {
        free(id);
    }
    ssSetDWorkRTWIdentifier(S, 0, NULL);
    
}

/* Required S-function trailer */
#ifdef    MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif

