%%%%%%%% Tests parameters %%%%%%%%
global parameter_examplesPath;
parameter_examplesPath = 'C:\Users\sornette\Documents\lescot-expl\BIND\trunk\examples';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
packagesList = fr.lescot.bind.utils.ClassPathUtils.getAllSubPackages('fr.lescot.bind.test');
command = 'runtests(';
for i = 1:1:length(packagesList)
    if i ~= 1
        command = [command ',''' packagesList{i} ''''];
    else
        command = [command '''' packagesList{i} ''''];
    end
end
command = [command ', ''-verbose'')'];
eval(command);
%%%%%%%% Clearing tests parameters %%%%%%%%
clear global parameter_examplesPath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
