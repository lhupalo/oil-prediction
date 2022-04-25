function [newSchedule] = changeSchedule(schedule)

newSchedule = schedule;

% Quantidade de timesteps a ser usada na simulação
q_tst = 100;

% Tamanho do timestep a ser usado na simulação
t_tst = 5*day; % 5 dias 

% Duração de cada timestep (piecewise constant)
for x = 1:q_tst
    newSchedule.step.val(x) = t_tst; 
end

% Uma ação de controle para cada intervalo
k = 1;
for i = 1:q_tst
    newSchedule.step.control(i) = schedule.step.control(1);
    newSchedule.step.control(i) = k;
    k = k + 1;
end


% Controle para taxa de injeção de água (injetor) (pseudo-aleatório)
for j = 1:q_tst
    rnd_ctrl = rand()*(0.0015-0.0001)+0.0001;
    newSchedule.control(j) = newSchedule.control(1);
    newSchedule.control(j).WCONINJE(5) = {rnd_ctrl};
end

% Controle para BHP do poço produtor (pseudo-aleatório)
% ctrl = 15e6;
% stp = (15e6-1e6)/q_tst;
for j = 1:q_tst
    rnd_ctrl = rand()*(15e6-1e6)+1e6;
    newSchedule.control(j).WCONPROD(9) = {rnd_ctrl};
%   ctrl = ctrl - stp;
end
end