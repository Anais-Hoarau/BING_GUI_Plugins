function s=espectralRR_sareas4(Y)

label2=' %%)\n';
label3=' %%)\n';
label4=' %%)\n\n';

if round(Y.psd_avlf)==Y.psd_avlf,label2=['.000',label2];end,
if round(Y.psd_alf)==Y.psd_alf,label3=['.000',label3];end,
if round(Y.psd_ahf)==Y.psd_ahf,label4=['.000',label4];end,

s=sprintf([ '**************************\n',...
            '* FREQUENCY-DOMAIN STATS *\n',...
            '**************************\n\n',...
            'Total Power: ',num2str(Y.psd_aatotal),' ms^2\n\n',...
            'VLF: ',num2str(Y.psd_aavlf),' ms^2',...
            ' (',num2str(Y.psd_avlf),label2,...
            'LF:  ',num2str(Y.psd_aalf),' ms^2',...
            ' (',num2str(Y.psd_alf),label3,...
            'HF:  ',num2str(Y.psd_aahf),' ms^2',...
            ' (',num2str(Y.psd_ahf),label4,...
            'LF/HF Ratio: ',num2str(Y.psd_rlfhf),'\n\n\n',...
            ]);




