function out = extract_variation_frequence_echantillonage(tc,value)
    diff_temps = diff(value);
    diff_tc = cherche_tc_franchissement_seuil(tc,1-diff_temps,0.5);
    % calculate the time length
    len_palier = diff_tc(:,2)-diff_tc(:,1);
    % remove first and last as they might be shorter and unrepresentative
    len_palier_without_first_without_last = len_palier(2:end-1);
    % interesting values:
    out.min = min(len_palier_without_first_without_last);
    out.max = max(len_palier_without_first_without_last);
    out.mean = mean(len_palier_without_first_without_last);
end