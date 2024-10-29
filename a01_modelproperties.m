%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMPULSE RESPONSE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clearvars
close all

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Read the model
disp('Reading the model ...');
[m,p,mss] = readmodel();


disp('Shocks decomposition ...');
%% Define shocks
% One period unexpected shocks: inflation, output, exchange rate, interest rate
% Create a list of shock variables and a list of their titles. The shock variables
% must have the names found in the model code (in file 'model.model')
listshocks = {...
                %'SHK_L_GDP_GAP', ...
                'SHK_L_GDP_MINE_GAP', ...
                'SHK_L_GDP_OTH_GAP', ...
                'SHK_DLA_GDP_BAR',...    
                'SHK_DLA_GDP_MINE_BAR',...    
                'SHK_DLA_GDP_OTH_BAR',...    
                'SHK_DLA_CPI',...
                'SHK_D4L_CPI_TAR',...                
                'SHK_L_S',...
                'SHK_RS',...
                'SHK_RR_BAR',...
                'SHK_DLA_Z_BAR',...                
                'SHK_L_GDP_RW_GAP',...
                'SHK_RS_RW',...
                'SHK_DLA_CPI_RW',...
                'SHK_RR_RW_BAR'...
                };
listtitles = {...
                %'Aggregate Demand Shock',...
                'Mining Sector Demand Shock',...
                'Non-Mining Sector Demand Shock',...
                'Potential GDP Growth Shock',...    
                'Potential Mining GDP Growth Shock',...    
                'Potential Non-Mining GDP Growth Shock',...                
                'Inflationary Shock',...
                'Inflation Target Shock',...                
                'Exchange Rate Shock', ...
                'Interest Rate (monetary policy) Shock',...
                'Real Interest Rate Shock',...
                'Real Exchange Rate Depreciation Shock',...                
                'Foreign Output Gap Shock',...
                'Foreign Nominal Interest Rate Shock',...
                'Foreign Inflation Shock',...
                'Foreign Real Interest Rate'...
                };


% Set the time frame for the simulation 
startsim = qq(0,1);
endsim = qq(4,4); % five-year simulation horizon

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

% Fill the respective databases with the shock values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent
%d.SHK_L_GDP_GAP.SHK_L_GDP_GAP(startsim) = 1;
d.SHK_DLA_GDP_BAR.SHK_DLA_GDP_BAR(startsim) = -1; 
d.SHK_L_GDP_MINE_GAP.SHK_L_GDP_MINE_GAP(startsim) = 1;
d.SHK_L_GDP_OTH_GAP.SHK_L_GDP_OTH_GAP(startsim) = 1;

d.SHK_DLA_CPI.SHK_DLA_CPI(startsim) = 1;
d.SHK_D4L_CPI_TAR.SHK_D4L_CPI_TAR(startsim) = -1; 

d.SHK_L_S.SHK_L_S(startsim) = 1;
d.SHK_RS.SHK_RS(startsim) = -1; 
d.SHK_RR_BAR.SHK_RR_BAR(startsim) = 1; 
d.SHK_DLA_Z_BAR.SHK_DLA_Z_BAR(startsim) = 1; 

d.SHK_L_GDP_RW_GAP.SHK_L_GDP_RW_GAP(startsim) = 1;
d.SHK_RS_RW.SHK_RS_RW(startsim) = 1;
d.SHK_DLA_CPI_RW.SHK_DLA_CPI_RW(startsim) = 1; 
d.SHK_RR_RW_BAR.SHK_RR_RW_BAR(startsim) = 1;

disp('Simulating the model ...');
%% Simulate IRFs
% Simulate the model's response to a given shock using the command 'simulate'.
% The inputs are model 'm' and the respective database 'd.{shock_name}'.
% Results are written in database 's.{shock_name}'.
for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

disp('Generating the report ...');
%% Generate pdf report 1
x = report.new('Shocks');

% Figure style
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'east';
% sty.legend.fondsize = 16;

% Create separate page with IRFs for each shock
for i = 1:length(listshocks)

x.figure(listtitles{i},'zeroline',true,'style',sty, ...
         'range',startsim:endsim,'legend',true,'marks',{'Deviation','Alternative'});
     
x.graph('CPI Inflation QoQ (% ar)');
x.series('',s.(listshocks{i}).DLA_CPI);

