filename1 = 'sig_wifi.pcm';
fid1 = fopen(filename1, 'r');
data1 = fread(fid1, 'int16');
fclose(fid1); 

% filename2 = 'File1_fd20_1_ofdm_only.pcm';
% fid2 = fopen(filename2, 'r');
% data1 = fread(fid2, 'int16');
% fclose(fid2); 
%%
inphase = data1(1:2:end); %синфазная
quadrature = data1(2:2:end); %квадратурная
%%
data2 = complex(inphase, quadrature);
%%
% subplot(3,1,1)
% plot(real(complex_signal));
% 
% subplot(3,1,2)
% plot(imag(complex_signal));
% 
% subplot(3,1,3)
% plot(abs(complex_signal));


% plot(data2);

data_samples = rot90(data2);
N = 64;
short_symbol = zeros(1, N);

short_26 = [1+i, -1-i, 1+i, -1-i, -1-i, 1+i];
short_26_ = [-1-i, -1-i, 1+i, 1+i, 1+i, 1+i];

short_symbol(9:4:32) = short_26;
short_symbol(37:4:57) = short_26_;

short_symbol_freq = ifft(ifftshift(short_symbol));
filt = rot90(conj(short_symbol_freq(1:16)), 2);

all_signal = conv(filt, data_samples);

plot(abs(all_signal));