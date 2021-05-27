function espectralRR
% PARA INSTRUCOES SOBRE USO, LEIA O ARQUIVO ESPECTRALRR_README.DOC
%
%

clear %limpa a memoria do matlab
clc %limpa a tela de comando

global psd_handle PSD F line1 line2 line3 aavlf aalf aahf aatotal avlf alf ahf rlfhf anlf anhf
global fill filename intervaloRR tempoRR verdadeiros ebs_indices intervaloRR_original tempoRR_original
global eventos prontuario pro_filename vlf2 lf2 hf2 ordem_ar escala maxF minF minP maxP algoritmo metodo
global fs janela N vlf1 lf1 hf1
global te_vlf2 tx_vlf1 te_lf2 tx_lf1 te_hf2 tx_hf1 te_minF te_maxF te_minP te_maxP tx_minF
global te_ordemAR te_N te_fs rb_normal rb_monolog rb_loglog fr_escala tx_escala
global fr_bandas tx_vlf tx_lf tx_hf tx_vlf1 tx_lf1 tx_hf1 tx_vlfa tx_lfa tx_hfa
global te_hf2 te_lf2 te_vlf2 tx_hzvlf tx_hzlf tx_hzhf pb_commouse fr_areas1
global tx_areas1 tx_areas2 tx_areas3 fr_psd tx_maxF rb_fhr rb_lhp rb_lhr tx_fs
global tx_maxP te_minP tx_minP tx_N te_N fr_algoritmo tx_algoritmo rb_mar rb_dft
global rb_ambos fr_janela tx_janela rb_ret rb_ham rb_han rb_bla rb_bar cb_fill tx_mensagem
global te_file tx_mensagens fr_prontuario tx_prontlabel pb_edita pb_atualiza pb_versinal
global pb_html tx_ordemAR fr_metodo tx_metodo rb_fhpis rb_fhpc rb_fhp rb_fhris rb_fhrc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%estes parametros podem ser facilmente alterados para personalizacao:
%

numerodajanela=100; %numero da figura do MatLab a ser usada como janela principal
fig_largura=1024;fig_altura=702; %largura e altura da janela do programa

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cria a tela do programa
%
figure(numerodajanela+1);close(numerodajanela+1);
figure(numerodajanela);close(numerodajanela);
main_window=figure(numerodajanela);
clf;
set(main_window,'Name','(GPDS/ENE/UnB) ECGLAB - Frequency-Domain Analysis','Position',[1,29,fig_largura,fig_altura],'Color',[.95 .95 .95])

