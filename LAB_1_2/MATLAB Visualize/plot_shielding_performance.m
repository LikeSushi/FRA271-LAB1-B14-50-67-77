function fHandles = plot_shielding_performance(summary, saveDir)
% PLOT_SHIELDING_PERFORMANCE สร้างกราฟแสดงประสิทธิภาพการกำบังสนามแม่เหล็ก (Shielding Efficiency)
% และค่าความไวของเซนเซอร์ (Sensitivity)
%
% Inputs:
%   summary - Struct ข้อมูลประมวลผล
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ

    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    c_ns = summary.RAW_C_No_Shield;
    c_s  = summary.RAW_C_Shield;
    d_ns = summary.RAW_D_No_Shield;
    d_s  = summary.RAW_D_Shield;

    fHandles = cell(1, 2);

    %% Fig 6: Shielding Attenuation Efficiency (%) vs Distance
    commonDistsC = intersect(c_ns.dists, c_s.dists);
    attenC = zeros(length(commonDistsC), 1);
    for i = 1:length(commonDistsC)
        idxNS = find(c_ns.dists == commonDistsC(i));
        idxS  = find(c_s.dists == commonDistsC(i));
        attenC(i) = (1 - c_s.meanFlux(idxS) / c_ns.meanFlux(idxNS)) * 100;
    end

    commonDistsD = intersect(d_ns.dists, d_s.dists);
    attenD = zeros(length(commonDistsD), 1);
    for i = 1:length(commonDistsD)
        idxNS = find(d_ns.dists == commonDistsD(i));
        idxS  = find(d_s.dists == commonDistsD(i));
        attenD(i) = (1 - d_s.meanFlux(idxS) / d_ns.meanFlux(idxNS)) * 100;
    end

    f6 = figure('Name', 'Shielding Efficiency', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    plot(commonDistsC, attenC, '-^', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0 0.447 0.741], 'DisplayName', 'Sensor C Shielding %');
    plot(commonDistsD, attenD, '-d', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.466 0.674 0.188], 'DisplayName', 'Sensor D Shielding %');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Shielding Attenuation Rate (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 6: Shielding Effectiveness (%) vs Distance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 10);
    saveas(f6, fullfile(saveDir, 'Fig6_Shielding_Attenuation_Efficiency.png'));
    saveas(f6, fullfile(saveDir, 'Fig6_Shielding_Attenuation_Efficiency.fig'));
    fHandles{1} = f6; close(f6);

    %% Fig 7: Sensitivity Comparison (Voltage Output Slope)
    f7 = figure('Name', 'Sensor Sensitivity', 'Position', [100, 100, 750, 500], 'Visible', 'off');
    hold on; grid on; box on;
    plot(c_ns.dists, c_ns.meanVolt, '-o', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0 0.447 0.741], 'DisplayName', 'Sensor C (No Shield)');
    plot(c_s.dists, c_s.meanVolt, '-s', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.85 0.325 0.098], 'DisplayName', 'Sensor C (Shielded)');
    plot(d_ns.dists, d_ns.meanVolt, '-^', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.466 0.674 0.188], 'DisplayName', 'Sensor D (No Shield)');
    plot(d_s.dists, d_s.meanVolt, '-v', 'LineWidth', 2, 'MarkerSize', 6, 'Color', [0.494 0.184 0.556], 'DisplayName', 'Sensor D (Shielded)');
    xlabel('Distance (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Voltage Output (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Fig 7: Sensor Sensitivity & Voltage Transfer Characteristic', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 10);
    saveas(f7, fullfile(saveDir, 'Fig7_Sensor_Sensitivity_Comparison.png'));
    saveas(f7, fullfile(saveDir, 'Fig7_Sensor_Sensitivity_Comparison.fig'));
    fHandles{2} = f7; close(f7);
end
