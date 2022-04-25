u1 = qWs_i; % Entrada
u2 = bhp_p; % Entrada
y = qOs_p; % Sa�da


n = 10; % N�mero de amostras do passado
m = 50; % N�mero total de amostras usadas no modelo

y_pred = [];

[X,A] = least_square(y,u1,u2,n,m);
y_pred = A*X;

for z=(m+n+1):length(y)
    w = z -(m+n-1);
    [X1,A1] = least_square(y(w:end),u1(w:end),u2(w:end),n,m);
    y_pred(z-n) = A1(m,:)*X;
    X = X1;
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