x.graph('Nominal Interest Rate (% ar)');
x.series('',s.(listshocks{i}).RS);

% x.graph('Nominal ER Deprec. QoQ (% ar)');
% x.series('',s.(listshocks{i}).DLA_S);

x.graph('Nominal ER (log in %)');
x.series('',s.(listshocks{i}).L_S);

x.graph('Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_GAP]);

x.graph('Real Interest Rate Gap (%)');
x.series('', s.(listshocks{i}).RR_GAP);

x.graph('Real Exchange Rate Gap (%)');
x.series('', s.(listshocks{i}).L_Z_GAP);
 
x.graph('Real Monetary Condition Index (%)');
x.series('', s.(listshocks{i}).MCI);

x.graph('Real Marginal Cost (%)');
x.series('', s.(listshocks{i}).RMC);

x.graph('Country Risk Premium (%)');
x.series('', s.(listshocks{i}).PREM);

x.graph('Mining Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_MINE_GAP]);

x.graph('Non-Mining Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_OTH_GAP]);

end

disp('Publish first');
x.publish('results/Shocks.pdf','display',false);

disp('Start second');
%% Generate pdf report 1
x = report.new('Shocks Decomposition');

% Figure style
sty = struct();
sty.line.linewidth = 1.5;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'east';
% sty.legend.fondsize = 16;

% Create separate page with IRFs for each shock
for i = 1:length(listshocks)

x.figure(listtitles{i},'zeroline',true,'style',sty, ...
         'range',startsim:endsim,'legend',true,'marks',{'Deviation','Alternative'});
     
x.graph('CPI Inflation QoQ (% ar)');
x.series('',s.(listshocks{i}).DLA_CPI);
x.series('',[p.a1*s.(listshocks{i}).DLA_CPI{-1} ...
    (1-p.a1)*s.(listshocks{i}).DLA_CPI{+1} ...
    p.a2*s.(listshocks{i}).RMC ...
    s.(listshocks{i}).SHK_DLA_CPI], ...
    'legendEntry=',{'Backward','Foreward','RMC','Shock'},'plotfunc',@barcon);

x.graph('Nominal Interest Rate (% ar)');
x.series('',s.(listshocks{i}).RS);
x.series('',[p.g1*s.(listshocks{i}).RS{-1} ...
    (1-p.g1)*s.(listshocks{i}).RSNEUTRAL ...
    (1-p.g1)*p.g2*(s.(listshocks{i}).D4L_CPI{+4}-s.(listshocks{i}).D4L_CPI_TAR{+4}) ...
    (1-p.g1)*p.g3*s.(listshocks{i}).L_GDP_GAP ...
    s.(listshocks{i}).SHK_RS],...
    'legendEntry=',{'Backward','Neutral IR','Inflation','GDP gap','Shock'},'plotfunc',@barcon);

% x.graph('Nominal ER Deprec. QoQ (% ar)');
% x.series('',s.(listshocks{i}).DLA_S);
% x.series('',[4*(1-p.e1)*(s.(listshocks{i}).L_S{+1}-s.(listshocks{i}).L_S) ...
%     4*p.e1*(s.(listshocks{i}).L_S{-1}-s.(listshocks{i}).L_S{-2}) ...
%     ...
%     4*p.e1*2/4*(s.(listshocks{i}).D4L_CPI_TAR-s.(listshocks{i}).D4L_CPI_TAR{-1}...
%     -p.ss_DLA_CPI_RW+p.ss_DLA_CPI_RW+s.(listshocks{i}).DLA_Z_BAR...
%     -s.(listshocks{i}).DLA_Z_BAR{-1}) ...
%     ...
%     4*(-s.(listshocks{i}).RS+s.(listshocks{i}).RS{-1}+s.(listshocks{i}).RS_RW...
%     -s.(listshocks{i}).RS_RW{-1}+s.(listshocks{i}).PREM-s.(listshocks{i}).PREM{-1})/4 ...
%     ...
%     4*(s.(listshocks{i}).SHK_L_S-s.(listshocks{i}).SHK_L_S{-1})],...
%     'legendEntry=',{'Forward','Backward','OTHERS','Interest rate','Shock'},'plotfunc',@barcon);

x.graph('Nominal ER (log in %)');
x.series('',s.(listshocks{i}).L_S);
x.series('',[(1-p.e1)*s.(listshocks{i}).L_S{+1} ...
    p.e1*s.(listshocks{i}).L_S{-1} ... 
    p.e1*2/4*(s.(listshocks{i}).D4L_CPI_TAR+s.(listshocks{i}).DLA_Z_BAR) ...
    (-1*s.(listshocks{i}).RS+s.(listshocks{i}).RS_RW+s.(listshocks{i}).PREM)/4 ...
    s.(listshocks{i}).SHK_L_S],...
    'legendEntry=',{'Forward','Backward','OTHERS','Interest rate','Shock'},'plotfunc',@barcon);

% x.graph('Output Gap (%)');
% x.series('',[s.(listshocks{i}).L_GDP_GAP]);
% x.series('',[p.b1*s.(listshocks{i}).L_GDP_GAP{-1} ...
%     -p.b2*s.(listshocks{i}).MCI p.b3*s.(listshocks{i}).L_GDP_RW_GAP...
%     s.(listshocks{i}).SHK_L_GDP_GAP],...
%     'legendEntry=',{'Backward','MCI','China GDP','Shock'},'plotfunc',@barcon);

x.graph('Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_GAP]);
x.series('',[s.(listshocks{i}).L_GDP_MINE_GAP ...
    s.(listshocks{i}).L_GDP_OTH_GAP],...
    'legendEntry=',{'Mining','Non-Mining'},'plotfunc',@barcon);

x.graph('Mining Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_MINE_GAP]);
x.series('',[p.b1_mine*s.(listshocks{i}).L_GDP_MINE_GAP{-1} ...
    -p.b2*s.(listshocks{i}).MCI p.b3_mine*s.(listshocks{i}).L_GDP_RW_GAP...
    s.(listshocks{i}).SHK_L_GDP_MINE_GAP],...
    'legendEntry=',{'Backward','MCI','China GDP','Shock'},'plotfunc',@barcon);

x.graph('Non-mining Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_OTH_GAP]);
x.series('',[p.b1_mine*s.(listshocks{i}).L_GDP_OTH_GAP{-1} ...
    -p.b2_oth*s.(listshocks{i}).MCI p.b3_oth*s.(listshocks{i}).L_GDP_RW_GAP...
    s.(listshocks{i}).SHK_L_GDP_OTH_GAP],...
    'legendEntry=',{'Backward','MCI','China GDP','Shock'},'plotfunc',@barcon);

x.graph('Real Interest Rate Gap (%)');
x.series('', s.(listshocks{i}).RR_GAP);
x.series('',[s.(listshocks{i}).RS ...
    -1*s.(listshocks{i}).D4L_CPI{+1} ...
    -1*s.(listshocks{i}).RR_BAR],...
    'legendEntry=',{'N.Int.Rate','Inflation YoY','Trend RR'},'plotfunc',@barcon);

x.graph('Real Exchange Rate Gap (%)');
x.series('', s.(listshocks{i}).L_Z_GAP);
x.series('',[s.(listshocks{i}).L_S ...
    s.(listshocks{i}).L_CPI_RW ...
    -1*s.(listshocks{i}).L_CPI ...
    -1*s.(listshocks{i}).L_Z_BAR],...
    'legendEntry=',{'N.ER','China CPI','CPI','Trend R.ER'},'plotfunc',@barcon);
 
x.graph('Real Monetary Condition Index (%)');
x.series('', s.(listshocks{i}).MCI);
x.series('', [p.b4*s.(listshocks{i}).RR_GAP (1-p.b4)*(-s.(listshocks{i}).L_Z_GAP)],...
    'legendEntry=',{'R.IR gap','R.ER gap'},'plotfunc',@barcon);

x.graph('Real Marginal Cost (%)');
x.series('', s.(listshocks{i}).RMC);
x.series('', [p.a3*s.(listshocks{i}).L_GDP_GAP (1-p.a3)*s.(listshocks{i}).L_Z_GAP],...
    'legendEntry=',{'GDP gap','R.ER gap'},'plotfunc',@barcon);

x.graph('Country Risk Premium (%)');
x.series('', s.(listshocks{i}).PREM);

end

disp('Publish second');
x.publish('results/Shocks Decomposition.pdf','display',false);


disp('Done!!!');