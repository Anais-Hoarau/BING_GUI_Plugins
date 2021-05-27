function sqlite4m_test

    database = 'my_testdb_';
    table = 'test_table';

    NumOfSamples = 10000;
    NumOfDBs = 5;

    fprintf('Creating %d DBs\n', NumOfDBs);
    for i=1:NumOfDBs
        dbid(i) = sqlite4m('open', [database num2str(i)]);
        sqlite4m(dbid(i), 'PRAGMA synchronous = OFF');
        sqlite4m(dbid(i), ['create table ' table ' (Val_char32 char(32), Val_double double, Val_float float, Val_int int, Val_tinyint tinyint, Val_bit bit, Val_char255 char(255))']);
    end

    disp ('------------------------------------------------------------');

    values = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';

    try
        for i=1:NumOfDBs    
            sqlite4m(dbid(i), 'begin');
            fprintf ('Create %d entries on DBID %d\n', NumOfSamples, i);
            tic;
            for idx=1:NumOfSamples
                sqlite4m(dbid(i), ['insert into ' table ' (Val_char32, Val_double, Val_char255) values (''' sprintf('Val_char32_%d_%d', i, idx) ''', ' num2str(idx) ', ''' values ''')']);
            end
            sqlite4m(dbid(i), 'commit');
            a = toc;
            fprintf ('Done for DBID %d, %f seconds = %d entries per second\n', i, a, int32(NumOfSamples/a));
        end
    catch
    end

    fprintf ('Question number of entries\n');
    for i=1:NumOfDBs
        res = sqlite4m(dbid(i), ['select count(*) as result from ' table]);
        fprintf ('select count(*) on db %d on returns the result %d\n', i, res.result);
    end

    fprintf ('Summarize all the values between 10 and 75\n');
    for i=1:NumOfDBs
        res = sqlite4m(dbid(i), ['select sum(Val_double) as sum from ' table ' where Val_double between 10 and 75']);
        fprintf ('Result from sum on DBID %d is %d\n', i, res.sum);
    end
    disp ('------------------------------------------------------------');
    fprintf('Closing all DBs\n');
    sqlite4m(0, 'close');
    fprintf('Opening all DBs\n');

    for i=1:NumOfDBs
        dbid(i) = sqlite4m('open', [database num2str(i)]);
    end

    disp ('Read all records into an array');
    for i=1:NumOfDBs
        tic;
        res = sqlite4m(dbid(i), ['SELECT * FROM ' table]);
        a = toc;
        fprintf ('Done for DBID %d, %f seconds = %d records per second\n', i, a, int32(NumOfSamples/a));
    end

    sqlite4m(0, 'close');

    for i=1:NumOfDBs
        delete ([database num2str(i)]);
    end
    
    disp ('------------------------------------------------------------');
    disp('Testing NaN management in various column types');
    db = sqlite4m('open', [database 'NaN']);
    sqlite4m(db,  ['CREATE TABLE ' table ' (Val_char32 CHAR(32), Val_double DOUBLE, Val_float FLOAT, Val_int INT, Val_tinyint TINYINT, Val_bit BIT, Val_char255 CHAR(255), Val_bool BOOLEAN)']);
    sqlite4m(db, ['INSERT INTO ' table ' VALUES(''NaN'',''NaN'',''NaN'',''NaN'',''NaN'',''NaN'',''NaN'',''NaN'')']); 
    result = sqlite4m(db, ['SELECT * FROM ' table]);
    disp(result);
    sqlite4m(db, 'close');
    delete([database 'NaN']);
    disp ('------------------------------------------------------------');
    disp ('Test finished.');
end