% Import des données cardiaques à partir du fichier matlab créer avec
% AcqKnowledge 4.1.

function struct_MP150 = import_MP150_struct_simu(MP150_file_name, vars)
load(MP150_file_name);

%% TO MODIFY : variables and items lists depending on MP150 recordings 
items = {'values', 'unit', 'comments'};

%% create missing variables in case of conversion from .acq to .mat
if ~exist('isi', 'var')
    isi = 1;
end
if ~exist('isi_units', 'var')
    isi_units = char('ms');
end
if ~exist('labels', 'var') && exist('acq', 'var')
    labels = char(acq.hdr.per_chan_data.comment_text);
end
if ~exist('start_sample', 'var')
    start_sample = 0;
end
if ~exist('units', 'var') && exist('acq', 'var')
    units = char(acq.hdr.per_chan_data.units_text);
end


%% create acq struct to loop on items
if ~exist('acq', 'var')
    acq.values = data;
else
    acq.values = acq.data;
end

acq.unit=cell(1,size((units(:,:)),1));
for i=1:size((units(:,:)),1)
    acq.unit{1,i}=strtrim(units(i,:));
end

acq.comments=cell(1,size(labels(:,:),1));
for i=1:1:size(labels(:,:),1)
    acq.comments{1,i}=strtrim(labels(i,:));
end

%% create structure_MP150
N = length(acq.data);
%Test si les unités sont bien des 'ms'
if strcmp(isi_units,'ms')
    time=zeros(N,1);
    for i=1:1:N
        time(i) = start_sample + i*isi - 1;
    end
else
    exception = MException('DataErr:UnitConflict', ...
        ['Please check the time data unit from MP150 imported data.']);
    throw(exception);
end

% création de la variable temps dans la strcuture MP150
struct_MP150.data.time.values = time/1000;
struct_MP150.data.time.unit = 's';
struct_MP150.data.time.comments = 'Time recorded with the MP150 device converted from ms to s';

for i = 1:length(vars)
    if ~isempty(vars{i})
        for j = 1:length(items)
            if iscell(acq.(items{j}))
                struct_MP150.data.(vars{i}).(items{j}) = acq.(items{j}){:,i};
            else
                struct_MP150.data.(vars{i}).(items{j}) = acq.(items{j})(:,i);
            end
        end
    end
end

%création de META
struct_MP150.META.synchronised=false;
struct_MP150.META.frequenceData = 1/(isi/1000);
    
end