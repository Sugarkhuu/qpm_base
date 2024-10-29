%%%%%%%%
%%% PREPARATION OF THE DATABASE
%%%%%%%%

%% Housekeeping
clearvars
close all

addpath utils

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% loading database
d=dbload('data.csv');

%% transform GDP

d.GDP_10 = d.GDP_10*d.GDP_15(qq(2015,1))/d.GDP_10(qq(2015,1));
d.GDP_05 = d.GDP_05*d.GDP_10(qq(2010,1))/d.GDP_05(qq(2010,1));
d.GDP = [d.GDP_05;d.GDP_10;d.GDP_15];
d.GDP_MINE_10 = d.GDP_MINE_10*d.GDP_MINE_15(qq(2015,1))/d.GDP_MINE_10(qq(2015,1));
d.GDP_MINE_05 = d.GDP_MINE_05*d.GDP_MINE_10(qq(2010,1))/d.GDP_MINE_05(qq(2010,1));
d.GDP_MINE = [d.GDP_MINE_05;d.GDP_MINE_10;d.GDP_MINE_15];
d.GDP_OTH = d.GDP - d.GDP_MINE;

%% seasonal adjustment
exceptions = {'RS', 'D4L_CPI_TAR', 'RS_RW'};
d = dbbatch(d, '$0_seas', 'x12(d.$0)', 'namelist',fieldnames(d)-exceptions, 'fresh', false);

%% log of variables
d = dbbatch(d, 'L_$1', '100*log(d.$0)', 'namefilter', '(.*)_seas');

%% defining the real exchange rate
d.L_Z = d.L_S + d.L_CPI_RW - d.L_CPI;

%% growth rate, qoq and yoy
d = dbbatch(d, 'DLA_$1', '4*diff(d.$0)', 'namefilter', 'L_(.*)', 'fresh', false);
d = dbbatch(d, 'D4L_$1', 'diff(d.$0,-4)', 'namefilter', 'L_(.*)', 'fresh', false); 

%% real variables 
% domestic real interest rate
d.RR = d.RS - d.D4L_CPI; 

% foreign real interest rate
d.RR_RW = d.RS_RW - d.D4L_CPI_RW; 

%% trends and gaps -- HPF
list = {'L_GDP','L_GDP_MINE','L_GDP_OTH', 'RR', 'RR_RW', 'L_GDP_RW'}; 
for i = 1:length(list)
    [d.([list{i} '_BAR']), d.([list{i} '_GAP'])] = hpf(d.(list{i}));
end

[d.L_Z_BAR, d.L_Z_GAP] = hpf(d.L_Z, qq(2013,1):qq(2024,1))

d.DLA_GDP_BAR = 4*diff(d.L_GDP_BAR);
d.DLA_Z_BAR = 4*diff(d.L_Z_BAR);

%% Foreign Output gap - HP filter with judgements

% judgement on the foreign output gap
% Eh survalj: https://www.imf.org/en/Publications/WEO/Issues/2020/09/30/world-economic-outlook-october-2020
% Mun 2018-2019 onii gapiig HP filter ajluulsan Amgaa dargiin unelsen GAP-ar avav
%2020 onoos https://www.imf.org/en/Publications/CR/Issues/2023/02/02/Peoples-Republic-of-China-2022-Article-IV-Consultation-Press-Release-Staff-Report-and-529067
% 'People�s Republic of China: 2022 Article IV, February 3, 2023'
% report-oos avch ulirliin noloog WEO-n zarim toonuudiig ashiglaj avav.
% Override if necessary using WEO, and so on:
JUDGEMENT = tseries(qq(2018,1):qq(2024,1),[0.29 0.18 -0.14 0.06 0.25 -0.24 -0.80 -0.45 -3 -3.5 -3.5 -4 -2 -1 -1.5 -2 -3.0 -2.8 -2.8 -2.4 -2.0 -1.4 -1.4 -1.1 -1.0]);
[d.L_GDP_RW_BAR, d.L_GDP_RW_GAP] = hpf(d.L_GDP_RW,inf,'lambda',1600,'level',d.L_GDP_RW-JUDGEMENT);

