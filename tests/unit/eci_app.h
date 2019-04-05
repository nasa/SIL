/*
 * Copyright © 2018 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 */

/**
 * File: eci_app.h 
 * Description:  Defines the datatypes & macros used by the ECI interface header file.
 */

#ifndef ECI_APP_H
#define ECI_APP_H

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*************************************************************************
 **
 ** Include section
 **
 **************************************************************************/
/* Removed to stub for testing
#include "cfe.h"
*/
/************************************************************************
** Macro Definitions
*************************************************************************/

#define EVENT_message0_ID     0  /* Identifier for Event message with zero data points */
#define EVENT_message1_ID     1  /* Identifier for Event message with one data points */
#define EVENT_message2_ID     2  /* Identifier for Event message with two data points */
#define EVENT_message3_ID     3  /* Identifier for Event message with three data points */
#define EVENT_message4_ID     4  /* Identifier for Event message with four data points */
#define EVENT_message5_ID     5  /* Identifier for Event message with five data points */

/*
 * The following Event and Message IDs match what is used in the demo
 * models and were added for testing.
 */
#define OUTBUS_MSG_OUT1_MID        12
#define OUTBUS_MSG_OUT2_A_MID      13
#define GNC_CMD_MSG_OUT2_A1_MID    14
#define OUTBUS_MSG_OUT4_MID        15
#define OUTBUS_MSG_OUT5_MID        16
#define OUTBUS_MSG_OUT6_MID        17

#define INBUS_MSG_IN1_MID          18
#define INBUS_MSG_IN2_A_MID        19  
#define ENV_CMD_MSG_IN2_A1_MID     20
#define INBUS_MSG_IN4_MID          21
#define INBUS_MSG_IN5_MID

#define QUEUE_SIZE 20
#define CMD_MSG_QUEUE_SIZE 20

/************************************************************************
** Type Definitions
*************************************************************************/

/* Datatypes have been changed to avoid needed common_types.h 
 * which isn't relevant for these tests */
    
/* For definition of size_t */
#include <stddef.h>
#include "rtwtypes.h"
    
/* ECI_MsgRcv and ECI_MsgSnd Interface Structure */
typedef struct {
   uint8_T     mid;     /* Message ID */
   void           *mptr;   /* Input/Output Buffer */
   size_t         siz;     /* Message Size (including header) */
   void           *qptr;   /* Location of Cmd Queue Buffer - NULL if Tlm Message */
   boolean_T*       sendMsg; /* Pointer to Flag indicating whether to send 
                                Output Buffer Msg on SB - Don't Care for Input Messages */
} ECI_Msg_t;

/* FDC Reporting Interface Structure */
typedef struct {
  uint8_T    *   FlagID;     /* Pointer to Flag Id  - unique id set by the user */
  boolean_T* StatusFlag; /* Pointer to status flag */
} ECI_Flag_t;

/* EVS Interface Structure */
typedef struct {
  uint8_T     eventBlock;   /* Event Block describes how many data points  */
  uint8_T    * eventID;     /* Event Id  - unique id set by the user*/
  uint8_T    * eventType;   /* Event Type - debug, info, error, crit set by user */
  uint32_T* eventMask;  /* Event Mask - filter set by user */
  boolean_T* eventFlag; /* Flag indicating simulink event has occurred */
  uint8_T    * eventMsg;    /* Msgpoint to send with an event taken from observable signal */     
  char* loc;          /* Location string */
  double* data_1;     /* First data point */
  double* data_2;     /* Second data point */
  double* data_3;     /* Third data point */
  double* data_4;     /* Fourth data point */
  double* data_5;     /* Fifth data point */
} ECI_Evs_t;

/* Table Interface Structure */
typedef struct{
    void**  tblptr;       /* Pointer to table  */
    char*   tblname;      /* Name of table  */
    char*   tbldesc;      /* Description of table  */
    char*   tblfilename;  /* Filename of table  */
    uint32_T  tblsize;      /* Size of table */
    void*   tblvalfunc;   /* Table validation func */
}ECI_Tbl_t;

/* Critical Data Store Structure */
typedef struct
{
   char*  cdsname;         /* Name of CDS block */
   size_t cdssiz;          /* Size of CDS block */
   void*  cdsptr;          /* Address of Critical Data  */
}ECI_Cds_t;

/* Added from cfe_time.h for stubbing */
typedef struct
{
  uint32_T  Seconds;            /**< \brief Number of seconds since epoch */
  uint32_T  Subseconds;         /**< \brief Number of subseconds since epoch (LSB = 2^(-32) seconds) */
} CFE_TIME_SysTime_t;

/* Time Interface Structure */
typedef CFE_TIME_SysTime_t ECI_TimeStamp_t;

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* ECI_APP_H */

/************************/
/*  End of File Comment */
/************************/
