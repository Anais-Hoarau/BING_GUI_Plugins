 fileList = {
%RT01
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_01\RT01-R2T1_AvecCorola 25052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_01\RT01-R1T1_SansCorola 25052010.txt'

%RT02
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_02\RT02-R2T1_SansCorola 25052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_02\RT02-R2T5_SansCorola 25052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_02\RT02-R1T1_AvecCorola 25052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_02\RT02-R1T3_AvecCorola 25052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_02\RT02-R1T3(2)_AvecCorola 25052010.txt'

%RT03 en attente

%RT04
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_04\RT04-R1T1_SansCorola 31052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_04\RT04-R1T3_SansCorola 31052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_04\RT04-R2T1_AvecCorola 31052010.txt'
%'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_04\RT04-R2T5_AvecCorola 31052010.txt'
 
%RT05
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_05\RT05-R2T1_SansCorola 31052010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_05\RT05-R1T1_AvecCorola 31052010.txt'
 
%RT06
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_06\RT06-R1T1_SansCorola 07062010.txt'
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_06\RT06-R1T3_SansCorola 07062010.txt'
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_06\RT06-R2T1_AvecCorola 07062010.txt'
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_06\RT06-R2T4_AvecCorola 07062010.txt'
% 
%RT07 
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_07\RT07-R1T1_AvecCorola 09062010.txt'
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_07\RT07-R2T1_SansCorola 09062010.txt'
'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\RT_07\RT07-R2T2_SansCorola 09062010.txt'
% 
%LB01
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_01\LB01-R1T1_SansCorola 02062010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_01\LB01-R1T3_SansCorola 02062010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_01\LB01-R2T1_AvecCorola 02062010.txt'

%LB04
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_04\LB04-R2T1_SansCorola 16062010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_04\LB04-R1T1_AvecCorola 16062010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_04\LB04-R1T3_AvecCorola 16062010.txt'

%LB05
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_05\LB05-R2T1_SansCorola 16062010.txt'
% 'E:\1_COROLA\Manip_SCOOP\0_Données MANIP\1_Données_Raffinées\LB_05\LB05-R2T2_SansCorola 16062010.txt'

};

for i=1:length(fileList)
    [pathstr, name, ext, versn] = fileparts(fileList{i});
    importScoop2BIND([name  ext],[pathstr '\']);
end

