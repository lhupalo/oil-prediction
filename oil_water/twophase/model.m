u1 = qWs_i; % Entrada
u2 = bhp_p; 
y = qOs_p; % Sa�da


n = 10; % N�mero de amostras do passado
m = 50; % N�mero total de amostras usadas no modelo

A = []; % Matriz com valores de entradas e sa�das
B = []; % Matriz das sa�das
nextA =[];

for w = 1:(length(y)-n-m)

    i = n+1+w;
    j = 1;

    while i ~= (m + (n+1+w))
        B(i-(n+w)) = y(i); % Guarda os valores de y(k) na matriz B

        while j ~= (3*n+1) % Preenche a matriz A
            if j <= n+1
                A(i-(n+w),j) = y(i-j);
            elseif j<= 2*n+1
                A(i-(n+w),j) = u1(i-(j-(n+1)));
            else
                A(i-(n+w),j) = u2(i-(j-(2*n+1)));
            end
            j = j + 1;
        end
        j = 1;
        i = i + 1;
    end

    H = A'*A;
    X = inv(H)*A'*B'; % Calcula o vetor dos par�metros

%     j = 1;
%     while j ~= (3*n+1) % Preenche a matriz A
%         if j <= n+1
%             nextA(j) = y(i-j);
%         elseif j<= 2*n+1
%             nextA(j) = u1(i-(j-(n+1)));
%         else
%             nextA(j) = u2(i-(j-(2*n+1)));
%         end
%         j = j + 1;
%     end

    if w == 1
        Y_test = A*X;
    end
%     nextY = nextA*X;
%     Y_test(i) = nextY;
end

% subplot(3,1,1)
% plot([1:1:length(y)],y,'b')
% title('Sa�das reais')
% subplot(3,1,2)
% plot([1:1:length(y)],Y_test(1:100),'r')
% title('Sa�das do modelo')
% subplot(3,1,3)
% plot([1:1:length(y)],y-Y_test(1:100),'k')
% title('Erro de predi��o')

subplot(3,1,1)
plot([n:1:m+n],y(n:m+n),'b')
title('Sa�das reais')
subplot(3,1,2)
plot([1:1:m],Y_test,'r')
title('Sa�das do modelo')
subplot(3,1,3)
plot([n:1:m+n],y(n:m+n)-Y_test,'k')
title('Erro de predi��o')
