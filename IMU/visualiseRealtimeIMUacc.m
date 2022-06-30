clear all
clear s_port
s_port = serialport('/dev/ttyACM0',115200);


%% Variables

global serialOut
serialOut = 0;

len = 150;
N_data = 12;
data_arr = nan(len,N_data);


%% Init

data_arr(end,:) = readValues(s_port);

T0 = data_arr(end,1);
data_arr(end,1) = 0;



%% Init plots

figure(5);
clf
ax51 = subplot(311);
h51 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h52 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xdd-raw','ydd-raw'})

ax52 = subplot(312);
h53 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h54 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xdd-outliers','ydd-outliers'})

ax53 = subplot(313);
h55 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h56 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
hold all
grid on
box on
legend({'xdd-mov.avg','ydd-mov.avg'})

ax51.YLim = [-0.3, 0.3];
ax52.YLim = [-0.3, 0.3];
ax53.YLim = [-0.3, 0.3];


%% Loop

while true
    
    data_arr(1:end-1,:) = data_arr(2:end,:);

    
    data_arr(end,:) = readValues(s_port, T0);

    
     % Update plots
    clearpoints(h51)
    addpoints(h51,data_arr(:,1),data_arr(:,2));
    clearpoints(h52)
    addpoints(h52,data_arr(:,1),data_arr(:,5));
    
    clearpoints(h53)
    addpoints(h53,data_arr(:,1),data_arr(:,3));
    clearpoints(h54)
    addpoints(h54,data_arr(:,1),data_arr(:,6));
 
    clearpoints(h55)
    addpoints(h55,data_arr(:,1),data_arr(:,4));
    clearpoints(h56)
    addpoints(h56,data_arr(:,1),data_arr(:,7));

    if data_arr(end,1) < 10
        ax51.XLim = [0,10];
        ax52.XLim = [0,10];
        ax53.XLim = [0,10];
    else
        ax51.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax52.XLim = [data_arr(end,1)-10,data_arr(end,1)];
        ax53.XLim = [data_arr(end,1)-10,data_arr(end,1)];
    end
    
    
    drawnow 
    
    flush(s_port)
    pause(0.001);
    
    
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