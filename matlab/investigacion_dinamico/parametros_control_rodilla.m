clear; clc;

%% Caso de análisis
M = 25;          % masa corporal [kg]
L = 0.42;        % longitud segmento pierna-pie [m]

%% Movimiento
tf = 3;          % tiempo de flexión [s]

%% Controlador
Ks = 8;          % rigidez virtual del controlador [N*m/rad]
Bs = 1;          % amortiguamiento virtual del controlador [N*m*s/rad]

%% Parámetros biodinámicos aproximados
b_pass = 0.05;   % amortiguamiento pasivo [N*m*s/rad]
k_pass = 0.5;    % rigidez pasiva [N*m/rad]

%% Actuador
torque_lim = 29.4;   % torque máximo referencial del actuador [N*m]

disp('Parámetros cargados correctamente');