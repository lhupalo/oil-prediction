% Modelo para predição da pressão de fundo de poço do poço injetor

u1 = qWs_i; % Taxa de injeção de água do poço injetor
u2 = bhp_p; % BHP do poço produtor
y = bhp_i; % BHP poço injetor

%y = cumsum(y); % BHP acumulado do poço injetor

n = 10; % Número de amostras do passado
m = 50; % Número total de amostras usadas no modelo

y_pred = [];

[X,A] = least_square(y,u1,u2,n,m); % Realiza o treinamento inicial
y_pred = A*X;

for z = (m+n+1):length(y)
    w = z -(m+n-1);
    [X1,A1] = least_square(y(w:end),u1(w:end),u2(w:end),n,m); % Calcula a nova matriz A e o novo vetor de parâmetros
    y_pred(z-n) = A1(m,:)*X; % Calcula o próximo ponto com base nos parâmetros anteriores
    X = X1; % Atualiza o vetor de parâmetros
end



% Plotando as funções 
subplot(2,1,1);
plot(n+1:length(y),y(n+1:end),'b');
hold on;
plot(n+1:length(y),y_pred,'r');
title('Função real e predita');
subplot(2,1,2);
e = y(n+1:end) - y_pred; % Erro entre a função real e a predita
plot(n+1:length(y), e);
title('Erro');


function [X,A] = least_square(y,u1,u2,n,m)
    B = [];
    A = [];
    for i = (n+1):m+n
        B(i-n) = y(i);

        for j = 1:3*n
            if j<= n
                A(i-n,j) = y(i - j + 1);
            elseif j<= 2*n
                A(i-n,j) = u1(i - (j-n) + 1);
            else
                A(i-n,j) = u2(i - (j-2*n) + 1);
            end
        end
    end
    X = inv(A'*A)*A'*B';
end