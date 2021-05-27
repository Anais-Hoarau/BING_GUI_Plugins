#include "sqlite4m.h"

//Maximum number of opened dbs
#define MAX_OPENED_DB 100
//Maximum number of prepared statements
#define MAX_PREPARED_STATEMENTS 1000

//Defining some constants used inside the code to know in which action we are
#define ACTION_OPEN_DB 0
#define ACTION_CLOSE_DB 1
#define ACTION_REQUEST_DB 2
#define ACTION_PREPARE_STATEMENT 3
#define ACTION_EXECUTE_STATEMENT 4
#define ACTION_FINALIZE_STATEMENT 5

using namespace std;

// Array to store dbids
static sqlite3* db_array[MAX_OPENED_DB] = { 0 };
//Array to store statements ids.
static sqlite3_stmt* statement_array[MAX_PREPARED_STATEMENTS] = { 0 }; // 0 Is not a valid id in our program. Id numbers start at 1.
//Array to store the dbid of the database corresponding to the statement
static sqlite3* statement_db_matching[MAX_PREPARED_STATEMENTS] = { 0 }; // 0 Is not a valid id in our program. Id numbers start at 1.

// Structure to store data from query result
struct return_uni_data
{
    const char *field_name;
    mxArray *field_value;
};

// Vector representing a line of data from SQL Query result.
typedef vector <return_uni_data> vector_return_line;

void mexFunction(int nlhs, mxArray *plhs[ ], int nrhs, const mxArray *prhs[ ]) 
{      
	_CrtSetDbgFlag ( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF );
    mexAtExit(exitCallback);
    
	int actionToPerform;
    
    //----------------------------
    // TEST ARGUMENTS
    //----------------------------

    
    // If you have 2 args, it can either be "text-text" or "int-text" or "int / cell array"
    if (nrhs == 2)	
    {
		// 1st arg is text / int
		if (!mxIsDouble(prhs[0]) && !mxIsChar(prhs[0]))
			{mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "First argument must be text or integer");}
		// If 1st arg is int, it must not be empty
		if (mxIsDouble(prhs[0]) && mxIsEmpty(prhs[0]))
			{mexErrMsgIdAndTxt("SQLITE4M:EmptyDBIDArray", "DBID must not be an empty array");}
        // 2nd arg is text / cell array
        if (!mxIsCell(prhs[1]) && !mxIsChar(prhs[1]))
			{mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "Second argument must be text or cell array");}
    }

    // If you have 3 args, it has to be "int / text / text"
    else if (nrhs == 3)	
    {	
		// 1st arg is int
        if (!mxIsDouble(prhs[0]))
			{mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "First argument must be integer");}
		// 1st arg is an empty int
		if (mxIsEmpty(prhs[0]))
			{mexErrMsgIdAndTxt("SQLITE4M:EmptyDBIDArray", "DBID must not be an empty array");}
		//2nd argument is text
        if (!mxIsChar(prhs[1]))
			{mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "Second argument must be text");}
		//3rd argument is text
        if (!mxIsChar(prhs[2]))
			{mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "Third argument must be text");}
    }
    // 0, 1 or 4+ args
    else
    {mexErrMsgIdAndTxt("SQLITE4M:ErrorInArg", "There must be 2 or 3 arguments");}
    

    //----------------------------
    // DETERMINE WHAT TO DO
    //----------------------------
	if (nrhs == 2){
		//dbid = sqlite4m('open', 'databasefile')
		if(mxIsChar(prhs[0])){
			actionToPerform = ACTION_OPEN_DB;
		}else if(mxIsChar(prhs[1])){
			string actionString = getStringFromMxArray(prhs[1]);
			//sqlite4m(dbid, 'close')
			if(actionString.compare("close") == 0){
				actionToPerform = ACTION_CLOSE_DB;
			//sqlite4m(statementId, 'finalize')
			}else if(actionString.compare("finalize") == 0)
				actionToPerform = ACTION_FINALIZE_STATEMENT;
			//query_result = sqlite4m(dbid, 'SQLQuery')
			else{
				actionToPerform = ACTION_REQUEST_DB;
			}
		//query_result = sqlite4m(statementId, {arguments})
		}else if(mxIsCell(prhs[1])){
			actionToPerform = ACTION_EXECUTE_STATEMENT;
		}
	}else if (nrhs == 3){
		string actionString = getStringFromMxArray(prhs[1]);
		//dbid = sqlite4m(dbid, 'open', 'databasefile')
		if(actionString.compare("open") == 0){
			actionToPerform = ACTION_OPEN_DB;
		}else if(actionString.compare("prepare") == 0){
			//statementId = sqlite4m(dbid, 'prepare', 'statement')
			actionToPerform = ACTION_PREPARE_STATEMENT;
		}
	}

	//----------------------------
    // DO STUFF AND GET REQUIRED ARGUMENTS
	//----------------------------
	int dbId = 0;
	string databaseFile;
	char* query;
	char* statement;
	int statementId;

	switch(actionToPerform){
		case ACTION_OPEN_DB:
			if(nrhs == 3){
				dbId = (int) *mxGetPr(prhs[0]);
				databaseFile = getStringFromMxArray(prhs[2]);
			}else{
				databaseFile = getStringFromMxArray(prhs[1]);
			}
			plhs[0] = actionOpenDB(dbId, databaseFile);
			break;
		case ACTION_CLOSE_DB:
			dbId = (int) *mxGetPr(prhs[0]);
			actionCloseDB(dbId);
			break;
		case ACTION_REQUEST_DB:
			dbId = (int) *mxGetPr(prhs[0]);
			query = getCharFromMxArray(prhs[1]);
			plhs[0] = actionRequestDB(dbId, query);
			break;
		case ACTION_PREPARE_STATEMENT:
			dbId = (int) *mxGetPr(prhs[0]);
			statement = getCharFromMxArray(prhs[2]);
			plhs[0] = actionPrepareStatement(dbId, statement);
			break;
		case ACTION_EXECUTE_STATEMENT:
			statementId = (int) *mxGetPr(prhs[0]);
			plhs[0] = actionExecuteStatement(statementId, prhs[1]);
			break;
		case ACTION_FINALIZE_STATEMENT:
			statementId = (int) *mxGetPr(prhs[0]);
			actionFinalizeStatement(statementId);
			break;
	}
}

