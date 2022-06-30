clear all

files = dir("CoolTerm*");

n = length(files);
data = cell(n,1);
for f = 1:n
    data{f} = readtable(files(f).name);
end

% data:
% 1, 2: distance 45 -- 10
% 3: distance 10 -- 45
% 4: angle 0 -30 0 30
% 5, 6: angle -30 0 30

% ref = 45:-5:10;
% tref = 0:9:72;

tref = [0 6 13 22 31 42 54 66 80;
        0 8 15 23 31 40 52 61 72;
        0 8 16 23 31 38 45 70 90];
    
ref = [45:-5:10;
    45:-5:10;
    10:5:45];

m = 3;
Tref = zeros(m,2*length(ref));
Ref = zeros(m,2*length(ref));
for k = 1:m
    for ind = 1:2*length(ref)
        ind_t = floor(ind / 2) + 1;
        Tref(k,ind) = tref(k,ind_t);
        ind_r = floor((ind-1) / 2) + 1;
        Ref(k,ind) = ref(k,ind_r);
    end
end


%%

figure(6)
clf;
offL = [2, 1];
offM = [3, 3];
offR = [0, 2];

for i = 1:2
    
    T  = data{i}.Var1;
    uL = data{i}.Var2;% + offL(i);
    uM = data{i}.Var3;% + offM(i);
    uR = data{i}.Var4;% + offR(i);
    
    T = (T - T(1))/1000000;
    
    subplot(2,1,i)
    hold all
    plot(T, uL, 'Linewidth', 2)
    plot(T, uM, 'Linewidth', 2)
    plot(T, uR, 'Linewidth', 2)
    
    plot(Tref(i,:), Ref(i,:), 'k--', 'Linewidth', 2)
    
    grid on
    box on
    xlabel('Time [s]')
    ylabel('Distance [cm]')
    legend({'Left','Middle','Right'})
end

%%

refa = 30:-10:-30;
st = 40;
refL = st - 10 * tand(refa);
refM = st +  0 * tand(refa);
refR = st + 10 * tand(refa);
tref_a = [0 7 15 23 31 38 46 60;
    0 8 16 24 33 42 49 59];

m = 2;
Tref_a = zeros(m,2*length(refa));
RefL = zeros(m,2*length(refa));
RefM = zeros(m,2*length(refa));
RefR = zeros(m,2*length(refa));

for k = 1:m
    for ind = 1:2*length(refa)
        ind_t = floor(ind / 2) + 1;
        Tref_a(k,ind) = tref_a(k,ind_t);
        ind_r = floor((ind-1) / 2) + 1;
        RefL(k,ind) = refL(ind_r);
        RefM(k,ind) = refM(ind_r);
        RefR(k,ind) = refR(ind_r);
    end
end


figure(7)
clf;

for i = 5:6
    
    j = i-4;
    
    T  = data{i}.Var1;
    uL = data{i}.Var2;
    uM = data{i}.Var3;
    uR = data{i}.Var4;
    
    T = (T - T(1))/1000000;
    
    h = subplot(2,1,j);
    hold all
    plot(T, uL, 'Linewidth', 2)
    plot(T, uM, 'Linewidth', 2)
    plot(T, uR, 'Linewidth', 2)
    
    h.ColorOrderIndex = 1;
    
    plot(Tref_a(j,:), RefL(j,:), '--', 'Linewidth', 2)
    plot(Tref_a(j,:), RefM(j,:), '--', 'Linewidth', 2)
    plot(Tref_a(j,:), RefR(j,:), '--', 'Linewidth', 2)
    
    grid on
    box on
    xlabel('Time [s]')
    ylabel('Distance [cm]')
    legend({'Left','Middle','Right'})
end