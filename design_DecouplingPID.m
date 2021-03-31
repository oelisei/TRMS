%% Decoupling PID controller for TRMS 
%
% This MATLAB script is a decoupling PID controller synthesis and analysis
% for the TRMS
%
% MATLAB(R) file generated by MATLAB(R) 9.0
%
% (C) MIT License 

%% Load model
run ('.\Model\load_TRMS_Linear_Model')
% Faster model
% load ('.\Model\TRMS_Model.mat')

%% Define controller architecture
% Parameterize the tunable elements using Control Design blocks
% Use the tunableGain object to parameterize DM and fix DM(1, 1) = -1 and DM(2, 2) = -1
% This creates a 2x2 static gain with the off-diagonal entries as tunable parameters
DM = tunableGain('Decoupler', diag([-1 -1]));
DM.Gain.Free = [false true; true false];

% Similarly, use the tunablePID object to parameterize the two PID controllers
PID_PITCH = tunablePID('PID_PITCH', 'pid');
PID_YAW = tunablePID('PID_YAW', 'pid');

% Next construct a model C0 of the controller
C0 = blkdiag(PID_PITCH, PID_YAW) * DM * [eye(2) -eye(2)];
C0.InputName = {'RefPitch', 'RefYaw', 'psi', 'phi'};
C0.OutputName = {'Um', 'Ut'};

%% Define controller constraints and objectives
% Set the crossover frequency to 0.8 rad/s
wc = 0.8;

% Define controller requirements
% Requirement 1 - Minimum margin gain of 6dB and minimum margin phase of 35� 
req1 = TuningGoal.Margins({'psi', 'phi'}, 6, 35);

% Requirement 2 - Maximum overshoot of 10%
req2 = TuningGoal.Overshoot({'RefPitch', 'RefYaw'}, {'psi', 'phi'}, 10);

% Requeriments 3 and 4 - Adjust rejection and sensitivity
rejectSpec = frd([100 100 1 1], [0.001 0.1 1 1000]); 
req3 = TuningGoal.Rejection('phi', rejectSpec);

sensSpec = frd([10 10 100 100], [0.001 10 100 1000]);
req4 = TuningGoal.Sensitivity('phi', sensSpec);

%% Tune the controller
[G, K, GAM, INFO] = looptune(TRMS.linear.sys, C0, wc, req1, req2, req3, req4);
KPID = ss(K);

%% Connect the closed-loop system
Tcl = connect(TRMS.linear.sys, KPID, {'RefPitch','RefYaw'}, {'psi','phi'});

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
legend('Psi', 'Refer�ncia', 'Location', 'best')
subplot(2, 1, 2)
plot(t_data, y_data(:, 2, 1), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel('Tempo (s)'), ylabel('Phi (rad)'), ylim([-0.1 0.1]), title({'Acoplamento', 'Guinada'})
line([0, 30], [0, 0], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Phi', 'Refer�ncia', 'Location', 'best')

% Yaw step response
figure()
opt = stepDataOptions('InputOffset', [0 0], 'StepAmplitude', [0 0.2]);
[y_data, t_data] = step(Tcl, 30, opt);
subplot(2, 1, 1)
plot(t_data, y_data(:, 2, 2), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel({'Tempo (s)', ''}), ylabel('Phi (rad)'), ylim([0 0.3]), title({'Resposta ao degrau', 'Guinada'})
line([0, 30], [0.2, 0.2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
line([0, 0], [0, 0.2], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Phi', 'Refer�ncia', 'Location', 'best');
subplot(2, 1, 2)
plot(t_data, y_data(:, 1, 2), 'LineWidth', 2, 'Color', 'Blue'), grid, xlabel('Tempo (s)'), ylabel('Psi (rad)'), ylim([-0.1 0.1]), title({'Acoplamento', 'Arfagem'})
line([0, 30], [0, 0], 'LineStyle', '--', 'LineWidth', 1, 'Color', 'Red')
legend('Psi', 'Refer�ncia', 'Location', 'best');

%% Frequency analysis
figure()
loopview(TRMS.linear.sys, KPID)
children = get(gca, 'children');
delete(children(3));
delete(children(4));
xlim([0.01 100])
ylim([-60 10])
title('Sensibilidades de entrada')
xlabel('Frequ�ncia')
ylabel('Valores singulares')

figure()
loopview(TRMS.linear.sys, KPID)
children = get(gca, 'children');
delete(children(1));
delete(children(2));
delete(children(3));
xlim([0.01 100])
ylim([-60 60])
title('Resposta em malha aberta')
xlabel('Frequ�ncia')
ylabel('Valores singulares')

figure
load('.\Functions\info.mat'); % This file contains plot intructions for command 'loopview'
loopview(TRMS.linear.sys, KPID, INFO);
title('Margens de estabilidade')
legend('Margens de estabilidade')
xlabel('Frequ�ncia')
ylabel('Margem de ganho; Margem de fase')
xlim([0.01 100])