static void actionFinalizeStatement(int statementId){
	int statementIndex = statementId - 1;
	int errorCode = sqlite3_finalize(statement_array[statementIndex]);
	if(errorCode != 0)
		{mexErrMsgIdAndTxt(errMsg(errorCode), sqlite3_errmsg(statement_db_matching[statementId - 1]));}
	statement_db_matching[statementIndex] = 0;
	statement_array[statementIndex] = 0;
}

static mxArray* actionExecuteStatement(int statementId, const mxArray* parameters){
	int statementIndex = statementId - 1;
	sqlite3_stmt* statement;
	const mwSize * numberOfParameters;
	mxArray* parameter;
	int bindResult;

	//Fetching the statement
	statement = statement_array[statementIndex];
	
	//Binding parameters to statement
	numberOfParameters = mxGetDimensions(parameters);
	int i =0;
	for(i; i < numberOfParameters[1] ;i++){
		parameter =  mxGetCell(parameters, i);
		//TODO : gestion des int64 ???
		if(mxIsChar(parameter)){
			bindResult = sqlite3_bind_text(statement, i + 1, getCharFromMxArray(parameter), -1, mxFree);
			if(bindResult != 0)
				{mexErrMsgIdAndTxt(errMsg(bindResult), sqlite3_errmsg(statement_db_matching[statementIndex]));}
		}else if(mxIsDouble(parameter)){
			bindResult = sqlite3_bind_double(statement, i + 1, (double) *mxGetPr(parameter));
			if(bindResult != 0)
				{mexErrMsgIdAndTxt(errMsg(bindResult), sqlite3_errmsg(statement_db_matching[statementIndex]));}
		}else if(mxIsNumeric(parameter)){//Then we have an int binding
			bindResult = sqlite3_bind_int(statement, i + 1, (int) *mxGetPr(parameter));
			if(bindResult != 0)
				{mexErrMsgIdAndTxt(errMsg(bindResult), sqlite3_errmsg(statement_db_matching[statementIndex]));}
		}
	}

	int columnCount;
	int resultType;
	double doubleResult;
	int intResult;
	const char * textResult;
	int isRow;
	mxArray * output;

	// Vector to store returned data from SQL request
	vector_return_line return_line;
	vector<vector_return_line> return_query;

	columnCount = sqlite3_column_count(statement);
	if(columnCount > 0)
	{
		// Memory allocation for field_names
		char **field_names = new char* [columnCount];
		for(int i = 0; i < columnCount; i++)
		{
			const char* field_name = sqlite3_column_name(statement, i);
			field_names[i] = new char [strlen(field_name)+1];
			strcpy(field_names[i], field_name);
		}

		isRow = sqlite3_step(statement);

		if(isRow != SQLITE_ROW)
		{
			sqlite3_step(statement);
			output = mxCreateDoubleMatrix(0, 0, mxREAL);
		}
		else
		{
			// As long as we have a row of data
			while(isRow == SQLITE_ROW)
			{
				// We get every column value
				for(int i = 0; i < columnCount; i++)
				{
					return_uni_data new_data;
					new_data.field_name = sqlite3_column_name(statement, i);
					resultType = sqlite3_column_type(statement, i);
					// Switch for each type of value
					switch (resultType) 
					{
					case SQLITE_INTEGER:
						intResult = sqlite3_column_int(statement, i);
						new_data.field_value = mxCreateDoubleScalar((double) intResult);
						break;
					case SQLITE_FLOAT:
						doubleResult = sqlite3_column_double(statement, i);
						new_data.field_value = mxCreateDoubleScalar((double) doubleResult);
						break;
					case SQLITE_NULL:
						new_data.field_value = mxCreateDoubleMatrix(0,0,mxREAL);
						break;
					case SQLITE_TEXT:
						const char* charDeclaredType = sqlite3_column_decltype(statement, i);
						string declaredType;
						if(charDeclaredType == NULL){
							declaredType = string("");
						}else{
							declaredType = string(charDeclaredType);
						}
						transform(declaredType.begin(), declaredType.end(), declaredType.begin(), toupper);
						const char * declaredAffinity;
						//Implementation of sqlite 5 rules of affinity. This is the full implementation, left as a comment
						//for the sake of understandability. See http://www.sqlite.org/datatype3.html for more about the
						//affinity rules.
						// /!\ strstr base comparisons with some finds
						//                             if(strstr(declaredType, "INT") != NULL)
						//                             {
						//                               declaredAffinity = "INTEGER";
						//                             }
						//                             else
						//                             {
						//                               if(strstr(declaredType, "CHAR") != NULL || strstr(declaredType, "CLOB") != NULL || strstr(declaredType, "TEXT") != NULL)
						//                               {
						//                                 declaredAffinity = "TEXT";
						//                               }
						//                               else
						//                               {
						//                                 if(strstr(declaredType, "BLOB") != NULL || strcmp(declaredType, "") == 0)
						//                                 {
						//                                   declaredAffinity = "NONE";
						//                                 }
						//                                 else
						//                                 {
						//                                   if(strstr(declaredType, "REAL") != NULL || strstr(declaredType, "FLOA") != NULL || strstr(declaredType, "DOUB") != NULL)
						//                                   {
						//                                     declaredAffinity = "REAL";
						//                                   }
						//                                   else
						//                                   {
						//                                     declaredAffinity = "NUMERIC";
						//                                   }
						//                                 }
						//                               }
						//                             }
						//This is the limited implementation of affinity rules, for the sake of performances.
						//If declaredType is NULL, we assume we have a text (used for pragma results for instance).
						if(declaredType.empty() || declaredType.find("CHAR") != string::npos || declaredType.find("CLOB") != string::npos || declaredType.find("TEXT") != string::npos)
						{
							declaredAffinity = "TEXT";
						}
						else
						{
							declaredAffinity = "OTHER";
						}
						//If the affinity is not text, as we are in the CASE of
						//a text value, we know it must be interpreted as a NaN,
						//not as a "NaN" string
						if(strcmp(declaredAffinity, "TEXT") != 0)
						{
							new_data.field_value = mxCreateDoubleScalar(mxGetNaN());
						}
						else
						{
							textResult = (const char*) sqlite3_column_text(statement, i);
							char *textFResult = new char [strlen(textResult)+1];
							strcpy(textFResult, textResult);
							new_data.field_value = mxCreateString((const char*) textFResult);
							delete textFResult;
						}
						break;
					}
					return_line.push_back(new_data);
				}
				return_query.push_back(return_line);
				return_line.clear();
				isRow = sqlite3_step(statement);
			}

			// Create StructArray
			int number_of_lines = return_query.size();
			int number_of_fields = columnCount;
			int dims[2] = {1, number_of_lines};
			output = mxCreateStructArray(2, dims, number_of_fields, (const char **) field_names);

			// Free memory used for field_names
			for(int i = 0; i < columnCount; i++)
			{
				delete [] field_names[i];
			}
			delete [] field_names;

			// Transfer value from our vector storage to the mxStructArray
			int index = 0;
			for (vector<vector_return_line>::iterator vvrl = return_query.begin(); vvrl!=return_query.end(); ++vvrl) 
			{
				int fieldnumber = 0;
				vector_return_line return_line_copy = *vvrl;
				for (vector_return_line::iterator vrl = return_line_copy.begin(); vrl!=return_line_copy.end(); ++vrl) 
				{
					mxSetFieldByNumber(output, index, fieldnumber, (*vrl).field_value);
					fieldnumber++;
				}
				index++;
			}
		}
	}
	else
	{
		sqlite3_step(statement);
		output = mxCreateDoubleMatrix(0, 0, mxREAL);
	}
	//Resetting statements for future usage
	int requestResult;
	requestResult = sqlite3_clear_bindings(statement);
	if(requestResult != 0)
			{mexErrMsgIdAndTxt(errMsg(requestResult), sqlite3_errmsg(statement_db_matching[statementIndex]));}
	requestResult = sqlite3_reset(statement);
	if(requestResult != 0)
			{mexErrMsgIdAndTxt(errMsg(requestResult), sqlite3_errmsg(statement_db_matching[statementIndex]));}
	return output;
}