mensageminicial=sprintf([...
      'ECGLAB - Frequency-Domain Analysis of R-R Intervals\n\n\n',...
      'Jo�o Luiz Azevedo de Carvalho, Ph.D.\n\n\n',...
      'Digital Signal Processing Group\n',...
      'Department of Electrical Engineering\n',...
      'School of Technology\n',...      
      'University of Brasilia\n\n\n',...
      'joaoluiz@gmail.com',...
]);     
tx_mensagem=uicontrol('Style','text','String',mensageminicial,'Position',[100 150 800 500],'FontSize',14,...
   'HorizontalAlignment','center','BackgroundColor',[.95 .95 .95]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%inicializacao de variaveis
%

fid=fopen('filename.cfg','r');filename=fgetl(fid);fclose(fid); % nome do arquivo a ser aberto
%ponto=find(filename=='.');filename=[filename(1:ponto(length(ponto))-1),'.irr']; %adapta a extensao
intervaloRR=-1;
tempoRR=-1;
intervaloRR_original=-1;
tempoRR_original=-1;
verdadeiros=-1;
ebs_indices=[];
eventos=[];
prontuario='';
pro_filename='';
psd_handle=-1; %handle do axes do espectro
PSD=-1; %amplitudes do espectro
F=-1; %eixo da frequencia
vlf2=-1; %limite das freq. muito baixas
lf2=-1; %limite das freq. baixas
hf2=-1; %limite das freq. altas
vlf1=-1; %limite das freq. muito baixas
lf1=-1; %limite das freq. baixas
hf1=-1; %limite das freq. altas
ordem_ar=-1; %ordem do modelo ar
escala='xxxxxx'; %escala usada: normal, loglog ou monolog
maxF=-1; %maior frequencia plotada
minF=-1; %menor frequencia plotada
minP=-1;
maxP=-1;
algoritmo='xxx'; %algoritmo usado: mar, dft, amb
janela='xxx'; %tipo de janela
metodo='xxxxx'; %metodo de correcao dos EBs
fs=-1; %taxa de amostragem com as splines
N=-1;
line1=-1;
line2=-1;
line3=-1;
aavlf=-1;
aalf=-1;
aahf=-1;
aatotal=-1;
avlf=-1;
alf=-1;
ahf=-1;
rlfhf=-1;
anlf=-1;
anhf=-1;
fs_ant=-1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: abrir arquivo
%
espectralrr_callbacks(-1);

%frame
fr_abrirarquivo=uicontrol('Style','frame','Position',[20 20 580 60],'BackgroundColor',[1 1 1]);

%texto pedindo o nome do arquivo
tx_file=uicontrol('Style','text',...
   'String','Enter the full path to the IRR or ASCII file to be opened:',...
   'Position',[30 50 300 20],'BackgroundColor',[1 1 1]);

%text edit para entrar com o nome do arquivo
te_file=uicontrol('Style','edit',...
   'String',filename,...
   'Position',[30 30 400 20],'BackgroundColor',[1 1 1],...
	'CallBack','espectralrr_callbacks(0);');

%botao para abrir o arquivo
pb_abrir_irr=uicontrol('Style','pushbutton',...
   'String','Open IRR',...
   'Position',[440 30 70 30],'BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(1);');
   
%botao para abrir o arquivo
pb_abrir_ascii=uicontrol('Style','pushbutton',...
   'String','Open ASCII',...
   'Position',[520 30 70 30],'BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(2);');
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: caixa de mensagens
%
   
%borda em volta da caixa de texto de mensagens 
fr_mensagens=uicontrol('Style','frame','Position',[620 20 390 60],'BackgroundColor',[1 1 1]);
   
%caixa de texto para mensagens
tx_mensagens=uicontrol('Style','text',...
   'Position',[630 30 370 40],'BackgroundColor',[1 1 1],...
   'String', ['IRR files are the ones obtained from ECGLabRR or EctopicsRR. R-R intervals in ASCII must ',...
      'contain a single interval value per line.']);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: edicao do prontuario
%

fr_prontuario=uicontrol('Style','frame','Position',[20 100 290 40],'BackgroundColor',[1 1 1],'Visible','off');
tx_prontlabel=uicontrol('Style','text','Position',[50 105 50 30],'BackgroundColor',[1 1 1],'Visible','off','String','Patient Record:','horiz','left');

pb_edita=uicontrol('Style','pushbutton','Position',[110 110 80 20],'Visible','off','String','Edit','BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(3);');

pb_atualiza=uicontrol('Style','pushbutton','Position',[200 110 80 20],'Visible','off','String','View/Update','BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(4);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: controles para definir as bandas
%
fr_bandas=uicontrol('Style','frame','Position',[20 160 290 80],'Visible','off','BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caixas de texto (label)
%

tx_vlf=uicontrol('Style','text','Visible','off',...
   'String','Very Low Freqs.:',...
   'Position',[30 210 95 20],'BackgroundColor',[1 1 1]);

tx_lf=uicontrol('Style','text','Visible','off',...
   'String','Low Frequencies:',...
   'Position',[30 190 95 20],'BackgroundColor',[1 1 1]);

tx_hf=uicontrol('Style','text','Visible','off',...
   'String','High Frequencies:',...
   'Position',[30 170 95 20],'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caixas de texto (pontos iniciais das bandas)
%

tx_vlf1=uicontrol('Style','text','Visible','off',...
   'Position',[125 210 30 20],...
	'String',num2str(vlf1),'BackgroundColor',[1 1 1]);

tx_lf1=uicontrol('Style','text','Visible','off',...
   'Position',[125 190 30 20],...
	'String',num2str(lf1),'BackgroundColor',[1 1 1]);

tx_hf1=uicontrol('Style','text','Visible','off',...
   'Position',[125 170 30 20],...
	'String',num2str(hf1),'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caixas de texto (label)
%

tx_vlfa=uicontrol('Style','text','Visible','off',...
   'String','to',...
   'Position',[155 210 10 20],'BackgroundColor',[1 1 1]);

tx_lfa=uicontrol('Style','text','Visible','off',...
   'String','to',...
   'Position',[155 190 10 20],'BackgroundColor',[1 1 1]);

tx_hfa=uicontrol('Style','text','Visible','off',...
   'String','to',...
   'Position',[155 170 10 20],'BackgroundColor',[1 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
% caixas de edicao de texto (pontos finais das bandas)
%

te_vlf2=uicontrol('Style','edit','Visible','off',...
   'Position',[165 210 40 20],...
   'Value', vlf2,'BackgroundColor',[1 1 1],...
	'String',num2str(vlf2),...
   'Callback','espectralrr_callbacks(5);');

te_lf2=uicontrol('Style','edit','Visible','off',...
   'Position',[165 190 40 20],...
   'Value', lf2,'BackgroundColor',[1 1 1],...
	'String',num2str(lf2),...
   'Callback','espectralrr_callbacks(6);');

te_hf2=uicontrol('Style','edit','Visible','off',...
   'Position',[165 170 40 20],...
   'Value', hf2,'BackgroundColor',[1 1 1],...
	'String',num2str(hf2),...
   'Callback','espectralrr_callbacks(7);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% caixas de texto (label Hz)
%

tx_hzvlf=uicontrol('Style','text','Visible','off',...
   'String','Hz','BackgroundColor',[1 1 1],...
   'Position',[205 210 14 20]);

tx_hzlf=uicontrol('Style','text','Visible','off',...
   'String','Hz','BackgroundColor',[1 1 1],...
   'Position',[205 190 14 20]);

tx_hzhf=uicontrol('Style','text','Visible','off',...
   'String','Hz','BackgroundColor',[1 1 1],...
   'Position',[205 170 14 20]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cb_fill=uicontrol('Style','checkbox','Visible','off',...
   'String','Fill','Position',[230 175 70 10],'BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(8);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% botao para definir as bandas com o mouse
%

pb_commouse=uicontrol('Style','pushbutton','Visible','off',...
   'String','Use Mouse',...
   'Position',[230 200 70 30],'BackgroundColor',[1 1 1],...
   'CallBack','espectralrr_callbacks(9);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: caixa de texto com as areas
%

fr_areas1=uicontrol('Style','frame','Visible','off','Position',[330 90 161+155+115 150],'BackgroundColor',[1 1 1]);
tx_areas1=uicontrol('Style','text','Visible','off',...
   'String','','FontName','Courier New','FontSize',9,...
   'HorizontalAlignment','left',...'BackgroundColor','w',...
   'Position',[340 105 140 130],'BackgroundColor',[1 1 1]);
tx_areas2=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','','FontName','Courier New','FontSize',9,...
   'HorizontalAlignment','left',...'BackgroundColor','w',...
   'Position',[490 95 144+125 140]);
tx_areas3=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','','FontName','Courier New','FontSize',9,...
   'HorizontalAlignment','left',...'BackgroundColor','w',...
   'Position',[490+134 105+60 134 130-60]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: delimitacao do eixo F
%

fr_psd=uicontrol('Style','frame','Visible','off','Position',[780 575 230 100],'BackgroundColor',[1 1 1]);

tx_minF=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Freq. From:','HorizontalAlignment','right',...
   'Position',[790 645 57 20]);

te_minF=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(minF),...
   'Position',[850 645 40 20],...
   'Callback','espectralrr_callbacks(10);');

tx_maxF=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Hz        To:','HorizontalAlignment','left',...
   'Position',[900 645 60 20]);

te_maxF=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(maxF),...
   'Position',[960 645 40 20],...
      'Callback','espectralrr_callbacks(11);');

tx_minP=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Ampl. From:','hor','right',...
   'Position',[781 625 59 20]);

te_minP=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(minP),...
   'Position',[840 625 50 20],...
   'Callback','espectralrr_callbacks(12);');

tx_maxP=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String',sprintf('ms2/Hz  To:'),'hor','right',...
   'Position',[890 625 60 20]);

te_maxP=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(maxP),...
   'Position',[950 625 50 20],...
      'Callback','espectralrr_callbacks(13);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: numero de pontos do PSD
%

tx_N=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','# of Pts.:',...
   'Position',[900 645-40 60 20]);

te_N=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(N),...
   'Position',[960 645-40 40 20],...
   'Callback','espectralrr_callbacks(14);');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: ordem do AR
%

tx_ordemAR=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','AR Order:',...
   'Position',[790 605 60 20]);

