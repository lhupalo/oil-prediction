% Modelo para predicao da producao de oleo 
clf;

u1 = qWs(:,2); % Taxa de injecao de agua do poco injetor
u2 = bhp(:,9);
u3 = qWs(:,4);
u4 = qWs(:,6);
u5 = qWs(:,7);
%u6 = qWs(:,6);
u6 = qWs(:,1);
% u8 = qWs(:,8);
% u9 = bhp(:,12); % BHP do produtor
% u10 = bhp(:,10);
% u11 = bhp(:,11);
% u12 = bhp(:,12);
% u13 = qWs(:,9); % Producao de agua
% u14 = qWs(:,10);
% u15 = qWs(:,11);
% u16 = qWs(:,12);
y = qOs(:,9); % Taxa de producaoo de oleo

%y = cumsum(y); %Producao acumulada

%wcut = qWs_p./(qWs_p+qOs_p); % Water cut
%y = wcut;

n = 10; % Numero de amostras do passado
m = 50; % Numero total de amostras usadas no modelo

y_pred = [];

[X,A] = least_square(y,u1,u2,u3,u4,u5,u6,n,m); % Realiza o treinamento inicial
y_pred = A*X; % Calcula o primeiro vetor de parametros

for z = (m+n+1):length(y)
    w = z -(m+n-1);
    [X1,A1] = least_square(y(w:end),u1(w:end),u2(w:end),u3(w:end),u4(w:end),u5(w:end),u6(w:end),n,m); % Calcula a nova matriz A e o novo vetor de par�metros
    y_pred(z-n) = A1(m,:)*X; % Calcula o proximo ponto com base nos parametros anteriores
    X = X1; % Atualiza o vetor de parametros
end


% Plotando as funcoes
clf;
subplot(2,1,1);
plot(n+1:length(y),y(n+1:end),'red');
hold on;
plot(n+1:length(y),y_pred,'black');
title('Funcao real e predita');
legend('Saida','Predicao');
xlabel('Step');
ylabel('Producao');
subplot(2,1,2);
e = y(n+1:end) - y_pred; % Erro entre a funcao real e a predita
plot(n+1:length(y), e);
title('Erro');
xlabel('Step');
ylabel('Saida - Predicao');

function [X,A] = least_square(y,u1,u2,u3,u4,u5,u6,n,m)
    B = [];
    A = [];
    for i = (n+1):m+n
        B(i-n) = y(i);

        for j = 1:7*n
            if j <= n
                A(i-n,j) = y(i - j + 1);
            elseif j <= 2*n
                A(i-n,j) = u1(i - (j-n) + 1);
            elseif j <= 3*n
                A(i-n,j) = u2(i - (j-2*n) + 1);
            elseif j <= 4*n
                A(i-n,j) = u3(i - (j-3*n) + 1);
            elseif j <= 5*n
                A(i-n,j) = u4(i - (j-4*n) + 1);
            elseif j <= 6*n
                A(i-n,j) = u5(i - (j-5*n) + 1);
            else
                A(i-n,j) = u6(i - (j-6*n) + 1);
            end
    end
    %X = inv(A'*A)*A'*B';
    X = (A'*A)\(A'*B');
    end
end