
% Sensor design 
n = 7; % number of sensors
a = linspace(-13.5,13.5,n); % sensor angles
L = 600; % Length

DL = L ./ cosd(a); % 
s_x = DL .* cosd(a);
s_y = DL .* sind(a);

% Rotate and translate left sensor
aL = 13.5;
offL = 150;
sL_x = s_x .* cosd(aL) + s_y .* sind(aL);
sL_y = -s_x .* sind(aL) + s_y .* cosd(aL) + offL;

% Rotate and translate right sensor
aR = -13.5;
offR = -150;
sR_x = s_x .* cosd(aR) + s_y .* sind(aR);
sR_y = -s_x .* sind(aR) + s_y .* cosd(aR) + offR;

% Bumper
B = 200; % Width of bumper side
aD = 76.5; % Angle of bumper side 

% Calculate standard bumper
aD_x = B .* cosd(aD); 
aD_y = B .* sind(aD);
sD_x = [aD_x, 0, aD_x];
sD_y = [aD_y, 0, -aD_y];

% Rotate and translate bumper
Dx = 500;
Dy = 0*25;
Da = 0*5;
sD_x_2 = sD_x .* cosd(Da) - sD_y .* sind(Da) + Dx;
sD_y_2 = sD_x .* sind(Da) + sD_y .* cosd(Da) + Dy;


% Calculate intersection (y = a1x + b1, y = a2x + b2)
% Left sensor
xL1 = (Dx*tand(aD-Da)+offL-Dy)./(tand(aD-Da)-tand(-aL-a));
yL1 = tand(-aL-a).*xL1+offL;

xL2 = (Dx*tand(-aD-Da)+offL-Dy)./(tand(-aD-Da)-tand(-aL-a));
yL2 = tand(-aL-a).*xL2+offL;

xL = [xL1(find(yL1>Dy)), xL2(find(yL2<Dy))];
yL = [yL1(find(yL1>Dy)), yL2(find(yL2<Dy))];

% Right sensor
xR1 = (Dx*tand(aD-Da)+offR-Dy)./(tand(aD-Da)-tand(-aR-a));
yR1 = tand(-aR-a).*xR1+offR;

xR2 = (Dx*tand(-aD-Da)+offR-Dy)./(tand(-aD-Da)-tand(-aR-a));
yR2 = tand(-aR-a).*xR2+offR;

xR = [xR1(find(yR1>Dy)), xR2(find(yR2<Dy))];
yR = [yR1(find(yR1>Dy)), yR2(find(yR2<Dy))];



% plot(xL,yL,'x','Linewidth',2,'Color','#0072BD','MarkerSize',14)
% plot(xR,yR,'x','Linewidth',2,'Color','#D95319','MarkerSize',14)

% Plot 
figure(7)
clf
hold on
for i = 1:n
    plot([0, xL(i)],[offL, yL(i)],'x-','Color','#0072BD','Linewidth',2,'MarkerSize',14)
    plot([0, xR(i)],[offR, yR(i)],'x-','Color','#D95319','Linewidth',2,'MarkerSize',14)
end
plot(sD_x_2, sD_y_2, 'k', 'Linewidth',2)
grid on
box on
axis equal


%%

LxyL = sqrt(xL.^2+(offL-yL).^2);
LxyR = sqrt(xR.^2+(offR-yR).^2);

dx = LxyL(1:3)-flip(LxyR(end-2:end));
dx_mean = mean(dx);

% DL_arr = LxyL(4) * 2 * [tand(13.5), tand(9), tand(4.5)];% [154, 102, 50.5];
% thL = atan((LxyL(1:3)-LxyL(end:-1:end-2))./DL_arr)*180/pi;
% 
% DR_arr = LxyR(4) * 2 * [tand(13.5), tand(9), tand(4.5)];% [154, 102, 50.5];
% thR = atan((LxyR(1:3)-LxyR(end:-1:end-2))./DR_arr)*180/pi;
% 
% dth = thL + thR;
% dth_mean = mean(dth)


% DDL = LxyL(4) * [tand(13.5) - tand(9), tand(9)-tand(4.5)];
% DDR = LxyR(4) * [tand(13.5) - tand(9), tand(9)-tand(4.5)];
% thL = [LxyL(1) - LxyL(2), LxyL(2) - LxyL(3)] ./ DDL;
% thR = [LxyR(end) - LxyR(end-1), LxyR(end-1) - LxyR(end-2)] ./ DDR;

% LxyR = flip(LxyR);

nums = 7;
DL = 2*LxyL(4)*tand(13.5);
DL_arr = (0:nums-1)*DL/(nums-1) - DL/2;
DR = 2*LxyR(4)*tand(13.5);
DR_arr = (0:nums-1)*DR/(nums-1) - DR/2;

