function F = filtro_pondera(g,G,wc,k,banda);
% Modelo de filtro de ponderacao segundo Zhou 
% Essentials of Robust Control - Eq. (6.7) e Eq. (6.10)
% F = filtro_pondera(g,G,wc,k,banda)
% F - filtro como sistema linear
% g - Ganho na rejeicao
% G - Ganho na passagem
% wc - Frequencia de ganho unitario, ou 0 dB (em rad/s).
% k - Ordem do filtro (o numero de zeros é igual ao de pólos).
% banda - 0 para passa-baixa e 1 para passa-alta.

if k < 1
    error('Ordem do filtro deve ser maior do que 1.')
end

M = 1/g;
epsilon = 1/G;

Mk = M^(1/k);
epsilonk = epsilon^(1/k);

n = 1; % numerador
d = 1; % denominador

if ~banda
    for i = 1:k
        n = conv(n,[1/Mk wc]);
        d = conv(d,[1 wc*epsilonk]);
    end
else
    for i = 1:k
        n = conv(n,[1 wc/Mk]);
        d = conv(d,[epsilonk wc]);
    end
end

[AFil,BFil,CFil,DFil] = tf2ss(n,d);
F = ss(AFil,BFil,CFil,DFil);
F = canon(F,'modal');