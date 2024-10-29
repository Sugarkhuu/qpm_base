%%%%%%%%
%%% PREPARATION OF THE DATABASE
%%%%%%%%

%% Housekeeping
clearvars
close all

addpath utils

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Read the model and database
[m,p,mss] = readmodel();

% get model variables descriptions 
desc = get(m,'descript');
desc.S = 'Nominal Exchange Rate: LCY per 1 FCY';

%% database 
% d=dbload('results_amgl/history_amgl.csv');

% load Kalman filter results
h = dbload('results/kalm_his.csv');
% Remove all residuals from the database filter database
% h = rmfield(h,get(m,'eList'));
% get range of the database h
h_range = dbrange(h);

%% historical and forecasting range
sdate = qq(2010, 1);
edate = qq(2024,3); 
sfdate = qq(2024, 4); 
efdate = qq(2029, 4);

%% 
ilist = {'L_GDP_GAP','L_GDP_MINE_GAP','L_GDP_OTH_GAP','DL_GDP_yearly','DL_GDP_MINE_yearly','DL_GDP_OTH_yearly',...
            'D4L_GDP','D4L_GDP_MINE','D4L_GDP_OTH','RS','D4L_CPI','DLA_CPI','D4L_S','DLA_S','MCI','RMC','RR_GAP','L_Z_GAP'};
ilabels = {'L_GDP_GAP','L_GDP_MINE_GAP','L_GDP_OTH_GAP','MCI','RMC','RR_GAP','L_Z_GAP','RS','D4L_CPI','D4L_GDP','D4L_S'};


%% forecasting plan
% fcast_plan = plan(m,sfdate:efdate); 
% fcast_plan = condition(fcast_plan,'RS',qq(2020,3):qq(2021,4));

fcast_plan = plan(m,sfdate:edate+5); 

%--------------------------------------------------------------------------
% Baseline scenario
%--------------------------------------------------------------------------
% h.SHK_L_GDP_GAP(sfdate+1) = 0.5; 
% h.SHK_L_GDP_GAP(sfdate+2:sfdate+4) = 0.8;

% Tuning - Sugaraa
h.RS(sfdate:sfdate+1) = 10; 
% h.RS(sfdate+2:sfdate+3) = 11; 
fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+1);
fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+1);

% h.L_GDP_RW_GAP(sfdate) = 0;
% h.L_GDP_RW_GAP(sfdate+1) = 0.75;
% h.L_GDP_RW_GAP(sfdate+2) = 1.75;
% h.L_GDP_RW_GAP(sfdate+3) = 2.0;
% fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:sfdate+3);
% fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:sfdate+3);
%--------------------------------------------------------------------------


% %--------------------------------------------------------------------------
% % Upside scenario
% %--------------------------------------------------------------------------
% h.SHK_L_GDP_GAP(sfdate:sfdate+1) = 0 + 0.9; 
% h.SHK_L_GDP_GAP(sfdate+2:sfdate+3) = 0 + 0.9;
% 
% h.RS(sfdate:sfdate+3) = 6; 
% fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+3);
% fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+3);
% 
% h.L_GDP_RW_GAP(sfdate:edate+4) = -3;
% fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:edate+4);
% fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:edate+4);
% %--------------------------------------------------------------------------


% %--------------------------------------------------------------------------
% % Downside scenario
% %--------------------------------------------------------------------------
% h.SHK_L_GDP_GAP(sfdate:sfdate+1) = -5.0 + 0.9; 
% h.SHK_L_GDP_GAP(sfdate+2:sfdate+3) = -2.6 + 0.9;
% 
% h.RS(sfdate:sfdate+3) = 6; 
% fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+3);
% fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+3);
% 
% h.L_GDP_RW_GAP(sfdate:edate+4) = -3;
% fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:edate+4);
% fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:edate+4);
% %--------------------------------------------------------------------------



