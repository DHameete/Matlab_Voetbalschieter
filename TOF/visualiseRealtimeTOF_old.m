clear s_port
s_port = serialport('/dev/tty.usbmodem95871501',115200);

nums = 7;

% Calibration vectors
offcalL = 0*[-35,-18,-4,0,-6,-17,-29];
offcalR = 0*[-36,-18,-1,0,-13,-20,-27];

figure(66)
clf
axis equal 
axis([-250, 250, -50, 550])
grid on
box on

hold on
plot(-20,0,'Marker','s','Color','#0072BD','MarkerSize',14,'Linewidth',2)
plot([0,500*tand(-13.5),500*tand(13.5),0]-20,[0,500,500,0],'--',...
    'Color','#0072BD','Linewidth',2)
plot(20,0,'Marker','s','Color','#D95319','MarkerSize',14,'Linewidth',2)
plot([0,500*tand(-13.5),500*tand(13.5),0]+20,[0,500,500,0],'--',...
    'Color','#D95319','Linewidth',2)

h1 = animatedline(zeros(1,nums),zeros(1,nums),'LineStyle','None','Marker','x',...
    'Color','#0072BD','MarkerSize',8);
h2 = animatedline(zeros(1,nums),zeros(1,nums),'LineStyle','None','Marker','x',...
    'Color','#D95319','MarkerSize',8);
h3 = animatedline([0, 0],[0, 0],'Color','#0072BD','Linewidth',2);
h4 = animatedline([0, 0],[0, 0],'Color','#D95319','Linewidth',2);
h5 = animatedline([0, 0],[0, 0],'Linewidth',2);

ht1 = text(0, 0, num2str(0));
ht2 = text(0, 0, num2str(0));



dT = 0.1;
Timeframe = 1;


n_means = 1;
sL_arr = zeros(n_means, nums);
iL = 1;
sR_arr = zeros(n_means, nums);

while true
    d_str = readline(s_port);
    d = str2num(d_str);
    
    sL_raw = d(1:nums);
%     sR_raw = d(nums+1:end);
    sR_raw = d(nums+1:end-2);
    
    sL_arr(iL,:) = sL_raw+offcalL;
    sL = mean(sL_arr,1);
    
    sR_arr(iL,:) = sR_raw+offcalR;
    sR = mean(sR_arr,1);
    
    iL = mod(iL,n_means)+1;
    
    DL = 2*sL(round(nums/2))*tand(13.5);
    DL_arr = (0:nums-1)*DL/(nums-1) - DL/2;
    DR = 2*sR(round(nums/2))*tand(13.5);
    DR_arr = (0:nums-1)*DR/(nums-1) - DR/2;
    
    angLprt = -atan((sL(1:3)-sL(end:-1:end-2))./(DL_arr(1:3)-DL_arr(end:-1:end-2)));
    angRprt = -atan((sR(1:3)-sR(end:-1:end-2))./(DL_arr(1:3)-DL_arr(end:-1:end-2)));
    
    angL = mean(angLprt);
    angR = mean(angRprt);
    
    avgL = mean(sL);
    avgR = mean(sR);
    
    % x?
%     sprintf('%.0f, %.0f', sum(abs(avgL - sL) > 0.1*avgL), sum(abs(avgR - sR) > 0.1*avgR))

    clearpoints(h1)
    addpoints(h1,DL_arr-20,sL);
    clearpoints(h3)
    addpoints(h3,[DL_arr(1), DL_arr(end)]-20,...
        [avgL+DL/2*sin(angL), avgL-DL/2*sin(angL)]);
    
    clearpoints(h2)
    addpoints(h2,DR_arr+20,sR);
    clearpoints(h4)
    addpoints(h4,[DR_arr(1), DR_arr(end)]+20,...
        [avgR+DR/2*sin(angR), avgR-DR/2*sin(angR)]);   
       
    D = DR_arr(end)+20 - (DL_arr(1)-20);
    ang = (angL + angR) / 2;
    avg = (avgL + avgR) / 2;
    clearpoints(h5)
    addpoints(h5,[DL_arr(1)-20, DR_arr(end)+20],...
        [avg+D/2*sin(ang), avg-D/2*sin(ang)]);   
    
    delete(ht1);
    ht1 = text(-40,sL(round(nums/2))-30,sprintf(['%.0f, %.0f', char(176)],avgL, angL*180/pi));
    delete(ht2);
    ht2 = text(10,sR(round(nums/2))-30,sprintf(['%.0f, %.0f', char(176)],avgR, angR*180/pi));
    
    drawnow
    
    flush(s_port);
    pause(0.1);
end