function [newSchedule] = makeSchedule(schedule)

schedule.step = struct;

% Quantidade de timesteps a ser usada na simulacao
q_tst = 2; % 4 anos

% Tamanho do timestep a ser usado na simulacao
t_tst = 30*3*day; % 90 dias (3 meses) 

% Duracao de cada timestep (piecewise constant)
for x = 1:q_tst
    schedule.step.val(x) = t_tst; 
end

% Uma acao de controle para cada intervalo
k = 1;
for i = 1:q_tst
    schedule.step.control(i) = k;
    k = k + 1;
end

%% Controle para taxa de injecao de agua (pseudo-aleatorio)

w_inj = 0.007; % Taxa de injecao de agua constante

% INJETOR 1
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    %schedule.control(j) = schedule.control(1);
    schedule.control(j).WCONINJE(1,5) = {w_inj};
end

% INJETOR 2
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(2,5) = {w_inj};
end

% INJETOR 3
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(3,5) = {w_inj};
end

% INJETOR 4
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(4,5) = {w_inj};
end

% INJETOR 5
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(5,5) = {w_inj};
end

% INJETOR 6
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(6,5) = {w_inj};
end

% INJETOR 7
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(7,5) = {w_inj};
end

% INJETOR 8
for j = 1:q_tst
    %rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    schedule.control(j).WCONINJE(8,5) = {w_inj};
end

%% Controle para BHP dos pocos produtores (pseudo-aleatorio)

bhp_p = 10e6; % BHP constante

% Produtor 1
for j = 1:q_tst
    %rnd_ctrl = rand()*(15e6-1e6)+1e6;
    schedule.control(j).WCONPROD(1,9) = {bhp_p};
end

% Produtor 2
for j = 1:q_tst
    %rnd_ctrl = rand()*(15e6-1e6)+1e6;
    schedule.control(j).WCONPROD(2,9) = {bhp_p};
end

% Produtor 3
for j = 1:q_tst
    rnd_ctrl = rand()*(15e6-1e6)+1e6;
    schedule.control(j).WCONPROD(3,9) = {bhp_p};
end

% Produtor 4
for j = 1:q_tst
    %rnd_ctrl = rand()*(15e6-1e6)+1e6;
    schedule.control(j).WCONPROD(4,9) = {bhp_p};
end

newSchedule = schedule;
end