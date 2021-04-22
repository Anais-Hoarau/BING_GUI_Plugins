%{
Class:
This class contains some static methods used to manipulate classes
%}
classdef ClassPathUtils
    
    methods(Static = true)

        %{
        Function:
        Returns a list of string containing all the names of the m files
        available in all the subdirectories of the package
        
        Arguments:
        packageName - name of the package ('package.subpackage').
        
        Returns:
        outMFiles : cell list with the name of the m files in the packages
        outClassesNames : cell list with the name of the classes in the packages
        
        %}
        function [outMFiles,outClassesNames] = getAllMFilesInPackage(packageName)
            %disp(packageName);
            allMFiles={};
            allClassesNames={};
            indice = 1;
            packageName = char(packageName);
            packageName = strrep(packageName, '.', [filesep() '+']);
            infos = what(packageName);
            mFilesArray = {infos.m};
            mFiles = {};
            for i = 1:1:length(mFilesArray)
                mFiles = {mFiles{:} mFilesArray{i}{:}};
            end
            
            subPackagesArrayOfArrays = {infos.packages};
            %subPackagesArray = C{length(C)}; % the last cell seems to be the good one
            subPackages = {};
            for i = 1:1:length(subPackagesArrayOfArrays)
                subPackagesArray = subPackagesArrayOfArrays{i};
                for j = 1:1:length(subPackagesArray)
                    subPackages = {subPackages{:} char(subPackagesArray(j))};
                end
            end
            subPackages = unique(subPackages);
            
            if ~isempty(mFiles)
               for i=1:1:length(mFiles)
                   fileName = strcat(packageName,filesep(),mFiles(i));
                   allMFiles(indice) = fileName;
                   className = strrep(fileName, '.m', '');
                   className = strrep(className, [ filesep() '+'], '.');
                   className = strrep(className, filesep(), '.');
                   allClassesNames(indice) = className;
                   indice = indice +1;
               end
            end
            
            if ~isempty(subPackages)
                for i=1:1:length(subPackages)
                    subPackage = subPackages(i);
                    subPackageName = strcat(packageName,'\+',subPackage);
                    [mFiles, classesNames] = fr.lescot.bind.utils.ClassPathUtils.getAllMFilesInPackage(subPackageName);
                    if ~isempty(mFiles)
                        for j=1:1:length(mFiles)
                            allMFiles(indice) = mFiles(j);
                            allClassesNames(indice) = classesNames(j);
                            indice = indice +1;
                        end
                    end
                end
            end
            
            outMFiles = allMFiles;
            outClassesNames =  allClassesNames;
        end
        
        %{
        Function:
        Returns a list of string containing all the names of the m files
        available in all the subdirectories of the package
        
        Arguments:
        classNameList : cell array of string with available classnames
        (output from getAllMFilesInPackage)
        class : name of the class to filter 
        
        Returns:
        outValidClassesNames : the names of the classes that extend class
        
        %}
        function outValidClassesNames = classesExtendingClass(classNameList,class)
            validClassesNames={};
            indice = 1;
            
            for i=1:1:length(classNameList)
                className = char(classNameList(i));
                SC = superclasses(className);
                
                for j=1:1:length(SC)
                    laSC = char(SC(j));
                    
                    if strcmp(laSC,class)
                        % une des classes meres de cette classe correspond
                        validClassesNames(indice) = classNameList(i);
                        indice = indice + 1;
                    end                  
                   
                end
            end
            
            outValidClassesNames = validClassesNames;
           
        end
        
        %{
        Function:
        Returns a list of all the subpackages of the argument package (including
        the argument itself).
        
        Arguments:
        packageName : A string representing a package name.
        
        Returns:
        out : A cell array of strings.
        
        %}
        function out = getAllSubPackages(packageName)
            packagesList = {packageName};
            metaPackage = meta.package.fromName(packageName);
            subPackages = [metaPackage.Packages];
            for i = 1:1:length(subPackages)
                packagesList = [packagesList fr.lescot.bind.utils.ClassPathUtils.getAllSubPackages(subPackages{i}.Name)]; %#ok<AGROW>
            end
            out = packagesList;
        end
        
    end
    
end

