classdef torqueMeasurement
    %TORQUEMEASUREMENT This class serves as a container for data generated
    %from Jan Jaroszynski's torque magnetometer utilizing NML DAQ at NHMFL.
    %   This class parses the text file generated from the data acqusition
    %   program and then allows calculation of Ic by requesting the user to
    %   enter necessary parameters and clean/scale the data as needed.
    %Version = 1.0

    properties
        angle
        field
        heaterpower
        loadcell
        pickupcoil
        temperature
        time
        coeff
        width
        length
        leftCutoff
        rightCutoff
    end

    methods
        function obj = torqueMeasurement()
            [holder,path] = uigetfile('*.txt');
            path = string([path,holder]);
            data = importdata(path,'\t',10);
            headers = string([data.colheaders]);
            data = data.data;
            standard = true;
            standardHeaders = ["XXX_","Field_","XXX_T_","HtrPwr_","Voltmeter_","Lockin_V_","Timestamp"];
            for i = 1:length(headers)
                standard = standard && contains(headers(i),standardHeaders(i));
            end
            if(~standard)
                disp("Headers:");
                disp(string([headers]));
                holder = str2double(input("Which column is temperature? [#]\n>","s"));
                obj.temperature = data(:,holder);
                holder = str2double(input("Which column is time? [#]\n>","s"));
                obj.time = data(:,holder);
                holder = str2double(input("Which column is magnetic field? [#]\n>","s"));
                obj.field = data(:,holder);
                holder = str2double(input("Which column is lock-in voltage (load cell)? [#]\n>","s"));
                obj.loadcell = data(:,holder);
                holder = str2double(input("Which column is keithley voltage (pickup coil)? [#]\n>","s"));
                obj.pickupcoil = 2.7*data(:,holder)/360;
                holder = str2double(input("Which column is heater power? [#]\n>","s"));
                obj.heaterpower = data(:,holder);
                holder = str2double(input("Which column is angle? [#]\n>","s"));
                obj.angle = 2.7*data(:,holder)/360;

            else
                obj.angle = 2.7*data(:,1)/360;
                obj.field = data(:,2);
                obj.temperature = data(:,3);
                obj.heaterpower = data(:,4);
                obj.pickupcoil = 2.7*data(:,5)/360;
                obj.loadcell = data(:,6);
                obj.time = data(:,7);
            end
            holder = str2double(string(input("What is the width of your sample? [m]\n>")));
            obj.width = holder;
            holder = str2double(string(input("What is the length of your sample? [m]\n>")));
            obj.length = holder;
            switch(str2double(string(input("Which probe did you use? (1 or 2)\n>","s"))))
                case 1
                    obj.coeff = 5.4059;
                case 2
                    obj.coeff = 5.1669;
            end
            h = figure('WindowStyle','docked');
            figure(h);
            hold on;
            title("Load vs Time");
            ylabel("Load [V]");
            xlabel("Angle [°]");
            scatter(obj.angle,obj.loadcell);
            hold off;
            pause(1);
            holder = str2double(input("At what angle does the rotation reverse?\n>","s"));
            holder = find(obj.angle>holder,1);
            obj.rightCutoff = holder;
            close(h);
            h = figure('WindowStyle','docked');
            figure(h);
            hold on;
            title("Load vs Time");
            ylabel("Load [V]");
            xlabel("Index [#]");
            cutLoad = obj.loadcell(1:holder);
            scatter(1:1:length(cutLoad),cutLoad);
            pause(1);
            holder = str2double(input("Where is the leftmost minima?\n>","s"));
            pause(1);
            obj.leftCutoff = holder;
            plot([holder,holder],[0,max(obj.loadcell)]);
            holder = str2double(input("Where is the rightmost minima?\n>","s"));
            pause(1);
            obj.rightCutoff = holder;
            plot([holder,holder],[0,max(obj.loadcell)]);
            close(h);
        end
    end
end

