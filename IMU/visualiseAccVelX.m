name = 'CoolTerm Capture 2021-06-01 13-54-42.txt';
data = readtable(name);
xdd_filt = data.Var1;
xd = data.Var2;


n = 10;
cmp = zeros(1,n);
sm = zeros(size(xdd_filt));

xd2 = zeros(size(xdd_filt));
for q = 2:length(xdd_filt)

    xd2(q) = xd2(q-1) + xdd_filt(q);
    
    cmp(mod(q,n)+1) = xdd_filt(q);
    diff = 0;
    for qn = 1:n 
        diff = diff + abs(cmp(mod(qn,n)+1) - cmp(mod(qn+1,n)+1));
    end
    sm(q) = diff;    
    
    if sm(q) < 0.01
        xd2(q) = 0;
    end
end


figure(88)
clf
ax881 = subplot(211);
plot(xdd_filt,'.-','Linewidth',2);
hold on
plot(xd,'.-','Linewidth',2);
plot(xd2,'.-','Linewidth',2);
grid on
legend({'xdd','xd'})
ax882 = subplot(212);
plot(sm,'.-','Linewidth',2);
grid on

linkaxes([ax881 ax882],'x')
