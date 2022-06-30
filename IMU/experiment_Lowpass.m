

name = 'CoolTerm Capture 2022-03-15 15-23-13.txt';

data = readtable(name);
T_raw = data.Var1;
xdd = data.Var2;
xd  = data.Var3;
xddraw = data.Var5;
yd  = data.Var6;
thd = data.Var8;
th  = data.Var9;

T = (T_raw - T_raw(1)) / 1000;
dt = diff(T);

fs = 400;

figure(81)
xdd_flt = lowpass(xddraw,1,fs);

n = length(xdd);

y = fft(xdd);
f = (0:n-1)*(fs/n);
power = abs(y).^2/n;

y0 = fftshift(y);
f0 = (-n/2:n/2-1)*(fs/n);
power0 = abs(y0).^2/n;




figure(83)
clf
subplot(211)
plot(T,xddraw,'Linewidth',2)
hold all
plot(T,xdd_flt,'Linewidth',2)
plot(T,xdd,'Linewidth',2)
% plot(T,0.05*sin(2*pi*4.75*T-2),'Linewidth',2)
legend({'raw','filter','moving avg'})
subplot(212)

% plot(f,power)
% hold on
plot(f0,power0)