static mxArray * actionPrepareStatement(int dbId, const char* statement){
	int dbIndex = dbId - 1;
	int query_result;
	sqlite3_stmt *preparedStatement;

	query_result = sqlite3_prepare_v2(db_array[dbIndex], statement, -1, &preparedStatement, 0);
	if(query_result != 0)
		{mexErrMsgIdAndTxt(errMsg(query_result), sqlite3_errmsg(db_array[dbIndex]));}

	//Free statement id lookup and assignement
	int i = 0;
	for (i; i < MAX_PREPARED_STATEMENTS && statement_array[i] != 0; i++)
	{}
	if (i >= MAX_PREPARED_STATEMENTS)
		{
			char * errMsg;
			sprintf(errMsg, "Max prepared statement in DB is %d", MAX_PREPARED_STATEMENTS);
			mexErrMsgIdAndTxt("SQLITE4M:TooManyPreparedStatements", errMsg);}
	else
	{
		statement_array[i] = preparedStatement;
		statement_db_matching[i] = db_array[dbIndex];
		return mxCreateDoubleScalar((double) i+1);
	}
}

static mxArray* actionRequestDB(int dbid, const char* query){
	int statementId;
	mxArray* mxStatementId;
	mxArray* output;

	mxStatementId = actionPrepareStatement(dbid, query);
	statementId = (int) *mxGetPr(mxStatementId);
	output = actionExecuteStatement(statementId, mxCreateCellMatrix(0,0));
	actionFinalizeStatement(statementId);
	return output;
}

