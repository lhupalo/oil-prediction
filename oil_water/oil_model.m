% Modelo para predição da produção de óleo 
clc
clear

run muitosdados.m; [qWs, qOs, qGs, bhp] = wellSolToVector(wellSols);

u1 = qWs(:,1);
u2 = qWs(:,3);
u3 = qWs(:,9);

y = qOs(:,9);

%y = cumsum(y); Produção acumulada

wcut = (qWs(:,9)+qWs(:,10)+qWs(:,11)+qWs(:,12))/(qOs(:,9)+qOs(:,10)+qOs(:,11)+qOs(:,12)); % Water cut
% y = wcut;

n = 2; % Número de amostras do passado
m = 20; % Número total de amostras usadas no modelo

y_pred = [];

[X,A] = least_square(y,u1,u2,u3,n,m); % Realiza o treinamento inicial
y_pred = A*X; % Calcula o primeiro vetor de parâmetros

for z = (m+n+1):length(y)
    w = z -(m+n-1);
    [X1,A1] = least_square(y(w:end),u1(w:end),u2(w:end),u3(w:end),n,m); % Calcula a nova matriz A e o novo vetor de parâmetros
    y_pred(z-n) = A1(m,:)*X; % Calcula o próximo ponto com base nos parâmetros anteriores
    X = X1; % Atualiza o vetor de parâmetros
end


% Plotando as funções 
subplot(2,1,1);
plot(n+1:length(y),y(n+1:end));
hold on;
plot(n+1:length(y),y_pred);
title('Função real e predita');
subplot(2,1,2);
e = y(n+1:end) - y_pred; % Erro entre a função real e a predita
plot(n+1:length(y), e);
title('Erro');

function [X,A] = least_square(y,u1,u2,u3,n,m)
    B = [];
    A = [];
    for i = (n+1):m+n
        B(i-n) = y(i);

        for j = 1:4*n
            if j <= n
                A(i-n,j) = y(i - j + 1);
            elseif j <= 2*n
                A(i-n,j) = u1(i - (j-n) + 1);
            elseif j <= 3*n
                A(i-n,j) = u2(i - (j-2*n) + 1);
            else
                A(i-n,j) = u3(i - (j-3*n) + 1);
            end
        end
    end
    X = inv(A'*A)*A'*B';
end