%% saving the database
dbsave(d, 'results/history_data.csv'); 

%% report - stylized Facts
disp('Generating Stylized Facts Report...');
x = report.new('Stylized Facts report');

% Figures
rng = get(d.GDP,'range');

sty = struct();
sty.line.linewidth = 1.0;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'a';'r'};
sty.legend.orientation = 'horizontal';
sty.axes.box = 'on';

x.figure('Nominal Variables','subplot',[3,2],'style',sty,'range',rng,...
  'dateformat','YYFP',...
  'legendLocation','SouthOutside');

x.graph('Headline Inflation (%)','legend',true);
x.series('',[d.DLA_CPI d.D4L_CPI],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Foreign Inflation (%)','legend',true);
x.series('',[d.DLA_CPI_RW d.D4L_CPI_RW],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Nominal Exchange Rate: LCY per 1 FCY','legend',false);
x.series('',[d.S]);

x.graph('Nominal Exchange Rate (%)','legend',true);
x.series('',[d.DLA_S d.D4L_S],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('Nominal Interest Rate (% p.a.)','legend',false);
x.series('',[d.RS]);

x.graph('Foreign Nominal Interest Rate (% p.a.)','legend',false);
x.series('',[d.RS_RW]);

x.pagebreak();

% New figure
x.figure('Real Variables','subplot',[2,2],'style',sty,'range',rng,...
  'dateformat','YYFP','legendLocation','SouthOutside');

x.graph('GDP Growth (%)','legend',true);
x.series('',[d.DLA_GDP d.D4L_GDP],'legendEntry=',{'q-o-q','y-o-y'});

x.graph('GDP (100*log)','legend',true);
x.series('',[d.L_GDP d.L_GDP_BAR],'legendEntry=',{'level','trend'});

x.graph('Mining GDP (100*log)','legend',true);
x.series('',[d.L_GDP_MINE d.L_GDP_MINE_BAR],'legendEntry=',{'level','trend'});

x.graph('Non-mining GDP (100*log)','legend',true);
x.series('',[d.L_GDP_OTH d.L_GDP_OTH_BAR],'legendEntry=',{'level','trend'});

x.pagebreak();

x.figure('Real Variables (cont.)','subplot',[2,2],'style',sty,'range',rng,...
  'dateformat','YYFP','legendLocation','SouthOutside');

x.graph('Real Interest Rate (% p.a.)','legend',false);
x.series('',[d.RR d.RR_BAR],'legendEntry=',{'level','trend'});

x.graph('Real Exchange Rate (100*log)','legend',false);
x.series('',[d.L_Z d.L_Z_BAR],'legendEntry=',{'level','trend'});

x.graph('Foreign GDP (100*log)','legend',false);
x.series('',[d.L_GDP_RW d.L_GDP_RW_BAR],'legendEntry=',{'level','trend'});

x.graph('Foreign Real Interest Rate (% p.a.)','legend',false);
x.series('',[d.RR_RW d.RR_RW_BAR],'legendEntry=',{'level','trend'});

x.pagebreak();

x.figure('Gaps','subplot',[3,2],'style',sty,'range',rng,'dateformat','YYFP');

% x.graph('GDP Gap (%)','legend',false);
% x.series('',[d.L_GDP_GAP]);

x.graph('GDP Gap (%)');
x.series('',[d.L_GDP_GAP]);
x.series('',[d.L_GDP_MINE_GAP ...
    d.L_GDP_OTH_GAP],...
    'legendEntry=',{'Mining','Non-Mining'},'plotfunc',@barcon);


x.graph('Foreign GDP Gap (%)','legend',false);
x.series('',[d.L_GDP_RW_GAP]);

x.graph('Real Interest Rate Gap (p.p. p.a.)','legend',false);
x.series('',[d.RR_GAP]);

x.graph('Real Exchange Rate Gap (p.p.)','legend',false);
x.series('',[d.L_Z_GAP]);

x.publish('results/Stylized_facts_2024q3','display',false);

rmpath utils

%% end 
disp('Done!!!');