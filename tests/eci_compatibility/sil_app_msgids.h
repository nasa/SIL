#ifndef SIL_APP_MSGIDS
#define SIL_APP_MSGIDS

/* ECI-related MID's */
#define SILTEST_FDC_MID    0x1800
#define SILTEST_CMD_MID    0x1801
#define SILTEST_TICK_MID   0x1803
#define SILTEST_HK_MID     0x1804
#define ECI_TBL_MANAGE_MID 0x1805
#define ECI_SEND_HK_MID    0x1806

/* Code's Input Commands */
#define  INCMDBUS_INCMDBUS_S_MID                   0x1807

/* Code's Input Telemetry */
#define INTLMBUS_INTLMBUS_S_MID                    0x0807

/* Code's Output Telemetry */
#define AYNCMSGBUS_AYNCMSGBUS_S_MID                0x0808
#define CDSDATABUS_CDSDATABUS_S_MID                0x0809
#define CONDITIONALMSGBUS_CONDITIONALMSGBUS_S_MID  0x0810
#define EVENTMSGBUS_EVENTMSGBUS_S_MID              0x0811
#define PERIODICMSGBUS_PERODICMSGBUS_S_MID         0x0812
#define STATUSFLAGBUS_STATUSFLAGBUS_S_MID          0x0813
#define TIMEBUS_TIMEBUS_S_MID                      0x0814
        
#endif