clc
clear all
close all

%% Set up gravity and add deckformat.
% gravity reset
% gravity off

mrstModule add ad-fi deckformat incomp ad-core ad-blackoil

%% Initialize the model properties (grids, parameters etc.) of EGGs Model

% We read in the deck file, convert the units to SI and then use the 
% resulting deck variable to create grid, rock, fluid and well 
% configurations.

fn    = fullfile('C:', 'Users','Eduardo', 'Dropbox', 'oil_water','egg', ...
    'Egg_Model_ECL.DATA');

if ~exist(fn, 'file')
   error('Egg model data is not available.')
end

%% Reading input deck

deck  = readEclipseDeck(fn); % Read deck    
deck = convertDeckUnits(deck); % Convert to MRST units (SI)

%% Reading grid structures

G     = initEclipseGrid(deck); 
G     = removeCells(G, ~deck.GRID.ACTNUM); % Remove inactive cells
G     = computeGeometry(G);

%% Defining fluid properties

fluid = initDeckADIFluid(deck);

%% Reading rock properties

rock  = initEclipseRock(deck);
rock  = compressRock(rock, G.cells.indexMap);

%% Introduce wells

W = processWells(G, rock, deck.SCHEDULE.control(1)); % Introduce wells

%% Make the schedule

deck.SCHEDULE.step = struct;
schedule = deck.SCHEDULE;
newSchedule = makeSchedule(schedule); % Change the schedule

% Enable this to get convergence reports when solving schedules
verbose = false;
actnum  = deck.GRID.ACTNUM; 

%% Initialize schedule and system before solving for all timesteps

% Pressure initializaton
po(1) = 400*barsa;

gravity on;
state = initResSol(G, po(1),[0.15 0.85]); % Tem que ver isso aqui.
initpress = convertTo(state.pressure(1:G.cells.num), barsa);

system = initADISystem({'Water', 'Oil'}, G, rock, fluid);

%% Run the schedule
[wellSols, states] = runScheduleADI(state, G, rock, system, newSchedule, 'force_step', false);
%simtime = cumsum(newSchedule.step.val);

%% Put the well solution data into a format more suitable for plotting
[qWs, qOs, qGs, bhp] = wellSolToVector(wellSols);

%% Plot the results

plotWellSols(wellSols);

%% Plot the reservoir and the wells
%Plota o grid e os poços
% plotGrid(G,'FaceColor','none','EdgeAlpha',0.1);
% axis tight off, view(-5,58);
% plotWell(G,W,'height',200);


%% Function to modify the schedule

function [newSchedule] = makeSchedule(schedule)

% Quantidade de timesteps a ser usada na simulacao
q_tst = 120; 

% Tamanho do timestep a ser usado na simulacao
t_tst = 12*day;

% Duracao de cada timestep (piecewise constant)
for x = 1:q_tst
    newSchedule.step.val(x) = t_tst; 
end

% Uma acao de controle para cada intervalo
k = 1;
q = 1;
for i = 1:q_tst

    if q < 9
        newSchedule.step.control(i) = k;
        q = q + 1;
    else
        k = k + 1;
        newSchedule.step.control(i) = k;
        q = 1;
    end
    number_of_controls = k;
end

%% Water injection rate control

w_inj = 0.00092150; % Taxa de injecao de agua comeca com 500 barris por dia 

% INJETOR 1
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j) = schedule.control(1);
    newSchedule.control(j).WCONINJE(1,5) = {w_inj};
    w_inj = w_inj + 0.00092150/2;
end

% INJETOR 2
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(2,5) = {w_inj};
    w_inj = w_inj + 0.00092150;
end

% INJETOR 3
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(3,5) = {w_inj*1.5};
    w_inj = w_inj + 0.00092150/5;
end

% INJETOR 4
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(4,5) = {w_inj*2};
    w_inj = w_inj + 0.00092150/3;
end

% INJETOR 5
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(5,5) = {w_inj*0.5};
    w_inj = w_inj + 0.00092150*2;
end

% INJETOR 6
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(6,5) = {w_inj};
    w_inj = w_inj + 0.00092150/2;
end

% INJETOR 7
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(7,5) = {w_inj*3};
    w_inj = w_inj + 0.00092150/5;
end

% INJETOR 8
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(0.0020-0.0015)+0.0015;
    newSchedule.control(j).WCONINJE(8,5) = {w_inj};
    w_inj = w_inj + 0.00092150;
end

%% BHP production wells control (pseudo-aleatorio)

bhp_p = 3e6; % BHP constante
    
% Produtor 1
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(7.5e6-5.5e6)+6e6;
    newSchedule.control(j).WCONPROD(1,9) = {bhp_p};
    bhp_p = bhp_p + 0.1e6;
end

% Produtor 2
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(7.5e6-5.5e6)+6e6;
    newSchedule.control(j).WCONPROD(2,9) = {bhp_p*0.25};
    bhp_p = bhp_p + 0.25e6;
end

% Produtor 3
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(7.5e6-5.5e6)+6e6;
    newSchedule.control(j).WCONPROD(3,9) = {bhp_p*0.75};
    bhp_p = bhp_p + 0.2e6;
end

% Produtor 4
for j = 1:number_of_controls
    %rnd_ctrl = rand()*(7.5e6-5.5e6)+6e6;
    newSchedule.control(j).WCONPROD(4,9) = {bhp_p*1.5};
    bhp_p = bhp_p - 0.1e6;
end


newSchedule.step.val = newSchedule.step.val';
newSchedule.step.control = newSchedule.step.control';
end


