
clear all; 

%%
m = 10;
R = 0.25; % [m] Radius of robot
I = m*R*R/2;
b = 1.5*1;
c = 2*1;

A = zeros(6,6);
A(1,1) = -b/m;
A(2,1) = 1;
A(3,3) = -b/m;
A(4,3) = 1;
A(5,5) = -c/I;
A(6,5) = 1;

B = zeros(6,3);
B(1,1) = 1/m;
B(3,2) = 1/m;
B(5,3) = 1/I;
C = zeros(3,6);
C(1,2) = 1;
C(2,4) = 1;
C(3,6) = 1;

D = zeros(3,3);



Kpx = 25;%20
Kdx = 80;%80;

Kpy = 10;%80;
Kdy = 60;%200;

Kpth = 20;
Kdth = 5;

% Enable/disable disturbance
d_input = 1;
d_sensor = 0;

% 
Lw = 0*0.75; % [m] Length from pivot to footrest
xset = 0.5;
Rdist = Lw + xset;

X0 = zeros(6,1);
X0(2) = Rdist;

X0ref = zeros(6,1);
X0ref(2) = Rdist;

%%
out = sim('simulatorTOF.slx');

xL = squeeze(out.xL.Data);
yL = squeeze(out.yL.Data);
xR = squeeze(out.xR.Data);
yR = squeeze(out.yR.Data);

t1 = out.q_chair.Time;

% Chair state
xchair = out.q_chair.Data(:,1);
ychair = out.q_chair.Data(:,2);
thchair = out.q_chair.Data(:,3);

% Robot reference state
xref = out.q_ref.Data(:,1);
yref = out.q_ref.Data(:,2);
thref = out.q_ref.Data(:,3);

% Robot state
xbot = out.q.Data(:,1);
ybot = out.q.Data(:,2);
thbot = out.q.Data(:,3);

% Difference
q_ex = xbot - xchair;
q_ey = ybot - ychair;
q_eth = thbot - thchair;

xd = cos(thchair) .* q_ex + sin(thchair) .* q_ey;
yd = -sin(thchair) .* q_ex + cos(thchair) .* q_ey;

q_e_abs = sqrt(q_ex.^2 + q_ey.^2);
q_e_ang = unwrap(atan2(q_ey, q_ex));

%%

Dx = q_ey;
Dy = q_ex;
Da = -thbot;

% Bumper
Bmp = 280/1000; % Width of bumper side
aB = 55; % Angle of bumper side 
Boff = 65/1000;

% Calculate standard bumper
aD_x = Bmp .* cosd(aB); 
aD_y = Bmp .* sind(aB);
sD_x = [-Boff-aD_x, -Boff, Boff, Boff+aD_x];
sD_y = [aD_y, 0, 0, aD_y];

% Rotate and translate bumper
sBx = sD_x .* cos(Da) - sD_y .* sin(Da) + Dx;
sBy = sD_x .* sin(Da) + sD_y .* cos(Da) + Dy;

rry = 1:70:141;
% rry = 1:30:91;
% rry = 1:50:3001;

figure(345);
clf
subplot(121);
hold all
plot(xchair(rry),ychair(rry),'s-','Linewidth',2,'Markersize',14)
plot(xbot(rry),ybot(rry),'s-','Linewidth',2,'Markersize',14)
set(gca,'ColorOrderIndex',1)
plot(sBy(rry,:)'+xchair(rry)',...
    sBx(rry,:)'+ychair(rry)')
set(gca,'ColorOrderIndex',1)
for i = 1:length(rry)
    idx = rry(i);
    plot([xchair(idx), xchair(idx)+cos(thchair(idx)-13.5/180*pi),...
        xchair(idx)+cos(thchair(idx)+13.5/180*pi), xchair(idx)], [ychair(idx),...
        ychair(idx)+sin(thchair(idx)-13.5/180*pi),...
        ychair(idx)+sin(thchair(idx)+13.5/180*pi), ychair(idx)],'--','Linewidth',2)
end

set(gca,'ColorOrderIndex',1)
plot(xL(:,rry)+xchair(rry)', yL(:,rry)+ychair(rry)','x','Linewidth',2)
set(gca,'ColorOrderIndex',1)
plot(xR(:,rry)+xchair(rry)', yR(:,rry)+ychair(rry)','o','Linewidth',2)

grid on
box on
axis equal
xlabel('x-world [m]')
ylabel('y-world [m]')


xL_c = xL .* cos(-thchair') - yL .* sin(-thchair');
yL_c = xL .* sin(-thchair') + yL .* cos(-thchair');
xR_c = xR .* cos(-thchair') - yR .* sin(-thchair');
yR_c = xR .* sin(-thchair') + yR .* cos(-thchair');

subplot(122);
hold all
plot(xL_c(:,rry),yL_c(:,rry),'-x','Linewidth',2)
set(gca,'ColorOrderIndex',1)
plot(xR_c(:,rry),yR_c(:,rry),'-o','Linewidth',2)

