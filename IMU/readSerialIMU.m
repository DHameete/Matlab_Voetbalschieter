clear s_port
s_port = serialport('/dev/ttyACM0',115200);

%%

% writeline(s_port,"10, 100")
% data_str = readline(s_port)

% Triangle
xT = 0.25;
triangle = [-xT*tand(30),xT; 
    -xT*tand(30),-xT; 
    xT*tand(60)-xT*tand(30),0]';
f_R = @(phi) [cos(phi)  -sin(phi); sin(phi)   cos(phi)];

%%

len = 75;
data_arr = nan(len,4);
n = 1;
R = 1.5;

Xc = R * cosd(linspace(0,360));
Yc = R * sind(linspace(0,360));

figure(4);
clf
ax1 = subplot(321);
h1 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h2 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xdd','xd'})

ax2 = subplot(323);
h3 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h4 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'ydd','yd'})

ax3 = subplot(325);
h5 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h6 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'thzd','thz'})

ax4 = subplot(3,2,[2 4 6]);
h7 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','o','Color','#0072BD','Linewidth',2);
h8 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','o','Color','#D95319','Linewidth',2);
hold all
plot(Xc, Yc);
box on
grid on
xlim([-2 2])
ylim([-2 2])
axis square

%
p1 = patch('EdgeColor','#0072BD','FaceColor','none',...
    'Linewidth',2); 
p2 = patch('EdgeColor','#D95319','FaceColor','none',...
    'Linewidth',2); 

pos1 = f_R(0)*triangle + [R; 0];
set(p1,'Xdata',pos1(1,:),'Ydata',pos1(2,:));
pos2 = f_R(0)*triangle + [R; 0];
set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:));

% linkaxes([ax1 ax2 ax3],'x')

for i = 1:3
    
    d_str = read(s_port, 8, "uint8");
     
    % time
    data_arr(end,1) = d_str(1) + d_str(2)*(2^8) + ...
        d_str(3)*(2^16) + d_str(4)*(2^24);
    
    % data
    indx = d_str(8)+2;
    data_arr(end,indx) = (d_str(5) + d_str(6)*(2^8) - ...
        bitshift(d_str(6),-7)*(2^16));
    
end

% data_str = readline(s_port);
% data = str2num(data_str);
% data_arr(end,:) = data(1:7);

T0 = data_arr(end,1) / 1000;
data_arr(end,1) = 0;

X = nan(len,1);
Y = nan(len,1);
X(end) = R * cosd(0);
Y(end) = R * sind(0);
TH = 0;

dlt = 0.07;

while true
    
    data_arr(1:end-1,:) = data_arr(2:end,:);
    X(1:end-1,:) = X(2:end,:);
    Y(1:end-1,:) = Y(2:end,:);
    
    for i = 1:3
        d_str = read(s_port, 8, "uint8");
        
        % time
        data_arr(end,1) = (d_str(1) + d_str(2)*(2^8) + ...
            d_str(3)*(2^16) + d_str(4)*(2^24))/1000-T0;
        
        % data
        indx = d_str(8)+2;
        data_arr(end,indx) = (d_str(5) + d_str(6)*(2^8) - ...
            bitshift(d_str(6),-7)*(2^16));
    end
    
    %
    dT = data_arr(end,1) - data_arr(end-1,1);

    THd = data_arr(end,4)/32767*8 * dT;
    Vx = -R * sin(TH + dlt) * THd;
    Vy =  R * cos(TH + dlt) * THd;
    
    TH = TH + THd;
    X(end) = X(end-1) + Vx;
    Y(end) = Y(end-1) + Vy;
    
    %
    clearpoints(h1)
    addpoints(h1,data_arr(:,1),data_arr(:,2)/32767*2);
%     clearpoints(h2)
%     addpoints(h2,data_arr(:,1),data_arr(:,4));
    
    clearpoints(h3)
    addpoints(h3,data_arr(:,1),data_arr(:,3)/32767*2);
%     clearpoints(h4)
%     addpoints(h4,data_arr(:,1),data_arr(:,5));

    clearpoints(h5)
    addpoints(h5,data_arr(:,1),data_arr(:,4)/32767*8);
%     clearpoints(h6)
%     addpoints(h6,data_arr(:,1),data_arr(:,7));    
    
    if data_arr(end,1) < 10
        ax1.XLim = [0,10];
        ax2.XLim = [0,10];
        ax3.XLim = [0,10];
    else
        ax1.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax2.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax3.XLim = [data_arr(end,1)-10,data_arr(end,1)];
    end
    
%     clearpoints(h7)
%     addpoints(h7,Xpos,Ypos);
    clearpoints(h8)
    addpoints(h8,X,Y);

    pos2 = f_R(0)*triangle + [X(end); Y(end)];
    set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))

    
    
    drawnow
    
    flush(s_port)
    pause(0.01);
    
end
