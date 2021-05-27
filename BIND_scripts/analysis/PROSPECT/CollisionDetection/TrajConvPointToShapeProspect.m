function [A,B,C,D] = TrajConvPointToShapeProspect(X,Y,Vx,ref,idx)
tripobjectsshapes = import_trip_objects_shapes_PROSPECT('\\vrlescot\PROSPECT\CODAGE\trip_objects_shapes.csv');

%% GET THE SHAPES SIZE PARAMETERS
if strcmp(ref(1:3),'car') && ~isempty(find(tripobjectsshapes(idx,:),1))
    Xmin = tripobjectsshapes(idx,1);
    Xmax = tripobjectsshapes(idx,2);
    Ymin = tripobjectsshapes(idx,3);
    Ymax = tripobjectsshapes(idx,4);
elseif (strcmp(ref(1:3),'vru') || strcmp(ref(1:3),'cyc') || strcmp(ref(1:3),'ped')) && ~isempty(find(tripobjectsshapes(idx,:),1))
    Xmin = tripobjectsshapes(idx,5);
    Xmax = tripobjectsshapes(idx,6);
    Ymin = tripobjectsshapes(idx,7);
    Ymax = tripobjectsshapes(idx,8);
end

%% SHAPE COORDONATES IN OBJECT BASIS (v1,v2)
A = [Xmax,-Ymin];
B = [Xmax,Ymax];
C = [-Xmin,Ymax];
D = [-Xmin,-Ymin];

Vy = [Vx(2),-Vx(1)]; 

%% CHANGE OF BASIS TO GET SHAPE COORDONATES IN WORLD REFERENCE
A = [X+dot(A,Vx),Y+dot(A,Vy)];
B = [X+dot(B,Vx),Y+dot(B,Vy)];
C = [X+dot(C,Vx),Y+dot(C,Vy)];
D = [X+dot(D,Vx),Y+dot(D,Vy)];

end