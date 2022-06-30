clear all

% name = 'CoolTerm Capture 2021-05-27 14-56-22.txt';
% name = 'CoolTerm Capture 2021-05-28 08-08-32.txt'; % xdd,ydd,thd only

% name = 'CoolTerm Capture 2021-05-28 08-29-41.txt'; % with Time
name = 'CoolTerm Capture 2021-05-28 16-30-26.txt'; % More accurate
name = 'CoolTerm Capture 2021-06-25 10-48-09.txt'; 

data = readtable(name);
T_raw = data.Var1;
xdd_raw = data.Var2;
ydd_raw = data.Var3;
thd = data.Var4;

T = (T_raw - T_raw(1)) / 1000;
dt = diff(T);

xd = cumsum(xdd_raw)*0.1;
yd = cumsum(ydd_raw)*0.1;

figure(4);
clf;
ax1 = subplot(311);
plot(T,xdd_raw,T,xd,'Linewidth',2);
grid on
legend({'xdd','xd'})

ax2 = subplot(312);
plot(T,ydd_raw,T,yd,'Linewidth',2);
grid on
legend({'ydd','yd'})

ax3 = subplot(313);
plot(T, thd,'Linewidth',2); 
grid on
legend('rzd')
linkaxes([ax1 ax2 ax3],'x')

%%

nmx = 180;
xdd_raw_prt = xdd_raw(1:nmx);
T1 = T(1:nmx);

xdd_avg1 = 0;
for n = 1:nmx
    xdd_avg1 = xdd_avg1 + (xdd_raw_prt(n) - xdd_avg1) / n;
end
xdd_avg2 = mean(xdd_raw_prt);

xdd_prt1 = xdd_raw_prt-xdd_avg1;
xdd_prt2 = xdd_raw_prt-xdd_avg2;

xdd1 = xdd_raw-xdd_avg1;

xdd1_flt = xdd1 .* (abs(xdd1) > 0.03);
xdd1_mv = movmean(xdd1, 5);


% k_mv = 3;
% xd_mv = movmean(xd,[k_mv 0]);
%

xd1 = [0; cumsum(xdd1(1:end-1).*dt)];
xd1_flt = [0; cumsum(xdd1_flt(1:end-1).*dt)];
xd1_mv = [0; cumsum(xdd1_mv(1:end-1).*dt)];

nV = 10; %% ##3 --> 10
cmp = zeros(1,nV);
xd1_flt_sumdiff = zeros(size(xd1_flt));
for k = 1:length(xd1_flt)
    cmp(mod(k,nV)+1) = xd1_flt(k);
    xd1_flt_sumdiff(k) = sum(sum(abs((cmp - cmp'))));
end
xd1_flt_flt = xd1_flt .* (abs(xd1_flt_sumdiff) > 0.01); %% ## 0.01 --> 


cmp = zeros(1,nV);
xd1_flt2 = zeros(size(xdd1_flt));
for q = 2:length(xdd1_flt)
    xd1_flt2(q) = xd1_flt2(q-1) + 0.1 * xdd1_flt(q);
    
    cmp(mod(q,nV)+1) = xd1_flt2(q);
    if sum(abs(diff(cmp))) < 0.01
        xd1_flt2(q) = 0;
    end
end


%

figure(5)
clf

ax51 = subplot(211);
plot(T,xdd1,'Linewidth',2)
hold on
plot(T,xdd1_flt, T, xdd1_mv,'Linewidth',2)
grid on
legend({'xdd1','xdd1-flt','xdd1-mv'})

ax52 = subplot(212);
hold on
plot(T,xd1,'Linewidth',2)
plot(T,xd1_flt,T,xd1_mv,'Linewidth',2)
plot(T,xd1_flt_flt,'Linewidth',2)
plot(T,xd1_flt2,'Linewidth',2)
% plot(T,zeros(size(T)),'k','Linewidth',2)
grid on
box on
legend({'xd1','xd1-flt','xd1-mv','xd1-flt-flt'})

linkaxes([ax51 ax52],'x')

%%

figure(6);
clf;
ax1 = subplot(211);
plot(T,xdd_raw,T,xd,'Linewidth',2);
grid on
legend({'xdd','xd'})
title('Old')

ax2 = subplot(212);
plot(T,xdd1_flt,T,xd1_flt2,'Linewidth',2);
grid on
legend({'xdd1','xd1'})
title('New')

linkaxes([ax1 ax2],'xy')


%%

global xd 

xd_mv = movmean(xd,[3 0]);

skd = 0.003;
move_x = sign(xd) .* (abs(xd) > skd);
move_x_mv = sign(xd_mv) .* (abs(xd_mv) > skd);

fig = uifigure('HandleVisibility', 'on','Name','Figure 7');
clf

ax71 = uiaxes(fig,'Position',[75 250 400 150]);
plot(ax71,T, xd, 'Linewidth', 2);
hold on
h_mv = plot(ax71,T, xd_mv, 'Linewidth', 2);
grid on
box on
xlabel('Time')
ylabel('x-vel')

ax72 = uiaxes(fig,'Position',[75 75 400 150]);
plot(ax72, T, move_x, 'Linewidth', 2);
hold(ax72,'on')
h_uv = plot(ax72,T, move_x_mv, 'Linewidth', 2);
grid(ax72,'on')
box(ax72','on')
xlabel(ax72,'Time')
ylabel(ax72,'x-control')

linkaxes([ax71 ax72],'x')

sld = uislider(fig,'Position',[125,50,100,3]);
sld.Value = 3;
sld.Limits = [0 10];
sld.ValueChangedFcn = @(eds,event) updateMovMean(eds, 0.003, h_mv, h_uv);

sld2 = uislider(fig,'Position',[325,50,100,3]);
sld2.Value = 0.003;
sld2.Limits = [0 0.01];
sld2.ValueChangedFcn = @(eds,event) updateFilter(eds, h_mv, h_uv);



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