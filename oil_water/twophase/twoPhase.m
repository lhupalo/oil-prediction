
try
   require deckformat ad-core ad-blackoil optimization
catch
   mrstModule add deckformat ad-core ad-blackoil optimization
end

current_dir = fileparts(mfilename('fullpath'));
fn    = fullfile(current_dir, 'simple10x1x10.data');
deck = readEclipseDeck(fn);

% Convert to MRST units (SI)
deck = convertDeckUnits(deck);

% Create grid
G = initEclipseGrid(deck);

% Set up the rock structure
rock  = initEclipseRock(deck);
rock  = compressRock(rock, G.cells.indexMap);

W = processWells(G, rock, deck.SCHEDULE.control(1));

% Create fluid
fluid = initDeckADIFluid(deck);

% Get schedule
schedule = deck.SCHEDULE;

% Enable this to get convergence reports when solving schedules
verbose = false;

%% Compute constants
% Once we are happy with the grid and rock setup, we compute
% transmissibilities. For this we first need the centroids.
G = computeGeometry(G);
T = computeTrans(G, rock);

%% Set up reservoir
% We turn on gravity and set up reservoir and scaling factors.
gravity on

state = initResSol(G, deck.PROPS.PVCDO(1), [.15, .85]);

% The scaling factors are use in the Newton solver and hopefully reduce the
% ill-conditionness of the system. The default values are 1.
scalFacs.pressure = 100*barsa;
scalFacs.rate     = 100/day;


%% Edit the schedule
newSchedule = editSchedule(schedule);

%% Run the whole schedule
% We setup the oil water system by calling the function |initADIsystem| and
% the equations are solved implicitely by calling |runScheduleADI|.
system = initADISystem({'Oil', 'Water'}, G, rock, fluid);
[wellSols, states] = runScheduleADI(state, G, rock, system, newSchedule);
[qWs, qOs, qGs, bhp] = wellSolToVector(wellSols); % qGs é gás, não usamos

%% Plot the results
simtime = cumsum(newSchedule.step.val);
plotWellSols(wellSols, simtime);

%% Export data
T = convertTo(simtime, day);
prod = find([wellSols{1}.sign] == -1);
inj = find([wellSols{1}.sign] == 1);

% Entradas
bhp_p = convertTo(bhp(:,prod), barsa); % BHP do produtor
qWs_i = convertTo(qWs(:,inj), meter^3/(day)); % Water rate do injetor

% Saídas
qWs_p = convertTo(qWs(:,prod), meter^3/(day)); % Water rate do produtor
qOs_p = convertTo(qOs(:,prod), meter^3/(day)); % Oil rate do produtor
bhp_i = convertTo(bhp(:,inj), barsa); % BHP do injetor

%%
% Plota o grid e os poços
plotGrid(G,'FaceColor','none','EdgeAlpha',0.1);
axis tight off, view(-5,58);


    