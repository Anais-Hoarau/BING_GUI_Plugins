function out = extract_seuils_frein(tc,value,ind_first,offset_last)

    appuis = cherche_tc_franchissement_seuil(tc,value,0.5);
    
    topD1.debut = appuis(ind_first,1);
    topD1.fin = appuis(ind_first,2)
    out.syncDebut.topFrein1 = topD1;
    topD2.debut = appuis(ind_first+1,1);
    topD2.fin = appuis(ind_first+1,2)
    out.syncDebut.topFrein2 = topD2;
    topD3.debut = appuis(ind_first+2,1);
    topD3.fin = appuis(ind_first+2,2)
    out.syncDebut.topFrein3 = topD3;
    
    topF1.debut = appuis(end-offset_last-2,1);
    topF1.fin = appuis(end-offset_last-2,2)
    out.syncFin.topFrein1 = topF1;
    topF2.debut = appuis(end-offset_last-1,1);
    topF2.fin = appuis(end-offset_last-1,2)
    out.syncFin.topFrein2 = topF2;
    topF3.debut = appuis(end-offset_last,1);
    topF3.fin = appuis(end-offset_last,2)
    out.syncFin.topFrein3 = topF3;
    
end
