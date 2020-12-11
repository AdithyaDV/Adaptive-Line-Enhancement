clc
clear
close all

%% Desired Signal - s(n) and Noise signal - w(n)
fs = 160;
ts = 1/fs;
total_time = 10;
t = 0:ts:total_time-ts;

f = 10;
A = 5;
sn = A*sin(2*pi*f*t);

% len = length(sn);
% wn = -A + 2*A.*(rand(1,len));
% ufsn = sn+wn;
% 
% SNR =  0.5; 
SNR =  -6;
ufsn = awgn(sn, SNR); %Noisy signal

%% Plotting of input signals
figure(1)
subplot(211)
plot(t, sn);title('Time domain desired signal');xlabel('Time(secs)');ylabel('Amplitude');
subplot(212)
plot((fs/2)*linspace(-1,1,total_time*fs), 10*log10(abs(fftshift(fft(sn)))));
title('Frequency domain');xlabel('Frequency(Hz)');ylabel('Amplitude in dB');
% figure(2)
% subplot(211)
% plot(t, wn);title('Time domain Noise');xlabel('Time(secs)');ylabel('Amplitude');
% subplot(212)
% plot((fs/2)*linspace(-1,1,total_time*fs), 10*log10(abs(fftshift(fft(wn)))));
% title('Frequency domain');xlabel('Frequency(Hz)');ylabel('Amplitude in dB');
figure(2)
subplot(211)
plot(t, ufsn);title('Time domain noisy singal');xlabel('Time(secs)');ylabel('Amplitude');
subplot(212)
plot((fs/2)*linspace(-1,1,total_time*fs), 10*log10(abs(fftshift(fft(ufsn)))));
title('Frequency domain');xlabel('Frequency(Hz)');ylabel('Amplitude in dB');

%% LMS
tic
epoch = 100;            % Number of epoch iterations
order = 30;               % tap delays / order of filter
delta = 1e-6;

delayed = [0,0,ufsn(1:length(ufsn)-2)];

[W, costFLMS] = lms(ufsn,delayed,order,delta,epoch);
yn = filter(W,1,delayed);
toc
LMS_time = toc;
disp('LMS time')
disp(LMS_time)
%% Outputs - FIR Filter using LMS
figure(3)
plot(t, ufsn);title('Time domain signal - LMS');xlabel('Time(secs)');ylabel('Amplitude');
hold('on');
plot(t, yn);legend('Desired Signal', 'Filtered Signal');
grid on

xf=freqz(ufsn);   
% Wf=freqz(W);   
df=freqz(sn);  
fyf = freqz(yn);

frequencies=(0:length(xf)-1)/length(xf);
figure(4)
plot(frequencies,10*log10(abs(xf)));
hold on
%plot(frequencies,10*log10(abs(Wf)),'r')
plot(frequencies,10*log10(abs(df)),'k')
plot(frequencies,10*log10(abs(fyf)),'g')

legend('Noisy signal','Desired signal','Filtered signal');
xlabel('Normalized frequencies');
ylabel('Amplitude in dB');
title('Frequency response - LMS');
grid on

%% RLS
tic
% epoch = 100;
lambda = 0.999;
delayed = [0,0,ufsn(1:length(ufsn)-2)];
[ERLS, W] = rls(delayed,ufsn,order,lambda,delta);
yn=filter(W,1,delayed);
toc
RLS_time = toc;
disp('RLS time')
disp(RLS_time)

%% Outputs - FIR Filter using RLS
figure(5)
plot(t, ufsn);title('Time domain signal - RLS');xlabel('Time(secs)');ylabel('Amplitude');
hold('on');
plot(t, yn);legend('Desired Signal', 'Filtered Signal');
grid on

xf=freqz(ufsn);   
% Wf=freqz(W);   
df=freqz(sn);  
fyf = freqz(yn);

frequencies=(0:length(xf)-1)/length(xf);
figure(6)
plot(frequencies,10*log10(abs(xf)));
hold on
%plot(frequencies,10*log10(abs(Wf)),'r')
plot(frequencies,10*log10(abs(df)),'k')
plot(frequencies,10*log10(abs(fyf)),'g')

legend('Noisy signal','Desired signal','Filtered signal');
xlabel('Normalized frequencies');
ylabel('Amplitude in dB');
title('Frequency response - RLS');
grid on

