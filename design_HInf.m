%% H-Infinity controller for TRMS 
%
% This MATLAB script is a H-Infinity controller synthesis and analysis for
% the TRMS
%
% MATLAB(R) file generated by MATLAB(R) 9.0
%
% (C) MIT License 

%% Load model
run ('.\Model\load_TRMS_Linear_Model')
% Faster model
% load ('.\Model\TRMS_Model.mat')

%% Define weighting functions
% Sensitivity weighting function
fw11 = filtro_pondera(0.01, 100, 1, 1, 0);
fw12 = filtro_pondera(0.01, 100, 1, 1, 0);
Ws = [fw11, 0; 0, fw12];

% Complementary sensitivity weighting function
fw21 = filtro_pondera(0.01, 1000, 1, 1, 1);
fw22 = filtro_pondera(0.01, 1000, 1, 1, 1);
Wt = [fw21, 0; 0, fw22];

% Control effort weighting function
fw3 = filtro_pondera(0.1, 10, 100, 1, 1);
Wu = ones(2,2)*fw3;

%% Define generalized plant architecture
r = {'RefPitch', 'RefYaw'};
z1 = {'z11', 'z12'};
z2 = {'z21', 'z22'};
z3 = {'z31', 'z32'};
z = [z1, z2, z3];
u = {'Um', 'Ut'};
e = {'e1', 'e2'};
y = {'psi', 'phi'};

Ws.inputname = e;
Ws.outputname = z1;

Wt.inputname = y;
Wt.outputname = z2;

Wu.inputname = u;
Wu.outputname = z3;

Sum = ss([eye(2), -eye(2)]);
Sum.inputname = [r,y];
Sum.outputname = e;

P = connect(TRMS.linear.sys, Sum, Ws, Wt, Wu, [r, u], [z, e]);

%% Tune the controller
[K, ~, gamma] = hinfsyn(P,2,2);
disp(gamma);

K.inputname = e;
K.outputname = u;

KHINF = connect(Sum, K, ({'RefPitch', 'RefYaw', 'psi', 'phi'}), {'Um', 'Ut'});

%% Connect the closed-loop system
Tcl = connect(TRMS.linear.sys, Sum, K, {'RefPitch', 'RefYaw'}, {'psi', 'phi'});

%% Analysis
%% Time response
% Pitch step response
figure()
opt = stepDataOptions('InputOffset', [0 0], 'StepAmplitude', [0.2 0]);
[y_data, t_data] = step(Tcl, 30, opt);
subplot(2, 1, 1)
plot(t_data, y_data(:, 1, 1), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel({'Tempo (s)', ''}), ylabel('Psi (rad)'), ylim([0 0.3]), title({'Resposta ao degrau', 'Arfagem'})
line([0, 30], [0.2, 0.2], 'LineStyle', '--','LineWidth', 1, 'Color', 'Red')
line([0, 0], [0, 0.2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Psi', 'ReferÍncia', 'Location', 'best')
subplot(2, 1, 2)
plot(t_data, y_data(:, 2, 1), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel('Tempo (s)'), ylabel('Phi (rad)'), ylim([-0.1 0.1]), title({'Acoplamento', 'Guinada'})
line([0, 30], [0, 0], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Phi', 'ReferÍncia', 'Location', 'best')

% Yaw step response
figure()
opt = stepDataOptions('InputOffset', [0 0], 'StepAmplitude', [0 0.2]);
[y_data, t_data] = step(Tcl, 30, opt);
subplot(2, 1, 1)
plot(t_data, y_data(:, 2, 2), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel({'Tempo (s)', ''}), ylabel('Phi (rad)'), ylim([0 0.3]), title({'Resposta ao degrau', 'Guinada'})
line([0, 30], [0.2, 0.2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
line([0, 0], [0, 0.2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Phi', 'ReferÍncia', 'Location', 'best');
subplot(2, 1, 2)
plot(t_data, y_data(:, 1, 2), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel('Tempo (s)'), ylabel('Psi (rad)'), ylim([-0.1 0.1]), title({'Acoplamento', 'Arfagem'})
line([0, 30], [0, 0], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Psi', 'ReferÍncia', 'Location', 'best');

%% Frequency analysis
figure()
loopview(TRMS.linear.sys, KHINF)
children = get(gca, 'children');
delete(children(3));
delete(children(4));
xlim([0.01 100])
ylim([-60 40])
title('Sensibilidades de entrada')
xlabel('FrequÍncia')
ylabel('Valores singulares')

figure()
loopview(TRMS.linear.sys, KHINF)
children = get(gca, 'children');
delete(children(1));
delete(children(2));
delete(children(3));
xlim([0.01 100])
ylim([-60 60])
title('Resposta em malha aberta')
xlabel('FrequÍncia')
ylabel('Valores singulares')

figure
load('.\Functions\info.mat'); % This file contains plot intructions for command 'loopview'
loopview(TRMS.linear.sys, KHINF, INFO);
title('Margens de estabilidade')
legend('Margens de estabilidade')
xlabel('FrequÍncia')
ylabel('Margem de ganho; Margem de fase')
xlim([0.01 100])