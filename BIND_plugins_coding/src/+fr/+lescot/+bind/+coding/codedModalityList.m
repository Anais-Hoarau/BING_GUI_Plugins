classdef codedModalityList < handle
    
    properties
        
        
        handleGraphic;
        
        name;
        
        Position;
        
    end
    
    methods
        
        function this = codedModalityList(parentFigure)
            %% Create Event List Panel
            this.handleGraphic.ModalityListPanel = uipanel('Parent',parentFigure,...
                'Title','Modalités codés :',...
                'Units','pixel',...
                'Position',[0 0 100 100],...
                'FontWeight','bold',...
                'Clipping','on');
            
            button_string =  'Supprimer l''occurence';
            this.handleGraphic.RemoveCodedModalityButton = uicontrol('Parent',this.handleGraphic.ModalityListPanel,...
                'Style','pushbutton',...
                'String', button_string, ...
                'Enable', 'inactive');
            
            
            this.handleGraphic.ListCodedModality = uitable('Parent',this.handleGraphic.ModalityListPanel,...
                'Enable', 'inactive', ...
                'RowName',[]);
            
        end
        
        function out = getHandles(this)
            out = {this.handleGraphic.ModalityListPanel ...
                this.handleGraphic.RemoveCodedModalityButton ...
                this.handleGraphic.ListCodedModality};
        end
        
        function out = getPosition(this)
            out = get(this.handleGraphic.ModalityListPanel,'Position');
        end
        
        function out = getName(this)
            out = get(this.handleGraphic.ModalityListPanel,'Title');
        end
        
        function setPosition(this, pos)
            if pos(3)>140 && pos(4)>=40
                set(this.handleGraphic.ModalityListPanel,'Position', pos);
                this.adjustListandButtonPosition
            end
        end
        
        function setName(this,name)
            set(this.handleGraphic.ModalityListPanel,'Title', name);
        end
        
        function setColumnNames(this,columnName)
            handles = this.getHandles;
            columnWidth = cell(1, length(columnName));
            for i=1:1:length(columnName)
                if i==1
                    columnWidth{i} = 20;
                else
                    columnWidth{i} = 'auto';
                end
            end
            set(handles{3},'ColumnName',columnName);
            set(handles{3},'ColumnWidth',columnWidth)
        end
        
        function adjustListandButtonPosition(this)
            panel_pos = get(this.handleGraphic.ModalityListPanel,'Position');
            
            set(this.handleGraphic.RemoveCodedModalityButton,'Units','Normalized')
            set(this.handleGraphic.RemoveCodedModalityButton,'Position', [0.05 0.05 0.85 0.1])
            
            set(this.handleGraphic.RemoveCodedModalityButton,'Units','Pixel')
            Rem_Button_Pos_Pixel = get(this.handleGraphic.RemoveCodedModalityButton, 'Position');
            Rem_Button_Pos_1 = Rem_Button_Pos_Pixel(1);
            Rem_Button_Pos_2 = 10;
            Rem_Button_Pos_3 = Rem_Button_Pos_Pixel(3);
            
            set(this.handleGraphic.RemoveCodedModalityButton,'Units','Characters')
            Rem_Button_Pos_Char = get(this.handleGraphic.RemoveCodedModalityButton, 'Position');
            Rem_Button_Pos_Char(4) = 2;
            set(this.handleGraphic.RemoveCodedModalityButton, 'Position', Rem_Button_Pos_Char)
            
            set(this.handleGraphic.RemoveCodedModalityButton,'Units','Pixel');
            Rem_Button_Pos_Pixel = get(this.handleGraphic.RemoveCodedModalityButton,'Position');
            Rem_Button_Pos_4 = Rem_Button_Pos_Pixel(4);
            set(this.handleGraphic.RemoveCodedModalityButton,'Position', [Rem_Button_Pos_1 Rem_Button_Pos_2 Rem_Button_Pos_3 Rem_Button_Pos_4])
            
            set(this.handleGraphic.ListCodedModality , 'Position', [5 ...
                Rem_Button_Pos_2+Rem_Button_Pos_4+10 ...
                max(panel_pos(3)-10,1) ...
                max(panel_pos(4)-(Rem_Button_Pos_2+Rem_Button_Pos_4+30),1)])
        end
        
        function setCodedModalities(this, table, varargin)
            handles = this.getHandles;
            cols = get(handles{3}, 'ColumnName');
            if (length(cols) == 3 && size(table,1) == 2) || (length(cols) == 4 && size(table,1) == 3)
                table = [num2cell(1:1:size(table,2)) ; table];
            end
            
            html_table = table;
            if ~isempty(varargin) && ~isempty(varargin{1})
                currentModalityIndex = varargin{1};
                html_row = this.htmlWrapper(html_table(:,currentModalityIndex));
                html_table(:,currentModalityIndex) = html_row;
            end
            
            columnEditable = {};
            columnFormat = {};
            if size(table,1) == 3
                columnEditable = [false,false,false];
                columnFormat = {'char','char','char'};
            elseif size(table,1) == 4
                columnEditable = [false,false,false,false];
                columnFormat = {'char','char','char','char'};
            end
            html_table = html_table';
            html_table = html_table(end:-1:1,:);
            set(handles{3},'ColumnEditable',columnEditable,...
                'ColumnFormat', columnFormat,...
                'Data', html_table);
        end
        
        function out = getCodedModalities(this)
            handles = this.getHandles;
            out = get(handles{3},'Data');
        end
        
        function setActive(this)
            set(this.getHandles{2}, 'Enable', 'on')
            set(this.getHandles{3}, 'Enable', 'on')
        end
        
        function html_data_row = htmlWrapper(this, table_row)
            hex_textColor = '#0000FF';
            hex_backgroundColor = '#CCFFFF';
            
            convert2str = @(x) num2str(x);
            str_data_row = cellfun(convert2str, table_row, 'UniformOutput', false);
            
            % Table width is hard coded, because UITABLE get ColumnWidth
            % does not return the acutal width but the initial one.
            html_fun = @(x,y) ['<HTML><TABLE width=100 bgcolor=' hex_backgroundColor '><TD><FONT color=' hex_textColor '><b>' x '</Font></TD></TABLE></HTML>'];
            html_data_row = cellfun(html_fun, str_data_row, 'UniformOutput', false);
        end
        
        function setClickCallback(this, func_handle)
            handles = this.getHandles;
            set(handles{3}, 'CellSelectionCallback', func_handle);
        end
        
        function setSuppressOccurenceCallback(this,func_handle)
            handles = this.getHandles;
            set(handles{2}, 'Callback', func_handle);
        end
        
    end
    
end


