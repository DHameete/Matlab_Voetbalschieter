clear s_port
s_port = serialport('/dev/ttyACM0',115200);

nums = 7;

% Calibration vectors
offcalL = 0*[-35,-18,-4,0,-6,-17,-29];
offcalR = 0*[-36,-18,-1,0,-13,-20,-27];

dT = 0.1;
Timeframe = 1;


n_means = 1;
sL_arr = zeros(n_means, nums);
iL = 1;
sR_arr = zeros(n_means, nums);

amax = 7.16; % 13.5
a = linspace(-amax,amax,nums);

% Rotate and translate left sensor
phiL = 0*-13.5;
offL = -100;

% Rotate and translate right sensor
phiR = 0*13.5;
offR = 100;

lim = 600;

%%

figure(66)
clf
axis equal 
axis([-300, 300, -50, 650])
grid on
box on

hold on
plot(offL,0,'Marker','s','Color','#0072BD','MarkerSize',14,'Linewidth',2)
plot([0,600*tand(-amax-phiL),600*tand(amax-phiL),0]+offL,[0,600,600,0],'--',...
    'Color','#0072BD','Linewidth',2)
plot(offR,0,'Marker','s','Color','#D95319','MarkerSize',14,'Linewidth',2)
plot([0,600*tand(-amax-phiR),600*tand(amax-phiR),0]+offR,[0,600,600,0],'--',...
    'Color','#D95319','Linewidth',2)
plot([-250,-250,250,250,-250],[300,600,600,300,300],'--','Color','k','Linewidth',2)

h1 = animatedline(zeros(1,nums),zeros(1,nums),'LineStyle','-','Marker','x',...
    'Color','#0072BD','MarkerSize',8);
h2 = animatedline(zeros(1,nums),zeros(1,nums),'LineStyle','-','Marker','x',...
    'Color','#D95319','MarkerSize',8);
h3 = animatedline([0, 0],[0, 0],'Color','#0072BD','Linewidth',2);
h4 = animatedline([0, 0],[0, 0],'Color','#D95319','Linewidth',2);
h5 = animatedline([0, 0],[0, 0],'Marker','x','MarkerSize',14,'Linewidth',2);
h6 = animatedline([0, 0],[0, 0],'Color','k','Linewidth',2);

ht1 = text(0, 0, num2str(0));
ht2 = text(0, 0, num2str(0));

cmd = '';

while true
    d_str = readline(s_port);
    d = str2num(d_str);
    
    sL_raw = d(1:nums);
    sR_raw = d(nums+1:2*nums);
    s_extra = d(2*nums+1:end);
    
    sL_arr(iL,:) = sL_raw+offcalL;
    sL_arr(sL_arr>lim) = NaN;
    sL = mean(sL_arr,1,'omitnan');
    
    sR_arr(iL,:) = sR_raw+offcalR;
    sR_arr(sR_arr>lim) = NaN;
    sR = mean(sR_arr,1,'omitnan');
    
    iL = mod(iL,n_means)+1;

    xLp = sL .* cosd(90+phiL-a) + offL;
    yLp = sL .* sind(90+phiL-a);
    
    xRp = sR .* cosd(90+phiR-a) + offR;
    yRp = sR .* sind(90+phiR-a);
    
%     angLprt = atan((yLp(2:3)-yLp(1:2)) ./ (xLp(2:3)-xLp(1:2)));
%     angRprt = atan((yRp(end-1:end)-yRp(end-2:end-1)) ./ (xRp(end-1:end)-xRp(end-2:end-1)));
    angLprt = atan((yLp(2:end)-yLp(1:end-1)) ./ (xLp(2:end)-xLp(1:end-1)));
    angRprt = atan((yRp(2:end)-yRp(1:end-1)) ./ ...
        (xRp(2:end)-xRp(1:end-1)));

    angL = mean(angLprt,'omitnan');
    angR = mean(angRprt,'omitnan');
     
    avgL = mean(sL,'omitnan');
    avgR = mean(sR,'omitnan');

    xLmean = mean(xLp,'omitnan');
    xRmean = mean(xRp,'omitnan');
    
    yLmean = mean(yLp,'omitnan');
    yRmean = mean(yRp,'omitnan');
    
%     bL = yLp(2) - tan(angL) * xLp(2);
%     bR = yRp(end-1) - tan(angR) * xRp(end-1);
    bL = mean(yLp,'omitnan') - tan(angL) * mean(xLp,'omitnan');
    bR = mean(yRp,'omitnan') - tan(angR) * mean(xRp,'omitnan');
    
    
    DL = -200:-50; % xLp(1):0;
    DR = 50:200; % 0:xRp(end);
    D = DL(1):DR(end); % xLp(1):xRp(end);
    
    adf = (angL + angR)/2;
    xdf = (bR - bL) / (tan(angL) - tan(angR));
    ydf = tan(angL) * xdf + bL;
    
    adf = tan((yRmean-yLmean)/(xRmean-xLmean));
    xdf = mean([xLp,xRp],'omitnan');
    ydf = (yLmean + yRmean)/2; 
    
%     sprintf('%3.0f, %3.0f, %3.0f', xdf, ydf, adf*180/pi)
%     sprintf('%3.0f, %3.0f, %3.0f, %3.0f', s_extra(1), s_extra(2), xdf, ydf)
%     sprintf('%3.1f', s_extra(3)*180/pi)

%     sprintf('%3.0f, %3.0f, %3.0f', mean([xLp,xRp],'omitnan'), sum(isnan(sL)), sum(isnan(sR)))

    if abs(adf) > 0.1
        if adf > 0.1
            cmd = 'Rotate left';
        else
            cmd = 'Rotate right';
        end
    elseif ydf < 300 || ydf > 600
         if ydf < 300
            cmd = 'Move backward';
        else
            cmd = 'Move forward';
        end       
    elseif abs(xdf) > 10
         if xdf < -10
            cmd = 'Move left';
        else
            cmd = 'Move right';
         end
    else
        cmd = 'Hold';
    end

    clearpoints(h1)
    addpoints(h1,xLp,yLp);
    clearpoints(h3)
    addpoints(h3,DL,DL*tan(angL)+bL);

    clearpoints(h2)
    addpoints(h2,xRp,yRp);
    clearpoints(h4)
    addpoints(h4,DR,DR*tan(angR)+bR);
       
    
%     clearpoints(h5)
%     addpoints(h5,xdf, ydf);
%     clearpoints(h6)
%     addpoints(h6,[D(1),D(end)],[D(1), D(end)]*tan(adf)+ydf);
    
    
    
%     addpoints(h6,[D(1),D(end)],[D(1), D(end)]*tan(s_extra(3))+ydf);

%     addpoints(h5,[D(1), D(end)]+s_extra(1),...
%     [s_extra(2)+D(1)*sin(s_extra(3)), s_extra(2)-D(end)*sin(s_extra(3))]);   
%     
%     delete(ht1);
%     ht1 = text(-40,sL(round(nums/2))-30,sprintf(['%.0f, %.0f', char(176)],avgL, angL*180/pi));
%     delete(ht2);
%     ht2 = text(10,sR(round(nums/2))-30,sprintf(['%.0f, %.0f', char(176)],avgR, angR*180/pi));
    
    title(cmd);
    drawnow
    
    flush(s_port);
    pause(0.1);
end