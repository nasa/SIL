/**
 * cfs_event.c
 *
 *    ABSTRACT:
 *      This S-function implements the CFS Target Event block.
 *      This block serves to purpose during simulation.  Instead,
 *      DWork is used as persistent data that can be addressed
 *      in the CFS Event Table.  This is so that this block can
 *      be used in reusable subsystem configurations.
 *
 *      Note that block TLC will generate code to initialize and
 *      update this DWork for target based code.
 *
 */

/* Must specify the S_FUNCTION_NAME as the name of the S-function */
#define S_FUNCTION_NAME  cfs_event
#define S_FUNCTION_LEVEL 2

/**
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

#define U(element) (*uPtrs[element])  /* Pointer to Input Port0 */

#define FLAG_IDX        0
#define DATA_IDX_START  1

/* Event ID Parm */
#define EVID_IDX 0
#define EVID(S)         (ssGetSFcnParam(S,EVID_IDX))
#define EVID_VAL(S)     (mxGetScalar(ssGetSFcnParam(S,EVID_IDX)))
/* Event Type Parm */
#define EVTYPE_IDX 1
#define EVTYPE(S)       (ssGetSFcnParam(S,EVTYPE_IDX))
#define EVTYPE_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,EVTYPE_IDX)))
/* Event Mask Parm */ 
#define EVMASK_IDX 2
#define EVMASK(S)       (ssGetSFcnParam(S,EVMASK_IDX))
#define EVMASK_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,EVMASK_IDX)))
/* Event formatting string Parm */
#define EVFORMAT_IDX 3
#define EVFORMAT(S)     (ssGetSFcnParam(S,EVFORMAT_IDX))
#define EVFORMAT_VAL(S) (mxGetData(ssGetSFcnParam(S,EVFORMAT_IDX)))
/* Number of Data Inputs Parm */
#define NUMDATA_IDX 4
#define NUMDATA(S)      (ssGetSFcnParam(S,NUMDATA_IDX))
#define NUMDATA_VAL(S)  (mxGetScalar(ssGetSFcnParam(S,NUMDATA_IDX)))
/* Block SID value (hidden parm) */
#define SIDVAL_IDX 5
#define SIDVAL(S)       (ssGetSFcnParam(S,SIDVAL_IDX))
#define SIDVAL_VAL(S)   (mxGetScalar(ssGetSFcnParam(S,SIDVAL_IDX)))

