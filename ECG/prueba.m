% Codificación y decodificación DTMF
clear; clf;
Fs = 10000;              % Frecuencia de muestreo: 10 kHz
Ts = 1/Fs;               % Período de muestreo
% Definición del teclado
keypad.keys = ['1' '2' '3' 'A';
               '4' '5' '6' 'B';
               '7' '8' '9' 'C';
               '*' '0' '#' 'D'];
keypad.row_freqs = [697 770 852 941];      % Frecuencias de filas
keypad.col_freqs = [1209 1336 1477 1633];  % Frecuencias de columnas
w = 2*pi*[keypad.row_freqs keypad.col_freqs];
% Generación de señal DTMF
[x, tt] = dtmf_generator('159D', [0.1 0.2 0.1 0.2], Ts, keypad);
soundsc(x, Fs);   % Reproducir señal
% Decodificación de la señal DTMF
[keys, B, A] = dtmf_decoder(x, Ts, keypad);
disp(keys);
% Ejecutar modelo de Simulink
sim('dtmf', tt(end));   % Ejecuta el modelo 'dtmf' durante tt(end) segundos
% ================= FUNCIÓN GENERADORA =================
function [wave, tt] = dtmf_generator(keys, durations, Ts, keypad)
% keys, durations : teclas presionadas y sus duraciones en vectores
% Ts : período de muestreo
% Uso académico únicamente
Nkey = length(keys);
Nduration = length(durations);
% Ajustar duración si es menor que el número de teclas
if Nduration < Nkey
    durations = [durations durations(1)*ones(1, Nkey - Nduration)];
end
wave = [];
tt = [];
pi2 = 2*pi;
% Intervalo de silencio entre teclas (0.1 s)
Nzero = ceil(0.1 / Ts);
zero_between_keys = zeros(1, Nzero);
tzero = (1:Nzero) * Ts;
for i = 1:Nkey
    t = Ts:Ts:durations(i);
    if i == 1
        tt = [tt t];
    else
        tt = [tt tt(end) + t];
    end
    % Encontrar posición de la tecla en el teclado
    [m, n] = find(keys(i) == keypad.keys);
    if isempty(m)
        error('Tecla incorrecta en dtmf_generator');
    end
    % Frecuencias correspondientes (fila y columna)
    w2 = pi2 * [keypad.row_freqs(m); keypad.col_freqs(n)];
    % Generar señal (suma de senoidales)
    wave = [wave sum(sin(w2 * t)) zero_between_keys]; 
    % Actualizar vector de tiempo con el intervalo de silencio
    tt = [tt tt(end) + tzero];
end
end