% Specify the path to the sig_wifi.pcm file
file_path = 'sig_wifi.pcm';

% Open the file for reading
fid = fopen(file_path, 'rb');  % 'rb' for reading in binary mode

if fid == -1
    error('Failed to open the file.');
end

% Read data from the file
data = fread(fid, 'int16');  % 'int16' indicates 16-bit data format

% Close the file after reading
fclose(fid);

% Create a complex signal from the in-phase and quadrature components
wifi_signal = complex(data(1:2:end), data(2:2:end));
clear file_path fid data ans;