#define NPARAMS 6  /* number of block mask parms */

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
    int       prm;
    long      lprm;
    size_t    nu;
    boolean_T illegalParam = 0;
    
    if ((ssGetSimMode(S)==SS_SIMMODE_SIZES_CALL_ONLY)) {
        /* Check the parameter 1: Event ID */
        if ( IS_INT(EVID(S)) ) {
            prm = (int)EVID_VAL(S);
            if (prm < 0 || prm > 255) {
                ssSetErrorStatus(S,"Event ID parameter must be between "
                        "0 and 255");
                return;
            }
        }
        else {
            ssSetErrorStatus(S,"Event ID parameter must be integer ");           
            return;
        }
        
        /* Check the parameter 2: Event Type */
        if ( IS_INT(EVTYPE(S)) ) {
            prm = (long)EVTYPE_VAL(S);
            if (prm < 0 || prm > 255) {
                ssSetErrorStatus(S,"Event Type parameter must be between "
                        "0 and 255");
                return;
            }
        }
        else {
            ssSetErrorStatus(S,"Event Type parameter must be integer");
            return;
        }
        
        /* Check the parameter 3: Event Mask */
        if (IS_INT(EVMASK(S))) {
            lprm = (long)EVMASK_VAL(S);
            if (lprm < 0 || lprm > 4294967295) { /* 2^32-1 */
                ssSetErrorStatus(S,"Event Mask parameter must be between "
                        "0 and 2^32-1");
                return;
            }
        }
        else {
            ssSetErrorStatus(S,"Event Mask parameter must be integer");
            return;
        }
        
        /* Check the parameter 4: Event formatting string */              
        if (!IS_INT(EVFORMAT(S)) ||
                (nu=mxGetNumberOfElements(EVFORMAT(S))) > 100) {
            illegalParam = 1;
        } else {
        }
        
        if (illegalParam) {
            ssSetErrorStatus(S,"Event format string parameter must be a "
                    "string of less than 100 characters");
            return;
        }
        
        /* Check the parameter 5: Number of data inputs */
        if (IS_REAL(NUMDATA(S))) {
            prm = (int)NUMDATA_VAL(S);
            if (prm < 0 || prm > 5) {
                ssSetErrorStatus(S,"Event number of data inputs must be between "
                        "0 and 5");
                return;
            }
        }
        else {
            ssSetErrorStatus(S,"Event number of data inputs must be integer");
            return;
        }
        /* No check needed on Parameter 6 (SID parm).  Value is 
         * string set by mask. */
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
    int                i;
    int                buflen = 0;
    
    char              *buf;
    char              *flagDwBuf;
    char              *dataDwBuf;
    char              *flagDwName = "evFlag_";
    char              *dataName   = "evData_";
    
    const mxArray*     prm1;
  
    /* Number of expected parameters */
    ssSetNumSFcnParams(S, 6);

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
    ssSetSFcnParamTunable(S, EVID_IDX,     0);
    ssSetSFcnParamTunable(S, EVTYPE_IDX,   0);
    ssSetSFcnParamTunable(S, EVMASK_IDX,   0);
    ssSetSFcnParamTunable(S, EVFORMAT_IDX, 0);
    ssSetSFcnParamTunable(S, NUMDATA_IDX,  0);
    ssSetSFcnParamTunable(S, SIDVAL_IDX,   0);  

    /* Set the number of input ports dynamically */
    prm1 = ssGetSFcnParam(S, NUMDATA_IDX); 
    int_T nDataPorts = (int_T)(mxGetPr(prm1)[0]); /* assuming param is a double value */
    if (!ssSetNumInputPorts(S,nDataPorts+1)) return;
    
    /* Configure the Flag input port */
    ssSetInputPortDataType(S, FLAG_IDX, SS_BOOLEAN);
    ssSetInputPortWidth(S, FLAG_IDX, 1);
    ssSetInputPortComplexSignal(S, FLAG_IDX, COMPLEX_NO);
    ssSetInputPortDirectFeedThrough(S, FLAG_IDX, 1); 
    ssSetInputPortAcceptExprInRTW(S, FLAG_IDX, 1);
    ssSetInputPortRequiredContiguous(S, FLAG_IDX, 1);
    ssSetInputPortOptimOpts(S, FLAG_IDX, SS_NOT_REUSABLE_AND_GLOBAL);  

    /* Configure the Data input ports  */
    for(i=1; i < nDataPorts+1; i++) {
        ssSetInputPortDataType(S, i, SS_DOUBLE);
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortComplexSignal(S, i, COMPLEX_NO);
        ssSetInputPortDirectFeedThrough(S, i, 1); 
        ssSetInputPortAcceptExprInRTW(S, i, 1);
        ssSetInputPortRequiredContiguous(S, i, 1);    
    }

    /* Set the number of output ports */
    if (!ssSetNumOutputPorts(S, 0)) return;
    
    /* Set up DWork for persistent storage of Event flag and
     * data inputs.  This is needed when this block is used
     * in reusable subsystems. Note: max 5 scalar data inputs
     * for blocks will be stored in contiguous DWork array.
     */
    if (nDataPorts > 0) {
        ssSetNumDWork(S, 2);
        ssSetDWorkWidth(S, 1, 5);   /* block max is 5 scalars */
        ssSetDWorkDataType(S, 1, SS_DOUBLE);
        ssSetDWorkName(S, 1, "eventData");
    }
    else {
        ssSetNumDWork(S, 1);
    }
    ssSetDWorkWidth(S, 0, 1);      
    ssSetDWorkDataType(S, 0, SS_BOOLEAN);
    ssSetDWorkName(S, 0, "eventFlag");

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
        
    if ((dataDwBuf = malloc(buflen+sizeof(dataName))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error for data input name string");
        return;
    }
         
    mxGetString(SIDVAL(S), buf, buflen); /* Get the SID string */
    
    /* append SID to global variable names */
    strcpy(flagDwBuf,flagDwName);
    strcpy(dataDwBuf,dataName);    
    strcat(dataDwBuf,buf); /* add SID as suffix */   
    strcat(flagDwBuf,buf); /* add SID as suffix */

    /* make dwork to store the flag input for this
     * block, and make it global so it is persistent
     * to store address in CFS Event Table. */
    ssSetDWorkRTWIdentifier(S, 0, flagDwBuf);    
    
    /* This Dwork is must be exported global to satisy the 
     * ability to access its address for CFS data structures.
     */
    ssSetDWorkRTWStorageClass(S, 0, SS_RTW_STORAGE_EXPORTED_GLOBAL); 
    if (nDataPorts > 0) {
        ssSetDWorkRTWIdentifier(S, 1, dataDwBuf);  
        ssSetDWorkRTWStorageClass(S, 1, SS_RTW_STORAGE_EXPORTED_GLOBAL); 
    }
    
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
 *   
 *   Note: Setting all this run-time parameter stuff to get this data
 *         to the block TLC.
 */
static void mdlSetWorkWidths(SimStruct *S)
{
    int            dlgP = EVFORMAT_IDX;
    uint8_T       *fmtArray;
    size_t         fmtSize = 0;
    mwSize         ndims;
    mwSize         i = 0;
    const  mwSize *dims;
    int_T         *tmpDims;

    /* Set the paramters as run-time so we can get this information in 
     * block TLC.
     */
    /* Set number of run-time parameters */
    if (!ssSetNumRunTimeParams(S, 6)) return;

    ssRegDlgParamAsRunTimeParam(S, EVID_IDX, 0,   "event_id",   ssGetDataTypeId(S, "uint8"));
    ssRegDlgParamAsRunTimeParam(S, EVTYPE_IDX, 1, "event_type", ssGetDataTypeId(S, "uint8"));
    ssRegDlgParamAsRunTimeParam(S, EVMASK_IDX, 2, "event_mask", ssGetDataTypeId(S, "uint32"));

    /* Event format string - parameter 4 */
    ssParamRec p;

    fmtSize=mxGetNumberOfElements(EVFORMAT(S));  
    if ((fmtArray=(uint8_T*)malloc(fmtSize)) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error for format string");
        return;
    }
    /* FIXME: test
    if(fmtSize > 80){
        ssWarning(S, "Message may be longer than CFS allows")
    }
    */ 
    /* Store the pointer to the memory location in the S-function 
     * userdata. Since the S-function owns this data, it needs to
     * free the memory during mdlTerminate */
    ssSetUserData(S, (void*)fmtArray);
    
    dims  =  mxGetDimensions(EVFORMAT(S));
    ndims =  mxGetNumberOfDimensions(EVFORMAT(S));
    
    /* If tmpDims already allocated, clear it */
    tmpDims = (int_T *)ssGetUserData(S);
    if (tmpDims != NULL) {
        free(tmpDims);
        ssSetUserData(S, NULL);
    }
    
    if ((tmpDims = (int_T*)malloc(ndims*sizeof(int_T))) == NULL) {
        ssSetErrorStatus(S,"Memory allocation error for format string dimensions");
        return;       
    }
    for( ; i < ndims; ++i) {
        tmpDims[i] = (int_T)(dims[i]);
    }  
    
    p.name             = "event_fmtstring";
    p.nDimensions      = ndims;
    p.dimensions       = tmpDims; 
    p.dataTypeId       = SS_UINT8;
    p.complexSignal    = COMPLEX_NO;
    p.data             = (void *)mxGetPr(EVFORMAT(S));
    p.dataAttributes   = NULL;
    p.nDlgParamIndices = 1;
    p.dlgParamIndices  = &dlgP;
    p.transformed      = false;
    p.outputAsMatrix   = false;      
    if (!ssSetRunTimeParamInfo(S, EVFORMAT_IDX, &p)) return;

    ssRegDlgParamAsRunTimeParam(S, NUMDATA_IDX, 4, "event_numdata", ssGetDataTypeId(S, "double"));
        
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
     * data which is stored as pointers in CFS Event table.
     */ 
    const bool sendFlag = *(bool*)ssGetInputPortSignal(S, FLAG_IDX);
    if(sendFlag){
        
        /* Get SID string*/
        char *sid_buf;
        int sid_buflen = mxGetN(SIDVAL(S)) + 1;
        sid_buf = malloc(sid_buflen);
        mxGetString(SIDVAL(S), sid_buf, sid_buflen);
        
        /* Allocate event string*/
        char *evt_buf;
        /* Message Length = SID string + length of format string + null term + 
                fudge factor to account for change in length due to formatting of values
        */
        int evt_buflen = sid_buflen + strlen(EVFORMAT_VAL(S)) + 1 + 20;
        evt_buf = malloc(evt_buflen);
        
        switch((int)NUMDATA_VAL(S)) { 
            case 0:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf);
                break;
            case 1:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf, 
                    *ssGetInputPortRealSignal(S, DATA_IDX_START));
                break;
            case 2:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf, 
                    *ssGetInputPortRealSignal(S, DATA_IDX_START),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+1));
                break;
            case 3:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf, 
                    *ssGetInputPortRealSignal(S, DATA_IDX_START),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+1),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+2));
                break;
            case 4:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf, 
                    *ssGetInputPortRealSignal(S, DATA_IDX_START),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+1),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+2),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+3));
                break;
            case 5:
                snprintf(evt_buf, evt_buflen, EVFORMAT_VAL(S), sid_buf, 
                    *ssGetInputPortRealSignal(S, DATA_IDX_START),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+1),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+2),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+3),
                    *ssGetInputPortRealSignal(S, DATA_IDX_START+4));
                break;
        }
        //ssPrintf("T=%6.2f: %s \n", ssGetT(S), evt_buf);
    }
}