static void actionCloseDB(int dbId){
		int dbIndex = dbId - 1;
		int query_result;
        // If dbid is 0, we close every db
        if(dbId == 0)
        {
			//First close all the statements (and as a consequence reset the matching table)
			for(int i = 0; i < MAX_PREPARED_STATEMENTS; i++){
				if(statement_array[i] != 0){
					actionFinalizeStatement(i + 1);
				}
			}
			//Next close all the db
            for (int i = 0; i < MAX_OPENED_DB; i++)
            {
                if(db_array[i] != 0)
                {
                    query_result = sqlite3_close(db_array[i]);
                    if(query_result != 0)
						{mexErrMsgIdAndTxt(errMsg(query_result), sqlite3_errmsg(db_array[i]));}
                    mexUnlock();
                    db_array[i] = 0;
                }
            }
        }
        // If dbid is not 0 and valid, we close it.
        else if (db_array[dbIndex] != 0)
        {
			//First close all related statements
			for(int i = 0; i < MAX_PREPARED_STATEMENTS; i++){
				if(statement_db_matching[i] == db_array[dbIndex]){
					actionFinalizeStatement(i + 1);
				}
			}
			//Then close the db
            query_result = sqlite3_close(db_array[dbIndex]);
            if(query_result != 0)
				{mexErrMsgIdAndTxt(errMsg(query_result), sqlite3_errmsg(db_array[dbIndex]));}
            mexUnlock();
            db_array[dbIndex] = 0;
        }
        else
			{mexErrMsgIdAndTxt("SQLITE4M:InexistantDBID", "Invalid DBID to close");}
}

