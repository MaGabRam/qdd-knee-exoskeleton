clear; clc; close all;

%% Evaluación térmica preliminar del actuador QDD
% Por: Mariel Valeriano

%% Datos tomados del perfil / avance
T_amb = 25;              % Temperatura ambiente [°C]
T_ref_bobina = 78;       % Temperatura superficial reportada en bobinas [°C]
Tmax_actuador = 29.4;    % Torque máximo reportado del actuador [N*m]

T_inicial = 14;          % Torque reportado con fuente de 24 V y 25 A [N*m]
I_inicial = 25;          % Corriente disponible en esa prueba [A]

masa_actuador = 0.728;   % Masa reportada del actuador [kg]

%% Resultados de tu modelo dinámico controlado
T_control_15 = 1.8486;   % Torque máximo control para 15 kg [N*m]
T_control_20 = 2.5582;   % Torque máximo control para 20 kg [N*m]
T_control_25 = 3.4465;   % Torque máximo control para 25 kg [N*m]

FS = 2;                  % Factor de seguridad
T_diseno_15 = T_control_15 * FS;
T_diseno_20 = T_control_20 * FS;
T_diseno_25 = T_control_25 * FS;

%% Estimación aproximada de constante torque-corriente
% Usando dato: 14 N*m con 25 A
Kt_aprox = T_inicial / I_inicial; % [N*m/A]

I_15 = T_diseno_15 / Kt_aprox;
I_20 = T_diseno_20 / Kt_aprox;
I_25 = T_diseno_25 / Kt_aprox;

%% Modelo térmico normalizado
% Se asume que 29.4 N*m corresponde al caso térmico alto,
% con temperatura reportada cercana a 78 °C.
% La temperatura final se escala con (T/Tmax)^2.

tau = 180;        % constante de tiempo térmica aproximada [s]
t_final = 600;    % simulación de 10 min [s]
dt = 1;
t = 0:dt:t_final;

torques = [T_diseno_15, T_diseno_20, T_diseno_25, 14, 29.4];
nombres = {'Diseño 15 kg', 'Diseño 20 kg', 'Diseño 25 kg', ...
           'Referencia 14 N*m', 'Máximo 29.4 N*m'};

T_temp = zeros(length(torques), length(t));
T_ss = zeros(length(torques), 1);

for i = 1:length(torques)

    ratio = torques(i) / Tmax_actuador;

    % Temperatura de régimen estimada
    T_ss(i) = T_amb + (T_ref_bobina - T_amb) * ratio^2;

    % Respuesta térmica de primer orden
    T_temp(i,:) = T_amb + (T_ss(i) - T_amb) * (1 - exp(-t/tau));

end

%% Gráfica térmica
figure;
plot(t/60, T_temp, 'LineWidth', 1.5);
grid on;
xlabel('Tiempo [min]');
ylabel('Temperatura estimada [°C]');
title('Evaluación térmica preliminar del actuador QDD');
legend(nombres, 'Location', 'best');

yline(60, '--', 'Referencia preventiva 60°C');
yline(78, '--', 'Temperatura reportada 78°C');

%% Tabla de resultados
T_final = T_temp(:,end);
T_max_sim = max(T_temp, [], 2);
uso_torque = (torques(:) / Tmax_actuador) * 100;

corriente_estimada = torques(:) / Kt_aprox;

tabla_termica = table(torques(:), uso_torque, corriente_estimada, ...
    T_ss, T_final(:), T_max_sim(:), ...
    'VariableNames', {'Torque_Nm', 'Uso_torque_porcentaje', ...
    'Corriente_estimada_A', 'Temperatura_regimen_C', ...
    'Temperatura_10min_C', 'Temperatura_max_C'});

disp(tabla_termica);

writetable(tabla_termica, 'resultados_termicos_qdd.xlsx');

%% Mensajes principales
fprintf('\nConstante torque-corriente aproximada Kt = %.3f N*m/A\n', Kt_aprox);
fprintf('Para el caso crítico de diseño 25 kg:\n');
fprintf('Torque de diseño = %.3f N*m\n', T_diseno_25);
fprintf('Corriente estimada = %.2f A\n', I_25);
fprintf('Temperatura estimada a 10 min = %.2f °C\n', T_final(3));
fprintf('Uso respecto al torque máximo = %.1f %%\n', uso_torque(3));