%% NLMS
tic
epoch = 100;
delayed = [0,0,ufsn(1:length(ufsn)-2)];
[W, costFNLMS] = nlms(ufsn, delayed, order, delta, epoch);
yn=filter(W,1,delayed);
toc
NLMS_time = toc;
disp('NLMS time')
disp(NLMS_time)

%% Outputs - FIR Filter using NLMS
figure(7)
plot(t, ufsn);title('Time domain signal - NLMS');xlabel('Time(secs)');ylabel('Amplitude');
hold('on');
plot(t, yn);legend('Desired Signal', 'Filtered Signal');
grid on

xf=freqz(ufsn);   
% Wf=freqz(W);   
df=freqz(sn);  
fyf = freqz(yn);

frequencies=(0:length(xf)-1)/length(xf);
figure(8)
plot(frequencies,10*log10(abs(xf)));
hold on
%plot(frequencies,10*log10(abs(Wf)),'r')
plot(frequencies,10*log10(abs(df)),'k')
plot(frequencies,10*log10(abs(fyf)),'g')

legend('Noisy signal','Desired signal','Filtered signal');
xlabel('Normalized frequencies');
ylabel('Amplitude in dB');
title('Frequency response - NLMS');
grid on
%% Affine Projection Filter
tic
order = 40;
apf = dsp.AffineProjectionFilter(order);
[yn,error] = apf(delayed, ufsn);
EAPF = error(:);
toc
APA_time = toc;
disp('APA time')
disp(APA_time)
%% Outputs - FIR Filter using Affine Projection
figure(9)
plot(t, sn);title('Time domain signal - Affine Projection');xlabel('Time(secs)');ylabel('Amplitude');
hold('on');
plot(t, yn);legend('Desired Signal', 'Filtered Signal');
grid on

xf=freqz(ufsn);   % frequency spectrum of noisy signal
% Wf=freqz(W);   % frequency response of (ALE-filter)
df=freqz(sn);   % frequency spectrum of desired signal
fyf = freqz(yn);

frequencies=(0:length(xf)-1)/length(xf);   % Normalized frequecies

figure(10)
plot(frequencies,10*log10(abs(xf)));
hold on
%plot(frequencies,10*log10(abs(Wf)),'r')
plot(frequencies,10*log10(abs(df)),'k')
plot(frequencies,10*log10(abs(fyf)),'g')

legend('Noisy signal','Desired signal','Filtered signal');
xlabel('Normalized frequencies');
ylabel('Amplitude (dB)');
title('Frequency response - Affine Projection');
grid minor

%% Weiner Filter
tic
delayed = [0,0,ufsn(1:length(ufsn)-2)];
W = wienerFilt(delayed,ufsn,order);
yn=filter(W,1,delayed);
toc
WF_time = toc;
disp('WF time')
disp(WF_time)
%% Outputs - FIR Filter using Weiener Method
figure(11)
plot(t, sn);title('Time domain signal - Weiner Filter');xlabel('Time(secs)');ylabel('Amplitude');
hold('on');
plot(t, yn);legend('Desired Signal', 'Filtered Signal');
grid on

xf=freqz(ufsn);   % frequency spectrum of noisy signal
% Wf=freqz(W);   % frequency response of (ALE-filter)
df=freqz(sn);   % frequency spectrum of desired signal
fyf = freqz(yn);

frequencies=(0:length(xf)-1)/length(xf);   % Normalized frequecies

figure(12)
plot(frequencies,10*log10(abs(xf)));
hold on
%plot(frequencies,10*log10(abs(Wf)),'r')
plot(frequencies,10*log10(abs(df)),'k')
plot(frequencies,10*log10(abs(fyf)),'g')

legend('Noisy signal','Desired signal','Filtered signal');
xlabel('Normalized frequencies');
ylabel('Amplitude (dB)');
title('Frequency response - Weiner Filter');
grid minor

%% Error Plots
figure(13)
plot(costFLMS, 'Linewidth', 1);hold('on');
plot(costFNLMS, 'Linewidth', 1);
legend('Error in Amplitude - LMS','Error in Amplitude - NLMS')

%% Audio Input
audiowrite('lms_audio.wav', yn, 48000)