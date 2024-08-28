function plotTorque(obj)
figure;
hold on;
xlabel("Angle [°] (B||ab = 0°)");
ylabel("I_c [A]");
title(strcat("Calculated I_c vs Angle from Torque Magnetometry"));
xlim([-30,30]);
ax = gca;
ax.FontSize = 25;
for i=1:length(obj)
    holder = obj(i);
    icAngle = holder.calcIc;
    plot(icAngle.angle,icAngle.ic,'k',"LineWidth",4,'Color',Colors(i));
end
end