plot([0,1.2,1.2,0],[0,1.2*tand(-13.5),1.2*tand(13.5),0]+0.1,'--',...
    'Color','#0072BD','Linewidth',2)
plot([0,1.2,1.2,0],[0,1.2*tand(-13.5),1.2*tand(13.5),0]-0.1,'--',...
    'Color','#D95319','Linewidth',2)

grid on
box on
axis equal
xlim([0 inf])
xlabel('x-chair [m]')
ylabel('y-chair [m]')



%% Transfer Function

[Gnum1, Gden1] = ss2tf(A,B,C,D,1);
[Gnum2, Gden2] = ss2tf(A,B,C,D,2);
[Gnum3, Gden3] = ss2tf(A,B,C,D,3);

Gsys = ss(A,B,C,D);

Cnum = [Kdx Kpx];
Cden = 1;
Csys = tf({Cnum; Cnum; Cnum},{Cden; Cden; Cden});

Gsys*Csys;



%% Plot


figure(3)
clf
ax1 = subplot(221);
hold on
plot(xchair, ychair, xbot, ybot, 'Linewidth', 2)
plot(xref, yref, 'Linewidth', 2,'Color','#77AC30')
grid on
box on
axis equal 
xlabel('X-position [m]')
ylabel('Y-position [m]')

ax2 = subplot(222);
plot(t1, thchair*180/pi, t1, q_e_ang*180/pi,'Linewidth',2)
grid on
box on
xlabel('Time [s]')
ylabel('Turn [deg]')
legend({'Wheelchair', 'Robot'},'Location','Best')

dc = sqrt(xchair.^2+ychair.^2);
dr = sqrt(xref.^2+yref.^2);
db = sqrt(xbot.^2+ybot.^2);
ax3 = subplot(223);
hold on
plot(t1, dr, t1, db, 'Linewidth', 2)
grid on
box on
% ylim([0, 5])
xlabel('Time [s]')
ylabel('Throttle [m]')
legend({'Wheelchair', 'Robot'},'Location','Best')

ax4 = subplot(224);
plot(t1, thchair*180/pi, t1, thbot*180/pi, 'Linewidth', 2)
grid on
box on
xlabel('Time [s]')
ylabel('Rotation [deg]')

% linkaxes([ax1 ax2],'y')
linkaxes([ax2 ax3 ax4],'x')

% figure(4)
% clf
% ax43 = subplot(311);
% plot(t1, xd, 'Linewidth', 2)
% grid on
% xlabel('Time [s]')
% ylabel('Longitudinal distance [m]')
% 
% ax44 = subplot(312);
% plot(t1, yd, 'Linewidth', 2)
% grid on
% xlabel('Time [s]')
% ylabel('Lateral distance [m]')
% ylim([-0.25, 0.75])
% 
% ax45 = subplot(313);
% plot(t1, thbot-thchair, 'Linewidth', 2)
% grid on
% xlabel('Time [s]')
% ylabel('Angle difference [rad]')
% 
% linkaxes([ax43 ax44 ax45],'x')
% linkaxes([ax43 ax44],'y')

figure(5)
clf
ax53 = subplot(311);
hold all
plot(t1, q_e_abs-Rdist, 'Linewidth', 2)
plot([t1(1) t1(end)], [-0.25 -0.25], 'k--', 'Linewidth', 2)
plot([t1(1) t1(end)], [0.25 0.25], 'k--', 'Linewidth', 2)
grid on
box on
xlabel('Time [s]')
ylabel('Distance error [m]')
ylim([-0.4, 0.4])

ax54 = subplot(312);
hold all
plot(t1, (q_e_ang-thchair)*180/pi, 'Linewidth', 2)
plot([t1(1) t1(end)], [-30 -30], 'k--', 'Linewidth', 2)
plot([t1(1) t1(end)], [30 30], 'k--', 'Linewidth', 2)
grid on
box on
xlabel('Time [s]')
ylabel('Angular error [deg]')
ylim([-40, 40])

ax55 = subplot(313);
hold all
plot(t1, (thbot-thchair)*180/pi, 'Linewidth', 2)
plot([t1(1) t1(end)], [-15 -15], 'k--', 'Linewidth', 2)
plot([t1(1) t1(end)], [15 15], 'k--', 'Linewidth', 2)
grid on
box on
xlabel('Time [s]')
ylabel('Rotational error [deg]')
ylim([-20, 20])

linkaxes([ax53 ax54 ax55],'x')
% linkaxes([ax54 ax55],'y')

%%

ux = out.u.Data(:,1);
uy = out.u.Data(:,2);

figure(12)
clf
subplot(211)
plot(t1,ux,'Linewidth', 2)
grid on
xlabel('Time [s]')
ylabel('Input x [N]')
subplot(212)
plot(t1,uy,'Linewidth', 2)
grid on
xlabel('Time [s]')
ylabel('Input y [N]')


%%
animate(t1, out.q_chair.Data, out.q.Data, out.q_ref.Data, out.u.Data)