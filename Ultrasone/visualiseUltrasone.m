th = -40:10:40;
phi = 7.5;

D0 = 29 * sind(phi);
DL = 29 - (D0 * sind(th)) ./ sind(90 - th - phi);
DM = 29 - 10 * tand(th);
DR = 29 - ((20-D0) * sind(th)) ./ sind(90 - th - phi);

% Measurements
if phi == 0
    DL_m = [57, 57,  0, 30, 29, 29, 28, 27,  0];
    DM_m = [54, 52, 32, 31, 29, 27, 24, 22,  0];
    DR_m = [46, 40, 36, 33, 30, 26,  0,  0,  0];    
elseif phi == 7.5
    DL_m = [53, 57, 50, 44, 29, 28, 26, 23, 20];
    DM_m = [59, 49, 31, 30, 27, 26, 23, 18, 14];
    DR_m = [ 0, 36, 34, 33, 29, 27,  0,  0,  0];
end

figure(5);
clf;
ax51 = subplot(211);
plot(th, DL, '-x', th, DM, '-x', th, DR, '-x', 'Linewidth', 2); 
grid on
ylabel('Distance [cm]')
title('Expected')
ax52 = subplot(212);
plot(th, DL_m, '-x', th, DM_m, '-x', th, DR_m, '-x', 'Linewidth', 2); 
grid on
xlabel('Angle [deg]')
ylabel('Distance [cm]')
title('Measured')
linkaxes([ax51 ax52],'xy')


figure(6);
clf;
ax61 = subplot(311);
plot(th, DL, '-x', th, DL_m, '-x', 'Linewidth', 2);
grid on
ylabel('Distance [cm]')
title('Left')
ax62 = subplot(312);
plot(th, DM, '-x', th, DM_m, '-x', 'Linewidth', 2);
grid on
ylabel('Distance [cm]')
title('Middle')
ax63 = subplot(313);
plot(th, DR, '-x', th, DR_m, '-x', 'Linewidth', 2);
grid on
xlabel('Angle [deg]')
ylabel('Distance [cm]')
title('Right')
legend({'Expect','Actual'})
linkaxes([ax61 ax62 ax63],'xy')