angLprt = -atan((LxyL(1:3)-LxyL(end:-1:end-2))./(DL_arr(1:3)-DL_arr(end:-1:end-2)));
angRprt = -atan((LxyR(1:3)-LxyR(end:-1:end-2))./(DL_arr(1:3)-DL_arr(end:-1:end-2)));

angL = mean(angLprt) + 0.2539;
angR = mean(angRprt) - 0.2539;
angL + angR;

avgL = mean(LxyL);
avgR = mean(LxyR);
avgL - avgR;

D = DR_arr(end) - DL_arr(1);
ang = (angL + angR) / 2;
avg = (avgL + avgR) / 2;

% dth = thL - thR;
% dth_mean = mean(dth)

a_approx = ((1-cosd(a(end))) * LxyL(4) ./ cosd(a(end))) ./ (a(end).^2);
x_approx = linspace(-25,25);%linspace(-13.5,13.5);
y_approx = a_approx * x_approx.^2 + LxyL(4);

% yhL = LxyL .* cosd(a);
% yhR = LxyR .* cosd(a);


figure(8);
clf
hold all
plot(a,LxyL,'x-','Color','#0072BD','Linewidth',2)
% plot([a(1),a(4)],[LxyL(1), LxyL(4)],'-','Color','#0072BD','Linewidth',2)
% plot([a(2),a(3)],[LxyL(2), LxyL(3)],'-','Color','#0072BD','Linewidth',2)
% plot([a(3),a(end-2)],[LxyL(3), LxyL(end-2)],'-','Color','#0072BD','Linewidth',2)
% plot(a,yhL,'x-','Linewidth',2)
plot(a,LxyR,'x-','Color','#D95319','Linewidth',2)
% plot([a(1),a(end)],[LxyR(1), LxyR(end)],'-','Color','#D95319','Linewidth',2)
% plot([a(2),a(end-1)],[LxyR(2), LxyR(end-1)],'-','Color','#D95319','Linewidth',2)
% plot([a(3),a(end-2)],[LxyR(3), LxyR(end-2)],'-','Color','#D95319','Linewidth',2)
% plot(a,yhR,'x-','Linewidth',2)
 
% plot([DL_arr(1), DL_arr(end)]-150,[avgL+DL/2*sin(angL), avgL-DL/2*sin(angL)],'Color','#0072BD','Linewidth',2)
% plot([DR_arr(1), DR_arr(end)]+150,[avgR+DR/2*sin(angR), avgR-DR/2*sin(angR)],'Color','#D95319','Linewidth',2)

% plot([DL_arr(1)-150, DR_arr(end)+150],[avg+D/2*sin(ang), avg-D/2*sin(ang)],'k','Linewidth',2)

grid on
box on




%%

xLp = LxyL .* sind(a+aL) - offL;
yLp = LxyL .* cosd(a+aL);

xRp = LxyR .* sind(a+aR) - offR;
yRp = LxyR .* cosd(a+aR);

aLdf = atan((yLp(2:3)-yLp(1:2)) ./ (xLp(2:3)-xLp(1:2)));
aRdf = atan((yRp(end-1:end)-yRp(end-2:end-1)) ./ (xRp(end-1:end)-xRp(end-2:end-1)));

aLdf = mean(aLdf) * 180 / pi;
bLdf = yLp(2) - tand(aLdf) * xLp(2);

aRdf = mean(aRdf) * 180 / pi;
bRdf = yRp(end-1) - tand(aRdf) * xRp(end-1);

adf = -(aLdf+aRdf)/2

xdf = (bRdf - bLdf) / (tand(aLdf) - tand(aRdf))
ydf = tand(aLdf) * xdf + bLdf

figure(9);
clf
hold on
for i = 1:n
    plot([-offL, xLp(i)],[0, yLp(i)],'x-','Color','#0072BD','Linewidth',2,'MarkerSize',14)
    plot([-offR, xRp(i)],[0, yRp(i)],'x-','Color','#D95319','Linewidth',2,'MarkerSize',14)
end

plot([xLp(1) xLp(3)], [yLp(1) yLp(3)],'Linewidth',2)
plot([xRp(end-2) xRp(end)], [yRp(end-2) yRp(end)],'Linewidth',2)

plot(-250:100, (-250:100)*tand(aLdf)+bLdf,'Linewidth',2)
plot(-100:250, (-100:250)*tand(aRdf)+bRdf,'Linewidth',2)
% plot(sD_x_2, sD_y_2, 'k', 'Linewidth',2)
grid on
box on
axis equal

