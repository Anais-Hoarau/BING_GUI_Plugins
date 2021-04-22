% In Matlab, just call the function "sqlite4m" with the following arguments:
% 
% 
% 	dbib/query_result = sqlite4m([dbid,] SQLQuery [, databasefile])
% 
% 
% The three basics uses of sqlite4m are:
% 
% 
% :- Open
% 
% 
% 	dbid = sqlite4m([dbid,] 'open', 'databasefile')
% 
% 
% Opens the database 'databasefile'. If there is no such database, it will be created.
% 
% You can have the following cases:
% 	- dbid not used by another database, then the database will be opened with dbid.
% 	- dbid is already used by another database, then the already opened database will be closed and the new database will be opened with dbid.
% 	- dbid is 0 or not specified, then first free dbid will be attributed to the newly opened database.
% 
% Returns the dbid you can use for next calls on this database.
% 
% You can have a maximum of 100 opened databases at the same time. You have to be aware that with such a big number of opened databases, performances will decrease and memory usage will increase if you don't work properly.
% 
% 
% :- Close
% 
% 
% 	sqlite4m(dbid, 'close')
% 
% 
% Closes the database dbid.
% 
% You can have the following cases:
% 	- dbid is a previously opened db, then it will be closed.
% 	- dbid is 0, then all opened databases will be closed.
% 
% Returns nothing.
% 
% 
% :- SQLQuery
% 
% 
% 	query_result = sqlite4m(dbid, 'SQLQuery')
% 
% 
% Executes SQL Query
% 
% You can have the following cases:
% 	- dbid is specified, then SQLQuery is executed on dbid.
% 
% Returns SQL Query result as a structure array.

Important note regarding NaN values : The "NaN" strings stored columns that don't have the "TEXT" affinity will be retrieved as NaN values in Matlab,
in order to provide consistent values types in the cell arrays for further processing. See http://www.sqlite.org/datatype3.html for more informations
about the concept of affinity in SQLite and the rules used to determine it.