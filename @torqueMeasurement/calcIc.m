function result = calcIc(obj)
cleanAngle = obj.angle(obj.leftCutoff:obj.rightCutoff);
cleanLoad = obj.loadcell(obj.leftCutoff:obj.rightCutoff);
cleanField = obj.field(obj.leftCutoff:obj.rightCutoff);
badSpots = find(diff(cleanAngle)==0);
cleanAngle(badSpots,:) = [];
cleanLoad(badSpots,:) = [];
cleanField(badSpots,:) = [];
cleanLoad = medfilt1(cleanLoad,1);
rezFit = polyfit([cleanAngle(1),cleanAngle(length(cleanAngle))],[cleanLoad(1),cleanLoad(length(cleanLoad))],1);
slope = rezFit(1);
intercept = rezFit(2);
holder = (slope.*cleanAngle) + intercept;
cleanLoad = cleanLoad - holder;
offset = cleanAngle(find(cleanLoad == max(cleanLoad))); %#ok<FNDSB>
cleanAngle = cleanAngle - offset;
offset = min(cleanLoad);
cleanLoad = cleanLoad - offset;
%{
h = figure('WindowStyle','docked');
figure(h);
hold on;
title("Angle Cleaning");
xlabel("Angle [°]");
ylabel("Load Cell [V]");
scatter(cleanAngle,cleanLoad);
hold off;
pause(1);
holder = input("Do you want to smooth the data? (y or n)\n>","s");
if(holder == "y")
    cleanLoad = smoothdata(cleanLoad,"gaussian",30);
    close(h);
    h = figure('WindowStyle','docked');
    figure(h);
    hold on;
    title("Angle Cleaning");
    xlabel("Angle [°]");
    ylabel("Load Cell [V]");
    scatter(cleanAngle,cleanLoad);
    hold off;
    pause(1);
end
holder = str2double(input("How many regions to cut away (left to right cutting)?\n>","s"));
%}
holder = 0;
if(holder>0)
    holder4 = zeros(2*holder,1);
    for i = 1:holder
        holder2 = str2double(input(strcat("What is the leftmost point of cutting region #",num2str(i),"?\n>"),"s"));
        holder3 = str2double(input(strcat("What is the rightmost point of cutting region #",num2str(i),"?\n>"),"s"));
        holder4(2*i-1) = holder2;
        holder4(2*i) = holder3;
    end
    holder4 = flip(holder4);
    cleanAngle = flip(cleanAngle);
    cleanField = flip(cleanField);
    cleanLoad = flip(cleanLoad);
    for i = 1:holder
        left = find(cleanAngle<holder4(2*i-1),1);
        right = find(cleanAngle<holder4(2*i),1);
        cleanAngle(left:right) = [];
        cleanField(left:right) = [];
        cleanLoad(left:right) = [];
    end
    cleanAngle = flip(cleanAngle);
    cleanField = flip(cleanField);
    cleanLoad = flip(cleanLoad);
end
x = cleanAngle;
g = @(x) interp1(cleanAngle,cleanLoad,x);
%close(h);
%f = figure('WindowStyle','docked');
%figure(f);
%hold on;
%xlabel("Angle [°] (B||ab = 0°)");
%ylabel("I_c [A]");
avgTemp = mean(obj.temperature);
avgField = max(obj.field);
%title(strcat("Calculated I_c vs Angle from Torque Magnetometry,",string(avgField)," [T] & ",string(avgTemp)," [K]"));
ic = (obj.coeff*4*1.3)/(100*obj.width*obj.length*(1-(obj.width/(3*obj.length))));
ic2 = ic;
ic2=ic2.*g(x)';
ic2 = ic2./(mean(cleanField).*cosd(x)');
%plot(x,ic2,'k',"LineWidth",4);
%xlim([-60,60]);
%hold off;
result.angle = cleanAngle;
result.ic = ic2';
end