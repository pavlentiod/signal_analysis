%% создание сигнала только с пятыми поднесущими

clear all;

Ng_right = 7; % Защитный интервал справа
N = 128; % Количество пилотных поднесущих (каждая вторая)
Fc = 64; % Центральная поднесущая
modulation_info = 4; % Способ манипуляции на информационных поднесущих
modulation_pilot = 2; % Способ манипуляции на пилотных поднесущих
prefix_length = 16; % Длительность циклического префикса
fs = 40e6; % Частота дискретизации
points = 1;


ofdm_symbols = zeros(N, points);
for i = 1:points
%     info_symbols = randi([0, 3], 1, 29);
%     pilot_symbols = randi([0, 1], 1, 29);
    info_symbols = randi([0, 15], 2, 1);  
    pilot_symbols = randi([0, 3], 2, 1); 
%     info_subcarriers = pskmod(info_symbols, modulation_info, 0, 'gray', InputType = 'integer');
%     pilot_subcarriers = pskmod(pilot_symbols, modulation_pilot);
    info_subcarriers = qammod(info_symbols, 16);  % модуляция 16-QAM
    pilot_subcarriers = pskmod(pilot_symbols, 4);  % модуляция QPSK
    ofdm_symbol = zeros(1, N);
    ofdm_symbol(44) = info_subcarriers(1);
    ofdm_symbol(84) = info_subcarriers(2);
    ofdm_symbol(45) = pilot_subcarriers(1);
    ofdm_symbol(85) = pilot_subcarriers(2);
    ofdm_symbols(:,i) = ofdm_symbol;
end

fifth_subs_signal = ifft(ofdm_symbols, 128);

last_16 = fifth_subs_signal(113:end,:);
fifth_subs_signal = reshape([last_16; fifth_subs_signal],[],1);

spectrum = pwelch(fifth_subs_signal, 128, 0, 128, 'twosided');

figure;
plot(linspace(0, fs, 128), 10*log10(spectrum));  % Отображение только половины спектра
title('Спектр сигнала');
xlabel('Частота (Гц)');
ylabel('Амплитуда (дБ)');


%% помеха синусом
ofdm_signal_without_cp = p4_signal(16+1:end);
ofdm_signal_freq = fft(ofdm_signal_without_cp, 128);
fs = 40e6;
for i = [5,-5]
    i = i*2;
    f_subcarrier = ofdm_signal_freq(64+i);
%     t = 0:1/fs:(length(ofdm_signal_without_cp)-1)/fs;
    amplitude = abs(ofdm_signal_without_cp(64+i)); 
    s = sin(2*pi*f_subcarrier);
    sinusoid = amplitude * s;
    ofdm_signal_without_cp(64+i) = ofdm_signal_without_cp(64+i) +  sinusoid;
    p4_signal_with_interference = ofdm_signal_without_cp;
    signal = fft(p4_signal_with_interference,128);
    scatterplot(signal);
    title(num2str(i/2));
end
% на спектре должны быть 2 пика
% проверка точно ли +-5 (создать офдм с заполненными только +-5
% поднесущими) при сложении с моделируемым сигналом мы получим обычный
% спектр 
% основное - проверит спектр

spectrum = pwelch(p4_signal_with_interference, 128, 0, 128, 'twosided');

figure;
plot(linspace(0, fs, 128), 10*log10(spectrum));  % Отображение только половины спектра
title('Спектр сигнала');
xlabel('Частота (Гц)');
ylabel('Амплитуда (дБ)')
