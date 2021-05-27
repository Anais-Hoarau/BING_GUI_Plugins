% Import des données cardiaques à partir du fichier matlab créer avec
% AcqKnowledge 4.1.

function struct_MP150 = import_MP150(MP150_file_name)

load(MP150_file_name);

N_voies =  size(data,2);


if N_voies ==3

N = length(data);   
    %Test si les unités sont bien des 'ms'
    if strcmp(isi_units,'ms')
        time=zeros(N,1);
        for i=1:1:N
        time(i)=start_sample + i*isi;
        end
    else
         exception = MException('DataErr:UnitConflict', ...
                    ['Please check the time data unit from MP150 imported data.']);
        throw(exception);
    end  
    
    % Facon très sale d'importer les données MP 150
    
    % création de la variable temps dans la strcuture MP150
    struct_MP150.data.time.values = time/1000;
    struct_MP150.data.time.unit = 's';
    struct_MP150.data.time.comments = 'Time recorded with the MP150 device converted from ms to s';
    
    % création des datas dans la structure MP150
    struct_MP150.data.TopCons.values = data(:,1);
    struct_MP150.data.Cardiaque.values = data(:,2);
    struct_MP150.data.Cardiaque_filtre.values = data(:,3);
    
    unit=cell(1,size((units(:,:)),1));
    for i=1:1:size((units(:,:)),1)
        unit{1,i}=units(i,:);
    end
    
    %création des unités
    struct_MP150.data.TopCons.unit = unit{1,1}; 
    struct_MP150.data.Cardiaque.unit = unit{1,2};
    struct_MP150.data.Cardiaque_filtre.unit = unit{1,3};
    
    comments=cell(1,size(labels(:,:),1));
    for i=1:1:size(labels(:,:),1)
        comments{1,i}=labels(i,:);
    end
    %création des unités
    struct_MP150.data.TopCons.comments =comments{1,1}; 
    struct_MP150.data.Cardiaque.comments = comments{1,2};
    struct_MP150.data.Cardiaque_filtre.comments = comments{1,3};
    

    %création de META
    struct_MP150.META.synchronised=false;
    struct_MP150.META.frequenceDATA = 1/(isi/1000);

elseif N_voies ==4

N = length(data);   
    %Test si les unités sont bien des 'ms'
    if strcmp(isi_units,'ms')
        time=zeros(N,1);
        for i=1:1:N
        time(i)=start_sample + i*isi;
        end
    else
         exception = MException('DataErr:UnitConflict', ...
                    ['Please check the time data unit from MP150 imported data.']);
        throw(exception);
    end  
    
    % Facon très sale d'importer les données MP 150
    
    % création de la variable temps dans la strcuture MP150
    struct_MP150.data.time.values = time/1000;
    struct_MP150.data.time.unit = 's';
    struct_MP150.data.time.comments = 'Time recorded with the MP150 device converted from ms to s';
    
     % création des datas dans la structure MP150
    struct_MP150.data.TopCons.values = data(:,1);
    struct_MP150.data.DeclareMindWandering.values = data(:,2);
    struct_MP150.data.Cardiaque.values = data(:,3);
    struct_MP150.data.Cardiaque_filtre.values = data(:,4);
    
    unit=cell(1,size((units(:,:)),1));
    for i=1:1:size((units(:,:)),1)
        unit{1,i}=units(i,:);
    end
    
    %création des unités
    struct_MP150.data.TopCons.unit = unit{1,1};
    struct_MP150.data.DeclareMindWandering.unit = unit{1,2};
    struct_MP150.data.Cardiaque.unit = unit{1,3};
    struct_MP150.data.Cardiaque_filtre.unit = unit{1,4};
    
    comments=cell(1,size(labels(:,:),1));
    for i=1:1:size(labels(:,:),1)
        comments{1,i}=labels(i,:);
    end
    %création des unités
    struct_MP150.data.TopCons.comments =comments{1,1};
    struct_MP150.data.DeclareMindWandering.comments = comments{1,2};
    struct_MP150.data.Cardiaque.comments = comments{1,3};
    struct_MP150.data.Cardiaque_filtre.comments = comments{1,4};
    
    %création de META
    struct_MP150.META.synchronised=false;
    struct_MP150.META.frequenceDATA = 1/(isi/1000);   
    
else

errordlg('Err - Import MP150 Data : number of recorded channels')
    
end
    
end