#ifndef SQLITE4M
#define SQLITE4M

#include <mex.h>
#include "sqlite3.h"
#include "stdlib.h"
#include <string>
#include <vector>

#include <cctype> // for toupper()
#include <algorithm> // for transform()

using namespace std;

// Structure to store data from query result
struct return_uni_data;

static mxArray* actionOpenDB(int dbid, string databaseFile);
static void actionCloseDB(int dbid);
static mxArray* actionRequestDB(int dbid, const char* query);
static mxArray* actionPrepareStatement(int dbid, const char* statement);
static mxArray* actionExecuteStatement(int statementId, const mxArray* parameters);
static void actionFinalizeStatement(int statementId);

static void exitCallback(void);

static char* errMsg(int query_result);

static string getStringFromMxArray(const mxArray *prhs);
static char* getCharFromMxArray(const mxArray *prhhs);

void mexFunction(int nlhs, mxArray *plhs[ ], int nrhs, const mxArray *prhs[ ]);

#endif