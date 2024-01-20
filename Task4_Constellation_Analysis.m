clear all;

Ng_right = 7; % Guard interval on the right
N = 128; % Number of pilot subcarriers (every other one)
Fc = 64; % Central subcarrier
modulation_info = 4; % Modulation scheme on information subcarriers
modulation_pilot = 2; % Modulation scheme on pilot subcarriers
prefix_length = 16; % Cyclic prefix length
fs = 40e6; % Sampling frequency
points = 1;

ofdm_symbols = zeros(N, points);
for i = 1:points
%     info_symbols = randi([0, 3], 1, 29);
%     pilot_symbols = randi([0, 1], 1, 29);
    info_symbols = randi([0, 15], 29, 1);  
    pilot_symbols = randi([0, 3], 29, 1); 
%     info_subcarriers = pskmod(info_symbols, modulation_info, 0, 'gray', InputType = 'integer');
%     pilot_subcarriers = pskmod(pilot_symbols, modulation_pilot);
    info_subcarriers = qammod(info_symbols, 16);  % 16-QAM modulation
    pilot_subcarriers = pskmod(pilot_symbols, 4);  % QPSK modulation
    ofdm_symbol = zeros(1, N);
    ofdm_symbol(9:2:66) = info_subcarriers;
    ofdm_symbol(65:2:121) = info_subcarriers;
    ofdm_symbol(10:2:67) = pilot_subcarriers;
    ofdm_symbol(64:2:120) = pilot_subcarriers;
%     ofdm_symbol(9:2:121) = info_subcarriers;
%     ofdm_symbol(10:2:120) = pilot_subcarriers;
    ofdm_symbols(:,i) = ofdm_symbol;
end

ofdm_signal = ifft(ofdm_symbols, 128);

ifft_signal = ifft(ofdm_symbols, 128);
last_16 = ifft_signal(113:end,:);
p4_signal = [last_16; ifft_signal];
p4_signal = reshape(p4_signal,[],1);

spectrum = pwelch(p4_signal, 128, 0, 128, 'twosided');

figure;
plot(linspace(0, fs, 128), 10*log10(spectrum));  % Display only half of the spectrum
title('Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');

%% Constellation shifts
ofdm_signal_without_cp = p4_signal(prefix_length+1:end);

% Frequency domain representation
ofdm_signal_freq = fft(ofdm_signal_without_cp, 128);
scatterplot(ofdm_signal_freq);
title('Original Signal');
% Frequency domain representations with different circular shifts
shifts = [-1, -10, 1, 10];
names =['Shift -1',"Shift -10", "Shift 1", "Shift 10"];
for i = 1:length(shifts)
    shifted_signal = fft(circshift(ofdm_signal_without_cp, shifts(i)), 128);
    scatterplot(shifted_signal);
    title(names(i))
end

%% Frequency shift | What is subcarrier spacing?
frequency_shifts = [0.1, 0.5, 1]; % in subcarrier spacing
shifted_signals = cell(1, length(frequency_shifts));

% #dF = 1/t

%% Points 5-6
Fs = 40e6;  % Transmitter sampling frequency
epsilon_values = [0.02, 0.01, -0.01, -0.02];  % Values for epsilon

% Create a time vector based on the original sampling frequency
t_transmitter = (0:length(p4_signal)-1) / Fs;

% Transmitter
for epsilon = epsilon_values
    % Correct the receiver sampling frequency
    Fs_receiver = Fs - epsilon * Fs;

    % Create a time vector based on the corrected sampling frequency
    t_receiver = (0:length(p4_signal)-1) / Fs_receiver;

    % Resample the signal at the receiver
    ofdm_signal_received = resample(p4_signal, Fs_receiver, Fs);

    % Modulate on the central subcarrier
    central_subcarrier_index = floor(length(p4_signal) / 2);
    central_subcarrier_signal = ofdm_signal_received(central_subcarrier_index, :);

    % Plot the signal constellation
    scatterplot(central_subcarrier_signal);
    title(['Signal Constellation (Epsilon = ' num2str(epsilon) ')']);
    xlabel('I');
    ylabel('Q');
    grid on;
end
