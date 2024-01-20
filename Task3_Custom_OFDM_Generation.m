% clear all
% clc
% Parameters - ADD GUARD INTERVALS
N = 128;  % Number of subcarriers
pilot_subcarriers = 56;  % Number of pilot subcarriers
info_subcarriers = 56;  % Number of information subcarriers
points = 100;  % Total number of OFDM symbols
fs = 40e6;
% Generate random data


% scatterplot(pilot_symbols(:,1))


% Create OFDM symbols
ofdm_symbols = zeros(N, points);
% Add frequency guard interval
for i = 1:points
    info_data = randi([0, 15], info_subcarriers, 1);  
    pilot_data = randi([0, 3], pilot_subcarriers, 1); 
    % Zero amplitude at the central subcarrier
%     info_data(26,:) = 0;
%     pilot_data(26,:) = 0;
    % Modulate data 
    info_symbols = qammod(info_data, 16);  % 16-QAM modulation
    pilot_symbols = pskmod(pilot_data, 4);  % QPSK modulation
    % Create an OFDM symbol for each sample
    ofdm_symbol = zeros(N, 1);  % Initialize OFDM symbol
    ofdm_symbol(9:2:120) = pilot_symbols;
    ofdm_symbol(10:2:121) = info_symbols;
%     ofdm_symbol = [ofdm_symbol; zeros(10,1)];
    ofdm_symbols(:,i) = ofdm_symbol;
end
% Transform the array of OFDM symbols into a one-dimensional data array


% Convert the array of OFDM symbols into a one-dimensional data array
ifft_signal = ifft(ofdm_symbols, 128);
last_16 = ifft_signal(113:end,:);
p3_signal = [last_16; ifft_signal];
p3_signal = reshape(p3_signal,[],1);
% p3_signal = repmat(p3_signal,2,1);
% clear N info_subcarriers pilot_subcarriers points info_data pilot_data info_symbols pilot_symbols ofdm_symbols cp_length ofdm_symbol_with_cp i ofdm_symbol;
spectrum = pwelch(p3_signal, 2048, 0, 128, 'twosided');

figure;
plot(linspace(0, fs, 128), 10*log10(spectrum));  % Display only half of the spectrum
title('Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
