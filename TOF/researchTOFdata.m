clear all

name = 'CoolTerm Capture 2021-08-12 09-31-15.txt'; % 4
name = 'CoolTerm Capture 2021-08-12 14-20-38.txt'; % 6
% name = 'CoolTerm Capture 2021-08-12 15-02-49.txt'; % 3 in air
name = 'CoolTerm Capture 2021-08-12 15-17-59.txt'; % 3 on beam
% name = 'CoolTerm Capture 2021-08-13 13-47-06.txt'; % 3 w/ robot

data = readtable(name);
T_raw = data.Var1;

n = size(data,2)-2;
sensorL = [];
sensorR = [];
for ii = 1:n/2
    sensorL = [sensorL, eval(sprintf('data.Var%d',ii+1))];
    sensorR = [sensorR, eval(sprintf('data.Var%d',ii+n/2+1))];%sensorR = [data.Var8, data.Var9, data.Var10, data.Var11, data.Var12, data.Var13];
end

T = (T_raw - T_raw(1)) / 1000;
dt = diff(T);

D = 100;

% alph = [-10.125, -3.375, 3.375, 10.125];
% a1 = 20;
% a2 = 17;
% a3 = 0;
% alph = [-a1, -a2, -a3, a3, a2, a1];
% alph = [-a1, 0, a1];
% 
% x = cosd(alph) .* sensorL;

DL = mean(sensorL,2);
HL = diff(sensorL,1,2);
HL_sum = sum(HL,2)/(n/2-1);
HL = real(asin((sensorL(:,1)-sensorL(:,3))/D));

DR = mean(sensorR,2);
HR = diff(sensorR,1,2);
HR_sum = sum(HR,2)/(n/2-1);
HR = real(asin((sensorR(:,1)-sensorR(:,3))/D));

figure(4);
clf;
ax41 = subplot(411);
hold on
plot(T,sensorL,'Linewidth',2);
plot(T,DL,'Linewidth',2);
grid on
legend({},'Location','NorthEast')
title('Left Sensor')
ylabel('Distance [mm]')

ax42 = subplot(412);
hold on
plot(T,sensorR,'Linewidth',2);
plot(T,DR,'Linewidth',2);
grid on
legend({},'Location','NorthEast')
title('Right Sensor')
ylabel('Distance [mm]')

ax43 = subplot(413);
plot(T,DL,'Linewidth',2);
hold on
plot(T,DR,'Linewidth',2);
grid on
legend({'Left','Right'},'Location','NorthEast')
xlabel('Time [s]')
ylabel('Average distance [mm]')

ax44 = subplot(414);
plot(T,HL*180/pi,'Linewidth',2);
hold on
plot(T,HR*180/pi,'Linewidth',2);
grid on
legend({'Left','Right'},'Location','NorthEast')
xlabel('Time [s]')
ylabel('Angle [deg]')

linkaxes([ax41 ax42 ax43],'y')
linkaxes([ax41 ax42 ax43 ax44],'x')
% ylim([0 800])

figure(5);
clf;
ax51 = subplot(211);
plot(T,sensorL,'Linewidth',2);
hold on
set(gca,'ColorOrderIndex',1)
plot(T,movmean(sensorL,[10,0]),'--','Linewidth',2)
grid on
% legend({},'Location','NorthEast')
title('Left Sensor')
ylabel('Difference [mm]')

ax52 = subplot(212);
plot(T,sensorR,'Linewidth',2);
hold on
set(gca,'ColorOrderIndex',1)
plot(T,movmean(sensorR,[10,0]),'--','Linewidth',2)
grid on
% legend({},'Location','NorthEast')
title('Right Sensor')
ylabel('Difference [mm]')

linkaxes([ax51 ax52],'xy')
ylim([200, 300])

%%

% angL = real(asin((sensorL(:,1)-sensorL(:,3))/D));
% angR = real(asin((sensorR(:,1)-sensorR(:,3))/D));
% 
% figure(6);
% clf
% axis equal 
% axis([-50, 350, 0, 600])
% grid on
% box on
% 
% 
% h1 = animatedline([0, D/2, D],sensorL(1,:),'Color','#0072BD','Linewidth',2);
% h2 = animatedline([2*D, 2*D+D/2, 3*D],sensorR(1,:),'Color','#D95319','Linewidth',2);
% h3 = animatedline([0, D],[DL(1)+D/2*sin(angL(1)), DL(1)-D/2*sin(angL(1))],'Color','b','Linewidth',2);
% h4 = animatedline([2*D, 3*D],[DR(1)+D/2*sin(angR(1)), DR(1)-D/2*sin(angR(1))],'Color','r','Linewidth',2);
% 
% 
% dT = 0.1;
% Timeframe = 1;
% for k = 1:length(T)
%     
%     if (T(k) > dT * Timeframe)
%         tic
%         
%         clearpoints(h1)
% %         addpoints(h1,50,0);
%         addpoints(h1,[0, D/2, D],sensorL(k,:));
% %         addpoints(h1,50,0);
%         clearpoints(h3)
%         addpoints(h3,[0, D],[DL(k)+D/2*sin(angL(k)), DL(k)-D/2*sin(angL(k))]);
%         
%         clearpoints(h2)
%         addpoints(h2,[2*D, 2*D+D/2, 3*D],sensorR(k,:));
%         clearpoints(h4)
%         addpoints(h4,[2*D, 3*D],[DR(k)+D/2*sin(angR(k)), DR(k)-D/2*sin(angR(k))]);
%         
%         title(['Time: ', num2str(T(k)), ' s'])
%         
%         drawnow
%         
%         Timeframe = Timeframe + 1;
%         Time = toc;
%         pause(dT - Time);
%     end
% end

