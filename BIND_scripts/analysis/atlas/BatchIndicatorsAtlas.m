function BatchIndicatorsAtlas()
    cd('C:\Documents and Settings\matlab\Bureau\Atlas');
    varList = {
        './03/sc8/atlas.trip', '8';
        './03/sc7/atlas.trip', '7';
        './03/sc6/atlas.trip', '6';
        './03/sc5/atlas.trip', '5';
        './03/sc2/atlas.trip', '2';
        './03/sc1/atlas.trip', '1';
        './05/scen8/atlas.trip', '8';
        './05/scen7/22071059.trip', '7';
        './05/scen6/22071048.trip', '6';
        './05/scen5/22071040.trip', '5';
        './05/scen2/22071019.trip', '2';
        './05/scen1/22071009.trip', '1';
        './06/sc8/25072041.trip', '8';
        './06/sc7/25072030.trip', '7';
        './06/sc6/25072002.trip', '6';
        './06/sc6/25072005.trip', '6';
        './06/sc6/25072012.trip', '6';
        './06/sc5/25071950.trip', '5';
        './06/sc2/25071933.trip', '2';
        './06/sc1/25071922.trip', '1';
        './07/sc8/atlas.trip', '8';
        './07/sc7/26071533.trip', '7';
        './07/sc6/26071518.trip', '6';
        './07/sc5/26071507.trip', '5';
        './07/sc2/26071450.trip', '2';
        './07/sc1/26071441.trip', '1';
        './08/sc8/27071558.trip', '8';
        './08/sc6/27071519.trip', '6';
        './08/sc6/27071527.trip', '6';
        './08/sc6/27071528.trip', '6';
        './08/sc5/27071507.trip', '5';
        './08/sc2/27071446.trip', '2';
        './08/sc1/27071437.trip', '1';
        './09/sc8/27071911.trip', '8';
        './09/sc8/27071915.trip', '8';
        './09/sc7/27071859.trip', '7';
        './09/sc6/27071839.trip', '6';
        './09/sc5/27071828.trip', '5';
        './09/sc2/27071812.trip', '2';
        './09/sc1/27071803.trip', '1';
        './10/sc8/28071556.trip', '8';
        './10/sc7/28071544.trip', '7';
        './10/sc6/28071526.trip', '6';
        './10/sc6/28071527.trip', '6';
        './10/sc6/28071542.trip', '6';
        './10/sc5/28071512.trip', '5';
        './10/sc2/28071454.trip', '2';
        './10/sc2/28071456.trip', '2'
        './10/sc2/28071458.trip', '2';
        './10/sc1/atlas.trip', '1';
        %'./11/sc8/28071827.trip', '8';
        './11/sc7/28071812.trip', '7';
        './11/sc6/28071750.trip', '6';
        './11/sc5/28071740.trip', '5';
        './11/sc2/28071727.trip', '2';
        './11/sc1/28071717.trip', '1';
        './12/sc8/29071105.trip', '8';
        './12/sc8/29071108.trip', '8';
        './12/sc7/29071046.trip', '7';
        './12/sc7/29071048.trip', '7';
        './12/sc6/29071026.trip', '6';
        './12/sc6/29071027.trip', '6';
        './12/sc5/29071011.trip', '5';
        './12/sc2/29070953.trip', '2';
        './12/sc1/29070945.trip', '1';
        './13/sc8/01081112.trip', '8';
        './13/sc7/01081032.trip', '7';
        './13/sc6/atlas.trip', '6';
        './13/sc5/01080959.trip', '5';
        './13/sc2/01080942.trip', '2';
        './13/sc1/atlas.trip', '1';
        './14/sc8/02081858.trip', '8';
        './14/sc7/02081847.trip', '7';
        './14/sc6/atlas.trip', '6';
        './14/sc5/02081817.trip', '5';
        './14/sc2/02081740.trip', '2';
        './14/sc1/atlas.trip', '1';
        './15/sc8/03081108.trip', '8';
        './15/sc7/03081057.trip', '7';
        './15/sc6/03081045.trip', '6';
        './15/sc5/03081035.trip', '5';
        './15/sc2/03081015.trip', '2';
        './15/sc1/03081009.trip', '1';
        './04/sc8/atlas.trip', '8';
        './04/sc7/atlas.trip', '7';
        './04/sc6/atlas.trip', '6';
        './04/sc5/atlas.trip', '5';
        './04/sc2/atlas.trip', '2';
        './04/sc1/atlas.trip', '1'
    };

    for i = 1:1:length(varList)
        try
            disp(['------------------------------------' varList{i, 1} '------------------------------------']);
            calculateIndicators(varList{i, 1});
        catch ME
            disp('Error caught, logging and skipping to next file');
            log = fopen('BatchIndicatorsAtlas.log', 'a+');
            fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' varList{i, 1}]);
            fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
            fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
            fclose(log);
        end
    end
end