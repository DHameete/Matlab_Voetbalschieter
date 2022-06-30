clear all
clear s_port
s_port = serialport('/dev/ttyACM0',115200);



%% Variables

global serialOut
serialOut = 0;

len = 75;
N_data = 9;
data_arr = nan(len,N_data);
% n = 1;
R = 1.5;

% circle
Xc = R * cosd(linspace(0,360));
Yc = R * sind(linspace(0,360));

%%

% Triangle
xT = 0.25;
triangle = [-xT*tand(30), xT; 
    -xT*tand(30), -xT; 
    xT*tand(60)-xT*tand(30), 0]';
f_R = @(phi) [cos(phi) -sin(phi); 
    sin(phi) cos(phi)];


%% Init

data_arr(end,:) = readValues(s_port);

T0 = data_arr(end,1);
data_arr(end,1) = 0;

Xref = R * cos(data_arr(end,7));
Yref = R * sin(data_arr(end,7));
TH = data_arr(end,7);

Xbot = Xref*ones(len,1);
Ybot = Yref*ones(len,1);
THbot = TH;

% Robot
robot = Robot([Xref,Yref,TH]);%%-pi/2]);


%% Init plots

figure(4);
clf
ax1 = subplot(321);
h1 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h2 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xdd','ydd'})

ax3 = subplot(323);
h3 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h4 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xd','yd'})

ax5 = subplot(325);
h5 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h6 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'x','y'})

ax6 = subplot(326);
h9 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h10 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'thzd','thz'})

ax2 = subplot(3,2,[2 4]);
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
    'Linewidth',2,'LineStyle','--'); 

legend({'bot','ref'})

robot.setPositionHandle(p1);
pos2 = f_R(TH)*triangle + [Xref(end); Yref(end)];
set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))


%% Loop

% a: yaw, b: pitch, g: roll
RRR = @(a,b,g) [cos(a)*cos(b), cos(a)*sin(b)*sin(g) - sin(a)*cos(g), cos(a)*sin(b)*cos(g) + sin(a)*sin(g); ...
    sin(a)*cos(b), sin(a)*sin(b)*sin(g) + cos(a)*cos(g), sin(a)*sin(b)*cos(g) - cos(a)*sin(g); ...
    -sin(b), cos(b)*sin(g), cos(b)*cos(g)];
qdd = zeros(len,3);

while true
    
    data_arr(1:end-1,:) = data_arr(2:end,:);
    Xbot(1:end-1) = Xbot(2:end);
    Ybot(1:end-1) = Ybot(2:end);
    
    data_arr(end,:) = readValues(s_port, T0);
    
    %
    dT = data_arr(end,1) - data_arr(end-1,1);   


    deltaX = data_arr(end,3) - Xbot(end);
    deltaY = data_arr(end,6) - Ybot(end);

    Xref = R * cos(data_arr(:,9));
    Yref = R * sin(data_arr(:,9));
    
%     uX = data_arr(end,10);%X - D*sind(TH);
%     uY = data_arr(end,11);%Y + D*cosd(TH);   
%     uTH = data_arr(end,12);
%     
%     u = [uX; uY; uTH]*pi/180;
%     qdd(1:end-1,:) = qdd(2:end,:);
%     qdd(end,:) = (RRR(u(3),u(1),u(2))*[data_arr(end,2);data_arr(end,5);data_arr(end,6)]).';
%     qdd(end,1) = data_arr(end,2) - sin(u(1)) * 9.81;
%     
%     robot.update(u,dT);
    
    Xbot(end) = robot.posGlobal(1);
    Ybot(end) = robot.posGlobal(2);
%     sprintf('ref: %3.2f, robot: %3.2f, delta: %3.2f', data_arr(end,7), ...
%         robot.posGlobal(3), data_arr(end,7)-robot.posGlobal(3))
%     sprintf('%3.2f, ',u)
    
    % TODO: HERE
    write(s_port, [robot.posGlobal(1:2)*10,robot.posLocal(3)/pi*127], "int8")

    
    % Update plots
    clearpoints(h1)
    addpoints(h1,data_arr(:,1),data_arr(:,2));
    clearpoints(h2)
    addpoints(h2,data_arr(:,1),data_arr(:,3));
%     addpoints(h2,data_arr(:,1),data_arr(:,2).*cosd(data_arr(:,10)) +...
%         data_arr(:,5).*sind(data_arr(:,11)).*sind(data_arr(:,10)));
    
    clearpoints(h3)
    addpoints(h3,data_arr(:,1),data_arr(:,4));
    clearpoints(h4)
    addpoints(h4,data_arr(:,1),data_arr(:,5));
 
    clearpoints(h5)
    addpoints(h5,data_arr(:,1),data_arr(:,6));
    clearpoints(h6)
    addpoints(h6,data_arr(:,1),data_arr(:,7));
    
    clearpoints(h9)
    addpoints(h9,data_arr(:,1),data_arr(:,8));
    clearpoints(h10)
    addpoints(h10,data_arr(:,1),data_arr(:,9));    


    if data_arr(end,1) < 10
        ax1.XLim = [0,10];
        ax3.XLim = [0,10];
        ax5.XLim = [0,10];
        ax6.XLim = [0,10];
    else
        ax1.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax3.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax5.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax6.XLim = [data_arr(end,1)-10,data_arr(end,1)];
    end
    
    clearpoints(h7)
    addpoints(h7,Xbot,Ybot);
    clearpoints(h8)
    addpoints(h8,Xref,Yref);
    
    robot.setPositionHandle(p1);
    pos2 = f_R(data_arr(end,9))*triangle + [Xref(end); Yref(end)];
    set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))
   
    
    drawnow
    
    flush(s_port)
    pause(0.01);
    
end

function data = readValues(s_port, T0)

    global serialOut

    if nargin < 2
        T0 = 0;
    end
    
    data = zeros(1,12);
    if serialOut    
        for i = 1:3
            d_str = read(s_port, 8, "uint8");
            
            % time
            data(1) = (d_str(1) + d_str(2)*(2^8) + ...
                d_str(3)*(2^16) + d_str(4)*(2^24))/1000-T0;
            
            % data
            num = d_str(8);
            indx = num + 8;
            if num == 2
                data(indx) = (d_str(5) + d_str(6)*(2^8) - ...
                    bitshift(d_str(6),-7)*(2^16));
                data(indx) = data(indx) / 32767 * 8; % 4-byte to 8 rad/s
            else
                data(indx) = (d_str(5) + d_str(6)*(2^8) - ...
                    bitshift(d_str(6),-7)*(2^16));
                data(indx) = data(indx) / 32767 * 2; % 4-byte to 2 m/s
            end
        end
    else
        d_str = readline(s_port);
        data = str2num(d_str);
        
        % time
        data(1) = data(1)/1000 - T0;
    end
end