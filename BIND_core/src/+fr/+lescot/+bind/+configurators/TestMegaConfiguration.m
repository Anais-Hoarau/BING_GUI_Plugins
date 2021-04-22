clear all;
clear console;
clc;

monTrip=fr.lescot.bind.kernel.implementation.SQLiteTrip('C:\Users\hoarau\Desktop\Bind_GIT\BIND_GUIplugins\BIND_examples\trip_307\demoTrip.trip', 0.04, false)
import fr.lescot.bind.configurators.*
c1=fr.lescot.bind.configurators.Configuration()

argX=fr.lescot.bind.configurators.Argument('trip', false, monTrip, 2);
arg1=fr.lescot.bind.configurators.Argument('position2points', false, [10 60] , 100);

c2=fr.lescot.bind.configurators.Configuration()
argc2=fr.lescot.bind.configurators.Argument('p', false, [400 400] , 100);
argc21=fr.lescot.bind.configurators.Argument('trip', false, 'test' , 2);

listArg={arg1,argX};
c1.setArguments(listArg);
c2.setArguments({argc2, argc21});

%fr.lescot.bind.configurators.PluginConfigurator_simplif.lancePluginStatic( monTrip,c1.findArgumentWithOrder(3).getValue(),'Magneto' )
% ouvre le magneto avec config c1 :
%fr.lescot.bind.plugins.Magneto_simplif(monTrip,c1.findArgumentWithOrder(3).getValue())

MalisteDesConfig={c1, c2};
%cc1=MalisteDesConfig{1}.findArgumentWithOrder(2)


megaConfig=fr.lescot.bind.configurators.MegaConfigurator();
megaConfig.addConfigurationInMega(c1);
megaConfig.addConfigurationInMega(c2);

megaConfig.getConfigurationNum(2).getArguments()
%{ 
reponse
  1×2 cell array

    {1×1 fr.lescot.bind.configurators.Argument}    {1×1 fr.lescot.bind.configurators.Argument}
%}

% fonctionne et ouvre les plugins un à un : megaConfig.OuvreToutPluginAVecConfig(monTrip)
length(MalisteDesConfig)


%%sauvegarder les variables de mega config
megaConfigToSave=megaConfig;
[FileName, PathName]=uiputfile('*.mat','Sauvegarder la configuration des plugins ("workspace" de megaConfigurator)');
nomCompletToSave= strcat(PathName,FileName);
save(nomCompletToSave, 'monTrip', 'megaConfigToSave');


%%charger les variables de mega config
[FileName, PathName]=uigetfile('*.mat', 'Récupérer la configuration des plugins (issues de megaConfigurator');
nomCompletToGet= strcat(PathName,FileName);
load(nomCompletToGet);
megaConfigToSave.OuvreToutPluginAVecConfig(monTrip)



