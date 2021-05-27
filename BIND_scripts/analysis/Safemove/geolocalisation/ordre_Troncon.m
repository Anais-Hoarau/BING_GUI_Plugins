cl% Une fois que l'on a les point de r�f�rence correspondant
% on va liste les diff�rents tron�ons rencontr�s sur le parcours
% dans l'ordre d'appartition !
A=cellstr(safemove.gis.troncon.values);
[B, indices] = unique(A(50000:60000));
indices_sorted = sort(indices);
C = A(indices_sorted);

% on trace en dynamique le parcours, tron�on par tron�on
figure,
hold on
for j = 1:length(C)
    %     j = j+1
    % trac� du segment
    lat = traceJC_IGN.latitude(strcmp(traceJC_IGN.IDtroncoon,char(C(j))));
    long = traceJC_IGN.longitude(strcmp(traceJC_IGN.IDtroncoon,char(C(j))));
    scatter (long, lat, 10);
%% FIXME (impossible actuellement)
%     % trac� superpos� de la progression sur le tron�on
%     latsEgo = safemove.gis.latMap.values(strcmp(traceJC_IGN.id,char(C(j))));
%     longsEgo = safemove.gis.longMap.values(strcmp(traceJC_IGN.id,char(C(j))));
%     M = latsEgo(:)~=0 & ~isnan(latsEgo(:)) & longsEgo(:)~=0 & ~isnan(longsEgo(:));
%     latsEgo = latsEgo(M);
%     longsEgo = longsEgo(M);
%     if (~isempty(latsEgo) && ~isempty(longsEgo))
%         for k=1:length(latsEgo)
%             scatter (longsEgo(k), latsEgo(k), 15, 'r');
%             pause (.002);
%         end
%     end
    C(j)
    pause(0.3)
end
