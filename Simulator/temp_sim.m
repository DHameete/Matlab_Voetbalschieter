T = 0.01;
time = 1:T:20;

% acceleration
ps = 0.5;
a_xr = -cos(ps*time)*ps^2;
a_yr = -sin(ps*time)*ps^2;

alpha_r = zeros(size(time));
v_xr = zeros(size(time));
v_yr = zeros(size(time));
x_r = zeros(size(time));
y_r = zeros(size(time));

x_r(1) = 1;

for ii = 2:length(time)

% orientation
omega_r = -0.1572;
alpha_r = alpha_r + T*omega_r;
% alpha_r = 0;

% robot motion
v_xr(ii) = v_xr(ii-1) + T * (a_xr(ii-1) + omega_r * v_yr(ii-1));
v_yr(ii) = v_yr(ii-1) + T * (a_yr(ii-1) - omega_r * v_xr(ii-1));

x_r(ii) = x_r(ii-1) + T * cos(alpha_r(ii-1) + atan2(v_yr(ii-1), v_xr(ii-1))) * ...
    sqrt(v_xr((ii-1))^2 + v_yr(ii-1)^2);
y_r(ii) = y_r(ii-1) + T * sin(alpha_r(ii-1) + atan2(v_yr(ii-1), v_xr(ii-1))) * ...
    sqrt(v_xr((ii-1))^2 + v_yr(ii-1)^2);

end

figure(73)
clf
subplot(211)
hold all
plot(time,a_xr,'Linewidth',2);
plot(time,a_yr,'Linewidth',2);
% plot(time,v_xr,'Linewidth',2);
% plot(time,v_yr,'Linewidth',2);

% plot(time,x_r,'Linewidth',2);
% plot(time,y_r,'Linewidth',2);
grid on
box on
% ylim([-4 2])
% legend({'ax','ay','vx','vy'})
subplot(212)
plot(x_r,y_r,'Linewidth',2)
axis equal