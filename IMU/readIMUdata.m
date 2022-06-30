clear all


% name = 'CoolTerm Capture 2021-05-27 14-56-22.txt';
% name = 'CoolTerm Capture 2021-05-28 08-08-32.txt'; % xdd,ydd,thd only

% name = 'CoolTerm Capture 2021-05-28 08-29-41.txt'; % with Time
% name = 'CoolTerm Capture 2021-05-28 16-30-26.txt'; % More accurate

% name = 'CoolTerm Capture 2021-06-02 17-13-23.txt'; % t, xdd, xd, ydd, yd, thd
% name = 'CoolTerm Capture 2021-06-02 17-23-22.txt'; % filter: 0.01
name = 'CoolTerm Capture 2021-06-02 17-27-39.txt'; % filter: 0.03
name = 'CoolTerm Capture 2021-06-03 08-52-43.txt'; % average: 3
name = 'CoolTerm Capture 2021-06-15 15-20-34.txt';
name = 'CoolTerm Capture 2021-06-16 11-08-00.txt';
name = 'CoolTerm Capture 2021-06-16 16-51-27.txt';
name = 'CoolTerm Capture 2022-03-15 13-50-23.txt';

data = readtable(name);
T_raw = data.Var1;
xdd = data.Var2;
xd  = data.Var3;
ydd = data.Var4;
yd  = data.Var5;
thd = data.Var6;
th  = data.Var7;

T = (T_raw - T_raw(1)) / 1000;
dt = diff(T);

x_c = [0; cumsum(xd(1:end-1).*dt)];
y_c = [0; cumsum(yd(1:end-1).*dt)];

k_mv = 3;
xd_mv = movmean(xd,[k_mv 0]);
yd_mv = movmean(yd,[k_mv 0]);

%%

figure(4);
clf;
ax1 = subplot(311);
plot(T, xdd, T, xd, 'Linewidth', 2);
hold on
% plot(T, x_c, 'Linewidth', 2);
grid on
legend({'xdd','xd'})

ax2 = subplot(312);
plot(T, ydd, T, yd, 'Linewidth', 2);
hold on
% plot(T, y_c, 'Linewidth', 2);
grid on
legend({'ydd','yd'})

ax3 = subplot(313);
plot(T, thd, T, th, 'Linewidth', 2); 
grid on
legend({'thzd','thz'})
linkaxes([ax1 ax2 ax3],'x')
linkaxes([ax1 ax2],'y')

%%

skd = 0.003;
move_x = sign(xd) .* (abs(xd) > skd);
move_y = sign(yd) .* (abs(yd) > skd);
move_th = sign(thd) .* (abs(thd) > 50);

move_x_mv = sign(xd_mv) .* (abs(xd_mv) > skd);
move_y_mv = sign(yd_mv) .* (abs(yd_mv) > skd);

figure(6)
clf
ax61 = subplot(331);
plot(T, xdd, 'Linewidth', 2);
grid on
ylabel('x-acc')
ax64 = subplot(334);
plot(T, xd, 'Linewidth', 2);
hold on
plot(T, xd_mv, 'Linewidth', 2);
grid on
ylabel('x-vel')
ax67 = subplot(337);
plot(T, move_x, 'Linewidth', 2);
hold on
plot(T, move_x_mv, 'Linewidth', 2);
grid on
xlabel('Time')
ylabel('x-control')

ax62 = subplot(332);
plot(T, ydd, 'Linewidth', 2);
grid on
ylabel('y-acc')
ax65 = subplot(335);
plot(T, yd, 'Linewidth', 2);
hold on
plot(T, yd_mv, 'Linewidth', 2);
grid on
ylabel('y-vel')
ax68 = subplot(338);
plot(T, move_y, 'Linewidth', 2);
hold on
plot(T, move_y_mv, 'Linewidth', 2);
grid on
xlabel('Time')
ylabel('y-control')

% ax63 = subplot(333);
ax66 = subplot(336);
plot(T, thd, 'Linewidth', 2);
grid on
ylabel('th-vel')
ax69 = subplot(339);
plot(T, move_th, 'Linewidth', 2);
hold on
grid on
xlabel('Time')
ylabel('th-control')

link1 = linkprop([ax61 ax64 ax67],'XLim');
link2 = linkprop([ax62 ax65 ax68],'XLim');
link3 = linkprop([ax66 ax69],'XLim');
link4 = linkprop([ax61 ax62],'YLim');
link5 = linkprop([ax64 ax65],'YLim');
link6 = linkprop([ax67 ax68],'YLim');



