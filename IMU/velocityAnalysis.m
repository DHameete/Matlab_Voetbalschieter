
thd = [linspace(1.26,1.26,250),... 
    linspace(-0.31,-0.31,500),...
    linspace(1.885,1.885,250)];
T = linspace(0,10,length(thd));

thd = linspace(1.57,1.57,40);
T = linspace(0,4,length(thd));
f = length(thd) / T(end)

R = 1.5;

X = zeros(size(T));
Y = zeros(size(T));
TH = zeros(size(T));

Vx = zeros(size(T));
Vy = zeros(size(T));

Vx(1) = -R * sin(0)*thd(1);
Vy(1) =  R * cos(0)*thd(1);

X(1) = R;
Y(1) = 0;
TH(1) = 0;

dlt = 0.07;
 
for i = 2:length(T)
          
    %
    dT = T(i)-T(i-1);

    
    Vx(i) = -R * sin(TH(i-1)+dlt)*thd(i);
    Vy(i) =  R * cos(TH(i-1)+dlt)*thd(i);
    
   
    X(i)  = X(i-1) + Vx(i) * dT;
    Y(i)  = Y(i-1) + Vy(i) * dT;
    TH(i) = TH(i-1) + thd(i) * dT;   

end

xc = R * cosd(linspace(0,360));
yc = R * sind(linspace(0,360));

Xp = R * cos(TH);
Yp = R * sin(TH);

Ract = sqrt(X.^2 + Y.^2);

figure(39)
clf
hold all
plot(X,Y,'o','Linewidth',2)
quiver(X(1:end-1),Y(1:end-1),diff(X),diff(Y))
plot(xc,yc,'Linewidth',2)

axis equal
grid on

figure(40)
clf
hold all
plot(T,X,T,Y,'Linewidth',2)
plot(T,Xp,'--',T,Yp,'--','Linewidth',2)
grid on
xlabel('Time [s]')
ylabel('Position [m]')
legend({'X-position','Y-position'})

figure(41)
clf
hold all
plot(T,thd,'Linewidth',2)
plot(T,Vx,T,Vy,'Linewidth',2)

