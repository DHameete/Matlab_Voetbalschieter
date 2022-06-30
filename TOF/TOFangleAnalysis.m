clear all; clc;

%% Constants

% Sensor design 
n = 7; % number of sensors
a = linspace(-13.5,13.5,n); % sensor angles

% Rotate and translate left sensor
phiL = 0*13.5;
offL = 0.1;

% Rotate and translate right sensor
phiR = -phiL;
offR = -offL;

% Bumper
Bmp = 0.280; % Width of bumper side
aB = 55; % Angle of bumper side 
Boff = 0.065;

% Calculate standard bumper
aD_x = Bmp .* sind(aB); 
aD_y = Bmp .* cosd(aB);
sD_x = [aD_x, 0, 0, aD_x];
sD_y = [-Boff-aD_y, -Boff, Boff, Boff+aD_y];

% Rotate and translate bumper
Dx = 0.5;
Dy = 0.05;
Da = -45 * pi / 180;
sBx = sD_x .* cos(Da) - sD_y .* sin(Da) + Dx;
sBy = sD_x .* sin(Da) + sD_y .* cos(Da) + Dy;

%% Reference

% Rotation
rot = 0*9 * pi / 180;

% Rays left
x3L_tmp = 0;
y3L_tmp = offL;
x4L_tmp = x3L_tmp + cosd(a);
y4L_tmp = y3L_tmp + sind(a);

x3L = x3L_tmp * cos(rot) - y3L_tmp * sin(rot);
y3L = x3L_tmp * sin(rot) + y3L_tmp * cos(rot);
x4L = x4L_tmp * cos(rot) - y4L_tmp * sin(rot);
y4L = x4L_tmp * sin(rot) + y4L_tmp * cos(rot);

% Rays right
x3R_tmp = 0;
y3R_tmp = offR;
x4R_tmp = x3R_tmp + cosd(a);
y4R_tmp = y3R_tmp + sind(a);

x3R = x3R_tmp * cos(rot) - y3R_tmp * sin(rot);
y3R = x3R_tmp * sin(rot) + y3R_tmp * cos(rot);
x4R = x4R_tmp * cos(rot) - y4R_tmp * sin(rot);
y4R = x4R_tmp * sin(rot) + y4R_tmp * cos(rot);


xL = NaN(1,n);
yL = NaN(1,n);
xR = NaN(1,n);
yR = NaN(1,n);

distL = NaN(1,n);
distR = NaN(1,n);


for j = 1:3
    
    % Bumper
    x1 = sBx(j);
    y1 = sBy(j);
    x2 = sBx(j+1);
    y2 = sBy(j+1);
    
    % Bezier parameters left
    denL = (x1 - x2) * (y3L - y4L) - (y1 - y2) * (x3L - x4L);
    tL = ((x1 - x3L) * (y3L - y4L) - (y1 - y3L) * (x3L - x4L)) ./ denL;
    uL = ((x1 - x3L) * (y1 - y2) - (y1 - y3L) * (x1 - x2)) ./ denL;

    intersectL = tL >= 0 & tL <= 1 & uL >= 0;
    distL(intersectL) = min(distL(intersectL), uL(intersectL));
    
    
    % Bezier parameters right
    denR = (x1 - x2) * (y3R - y4R) - (y1 - y2) * (x3R - x4R);
    tR = ((x1 - x3R) * (y3R - y4R) - (y1 - y3R) * (x3R - x4R)) ./ denR;
    uR = ((x1 - x3R) * (y1 - y2) - (y1 - y3R) * (x1 - x2)) ./ denR;
    
    intersectR = tR >= 0 & tR <= 1 & uR >= 0;
    distR(intersectR) = min(distR(intersectR), uR(intersectR));
    
    
    % Intersections left 
    xL_tmp = x3L + distL .* (x4L - x3L);
    yL_tmp = y3L + distL .* (y4L - y3L);
    
    xL(intersectL) = xL_tmp(intersectL);
    yL(intersectL) = yL_tmp(intersectL);
    

    % Intersections right
    xR_tmp = x3R + distR .* (x4R - x3R);
    yR_tmp = y3R + distR .* (y4R - y3R);
    
    xR(intersectR) = xR_tmp(intersectR);
    yR(intersectR) = yR_tmp(intersectR);
       
