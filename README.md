# TRMS
Mathematical modelling and controller design for the TRMS (Twin-rotor MIMO System).

## About
This repository contains:
 - The nonlinear Euler-Lagrangian model of the TRMS
 - Scripts for trimming and linearizing the system
 - Scripts for controller design
 - Simulink models to evaluate controller performance against the nonlinear system

All development was made in MATLAB and Simulink R2016a. Compatible models for older versions of Simulink are also included.

Mathematical modeling and parameters' numerical values were obtained from the works of [Tastemirov, Lecchini-Visintini and Morales-Viviescas (2017)](https://www.researchgate.net/publication/318230828_Complete_dynamic_model_of_the_Twin_Rotor_MIMO_System_TRMS_with_experimental_validation) and [Rao, Akhila and Morales-Viviescas (2019)](https://www.researchgate.net/publication/334784613_Extended_Kalman_observer_based_Robust_Control_of_one_degree_of_freedom_TRMS) for the laboratory equipment produced by [Feedback Instruments](https://www.feedback-shop.co.uk/twin-rotor-mimo-system-33-007i.html).

As far as this release, three controllers were developed: a decentralized PID controller, a LQI regulator and a H-Infinity controller.

## Environment setup
Add folders "Model" and "Functions" to MATLAB path.

## Quick description of files

File | About
--- | ---
TRMS/Functions/filtro_pondera | Filter synthesis
TRMS/Functions/info.mat | Plot instructions for "loopview" command
TRMS/Model/lib_Lagrangian_Model_Nonlinear.slx | Nonlinear model of the TRMS
TRMS/Model/load_TRMS_Linear_Model.m | Trimming and linearization
TRMS/Model/load_TRMS_Model_Parameters.m | Loads numerical values of the model
TRMS/Model/trim_Lagrangian_Model_Nonlinear.slx | Model used for trimming
TRMS/Model/old | Older versions of Simulink models
TRMS/design_DecouplingPID.m | Design and linear analysis for PID controller
TRMS/design_LQI.m | Design and linear analysis for LQI controller
TRMS/design_HInf.m | Design and linear analysis for H-Infinity controller
TRMS/sim_DecouplingPID.slx | Nonlinear simulation of PID controller
TRMS/sim_LQI.slx | Nonlinear simulation of LQI controller
TRMS/sim_HInf.slx | Nonlinear simulation of H-Infinity controller
TRMS/Model/old | Older versions of Simulink models
