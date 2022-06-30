clear all

filepath = [getenv('ROBOCUP_REPO_PATH'),'/Tools/trc/motion_data.mat'];
file = dir(filepath);
load(filepath);

savename = sprintf('data/recorddata_%d-%02d-%02d_%02d-%02d-%02d.mat',datevec(file.datenum));
save(savename, 'data')

%%

name = 'data/recorddata_2022-02-22_21-38-53.mat';
n = 44916;
name = 'data/recorddata_2022-02-22_21-56-46.mat';
n = 48730;

data_arr = load(name);


T_raw = data_arr.data(1,n:end);

T = (T_raw - T_raw(1));
dt = diff(T);

js_in = data_arr.data(2:4,n:end);
vel_ref = data_arr.data(5:7,n:end);
vel_local = data_arr.data(8:10,n:end);
vel_global = [-data_arr.data(12,n:end); data_arr.data(11,n:end); data_arr.data(13,n:end)];
pos_global = [-data_arr.data(15,n:end); data_arr.data(14,n:end); data_arr.data(16,n:end)];

R = sqrt(pos_global(1,:).^2 + pos_global(2,:).^2);
PHI = atan2(pos_global(2,:),pos_global(1,:));

%%

figure;
clf;
ax1 = subplot(221);
hold on
plot(T, js_in, 'Linewidth', 2);
grid on
box on
legend({'x','y','th'})

ax2 = subplot(222);
hold on
plot(T, R, 'Linewidth', 2);
grid on
box on
ylim([0.5 1.5])
ylabel('R [m]')

ax3 = subplot(223);
hold all
plot(pos_global(1,:),pos_global(2,:), 'Linewidth', 2); 
plot(pos_global(1,1),pos_global(2,1), 'o','Linewidth', 2); 
grid on
box on
xlim([-3, 3])
ylim([-3, 3])
axis equal

ax4 = subplot(224);
hold on
plot(T, PHI, 'Linewidth', 2);
grid on
box on
ylim([-2.5 2.5])
ylabel('Angle [rad]')

linkaxes([ax1 ax2 ax4],'x');