end

% Plot 
figure(7)
clf
hold on
plot([x3L x3R], [y3L y3R], 'k', 'Linewidth',2)
for i = 1:n
    plot([x3L, xL(i)],[y3L, yL(i)],'x-','Color','#0072BD','Linewidth',2,'MarkerSize',14)
    plot([x3R, xR(i)],[y3R, yR(i)],'x-','Color','#D95319','Linewidth',2,'MarkerSize',14)
end
plot(sBx, sBy, 'k', 'Linewidth',2)

grid on
box on
axis equal
title('Input')

%% Plot lengths

sL = sqrt(xL.^2+(yL-offL).^2);
sR = sqrt(xR.^2+(yR-offR).^2);

figure(8);
clf
hold all
plot(a,sL,'x-','Color','#0072BD','Linewidth',2)
plot(a,sR,'x-','Color','#D95319','Linewidth',2)
grid on
box on
xlabel('Angle [deg]')
ylabel('Distance [mm]')
legend({'Left','Right'})

%% Calculate x,y, alpha offset

xLp = sL .* cosd(a+phiL);
yLp = sL .* sind(a+phiL) + offL;

xRp = sR .* cosd(a+phiR);
yRp = sR .* sind(a+phiR) + offR;

aLdf_all = atan2((yLp(2:end)-yLp(1:end-1)),(xLp(2:end)-xLp(1:end-1)));
aRdf_all = atan2((yRp(2:end)-yRp(1:end-1)),(xRp(2:end)-xRp(1:end-1)));

aLdf = mean(aLdf_all,'omitnan') * 180 / pi;
bLdf = yLp(4) - tand(aLdf) * xLp(4);

aRdf = mean(aRdf_all,'omitnan') * 180 / pi;
bRdf = yRp(4) - tand(aRdf) * xRp(4);

adf = (aLdf+aRdf)/2;

xdf = (bRdf - bLdf) / (tand(aLdf) - tand(aRdf));
ydf = tand(aLdf) * xdf + bLdf;

figure(9);
clf
hold on
for i = 1:n
    plot([0, xLp(i)],[offL, yLp(i)],'x-','Color','#0072BD','Linewidth',2,'MarkerSize',14)
    plot([0, xRp(i)],[offR, yRp(i)],'x-','Color','#D95319','Linewidth',2,'MarkerSize',14)
end

yLpvct = min(yLp):0.01:max(yLp);
plot((yLpvct-bLdf)./tand(aLdf),yLpvct,'Linewidth',2)
yRpvct = min(yRp):0.01:max(yRp);
plot((yRpvct-bRdf)./tand(aRdf), yRpvct,'Linewidth',2)

plot([0,0.6,0.6,0],[0,0.6*tand(-13.5-phiL),0.6*tand(13.5-phiL),0]+offL,'--',...
    'Color','#0072BD','Linewidth',2)
plot([0,0.6,0.6,0],[0,0.6*tand(-13.5-phiR),0.6*tand(13.5-phiR),0]+offR,'--',...
    'Color','#D95319','Linewidth',2)
plot([0.3,0.6,0.6,0.3,0.3],[-0.25,-0.25,0.25,0.25,-0.25],'--','Color','k','Linewidth',2)

plot(xdf,ydf,'x','Color','#77AC30','Linewidth',4,'MarkerSize',16)

% Robot
Xbot = [0.444,0.444,0.312,0.23,0.045,0,0,0.045,0.23,0.312,0.444];
Ybot = [0.162,-0.162,-0.24,-0.225,-0.12,-0.065,0.065,0.120,0.225,0.240,0.162];
Xbot_R = Xbot .* cos(Da) - Ybot .* sin(Da) + Dx;
Ybot_R = Xbot .* sin(Da) + Ybot .* cos(Da) + Dy;
plot(Xbot_R,Ybot_R,'k','Linewidth',2)

grid on
box on
axis equal
title('Output')

