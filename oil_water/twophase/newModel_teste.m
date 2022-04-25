u1 = qWs_i; % Taxa de inje��o de �gua do po�o injetor (entrada)
u2 = bhp_p; % BHP do po�o produtor (entrada)
y = qOs_p; % Taxa de produ��o de �leo (sa�da)

wcut = qWs_p./(qWs_p+qOs_p);
%y = wcut;

n = 10; % N�mero de amostras do passado
m = 50; % N�mero total de amostras usadas no modelo

y_pred = [];

[X,A] = least_square(y,u1,u2,n,m); % Realiza o treinamento inicial
y_pred = A*X;

for z=(m+n+1):length(y)
    w = z -(m+n-1);
    [X1,A1] = least_square(y(w:end),u1(w:end),u2(w:end),n,m); % Calcula a nova matriz A e o novo vetor de par�metros
    y_pred(z-n) = A1(m,:)*X; % Calcula o pr�ximo ponto com base nos par�metros anteriores
    X = X1; % Atualiza o vetor de par�metros
end



% Plotando as fun��es 
subplot(2,1,1);
plot(n+1:length(y),y(n+1:end));
hold on;
plot(n+1:length(y),y_pred);
title('Fun��o real e predita');
subplot(2,1,2);
e = y(n+1:end) - y_pred; % Erro entre a fun��o real e a predita
plot(n+1:length(y), e);
title('Erro');

figure;
plot(cumsum(y(11:end)));
hold on;
plot(cumsum(y_pred));
title('Produ��o de �leo acumulada')

function [X,A] = least_square(y,u1,u2,n,m)
    B = [];
    A = [];
    for i = (n+1):m+n
        B(i-n) = y(i);

        for j=1:3*n
            if j<= n
                A(i-n,j) = y(i - j + 1);
            elseif j<= 2*n
                A(i-n,j) = u1(i - (j-n) +1);
            else
                A(i-n,j) = u2(i - (j-2*n)+1);
            end
        end
    end
    X = inv(A'*A)*A'*B';
end