clear all


%% Variables

names = {'CoolTerm Capture 2022-03-22 15-31-33.txt'; ...
	'CoolTerm Capture 2022-03-22 15-32-51.txt'; ...
	'CoolTerm Capture 2022-03-22 15-34-21.txt'};
% names = {'CoolTerm Capture 2022-03-22 15-32-51.txt'};
n = 1;



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

for ii = 1:length(names)
    name = names{ii};
    data_arr = load(name);

    T = data_arr(:,1);
    T0 = T(1);
    T = T - T0;

    qdd = data_arr(:, [2, 5]);
    qdd(:,1) = qdd(:,1) + [zeros(1200,1); 0.6*ones(6600-1200,1); zeros(length(T)-6600,1)];
    qd  = data_arr(:, [3, 6]);
    q   = data_arr(:, [4, 7]);
    thd = data_arr(:, 8);
    th  = data_arr(:, 9);
    ang = data_arr(:, 10:12);

    Xref = R * cos(data_arr(end,7));
    Yref = R * sin(data_arr(end,7));
    TH = data_arr(end,7);

    % Robot
%     robot = Robot([Xref,Yref,TH]);%%-pi/2]);

    clen = 10;
    vlen = 3;
    qd_pred = zeros(size(qdd(:,1)));
    q_pred = zeros(size(qdd(:,1)));
    for jj = clen+1:length(T)
        sumdiff = sum(abs(diff(qdd(jj-clen:jj,1))));
        dt = T(jj)-T(jj-1);
        if sumdiff > 0.0001 || abs(qdd(jj,1)) > 0.0001*1000    
            qd_pred(jj) = qd_pred(jj-1) + qdd(jj,1) * dt/1000;
        end
        
        q_pred(jj) = q_pred(jj-1) + qd_pred(jj) * dt/1000;
        
    end
    
    
    

    %% Init plots

    figure;
    clf
    ax1 = subplot(321);
    hold all
    h1 = plot(T,qdd(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
    h2 = plot(T,qdd(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
    grid on
    box on
    legend({'xdd','ydd'})

    ax3 = subplot(323);
    hold all
    h3 = plot(T,qd(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
    h4 = plot(T,qd(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
    plot(T,qd_pred,'Linewidth',2);
    grid on
    box on
    legend({'xd','yd'})

    ax5 = subplot(325);
    hold all
    h5 = plot(T,q(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
    h6 = plot(T,q(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
    plot(T,q_pred,'Linewidth',2);
    grid on
    box on
    legend({'x','y'})

    ax6 = subplot(326);
    hold all
    h9 = plot(T,thd,'LineStyle','-','Color','#0072BD','Linewidth',2);
    h10 = plot(T,th,'LineStyle','-','Color','#D95319','Linewidth',2);
    grid on
    box on
    legend({'thzd','thz'})

    ax4 = subplot(324);
    hold all
    plot(T,ang,'Linewidth',2)
    plot(T,sum(abs(ang),2),'Linewidth',2)
    grid on
    box on
    legend({'pitch','roll','yaw'})
    
    ax2 = subplot(3,2,2);
    hold all
    h7 = plot(q(:,1),q(:,2),'LineStyle','-','Color','#0072BD','Linewidth',2);
    % h8 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','o','Color','#D95319','Linewidth',2);
    plot(Xc, Yc);
    box on
    grid on
    xlim([-2 2])
    ylim([-2 2])
    axis square

    %
    p1 = patch('EdgeColor','#0072BD','FaceColor','none',...
        'Linewidth',2); 
    % p2 = patch('EdgeColor','#D95319','FaceColor','none',...
    %     'Linewidth',2,'LineStyle','--'); 

    % legend({'bot','ref'})

%     robot.setPositionHandle(p1);
    % pos2 = f_R(TH)*triangle + [Xref(end); Yref(end)];
    % set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))

    sgtitle(name);
    linkaxes([ax1 ax3 ax4 ax5 ax6],'x')

end

%% Loop