% % % % %--------------------------------------------------------------------------
% % % % % the second scenario in V shaped recovery
% % % % %--------------------------------------------------------------------------
% % % % h.SHK_L_GDP_GAP(sfdate:sfdate) = -5.0 + 3 - 3 + 0.1 - 0.1; 
% % % % h.SHK_L_GDP_GAP(sfdate+1:sfdate+2) = -2.6 + 0.9; 
% % % % h.SHK_L_GDP_GAP(sfdate+3:sfdate+4) = -0 + 0.9;
% % % % 
% % % % h.RS(sfdate:sfdate+2) = 6; 
% % % % fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+2);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+2);
% % % % 
% % % % h.RS(sfdate+3:sfdate+4) = 7; 
% % % % fcast_plan  = exogenize(fcast_plan,'RS',sfdate+3:sfdate+4);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate+3:sfdate+4);
% % % % 
% % % % h.L_GDP_RW_GAP(sfdate:edate+5) = -4;
% % % % fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:edate+5);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:edate+5);
% % % % %--------------------------------------------------------------------------
% % % 
% % % % %--------------------------------------------------------------------------
% % % % % the first scenario in U shaped recovery
% % % % %--------------------------------------------------------------------------
% % % % h.SHK_L_GDP_GAP(sfdate:sfdate) = -5.0 + 3 + 0.1; 
% % % % h.SHK_L_GDP_GAP(sfdate+1:sfdate+3) = -5 + 0.9; 
% % % % h.SHK_L_GDP_GAP(sfdate+4:sfdate+4) = -2.6 + 0.9; 
% % % % 
% % % % h.RS(sfdate:sfdate+4) = 6; 
% % % % fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+4);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+4);
% % % % 
% % % % h.L_GDP_RW_GAP(sfdate:edate+5) = -3;
% % % % fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:edate+5);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:edate+5);
% % % % %--------------------------------------------------------------------------
% % % 
% % % % %--------------------------------------------------------------------------
% % % % % the second scenario in U shaped recovery
% % % % %--------------------------------------------------------------------------
% % % % h.SHK_L_GDP_GAP(sfdate:sfdate) = -5.0 + 3 + 0.1; 
% % % % h.SHK_L_GDP_GAP(sfdate+1:sfdate+3) = -5 + 0.9; 
% % % % h.SHK_L_GDP_GAP(sfdate+4:sfdate+4) = -2.6 + 0.9; 
% % % % 
% % % % h.RS(sfdate:sfdate+4) = 6; 
% % % % fcast_plan  = exogenize(fcast_plan,'RS',sfdate:sfdate+4);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_RS',sfdate:sfdate+4);
% % % % 
% % % % h.L_GDP_RW_GAP(sfdate:edate+5) = -4;
% % % % fcast_plan  = exogenize(fcast_plan,'L_GDP_RW_GAP',sfdate:edate+5);
% % % % fcast_plan  = endogenize(fcast_plan,'SHK_L_GDP_RW_GAP',sfdate:edate+5);
% % % % %--------------------------------------------------------------------------
% % % 
% % % % % -5 ni shock, 3 ni hul horiug sulruulsnii sain shock, 0.1 ni nuursnii
% % % % shock, 0.9 ni altnii aguulamjiin shock

% conditions in common among the aforementioned scenarios

% h.SHK_DLA_Z_BAR(sfdate:sfdate+3) = 5; 

% h.DLA_Z_BAR(sfdate:sfdate+3) = 5; 
% fcast_plan  = exogenize(fcast_plan,'DLA_Z_BAR',sfdate:edate+4);
% fcast_plan  = endogenize(fcast_plan,'SHK_DLA_Z_BAR',sfdate:edate+4);

% h.SHK_L_S(sfdate+1) = 0.015;
% h.SHK_L_S(sfdate+2:sfdate+3) = -0.1;

h.D4L_CPI_TAR(sfdate:sfdate+3) = 6; 
fcast_plan  = exogenize(fcast_plan,'D4L_CPI_TAR',sfdate:edate+4);
fcast_plan  = endogenize(fcast_plan,'SHK_D4L_CPI_TAR',sfdate:edate+4);

h.RS_RW(sfdate:sfdate+3) = 4.35; 
fcast_plan  = exogenize(fcast_plan,'RS_RW',sfdate:edate+4);
fcast_plan  = endogenize(fcast_plan,'SHK_RS_RW',sfdate:edate+4);

% for table
s = simulate(m,h,sfdate:efdate,'plan',fcast_plan,'anticipate',true); %
s2 = dbextend(dbclip(h,h_range(1):efdate),s);

for i = 1:length(ilist)
    s_table.(ilist{i})=s2.(ilist{i});
    
end

dbsave(s, 'results/s.csv');
dbsave(s2, 'results/s2.csv');
dbsave(s_table, 'results/s_table.csv');

%% Generate report

srep = sdate; % beginning of reported range
erep = efdate %edate+8; % end of reported range

% Start the report
x = report.new('Forecast','visible',false);

% Define style for figures
sty = struct();
sty.line.linewidth = 1.5;
sty.title.fontsize = 9;
sty.axes.fontsize = 8;

% plot figure in a FOR loop

    % open new figure window
    x.figure('','range',srep:erep,'dateformat','YY:P','style',sty);
    % open new graph
for i = 1:length(ilist)
    x.graph(desc.(ilist{i}),'legend',false);
    % plot simulation results
    x.series('',s.(ilist{i}));
    % plot filtered data
    x.series('',h.(ilist{i}),'plotOptions',{'color','k'});
end

%% Table

disp('Report table starts ...');
start_dt = qq(2024,1);
lastHist = qq(2024,3);
end_dt   = qq(2026,4);
rngFcRep = start_dt:end_dt;

tblOpts = {'range',rngFcRep,'vline',lastHist};

x.table('General Overview',tblOpts{:},'dateFormat','YYFP','decimal',1,'fontsize','tiny');
x.subheading('');

x.subheading('Economic indicators', 'bold', true);
for i = 1:length(ilist)
    x.series(desc.(ilist{i}),s2.(ilist{i}));
end


% generate the PDF file
x.publish('results/Forecast.pdf','display',false);


disp('Done!!!');