R = 1.5;
dt = 0.2;
Rob = Robot([R,0,0]);

% uX = -1.5*[ones(1,25),zeros(1,50),ones(1,25)];
% uY = [zeros(1,25),ones(1,25),zeros(1,50)];
% uTh = [zeros(1,25),zeros(1,25),ones(1,25),zeros(1,25)];

% Input
n = 101;
thd = pi/2;
uX = -[R*thd; zeros(n-1,1)];%-R*thd*ones(n,1);
uY = zeros(n,1);
uTh = zeros(n,1);%thd*ones(n,1);

% Time
dT = dt * ones(n,1);
T = [0; cumsum(dT(1:end-1))];

% Plot robot triangle
xT = 0.1;
triangle = [xT, -xT*tand(30); 
    -xT, -xT*tand(30);
    0,xT*tand(60)-xT*tand(30)]';
f_R = @(phi) [cos(phi) -sin(phi); 
    sin(phi) cos(phi)];

% Prepare figure
figure(6)
clf
h1 = animatedline(Rob.posGlobal(1),Rob.posGlobal(2),'LineStyle','-','Marker','x','Color','#0072BD','Linewidth',2);
h2 = animatedline([0, 0],[0, 0],'LineStyle','-','Marker','x','Color','#D95319','Linewidth',2);
p1 = patch('EdgeColor','#0072BD','FaceColor','none',...
    'Linewidth',2); 
hold all
grid on
box on
axis equal
xlim([-2 2])
ylim([-2 2])

Rob.setPositionHandle(p1);

vel = zeros(n,3);

for i = 1:length(T)
    
    v = [uX(i), uY(i), uTh(i)];
    Rob.update(v,dT(i));
       
    addpoints(h1,Rob.posGlobal(1),Rob.posGlobal(2))
        
    Rob.setPositionHandle(p1);
    vel(i,:) = Rob.vel;
    
    drawnow
    pause(0.01);
    
end

figure(7)
clf;
hold all
yyaxis left
plot(T,vel(:,1:2),'Linewidth',2)
ylabel('Velocity [m/s]')
yyaxis right
plot(T,vel(:,3),'Linewidth',2)
grid on
box on
xlabel('Time [s]')
ylabel('Velocity [rad/s]')