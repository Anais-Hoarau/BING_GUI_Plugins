tic;
directory = uigetdir(char(java.lang.System.getProperty('user.home')));
disp('+++++++++++++++++++++++++ Script P1_FindPOI +++++++++++++++++++++++++');
P1_FindPOI(directory);
disp('+++++++++++++++++++++++++ Script P2_FindIntersection +++++++++++++++++++++++++');
P2_FindIntersection(directory);
disp('+++++++++++++++++++++++++ Script P3_BasicCalculation +++++++++++++++++++++++++');
P3_BasicCalculation(directory);
disp('+++++++++++++++++++++++++ Script P3_CalculatePercent +++++++++++++++++++++++++');
P3_CalculatePercent(directory);
disp('+++++++++++++++++++++++++ Script P4_FindBetweenIntersections +++++++++++++++++++++++++');
P4_FindBetweenIntersections(directory);
disp('+++++++++++++++++++++++++ Script P5_AddRemarks +++++++++++++++++++++++++');
listing = dir(fullfile(directory, 'c*.xls'));
isPresentRemarksFile = ~isempty(listing);
if isPresentRemarksFile
    P5_AddRemarks(directory);
else
   disp('Script skipped, no remark file found'); 
end
disp('+++++++++++++++++++++++++ Script P6_Curves +++++++++++++++++++++++++');
P6_Curves(directory);
disp('+++++++++++++++++++++++++ Script P6_CurvesByDistance +++++++++++++++++++++++++');
P6_CurvesByDistance(directory);
disp('+++++++++++++++++++++++++ Script P7_CreateKMLforSituations +++++++++++++++++++++++++');
P7_CreateKMLforSituations(directory);
disp('+++++++++++++++++++++++++ Script P13_PrepareErrorSituations +++++++++++++++++++++++++');
P13_PrepareErrorSituations(directory);
disp(['+++++++++++++++++++++++++ Processed in ' num2str(toc/60) 'm +++++++++++++++++++++++++']);