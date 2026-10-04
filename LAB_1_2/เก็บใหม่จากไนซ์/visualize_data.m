% MATLAB Visualization Script - 4 Distinct Graphs (Sensor C & D: Magnetic Flux & Voltage)
% Target Directory: C:\Users\Chard\Downloads\เก็บใหม่จากไนซ์-20261003T020828Z-1-001\เก็บใหม่จากไนซ์

baseDir = 'C:\Users\Chard\Downloads\เก็บใหม่จากไนซ์-20261003T020828Z-1-001\เก็บใหม่จากไนซ์';
outputDir = fullfile(baseDir, 'MATLAB_Visualizations');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

categories = {'RAW C - No Shield', 'RAW C - Shield', 'RAW D - No Shield', 'RAW D - Shield'};

fprintf('Processing MATLAB Dataset...\n');

dataSummary = struct();

for c = 1:length(categories)
    catName = categories{c};
    catPath = fullfile(baseDir, catName);
    files = dir(fullfile(catPath, '*.mat'));
    
    distMapFlux = containers.Map('KeyType', 'double', 'ValueType', 'any');
    distMapVolt = containers.Map('KeyType', 'double', 'ValueType', 'any');
    
    for f = 1:length(files)
        fname = files(f).name;
        
        if contains(fname, 'Realtime', 'IgnoreCase', true)
            continue;
        end
        
        tokens = regexp(fname, '(\d+\.\d+|\d+)cm', 'tokens');
        if isempty(tokens)
            continue;
        end
        dist = str2double(tokens{1}{1});
        
        filePath = fullfile(catPath, fname);
        S = load(filePath);
        if ~isfield(S, 'data')
            continue;
        end
        
        d = S.data;
        fluxData = [];
        voltData = [];
        
        for idx = 1:d.numElements
            elem = d.get(idx);
            if contains(elem.Name, 'flux', 'IgnoreCase', true)
                fluxData = elem.Values.Data;
            elseif contains(elem.Name, 'voltage', 'IgnoreCase', true)
                voltData = elem.Values.Data;
            end
        end
        
        if isempty(fluxData) || isempty(voltData)
            continue;
        end
        
        meanFlux = mean(abs(fluxData));
        rmsFlux  = rms(fluxData);
        peakFlux = max(abs(fluxData));
        meanVolt = mean(voltData);
        rmsVolt  = rms(voltData);
        
        if ~isKey(distMapFlux, dist)
            distMapFlux(dist) = [];
            distMapVolt(dist) = [];
        end
        distMapFlux(dist) = [distMapFlux(dist); [meanFlux, rmsFlux, peakFlux]];
        distMapVolt(dist) = [distMapVolt(dist); [meanVolt, rmsVolt]];
    end
    
    dists = sort(cell2mat(keys(distMapFlux)));
    meanFluxArr = zeros(length(dists), 1);
    stdFluxArr  = zeros(length(dists), 1);
    meanVoltArr = zeros(length(dists), 1);
    stdVoltArr  = zeros(length(dists), 1);
    
    for i = 1:length(dists)
        distVal = dists(i);
        fluxMat = distMapFlux(distVal);
        voltMat = distMapVolt(distVal);
        
        meanFluxArr(i) = mean(fluxMat(:, 1));
        stdFluxArr(i)  = std(fluxMat(:, 1));
        meanVoltArr(i) = mean(voltMat(:, 1));
        stdVoltArr(i)  = std(voltMat(:, 1));
    end
    
    fieldKey = strrep(strrep(catName, ' - ', '_'), ' ', '_');
    dataSummary.(fieldKey).dists = dists;
    dataSummary.(fieldKey).meanFlux = meanFluxArr;
    dataSummary.(fieldKey).stdFlux  = stdFluxArr;
    dataSummary.(fieldKey).meanVolt = meanVoltArr;
    dataSummary.(fieldKey).stdVolt  = stdVoltArr;
end

c_ns = dataSummary.RAW_C_No_Shield;
c_s  = dataSummary.RAW_C_Shield;
d_ns = dataSummary.RAW_D_No_Shield;
d_s  = dataSummary.RAW_D_Shield;

fprintf('Generating 4 Graphs Layout...\n');

%% --- Combined 2x2 Figure containing all 4 Graphs ---
fig4 = figure('Name', '4 Graphs Comparison (Sensors C & D)', 'Position', [50, 50, 1200, 900], 'Visible', 'off');

