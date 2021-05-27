//
// MATLAB Compiler: 7.0.1 (R2019a)
// Date: Wed Mar 11 18:46:27 2020
// Arguments:
// "-B""macro_default""-W""cpplib:RRIntervalsRT""-d""./Compilation_dll""RRInterv
// alsRealTime.m""-T""link:lib"
//

#ifndef __RRIntervalsRT_h
#define __RRIntervalsRT_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_RRIntervalsRT_C_API 
#define LIB_RRIntervalsRT_C_API /* No special import/export declaration */
#endif

/* GENERAL LIBRARY FUNCTIONS -- START */

extern LIB_RRIntervalsRT_C_API 
bool MW_CALL_CONV RRIntervalsRTInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_RRIntervalsRT_C_API 
bool MW_CALL_CONV RRIntervalsRTInitialize(void);

extern LIB_RRIntervalsRT_C_API 
void MW_CALL_CONV RRIntervalsRTTerminate(void);

extern LIB_RRIntervalsRT_C_API 
void MW_CALL_CONV RRIntervalsRTPrintStackTrace(void);

/* GENERAL LIBRARY FUNCTIONS -- END */

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

extern LIB_RRIntervalsRT_C_API 
bool MW_CALL_CONV mlxRRIntervalsRealTime(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

/* C INTERFACE -- MLX WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */

#ifdef __cplusplus
}
#endif


/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- START */

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__MINGW64__)

#ifdef EXPORTING_RRIntervalsRT
#define PUBLIC_RRIntervalsRT_CPP_API __declspec(dllexport)
#else
#define PUBLIC_RRIntervalsRT_CPP_API __declspec(dllimport)
#endif

#define LIB_RRIntervalsRT_CPP_API PUBLIC_RRIntervalsRT_CPP_API

#else

#if !defined(LIB_RRIntervalsRT_CPP_API)
#if defined(LIB_RRIntervalsRT_C_API)
#define LIB_RRIntervalsRT_CPP_API LIB_RRIntervalsRT_C_API
#else
#define LIB_RRIntervalsRT_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_RRIntervalsRT_CPP_API void MW_CALL_CONV RRIntervalsRealTime(int nargout, mwArray& RRinterval, mwArray& bpm, mwArray& stim, mwArray& nb_errors, const mwArray& ecgValue, const mwArray& init, const mwArray& correctionThreshold, const mwArray& MPP);

/* C++ INTERFACE -- WRAPPERS FOR USER-DEFINED MATLAB FUNCTIONS -- END */
#endif

#endif