te_ordemAR=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(ordem_ar),...
   'Position',[850 605 40 20],...
   'Callback','espectralrr_callbacks(15);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: taxa de amostragem do sinal R-R
%

tx_fs=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','HRV signal interpolation rate:',...
   'Position',[790 580 170 20]);

te_fs=uicontrol('Style','edit','Visible','off','BackgroundColor',[1 1 1],...
   'String',num2str(ordem_ar),...
   'Position',[960 585 40 20],...
   'Callback','espectralrr_callbacks(16);');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: escolha da escala utilizada
%

fr_escala=uicontrol('Style','frame','Visible','off','BackgroundColor',[1 1 1],'Position',[780 465 90 100]);

tx_escala=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Scale:',...
   'Position',[790 535 70 20]);

rb_normal=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Normal',...
   'Position',[790 515 70 20],'Callback','espectralrr_callbacks(17);');

rb_monolog=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Monolog',...
   'Position',[790 495 70 20],'Callback','espectralrr_callbacks(18);');

rb_loglog=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Log-Log',...
   'Position',[790 475 70 20],'Callback','espectralrr_callbacks(19);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	GUI: escolha do algoritmo: AR ou DFT
%

fr_algoritmo=uicontrol('Style','frame','Position',[880 465 130 100],'Visible','off','BackgroundColor',[1 1 1]);

