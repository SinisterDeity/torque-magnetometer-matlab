function plotTorque(obj,multiPlot)
%PLOTTORQUE
icAngle = obj.calcIc;
if(~multiPlot)
    figure;
    hold on;
    xlabel("Angle [°] (B||ab = 0°)");
    ylabel("I_c [A]");
    title(strcat("Calculated I_c vs Angle from Torque Magnetometry"));
    xlim([-60,60]);
    ax = gca;
    ax.FontSize = 25;
end
plot(icAngle.angle,icAngle.ic,'k',"LineWidth",4);
end

