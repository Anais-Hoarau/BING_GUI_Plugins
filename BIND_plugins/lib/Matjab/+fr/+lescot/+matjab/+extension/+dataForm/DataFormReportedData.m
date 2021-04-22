%Class: fr.lescot.matjab.extension.dataForm.DataFormReportedData
classdef DataFormReportedData < handle
    
    properties(Access = private)
        smackReportedData;
    end
    
    methods
        
        function this = DataFormReportedData(varargin)
            %Complicated stuff to be able to load the inner class Item from Java
            classLoader = org.jivesoftware.smackx.FormField().getClass().getClassLoader();
            dataClass = java.lang.Class.forName('org.jivesoftware.smackx.packet.DataForm$ReportedData', false, classLoader);
            constructors = dataClass.getConstructors();
            constructor = constructors(1);
            %Appy the correct constructor according to varargin
            if strcmpi('org.jivesoftware.smackx.DataForm$ReportedData', class(varargin{1}))
                this.smackReportedData = varargin{1};
            else
                %Transform the cell array into a Vector
                vector = java.util.Vector;
                cellArray = varargin{1};
                for i = 1:1:length(cellArray)
                    vector.add(cellArray{i});
                end
                this.smackReportedData = constructor.newInstance(vector);
            end
        end
        
        function out = unwrap(this)
            out = this.smackReportedData;
        end
        
        function out = getFields(this)
            import fr.lescot.matjab.extension.dataForm.*;
            iterator = this.smackReportedData.getFields();
            out = {};
            while(iterator.hasNext())
                out = {out{:} FormField(iterator.next())};
            end
        end
        
        function out = toXML(this)
           out = this.smackReportedData.toXML(); 
        end
    end
    
end

