%Class: fr.lescot.matjab.extension.dataForm.FormFieldOption
classdef FormFieldOption < handle

    properties(Access = private)
        smackOption;
    end
    
    methods
        
        function this = FormFieldOption(varargin)
            %Complicated stuff to be able to load the inner class Option from Java
            classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
            optionClass = java.lang.Class.forName('org.jivesoftware.smackx.FormField$Option', false, classLoader);
            stringClass = java.lang.Class.forName('java.lang.String', false, classLoader);
            arguments = javaArray('java.lang.Class', 1);
            arguments(1) = stringClass;
            optionConstructorWithOneArg = optionClass.getConstructor(arguments);
            arguments = javaArray('java.lang.Class', 2);
            arguments(1:2) = stringClass;
            optionConstructorWithTwoArg = optionClass.getConstructor(arguments);
            %Analyse varargin and build the corresponding object
            if size(varargin,2) == 2
                arguments = javaArray('java.lang.String', 2);
                arguments(1) = java.lang.String(varargin{1});
                arguments(2) = java.lang.String(varargin{2});
                this.smackOption = optionConstructorWithTwoArg.newInstance(arguments);
            else
                if size(varargin,2) == 1
                    if strcmp('org.jivesoftware.smackx.FormField$Option', class(varargin{1}))
                        this.smackOption = varargin{1};
                    else
                        arguments = javaArray('java.lang.String', 1);
                        arguments(1) = java.lang.String(varargin{1});
                        this.smackOption = optionConstructorWithOneArg.newInstance(arguments);
                    end
                end
            end
        end
        
        function out = unwrap(this)
            out = this.smackOption;
        end
        
        function out = getLabel(this)
            out = this.smackOption.getLabel();
        end
        
        function out = getValue(this)
            out = this.smackOption.getValue();
        end
        
        function out = toXML(this)
            out = this.smackOption.toXML();
        end
           
    end
    
end