%%
% 
% nmx = 180;
% xdd_raw_prt = xdd_raw(1:nmx);
% T1 = T(1:nmx);
% 
% xdd_avg1 = 0;
% for n = 1:nmx
%     xdd_avg1 = xdd_avg1 + (xdd_raw_prt(n) - xdd_avg1) / n;
% end
% xdd_avg2 = mean(xdd_raw_prt);
% 
% xdd_prt1 = xdd_raw_prt-xdd_avg1;
% xdd_prt2 = xdd_raw_prt-xdd_avg2;
% 
% xdd1 = xdd_raw-xdd_avg1;
% 
% xdd1_flt = xdd1 .* (abs(xdd1) > 0.03);
% xdd1_mv = movmean(xdd1, 5);
% 
% 
% % k_mv = 3;
% % xd_mv = movmean(xd,[k_mv 0]);
% %
% 
% xd1 = [0; cumsum(xdd1(1:end-1).*dt)];
% xd1_flt = [0; cumsum(xdd1_flt(1:end-1).*dt)];
% xd1_mv = [0; cumsum(xdd1_mv(1:end-1).*dt)];
% 
% nV = 10; %% ##3 --> 10
% cmp = zeros(1,nV);
% xd1_flt_sumdiff = zeros(size(xd1_flt));
% for k = 1:length(xd1_flt)
%     cmp(mod(k,nV)+1) = xd1_flt(k);
%     xd1_flt_sumdiff(k) = sum(sum(abs((cmp - cmp'))));
% end
% xd1_flt_flt = xd1_flt .* (abs(xd1_flt_sumdiff) > 0.01); %% ## 0.01 --> 
% 
% 
% cmp = zeros(1,nV);
% xd1_flt2 = zeros(size(xdd1_flt));
% for q = 2:length(xdd1_flt)
%     xd1_flt2(q) = xd1_flt2(q-1) + 0.1 * xdd1_flt(q);
%     
%     cmp(mod(q,nV)+1) = xd1_flt2(q);
%     if sum(abs(diff(cmp))) < 0.01
%         xd1_flt2(q) = 0;
%     end
% end
% 
% 
% %
% 
% figure(5)
% clf
% 
% ax51 = subplot(211);
% plot(T,xdd1,'Linewidth',2)
% hold on
% plot(T,xdd1_flt, T, xdd1_mv,'Linewidth',2)
% grid on
% legend({'xdd1','xdd1-flt','xdd1-mv'})
% 
% ax52 = subplot(212);
% hold on
% plot(T,xd1,'Linewidth',2)
% plot(T,xd1_flt,T,xd1_mv,'Linewidth',2)
% plot(T,xd1_flt_flt,'Linewidth',2)
% plot(T,xd1_flt2,'Linewidth',2)
% % plot(T,zeros(size(T)),'k','Linewidth',2)
% grid on
% box on
% legend({'xd1','xd1-flt','xd1-mv','xd1-flt-flt'})
% 
% linkaxes([ax51 ax52],'x')
% 
% %%
% 
% figure(6);
% clf;
% ax1 = subplot(211);
% plot(T,xdd_raw,T,xd,'Linewidth',2);
% grid on
% legend({'xdd','xd'})
% title('Old')
% 
% ax2 = subplot(212);
% plot(T,xdd1_flt,T,xd1_flt2,'Linewidth',2);
% grid on
% legend({'xdd1','xd1'})
% title('New')
% 
% linkaxes([ax1 ax2],'xy')
% 
% 
% %%
% 
% global xd 
% 
% xd_mv = movmean(xd,[3 0]);
% 
% skd = 0.003;
% move_x = sign(xd) .* (abs(xd) > skd);
% move_x_mv = sign(xd_mv) .* (abs(xd_mv) > skd);
% 
% fig = uifigure('HandleVisibility', 'on','Name','Figure 7');
% clf
% 
% ax71 = uiaxes(fig,'Position',[75 250 400 150]);
% plot(ax71,T, xd, 'Linewidth', 2);
% hold on
% h_mv = plot(ax71,T, xd_mv, 'Linewidth', 2);
% grid on
% box on
% xlabel('Time')
% ylabel('x-vel')
% 
% ax72 = uiaxes(fig,'Position',[75 75 400 150]);
% plot(ax72, T, move_x, 'Linewidth', 2);
% hold(ax72,'on')
% h_uv = plot(ax72,T, move_x_mv, 'Linewidth', 2);
% grid(ax72,'on')
% box(ax72','on')
% xlabel(ax72,'Time')
% ylabel(ax72,'x-control')
% 
% linkaxes([ax71 ax72],'x')
% 
% sld = uislider(fig,'Position',[125,50,100,3]);
% sld.Value = 3;
% sld.Limits = [0 10];
% sld.ValueChangedFcn = @(eds,event) updateMovMean(eds, 0.003, h_mv, h_uv);
% 
% sld2 = uislider(fig,'Position',[325,50,100,3]);
% sld2.Value = 0.003;
% sld2.Limits = [0 0.01];
% sld2.ValueChangedFcn = @(eds,event) updateFilter(eds, h_mv, h_uv);



%%
function [vel, u] = updateMovMean(hObject,p, h1, h2)   
    global xd
    n = hObject.Value;
    
    vel = movmean(xd,[n 0]);
    u = sign(vel) .* (abs(vel) > p);
    
    h1.YData = vel;
    h2.YData = u;
    drawnow
end

function [vel, u] = updateFilter(hObject, h1, h2)   
    
    p = hObject.Value;
    
    vel = h1.YData;
    u = sign(vel) .* (abs(vel) > p);
    
    h2.YData = u;
    drawnow
end