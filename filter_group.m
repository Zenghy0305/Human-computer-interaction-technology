function y = filter_group(eeg, fs, idx_fb)

[num_chans,~] = size(eeg);
fs=fs/2;
%设置通带阻带列表采用带通滤波器将原始信号分成对应idx_fb的子频带
pass_list = [4, 10, 16, 22, 28, 34, 38];
stop_list = [2, 6, 10, 16, 22, 28,34];
pass_max = 40;
stop_max = 50;
Wp = [pass_list(idx_fb)/fs, pass_max/fs];
Ws = [stop_list(idx_fb)/fs, stop_max/fs];
[N, Wn]=cheb1ord(Wp, Ws, 3, 30);
[B, A] = cheby1(N, 0.5, Wn,'bandpass');
y = zeros(size(eeg));
for i = 1:1:num_chans
    y(i, :) = filtfilt(B, A, eeg(i, :));
end