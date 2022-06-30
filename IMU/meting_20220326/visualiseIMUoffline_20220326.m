clear all


%% Variables

names = {'CoolTerm Capture 2022-03-26 13-55-59.txt'; ...
	'CoolTerm Capture 2022-03-26 13-56-38.txt'; ...
	'CoolTerm Capture 2022-03-26 13-57-48.txt'};
names = {'CoolTerm Capture 2022-03-26 13-55-59.txt'}; % good
% names = {'CoolTerm Capture 2022-03-26 13-56-38.txt'}; % baaad

n = 1;



% n = 1;
R = 1.5;

% circle
Xc = R * cosd(linspace(0,360));
Yc = R * sind(linspace(0,360));

%%

g = [0; 0; 9.81];


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
%     data_arr = load(name);
    tab = readtable(name);
    tab.Var7 = zeros(size(tab.Var7));
    data_arr = table2array(tab);


    T = data_arr(:,1)/1000;
    T0 = T(1);
    T = T - T0;

    qdd_raw = data_arr(:, 2:4) - g.';
    qdd = data_arr(:, 5:6);
    qd  = data_arr(:, 8:9);
    q   = data_arr(:, 10:11);
    thd = data_arr(:, 12);
    th  = data_arr(:, 13);
    ang = data_arr(:, 14:16);

    Xref = R * cos(data_arr(end,13));
    Yref = R * sin(data_arr(end,13));
    TH = data_arr(end,13);

    % Robot
%     robot = Robot([Xref,Yref,TH]);%%-pi/2]);

    ang_mv = movmean(ang,1000);
    qdd_pred = qdd(:,1).*(ang_mv(:,1));
    qdd_pred = movmean(qdd_raw(:,1),[100 0]) .* cosd(ang_mv(:,1)) - ...
        movmean(qdd_raw(:,3),[100 0]) .* sind(ang_mv(:,1));
    qdd_pred = movmean(qdd_raw(:,1),[100 0]) + [zeros(700,1); 0.15*ones(4000-700,1); zeros(length(T)-4000,1)];
%     qdd_rot = qdd(:,1) + [zeros(1200,1); 0.6*ones(6600-1200,1); zeros(length(T)-6600,1)];

    qdd_pred = qdd_raw(:,1);

    clen = 100;
    vlen = 3;
    qd_pred = zeros(size(qdd(:,1)));
    qd_pred2 = zeros(size(qdd(:,1)));
    q_pred = zeros(size(qdd(:,1)));
    for jj = clen+1:length(T)
        sumdiff = sum(abs(diff(qdd_pred(jj-clen:jj,1))));
        dt = T(jj)-T(jj-1);
        if sumdiff > 0.001 || abs(qdd_pred(jj,1)) > 0.0001*1000    
            qd_pred(jj) = qd_pred(jj-1) + qdd_pred(jj,1) * dt;
            qd_pred2(jj) = qd_pred2(jj-1) + 0.5*(qdd_pred(jj,1)+qdd_pred(jj-1,1)) * dt;
        end
        qd_pred(jj) = qd_pred(jj-1) + qdd_pred(jj,1) * dt;
        qd_pred2(jj) = qd_pred2(jj-1) + 0.5*(qdd_pred(jj,1)+qdd_pred(jj-1,1)) * dt;
        
        q_pred(jj) = q_pred(jj-1) + qd_pred(jj) * dt;
        
    end
    
    
    

    %% Init plots

    figure(ii);
    clf
    ax1 = subplot(321);
    hold all
    h1 = plot(T,qdd(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
    h2 = plot(T,qdd(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
    plot(T,qdd_pred)
    grid on
    box on
    legend({'xdd','ydd'})
    

    ax3 = subplot(323);
    hold all
    h3 = plot(T,qd(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
    h4 = plot(T,qd(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
    plot(T,qd_pred,'Linewidth',2);
    plot(T,qd_pred2,'Linewidth',2);
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
    h10 = plot(T,unwrap(th),'LineStyle','-','Color','#D95319','Linewidth',2);
    grid on
    box on
    legend({'thzd','thz'})

    ax4 = subplot(324);
    hold all
    plot(T,ang,'Linewidth',2)
    plot(T,sum(abs(ang),2),'Linewidth',2)
    
    plot(T,ang_mv,'Linewidth',2)
    grid on
    box on
    legend({'pitch','roll','yaw'})
    
    ax2 = subplot(3,2,2);
    hold all
    hold all
%     h7 = plot(T,qdd_raw(:,1),'LineStyle','-','Color','#0072BD','Linewidth',2);
%     h8 = plot(T,qdd_raw(:,2),'LineStyle','-','Color','#D95319','Linewidth',2);
%     plot(T,qdd_raw(:,3),'Linewidth',2); 
%     plot(T,qdd,'Linewidth',2)
    plot(T,qdd_raw(:,1),'Linewidth',2)
    plot(T,movmean(qdd_raw(:,1),[100 0]),'Linewidth',2)
    plot(T,qdd(:,1),'Linewidth',2)
    plot(T,movmean(qdd_raw(:,1),[1000 0]),'Linewidth',2)
    grid on
    box on
%     legend({'xdd','ydd'})
    legend({'raw','movmean','filtered'})
    ylim([-1.5 1.5])

    %
%     p1 = patch('EdgeColor','#0072BD','FaceColor','none',...
%         'Linewidth',2); 
    % p2 = patch('EdgeColor','#D95319','FaceColor','none',...
    %     'Linewidth',2,'LineStyle','--'); 

    % legend({'bot','ref'})

%     robot.setPositionHandle(p1);
    % pos2 = f_R(TH)*triangle + [Xref(end); Yref(end)];
    % set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))

    sgtitle(name);
    linkaxes([ax1 ax2 ax3 ax4 ax5 ax6],'x')
    linkaxes([ax1 ax2],'y')

end

%% Loop
