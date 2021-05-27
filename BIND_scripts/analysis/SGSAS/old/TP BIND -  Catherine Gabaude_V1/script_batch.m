listing_trips = dir('*.trip');
for i=1:length(listing_trips)
   disp(['le trip ' listing_trips(i).name ' est encours de traitement' ])
    
    Creer_situation_Curve(listing_trips(i).name)
    
    Remplir_Situation(listing_trips(i).name,'curve')
    
end