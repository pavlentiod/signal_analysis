%% Point 1-2
data_samples = wifi_signal;  % Point 2
% data_samples = p3_signal; % Point 3
% Signal parameters
fs = 11.2e6;  % Sampling frequency 11.2 MHz
t = (0:length(data_samples)-1) / fs;  % Time scale

% Create a figure for the plots
figure;

% Create subplots for envelope, real, and imaginary parts of the signal
subplot(3,1,1);
plot(t, abs(data_samples));  % Envelope
title('Signal Envelope');
xlabel('Time (seconds)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, real(data_samples));  % Real part
title('Real Part of Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, imag(data_samples));  % Imaginary part
% plot(t*1e5, imag(data_samples));  % For the signal generated in Point 3

title('Imaginary Part of Signal');
xlabel('Time (seconds)');
ylabel('Amplitude');

% Mark OFDM symbols and preamble data
hold on;  % Add to the current plot

% Mark the beginning of each symbol using preamble data
frame_starts = PREAMBLE_DATA.Frame_start / fs;  % Convert to seconds

for i = 1:length(frame_starts)
    plot([frame_starts(i), frame_starts(i)], ylim, 'r--');  % Red dashed lines
end

hold off;  % Finish adding to the plot

% Additional plot settings
grid on;

%% Point 3

data_samples = wifi_signal;  % Point 2
% data_samples = p3_signal; % Point 3
% data_samples = ofdm_signal_cp; % Point 3 new
% FFT and window parameters
fft_size = 8192;  % FFT size
window_size = 2048;  % Window size
fs = 11.2e6;

% Calculate the spectrum of the signal
spectrum = pwelch(data_samples, window_size, 0, fft_size, 'twosided');

% Mark frequency guard intervals (if any)
frame_starts = PREAMBLE_DATA.Frame_start;  % OFDM symbol and preamble starts
frame_starts = frame_starts / fs;  % Convert to seconds

% Plot the spectrum
figure;
plot(linspace(0, fs/2, fft_size), 10*log10(spectrum(1:fft_size)));  % Display only half of the spectrum
title('Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');

% Mark frequency guard intervals (if any)
hold on;

for i = 1:length(frame_starts)
    % Mark the corresponding frequency interval for each symbol start
    plot([frame_starts(i), frame_starts(i)], ylim, 'r--');  % Red dashed lines
end

hold off;

% Plot settings
grid on;

%% Point 4
data_samples = wifi_signal;  % Point 2
% data_samples = signal_data; % Point 3

% Spectrogram parameters
window_length = 256;  % Window length
overlap = 128;  % Overlap between windows

% Calculate and display the spectrogram
figure;

% Compute the spectrogram
[S, F, T, P] = spectrogram(data_samples, hamming(window_length), overlap, window_length, fs, 'yaxis');

% Display the spectrogram
subplot(2,1,1);
imagesc(T, F, 10*log10(abs(P)));  % Display amplitude in decibels
title('Signal Spectrogram');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
colorbar;

% Check for pilot subcarriers
% Pilot subcarriers usually show constant amplitude or phase.
subplot(2,1,2);
pilot_subcarriers = [1, 2, 3, 4];  % Example set of pilot subcarriers (replace with your own)
plot(T, abs(S(pilot_subcarriers, :)));  % Display amplitude of pilot subcarriers
title('Pilot Subcarriers');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend('Pilot 1', 'Pilot 2', 'Pilot 3', 'Pilot 4');

% Plot settings
colormap('jet');  % Color map
clear window_length overlap S F T P pilot_subcarriers;

%% Point 5
frame_start = PREAMBLE_DATA.Frame_start(2);  % Start of the second frame
frame_duration = PREAMBLE_DATA.Frame_start(3) - frame_start;  % Duration in seconds

% Calculate PAPR for the original sample
papr_original = 10*log10(max(abs(data_samples(frame_start:frame_start+frame_duration)).^2) / mean(abs(data_samples(frame_start:frame_start+frame_duration)).^2));

% Increase the sampling frequency by 4 times
data_samples_resampled = resample(data_samples, 4, 1);  % Increase the frequency

% Calculate the peak factor for the increased sampling frequency
papr_resampled = 10*log10(max(abs(data_samples_resampled(frame_start*4:(frame_start+frame_duration)*4)).^2) / mean(abs(data_samples_resampled(frame_start*4:(frame_start+frame_duration)*4)).^2));

% Display the results
fprintf('Peak Factor: %.2f dB\n', papr_original);
fprintf('Peak Factor with increased sampling frequency: %.2f dB\n', papr_resampled);
clear fs_new data_samples_resampled frame_duration frame_start papr_resampled papr_original;
