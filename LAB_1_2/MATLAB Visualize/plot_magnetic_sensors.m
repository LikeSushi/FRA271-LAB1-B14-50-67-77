function fHandles = plot_magnetic_sensors(summary, saveDir)
% PLOT_MAGNETIC_SENSORS สร้างรูปกราฟ 4 รูปหลัก และกราฟรวม 4 ช่อง (Sensors C & D)
%
% Inputs:
%   summary - Struct ข้อมูลสรุปจาก process_static_data
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ

    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    c_ns = summary.RAW_C_No_Shield;
    c_s  = summary.RAW_C_Shield;
    d_ns = summary.RAW_D_No_Shield;
    d_s  = summary.RAW_D_Shield;

    fHandles = cell(1, 5);

    %% Fig 1: Sensor C - Magnetic Flux Density vs Distance
    f1 = figure('Name', 'Sensor C Magnetic Flux', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    errorbar(c_ns.dists, c_ns.meanFlux, c_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
    errorbar(c_s.dists, c_s.meanFlux, c_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Magnetic Flux Density |mT|', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 1: Sensor C - Magnetic Flux Density vs Distance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    saveas(f1, fullfile(saveDir, 'Fig1_Sensor_C_Magnetic_Flux_vs_Distance.png'));
    saveas(f1, fullfile(saveDir, 'Fig1_Sensor_C_Magnetic_Flux_vs_Distance.fig'));
    fHandles{1} = f1; close(f1);

    %% Fig 2: Sensor C - Voltage vs Distance
    f2 = figure('Name', 'Sensor C Voltage', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    errorbar(c_ns.dists, c_ns.meanVolt, c_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
    errorbar(c_s.dists, c_s.meanVolt, c_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 2: Sensor C - Voltage Output vs Distance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    saveas(f2, fullfile(saveDir, 'Fig2_Sensor_C_Voltage_vs_Distance.png'));
    saveas(f2, fullfile(saveDir, 'Fig2_Sensor_C_Voltage_vs_Distance.fig'));
    fHandles{2} = f2; close(f2);

    %% Fig 3: Sensor D - Magnetic Flux Density vs Distance
    f3 = figure('Name', 'Sensor D Magnetic Flux', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    errorbar(d_ns.dists, d_ns.meanFlux, d_ns.stdFlux, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
    errorbar(d_s.dists, d_s.meanFlux, d_s.stdFlux, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Magnetic Flux Density |mT|', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 3: Sensor D - Magnetic Flux Density vs Distance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    saveas(f3, fullfile(saveDir, 'Fig3_Sensor_D_Magnetic_Flux_vs_Distance.png'));
    saveas(f3, fullfile(saveDir, 'Fig3_Sensor_D_Magnetic_Flux_vs_Distance.fig'));
    fHandles{3} = f3; close(f3);

    %% Fig 4: Sensor D - Voltage vs Distance
    f4 = figure('Name', 'Sensor D Voltage', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    errorbar(d_ns.dists, d_ns.meanVolt, d_ns.stdVolt, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
    errorbar(d_s.dists, d_s.meanVolt, d_s.stdVolt, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 4: Sensor D - Voltage Output vs Distance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    saveas(f4, fullfile(saveDir, 'Fig4_Sensor_D_Voltage_vs_Distance.png'));
    saveas(f4, fullfile(saveDir, 'Fig4_Sensor_D_Voltage_vs_Distance.fig'));
    fHandles{4} = f4; close(f4);

    %% Fig 5: 4 Graphs Combined Comparison Grid
    fGrid = figure('Name', '4 Graphs Comparison Grid', 'Position', [50, 50, 1200, 850], 'Visible', 'off');

    % Subplot 1
    subplot(2, 2, 1);
    hold on; grid on; box on;
    errorbar(c_ns.dists, c_ns.meanFlux, c_ns.stdFlux, '-o', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
    errorbar(c_s.dists, c_s.meanFlux, c_s.stdFlux, '-s', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Magnetic Flux Density |mT|', 'FontSize', 10, 'FontWeight', 'bold');
    title('1) Sensor C - Magnetic Flux vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northeast');

    % Subplot 2
    subplot(2, 2, 2);
    hold on; grid on; box on;
    errorbar(c_ns.dists, c_ns.meanVolt, c_ns.stdVolt, '-o', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0 0.447 0.741], 'DisplayName', 'No Shield');
    errorbar(c_s.dists, c_s.meanVolt, c_s.stdVolt, '-s', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.85 0.325 0.098], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 10, 'FontWeight', 'bold');
    title('2) Sensor C - Voltage vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northeast');

    % Subplot 3
    subplot(2, 2, 3);
    hold on; grid on; box on;
    errorbar(d_ns.dists, d_ns.meanFlux, d_ns.stdFlux, '-o', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
    errorbar(d_s.dists, d_s.meanFlux, d_s.stdFlux, '-s', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Magnetic Flux Density |mT|', 'FontSize', 10, 'FontWeight', 'bold');
    title('3) Sensor D - Magnetic Flux vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northeast');

    % Subplot 4
    subplot(2, 2, 4);
    hold on; grid on; box on;
    errorbar(d_ns.dists, d_ns.meanVolt, d_ns.stdVolt, '-o', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.466 0.674 0.188], 'DisplayName', 'No Shield');
    errorbar(d_s.dists, d_s.meanVolt, d_s.stdVolt, '-s', 'LineWidth', 1.8, 'MarkerSize', 5, 'Color', [0.494 0.184 0.556], 'DisplayName', 'With Shield');
    xlabel('Distance (cm)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 10, 'FontWeight', 'bold');
    title('4) Sensor D - Voltage vs Distance', 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northeast');

    sgtitle('Fig 5: Comprehensive Performance Comparison (Sensor C & Sensor D)', 'FontSize', 13, 'FontWeight', 'bold');

    saveas(fGrid, fullfile(saveDir, 'Fig5_Sensor_C_D_4_Graphs_Comparison_Grid.png'));
    saveas(fGrid, fullfile(saveDir, 'Fig5_Sensor_C_D_4_Graphs_Comparison_Grid.fig'));
    fHandles{5} = fGrid; close(fGrid);
end