% Graph 1: Sensor C - Magnetic Flux vs Distance
subplot(2, 2, 1);
hold on; grid on; box on;
errorbar(c_ns.dists, c_ns.meanFlux, c_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
errorbar(c_s.dists, c_s.meanFlux, c_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density |mT|', 'FontSize', 10, 'FontWeight', 'bold');
title('Graph 1: Sensor C - Magnetic Flux vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northeast');

% Graph 2: Sensor C - Voltage vs Distance
subplot(2, 2, 2);
hold on; grid on; box on;
errorbar(c_ns.dists, c_ns.meanVolt, c_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
errorbar(c_s.dists, c_s.meanVolt, c_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontSize', 10, 'FontWeight', 'bold');
title('Graph 2: Sensor C - Voltage vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northeast');

% Graph 3: Sensor D - Magnetic Flux vs Distance
subplot(2, 2, 3);
hold on; grid on; box on;
errorbar(d_ns.dists, d_ns.meanFlux, d_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
errorbar(d_s.dists, d_s.meanFlux, d_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density |mT|', 'FontSize', 10, 'FontWeight', 'bold');
title('Graph 3: Sensor D - Magnetic Flux vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northeast');

% Graph 4: Sensor D - Voltage vs Distance
subplot(2, 2, 4);
hold on; grid on; box on;
errorbar(d_ns.dists, d_ns.meanVolt, d_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
errorbar(d_s.dists, d_s.meanVolt, d_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontSize', 10, 'FontWeight', 'bold');
title('Graph 4: Sensor D - Voltage vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
legend('Location', 'northeast');

sgtitle('MATLAB Performance Comparison: Sensor C & Sensor D (Shield vs No Shield)', 'FontSize', 13, 'FontWeight', 'bold');

saveas(fig4, fullfile(outputDir, '4_Graphs_Comparison_Grid.png'));
saveas(fig4, fullfile(outputDir, '4_Graphs_Comparison_Grid.fig'));
close(fig4);

%% --- Individual Figure Files ---

% 1. Sensor C - Magnetic Flux
f1 = figure('Name', 'Sensor C Magnetic Flux', 'Position', [100, 100, 700, 500], 'Visible', 'off');
hold on; grid on; box on;
errorbar(c_ns.dists, c_ns.meanFlux, c_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
errorbar(c_s.dists, c_s.meanFlux, c_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density |mT|', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensor C: Magnetic Flux Density vs Distance (Shield vs No Shield)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
saveas(f1, fullfile(outputDir, 'Graph1_Sensor_C_Magnetic_Flux.png'));
saveas(f1, fullfile(outputDir, 'Graph1_Sensor_C_Magnetic_Flux.fig'));
close(f1);

% 2. Sensor C - Voltage
f2 = figure('Name', 'Sensor C Voltage', 'Position', [100, 100, 700, 500], 'Visible', 'off');
hold on; grid on; box on;
errorbar(c_ns.dists, c_ns.meanVolt, c_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
errorbar(c_s.dists, c_s.meanVolt, c_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensor C: Voltage Output vs Distance (Shield vs No Shield)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
saveas(f2, fullfile(outputDir, 'Graph2_Sensor_C_Voltage.png'));
saveas(f2, fullfile(outputDir, 'Graph2_Sensor_C_Voltage.fig'));
close(f2);

% 3. Sensor D - Magnetic Flux
f3 = figure('Name', 'Sensor D Magnetic Flux', 'Position', [100, 100, 700, 500], 'Visible', 'off');
hold on; grid on; box on;
errorbar(d_ns.dists, d_ns.meanFlux, d_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
errorbar(d_s.dists, d_s.meanFlux, d_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Magnetic Flux Density |mT|', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensor D: Magnetic Flux Density vs Distance (Shield vs No Shield)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
saveas(f3, fullfile(outputDir, 'Graph3_Sensor_D_Magnetic_Flux.png'));
saveas(f3, fullfile(outputDir, 'Graph3_Sensor_D_Magnetic_Flux.fig'));
close(f3);

% 4. Sensor D - Voltage
f4 = figure('Name', 'Sensor D Voltage', 'Position', [100, 100, 700, 500], 'Visible', 'off');
hold on; grid on; box on;
errorbar(d_ns.dists, d_ns.meanVolt, d_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
errorbar(d_s.dists, d_s.meanVolt, d_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
xlabel('Distance (cm)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Voltage (V)', 'FontSize', 12, 'FontWeight', 'bold');
title('Sensor D: Voltage Output vs Distance (Shield vs No Shield)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 11);
saveas(f4, fullfile(outputDir, 'Graph4_Sensor_D_Voltage.png'));
saveas(f4, fullfile(outputDir, 'Graph4_Sensor_D_Voltage.fig'));
close(f4);

fprintf('Done! All 4 graphs generated and saved to %s\n', outputDir);