static mxArray * actionOpenDB(int dbid, string databaseFile){
	// Make UTF8
	string utf8_databaseFile;
	string databaseFilestr = string(databaseFile);
	int query_result;  

	size_t len = databaseFilestr.length();
	if(!len)
		{mexErrMsgIdAndTxt("SQLITE4M:NoDBFilename", "DB filename can not be empty");}

	for(size_t i = 0; i < len; i++)
	{
		if(databaseFilestr[i] < 0)
		{
			utf8_databaseFile.push_back(0xC3);
			utf8_databaseFile.push_back(databaseFilestr[i] & 0xBF);
		}
		else
		{
			utf8_databaseFile.push_back(databaseFilestr[i]);
		}
	}

	int i = 0;
	// If dbid is not specified or 0, we check we can open one more db
	if(dbid == 0)
	{
		for (i; i < MAX_OPENED_DB && db_array[i] != 0; i++)
		{}
		if (i >= MAX_OPENED_DB)
		{
			char * errMsg;
			sprintf(errMsg, "Max opened DB is %d", MAX_OPENED_DB);
			mexErrMsgIdAndTxt("SQLITE4M:TooManyOpenedDB", errMsg);
		}
	}

	sqlite3 *ppDb = 0;
	query_result = sqlite3_open(utf8_databaseFile.c_str(), &ppDb);

	if(query_result != 0)
		{mexErrMsgIdAndTxt(errMsg(query_result), sqlite3_errmsg(ppDb));}
	mexLock();

	// If we have a dbid arg that is not 0
	if(dbid != 0)
	{
		// If it already exists, we close it
		if (db_array[dbid-1] != 0)
		{
			query_result = sqlite3_close(db_array[dbid]);
			if(query_result != 0)
			{mexErrMsgIdAndTxt(errMsg(query_result), sqlite3_errmsg(ppDb));}
			mexUnlock();
			db_array[dbid-1] = 0;
		}
		// We add the new dbid
		db_array[dbid-1] = ppDb;
		return mxCreateDoubleScalar((double) dbid);
	}
	// Else we give first free dbid
	else
	{
		db_array[i] = ppDb;
		return mxCreateDoubleScalar((double) i+1);
	}
}

/* AtExit function: closes all opened DB */
static void exitCallback(void)
{ 
    actionCloseDB(0);
}

static char* errMsg(int query_result)
{
    switch(query_result)
    {    
        case 1:   return ("SQLITE4M:ERROR");
        case 2:   return ("SQLITE4M:INTERNAL");
        case 3:   return ("SQLITE4M:PERM");
        case 4:   return ("SQLITE4M:ABORT");
        case 5:   return ("SQLITE4M:BUSY");
        case 6:   return ("SQLITE4M:LOCKED");
        case 7:   return ("SQLITE4M:NOMEM");
        case 8:   return ("SQLITE4M:READONLY");
        case 9:   return ("SQLITE4M:INTERRUPT");
        case 10:  return ("SQLITE4M:IOERR");
        case 11:  return ("SQLITE4M:CORRUPT");
        case 12:  return ("SQLITE4M:NOTFOUND");
        case 13:  return ("SQLITE4M:FULL");
        case 14:  return ("SQLITE4M:CANTOPEN");
        case 15:  return ("SQLITE4M:PROTOCOL");
        case 16:  return ("SQLITE4M:EMPTY");
        case 17:  return ("SQLITE4M:SCHEMA");
        case 18:  return ("SQLITE4M:TOOBIG");
        case 19:  return ("SQLITE4M:CONSTRAINT");
        case 20:  return ("SQLITE4M:MISMATCH");
        case 21:  return ("SQLITE4M:MISUSE");
        case 22:  return ("SQLITE4M:NOLFS");
        case 23:  return ("SQLITE4M:AUTH");
        case 24:  return ("SQLITE4M:FORMAT");
        case 25:  return ("SQLITE4M:RANGE");
        case 26:  return ("SQLITE4M:NOTADB");
        case 100: return ("SQLITE4M:ROW");
        case 101: return ("SQLITE4M:DONE");
    }    
}

static string getStringFromMxArray(const mxArray *prhs){
	return string(getCharFromMxArray(prhs));
}

static char* getCharFromMxArray(const mxArray *prhs){
	char *text;
	mwSize textLength;

	textLength = mxGetNumberOfElements(prhs) + 1;
	text = (char*) mxCalloc(textLength, sizeof(char));
	mxGetString(prhs, text, textLength);
	return text;
}