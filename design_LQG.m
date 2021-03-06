%% LQG with integral action controller for TRMS 
%
% This MATLAB script is a LQG with integral action controller synthesis and
% analysis for the TRMS
%
% MATLAB(R) file generated by MATLAB(R) 9.0
%
% (C) MIT License 

%% Load model
run ('.\Model\load_TRMS_Linear_Model')
% Faster model
% load ('.\Model\TRMS_Model.mat')

%% Define controller constraints and objectives
% Large Q yields small values for states
Q = 1000 * eye(8);  
Q(5, 5) = 0.01;
Q(6, 6) = 0.01;

% Large R yields small control effort
R = 1*eye(2);  

%% Tune the controller
[K, S, E] = lqi(TRMS.linear.sys, Q, R);

%Ai = [sys.A-sys.B*K(1:2,1:6), sys.B*-K(1:2, 7:8); -sys.C, zeros(2,2)];
%Bi = [zeros(6,2); eye(2)];
%Ci = [sys.C, zeros(2,2)];
%Di = sys.D;
%Tcl = ss(Ai, Bi, Ci, Di);
%Tcl.InputName = {'RefPitch', 'RefYaw'};
%Tcl.OutputName = {'psi', 'phi'};

sum = ss([eye(2), -eye(2)]);
sum.inputname = [{'RefPitch', 'RefYaw'}, {'psi', 'phi'}];
sum.outputname = {'e1', 'e2'};

integrator = eye(2)*tf(1, [1 0]);
integrator.inputname = {'e1' 'e2'};
integrator.outputname = {'Xi1' 'Xi2'};

kalmf = kalman(TRMS.linear.sys, [], eye(2));
kalmf = kalmf(3:8, :);

gains = ss(-K);
gains.inputname = {'Psi_e', 'Psi_dot_e', 'Phi_e', 'Phi_dot_e', 'Wm_e', 'Wt_e', 'Xi1', 'Xi2'};
gains.outputname = {'Um', 'Ut'};

KLQG = connect(sum, integrator, kalmf, gains, [{'RefPitch', 'RefYaw'}, {'psi', 'phi'}], {'Um', 'Ut'});

%% Connect the closed-loop system
Tcl = connect(TRMS.linear.sys, KLQG, {'RefPitch', 'RefYaw'}, {'psi', 'phi'});

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
loopview(TRMS.linear.sys, KLQG)
children = get(gca, 'children');
delete(children(3));
delete(children(4));
xlim([0.01 100])
ylim([-60 40])
title('Sensibilidades de entrada')
xlabel('FrequÍncia')
ylabel('Valores singulares')

figure()
loopview(TRMS.linear.sys, KLQG)
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
loopview(TRMS.linear.sys, KLQG, INFO);
title('Margens de estabilidade')
legend('Margens de estabilidade')
xlabel('FrequÍncia')
ylabel('Margem de ganho; Margem de fase')
xlim([0.01 100])