tx_algoritmo=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Algorithm:',...
   'Position',[890 535 110 20]);

rb_mar=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','AR Model',...
   'Position',[890 515 110 20],'Callback','espectralrr_callbacks(20);');

rb_dft=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Fourier Transform',...
   'Position',[890 495 110 20],'Callback','espectralrr_callbacks(21);');

rb_ambos=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Both',...
   'Position',[890 475 110 20],'Callback','espectralrr_callbacks(22);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: escolha da janela utilizada
%

fr_janela=uicontrol('Style','frame','Visible','off','BackgroundColor',[1 1 1],'Position',[780 355 230 100]);

tx_janela=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Window:','Hor','center',...
   'Position',[790 425 210 20]);

rb_ret=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Rectangular',...
   'Position',[810 405 80 20],'Callback','espectralrr_callbacks(23);');

rb_bar=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Bartlett',...
   'Position',[810 385 70 20],'Callback','espectralrr_callbacks(24);');

rb_ham=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Hamming',...
   'Position',[810 365 70 20],'Callback','espectralrr_callbacks(25);');

rb_han=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Hanning',...
   'Position',[900 405 70 20],'Callback','espectralrr_callbacks(26);');

rb_bla=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','Blackman',...
   'Position',[900 385 70 20],'Callback','espectralrr_callbacks(27);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	GUI: escolha do metodo de correcao de batimentos ectopicos
%

fr_metodo=uicontrol('Style','frame','Position',[780 145 230 200],'Visible','off','BackgroundColor',[1 1 1]);

tx_metodo=uicontrol('Style','text','Visible','off','BackgroundColor',[1 1 1],...
   'String','Method:','Hor','center',...
   'Position',[790 315 210 20]);

rb_fhpis=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHPIS: R-R signal interpolated w/ splines',...
   'Position',[790 295 213 20],'Callback','espectralrr_callbacks(28);');

rb_fhpc=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHPc: corrected series of R-R intervals',...
   'Position',[790 275 210 20],'Callback','espectralrr_callbacks(29);');

rb_fhp=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHP: series of normal R-R intervals',...
   'Position',[790 255 210 20],'Callback','espectralrr_callbacks(30);');

rb_fhris=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHRIS: HR signal interpolated w/ splines',...
   'Position',[790 235 213 20],'Callback','espectralrr_callbacks(31);');

rb_fhrc=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHRc: corrected instantaneous HR',...
   'Position',[790 215 219 20],'Callback','espectralrr_callbacks(32);');

rb_fhr=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','FHR: normal instantaneous HR',...
   'Position',[790 195 210 20],'Callback','espectralrr_callbacks(33);');

rb_lhp=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','LHP: Lomb-Scargle Periodogram of R-R',...
   'Position',[790 175 210 20],'Callback','espectralrr_callbacks(34);');

rb_lhr=uicontrol('Style','radio','Visible','off','BackgroundColor',[1 1 1],...
   'String','LHR: Lomb-Scargle Periodogram of HR',...
   'Position',[790 155 214 20],'Callback','espectralrr_callbacks(35);');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: gera html
%

pb_html=uicontrol('Style','push','Position',[880 95 130 40],'Visible','off','BackgroundColor',[1 1 1],...
   'String','HTML Report','CallBack','espectralrr_callbacks(36);');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GUI: ver sinal R-R
%

pb_versinal=uicontrol('Style','push','Position',[780 95 80 40],'Visible','off','BackgroundColor',[1 1 1],...
   'String','Display Signal','CallBack','espectralrr_callbacks(37);');