function [] = animate(t1, q_chair, q_bot, q_ref, u)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ux = u(:,1);
uy = u(:,2);

umax = max(max(ux),max(uy));
ux = ux/umax;
uy = uy/umax;

% Triangle
xT = 0.25;
triangle = [-xT*tand(30),xT; 
    -xT*tand(30),-xT; 
    xT*tand(60)-xT*tand(30),0]';
circle = 1.25*[0,2,cos(linspace(0,2*pi)); 0,0,sin(linspace(0,2*pi))];
f_R = @(phi) [cos(phi)  -sin(phi); sin(phi)   cos(phi)];

%
xchair = q_chair(:,1);
ychair = q_chair(:,2);
thchair = q_chair(:,3);

xbot = q_bot(:,1);
ybot = q_bot(:,2);
thbot = q_bot(:,3);

xref = q_ref(:,1);
yref = q_ref(:,2);
thref = q_ref(:,3);

%
figure(6)
clf
hold on
h1 = animatedline(0,0,'Color','#0072BD','Linewidth',2);
h2 = animatedline(xbot(1),ybot(1),'Color','#D95319','Linewidth',2);
h3 = animatedline(xref(1),yref(1),'Color','#77AC30','Linewidth',2);

h4 = animatedline(xbot(1),ybot(1),'Color','k','Linewidth',2);

p1 = patch('EdgeColor','#0072BD','FaceColor','none',...
    'Linewidth',2); 
% pc = patch('EdgeColor','#0072BD','FaceColor','none',...
%     'Linewidth',2); 
p2 = patch('EdgeColor','#D95319','FaceColor','none',...
    'Linewidth',2); 
p3 = patch('EdgeColor','#77AC30','FaceColor','none',...
    'Linewidth',2); 


pos1 = f_R(thchair(1))*triangle + [xchair(1); ychair(1)];
set(p1,'Xdata',pos1(1,:),'Ydata',pos1(2,:));
% posc = f_R(thchair(1))*circle + [xchair(1); ychair(1)];
% set(pc,'Xdata',posc(1,:),'Ydata',posc(2,:));
pos2 = f_R(thbot(1))*triangle + [xbot(1); ybot(1)];
set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:));
pos3 = f_R(thref(1))*triangle + [xref(1); yref(1)];
set(p3,'Xdata',pos3(1,:),'Ydata',pos3(2,:));




axis equal 
% axis([-10,5,-1,20])
text(0.9,0.95,'3X ','Units','normalized','FontSize',14)
grid on
box on

dT = 0.1;
Timeframe = 1;
start = tic;
for k = 1:length(t1)
    
    if (t1(k) > dT * Timeframe)
        tic
        
        addpoints(h1,xchair(k),ychair(k));
        addpoints(h2,xbot(k),ybot(k));
        addpoints(h3,xref(k),yref(k));
        
        clearpoints(h4)
        addpoints(h4,xbot(k),ybot(k));
        addpoints(h4,xbot(k)+ux(k),ybot(k)+uy(k));
        
        pos1 = f_R(thchair(k))*triangle + [xchair(k); ychair(k)];
        set(p1,'Xdata',pos1(1,:),'Ydata',pos1(2,:))
%         posc = f_R(thchair(k))*circle + [xchair(k); ychair(k)];
%         set(pc,'Xdata',posc(1,:),'Ydata',posc(2,:))
        pos3 = f_R(thref(k))*triangle + [xref(k); yref(k)];
        set(p3,'Xdata',pos3(1,:),'Ydata',pos3(2,:))
        pos2 = f_R(thbot(k))*triangle + [xbot(k); ybot(k)];
        set(p2,'Xdata',pos2(1,:),'Ydata',pos2(2,:))

        
%         plot([xbot(k) xbot(k)+ux(k)], [ybot(k) ybot(k)+uy(k)], 'Linewidth', 2)
        
        title(['Time: ', num2str(t1(k)), ' s'])
        
        drawnow
        
        Timeframe = Timeframe + 1;
        Time = toc;
        pause((dT - Time)/3);
    end
end
toc(start)


end

