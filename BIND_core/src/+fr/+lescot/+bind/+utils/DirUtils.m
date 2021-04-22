%{
Class:
This class contains some static methods in relation with directories content listing
%}
classdef DirUtils

    
    properties
    end
    
    methods(Static)
        
        %{
        Function:
        Returns a cell array of string listing all the files contained in
        the specified directory or it's subdirectories. If pattern is
        specified, only files matching the regexp pattern will be returned.
        The pattern is to the file name, including the directories part,
        starting from the specified directory. *This is not a wildcard as in
        the dir method for example !* It applies a fully featured regepx !
 
        So for example let's imagine the
        following arborescence, and imagine myFolder is our current folder :
        (start code)
        + myFolder
        +--- file1.m
        +--- file2.m
        +--- mySubFolder
            +--- file3.cpp
            +--- file4.cpp
        (end)
        recursiveFileListing('.') will return
        >{'.\file1.m'  '.\file2.m' '.\mySubFolder\file3.cpp' '.\mySubFolder\file4.cpp'}
        recursiveFileListing('.', '.*\.cpp$') will return
        >{'.\mySubFolder\file3.cpp' '.\mySubFolder\file4.cpp'}
        recursiveFileListing('.', 'sub') will return
        >{'.\mySubFolder\file3.cpp' '.\mySubFolder\file4.cpp'}
        Arguments:
        packageName - name of the package ('package.subpackage').
        
        Returns:
        outMFiles : cell list with the name of the m files in the packages
        outClassesNames : cell list with the name of the classes in the packages
        
        %}
        function out = recursiveFileListing(directory, pattern)
            if(nargin == 1)
                pattern = '.*';
            end
            import fr.lescot.bind.utils.DirUtils;
            out = {};
            directoryContent = dir(directory);
            for i = 1:1:length(directoryContent)
                item = directoryContent(i);
                if(~any(strcmp({'.' '..'}, item.name)))
                    prefixedName = [directory filesep item.name];
                    if(item.isdir);
                       subDirectoryFiles = DirUtils.recursiveFileListing(prefixedName, pattern);
                       out = [out(:); subDirectoryFiles(:)];
                    else
                       if strcmp(prefixedName, regexp(prefixedName, pattern, 'match'))
                            out{end + 1} = prefixedName;
                       end
                    end
                end
            end
        end
    end
    
end