/* Function: mdlTerminate =================================================
 * Abstract:
 *   In this function, you should perform any actions that are necessary
 *   at the termination of a simulation.
 */
static void mdlTerminate(SimStruct *S)
{
    char  *id;
    int_T *tmpDims;
    int_T nDataPorts;  
    const mxArray*     prm1;
   
    prm1 = ssGetSFcnParam(S, NUMDATA_IDX); 
    nDataPorts = (int_T)(mxGetPr(prm1)[0]); /* assuming param is a double value */
    
    
    /* Free memory used to store the run-time parameter data*/      
    tmpDims = ssGetUserData(S);
    if (tmpDims != NULL) {
        free(tmpDims);
        ssSetUserData(S, NULL);
    }
    
    /* Identifier; free any old setting and update */
    id = ssGetDWorkRTWIdentifier(S, 0);
    if (id != NULL) {
        free(id);
    }
    ssSetDWorkRTWIdentifier(S, 0, NULL);
    if(nDataPorts > 0) {
        id = ssGetDWorkRTWIdentifier(S, 1);
        if (id != NULL) {
            free(id);
        }
        ssSetDWorkRTWIdentifier(S, 1, NULL);
    }    
}

/* Required S-function trailer */
#ifdef    MATLAB_MEX_FILE
# include "simulink.c"
#else
# include "cg_sfun.h"
#endif

