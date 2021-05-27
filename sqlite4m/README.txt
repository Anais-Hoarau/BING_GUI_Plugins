---------------------- README /\ SQLITE4M ----------------------



----- Introduction



sqlite4m is an interface between Matlab and SQLite.
It can be used on Windows x86 and x64 platforms.

It was developed using Martin Kortmann's specifications of its own mksqlite. The whole source code has been redeveloped without any use of his work.



----- Installation



To install sqlite4m, just extract sqlite4m.mexwXX to a directory and add this directory to the Matlab search path. XX corresponds to your Matlab version, either 32 or 64 bits.



----- Return Value



The return value of sqlite4m is a Struct Array (See http://www.mathworks.com/access/helpdesk/help/techdoc/ref/struct.html).
The array has 1 row, and as many column as your request returned lines.
Each element of the array is a struct, that corresponds to a line of you request return. The "fields" of those structs are the names of the columns that are returned by the request. Values are values of those columns for the given line.



----- Use sqlite4m



The use of sqlite4m is exactly the same as mksqlite.

In Matlab, just call the function "sqlite4m" with the following arguments:


	dbib/query_result = sqlite4m([dbid,] SQLQuery [, databasefile])


The three basics uses of sqlite4m are:


:- Open


	dbid = sqlite4m([dbid,] 'open', 'databasefile')


Opens the database 'databasefile'. If there is no such database, it will be created.

You can have the following cases:
	- dbid not used by another database, then the database will be opened with dbid.
	- dbid is already used by another database, then the already opened database will be closed and the new database will be opened with dbid.
	- dbid is 0 or not specified, then first free dbid will be attributed to the newly opened database.

Returns the dbid you can use for next calls on this database.

You can have a maximum of 100 opened databases at the same time. You have to be aware that with such a big number of opened databases, performances will decrease and memory usage will increase if you don't work properly.


:- Close


	sqlite4m(dbid, 'close')


Closes the database dbid.

You can have the following cases:
	- dbid is a previously opened db, then it will be closed.
	- dbid is 0, then all opened databases will be closed.

Returns nothing.


:- SQLQuery


	query_result = sqlite4m(dbid, 'SQLQuery')


Executes SQL Query

You can have the following cases:
	- dbid is specified, then SQLQuery is executed on dbid.

Returns SQL Query result as a structure array.



----- (Re)Build sqlite4m



sqlite4m source code can be found in sqlite4m.cpp.
To rebuild it, you can execute buildit.m. This will generate sqlite4m.mexw32 and sqlite4m.mexw64.
To use this script that build both mexw32 and mex64, you must have Microsoft Visual Studio 8 (2005) installed, and its cross compiler.

This script only works on a win32 platform, and only generate mex for 32 and 64 bits Windows. It will add Matlab 64 bits libs, so the execution of the script might be long.

If you have a newer version, you have to specify it in both mexopts_32 and mexopts_64, at lines 22 and 23 (and maybe elsewhere, depending on what's new).
Those lines are about the installation directory of Visual Studio.
Since Matlab doesn't support cross-compiling natively, customised mexopts files are used, so that prevent the script from being used on other platforms.



----- 