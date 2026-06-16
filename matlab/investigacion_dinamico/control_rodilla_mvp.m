clear; clc; close all;

%% Parámetros generales
g = 9.81;
factor_CM = 0.43;
porcentaje_pierna_pie = 0.06;

% Casos pediátricos: [masa corporal, longitud pierna-pie]
casos = [15 0.28;
         20 0.35;
         25 0.42];

% Movimiento
tf = 3;          % tiempo de flexión [s]
t_end = 4;       % simulación total [s]

% Actuador
torque_lim = 29.4;  % límite referencial del actuador [N*m]
FS = 2;             % factor de seguridad para comparación de diseño

% Parámetros biodinámicos aproximados
b_pass = 0.05;      % amortiguamiento pasivo [N*m*s/rad]
k_pass = 0.5;       % rigidez pasiva aproximada [N*m/rad]
theta0 = 0;         % posición neutra [rad]

% Controlador de rigidez/impedancia simplificado
Ks = 8;             % rigidez virtual del controlador [N*m/rad]
Bs = 1.0;           % amortiguamiento virtual del controlador [N*m*s/rad]

%% Resultados
resultados = [];

figure(1); hold on; grid on;
title('Seguimiento angular de rodilla');
xlabel('Tiempo [s]');
ylabel('Ángulo [deg]');

figure(2); hold on; grid on;
title('Torque comandado por el controlador');
xlabel('Tiempo [s]');
ylabel('Torque [N*m]');

for i = 1:size(casos,1)

    M = casos(i,1);
    L = casos(i,2);

    m = porcentaje_pierna_pie * M;
    d = factor_CM * L;
    I = m*d^2;

    p.g = g;
    p.M = M;
    p.L = L;
    p.m = m;
    p.d = d;
    p.I = I;
    p.tf = tf;
    p.torque_lim = torque_lim;
    p.b_pass = b_pass;
    p.k_pass = k_pass;
    p.theta0 = theta0;
    p.Ks = Ks;
    p.Bs = Bs;

    % Condiciones iniciales: theta = 0 rad, omega = 0 rad/s
    x0 = [0; 0];

    % Simulación dinámica
    [t,x] = ode45(@(t,x) dinamica_rodilla_controlada(t,x,p), [0 t_end], x0);

    theta = x(:,1);
    omega = x(:,2);

    theta_ref = zeros(size(t));
    omega_ref = zeros(size(t));
    T_cmd = zeros(size(t));
    P_mec = zeros(size(t));

    for j = 1:length(t)

        [theta_ref(j), omega_ref(j)] = referencia_rodilla(t(j), tf);

        % Controlador con compensación de gravedad y rigidez aproximada
        T_grav_ref = m*g*d*sin(theta_ref(j));
        T_rig_ref = k_pass*(theta_ref(j)-theta0);

        T_unsat = T_grav_ref + T_rig_ref + ...
                  Ks*(theta_ref(j)-theta(j)) + ...
                  Bs*(omega_ref(j)-omega(j));

        % Saturación del actuador
        T_cmd(j) = max(min(T_unsat, torque_lim), -torque_lim);

        % Potencia mecánica aproximada
        P_mec(j) = T_cmd(j)*omega(j);
    end

    error_deg = rad2deg(theta_ref - theta);

    torque_max = max(abs(T_cmd));
    torque_diseno = torque_max * FS;
    error_rms = rms(error_deg);
    error_max = max(abs(error_deg));
    omega_max = max(abs(omega));
    energia_ciclo = trapz(t, abs(P_mec));

    resultados = [resultados;
        M, L, torque_max, torque_diseno, error_rms, error_max, omega_max, energia_ciclo];

    % Graficar seguimiento angular
    figure(1);
    plot(t, rad2deg(theta), 'LineWidth', 1.5, ...
        'DisplayName', ['\theta real ', num2str(M), ' kg']);

    % Graficar torque
    figure(2);
    plot(t, T_cmd, 'LineWidth', 1.5, ...
        'DisplayName', ['Torque ', num2str(M), ' kg']);

end

% Graficar referencia común
figure(1);
plot(t, rad2deg(theta_ref), 'k--', 'LineWidth', 2, ...
    'DisplayName', '\theta referencia');
legend('Location','best');

figure(2);
yline(torque_lim, 'r--', 'Límite +29.4 N*m');
yline(-torque_lim, 'r--', 'Límite -29.4 N*m');
legend('Location','best');

%% Tabla final
tabla = array2table(resultados, ...
    'VariableNames', {'Masa_corporal_kg', 'Longitud_segmento_m', ...
    'Torque_max_control_Nm', 'Torque_diseno_FS2_Nm', ...
    'Error_RMS_deg', 'Error_max_deg', ...
    'Velocidad_max_rad_s', 'Energia_ciclo_J'});

disp(tabla);

writetable(tabla, 'resultados_control_dinamico_rodilla.xlsx');

%% Funciones locales

function dx = dinamica_rodilla_controlada(t,x,p)

    theta = x(1);
    omega = x(2);

    [theta_ref, omega_ref] = referencia_rodilla(t, p.tf);

    % Controlador: compensación + rigidez/impedancia virtual
    T_grav_ref = p.m*p.g*p.d*sin(theta_ref);
    T_rig_ref = p.k_pass*(theta_ref-p.theta0);

    T_unsat = T_grav_ref + T_rig_ref + ...
              p.Ks*(theta_ref-theta) + ...
              p.Bs*(omega_ref-omega);

    T_cmd = max(min(T_unsat, p.torque_lim), -p.torque_lim);

    % Torques resistentes de la planta
    T_grav = p.m*p.g*p.d*sin(theta);
    T_fric = p.b_pass*omega;
    T_rig = p.k_pass*(theta-p.theta0);

    % Dinámica
    alpha = (T_cmd - T_grav - T_fric - T_rig)/p.I;

    dx = [omega; alpha];
end

function [theta_ref, omega_ref] = referencia_rodilla(t, tf)

    theta_i = deg2rad(0);
    theta_f = deg2rad(90);

    u = t/tf;

    if u > 1
        u = 1;
    end

    if u < 0
        u = 0;
    end

    % Trayectoria suave minimum jerk
    s = 10*u^3 - 15*u^4 + 6*u^5;

    if t <= tf
        sdot = (30*u^2 - 60*u^3 + 30*u^4)/tf;
    else
        sdot = 0;
    end

    delta_theta = theta_f - theta_i;

    theta_ref = theta_i + delta_theta*s;
    omega_ref = delta_theta*sdot;
end