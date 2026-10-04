function figHandles = plot_loadcell_calibration(dataDir, saveDir)
% PLOT_LOADCELL_CALIBRATION สร้างกราฟเส้นโค้งคุณลักษณะการสอบเทียบ (Calibration Curves)
% สำหรับเซนเซอร์วัดแรง / โหลดเซลล์ (Lab 1.4: Load Cell & Instrumentation Amplifier)
%
% ครอบคลุม:
%   1. Fig1_LoadCell_Voltage_vs_Mass.png            - กราฟ V_out vs Mass (kg) พร้อม Error Bars (\mu \pm 1SD)
%   2. Fig1b_LoadCell_Voltage_vs_Mass_No_Errorbar.png - กราฟ V_out vs Mass (kg) แบบไม่มี Error Bar (Legend ขวาบน)
%   3. Fig1c_LoadCell_Voltage_vs_Force.png           - กราฟ V_out vs Applied Force (N)
%   4. Fig1d_LoadCell_Individual_Trials.png          - กราฟเปรียบเทียบการวัดซ้ำทุกรอบ (Trial 1, 2, 3... vs Mean)
%   5. Fig1e_LoadCell_ADC_vs_Mass.png                - กราฟรหัส ADC ดิบ (12-bit STM32) vs Mass (kg)
%
% Inputs:
%   dataDir - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.4')
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ (เช่น './output_figures')
%
% Outputs:
%   figHandles - Handles ของรูปภาพที่ถูกสร้างขึ้น
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% สำหรับวิชา RMX / FRA Lab: Sensors - Lab 1.4

    if nargin < 1 || isempty(dataDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentScriptDir, '..', 'Lab1.4');
    end
    if nargin < 2 || isempty(saveDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        saveDir = fullfile(currentScriptDir, 'output_figures');
    end
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    fprintf('กำลังประมวลผลข้อมูลการสอบเทียบ Load Cell (Calibration Curves)...\n');
    r = process_static_data(dataDir);

    figHandles = [];
    themeColor = [0.0 0.4470 0.7410]; % สีน้ำเงินมาตรฐานวิชาการ
    accentColor = [0.8500 0.3250 0.0980]; % สีส้มเน้น

    % -------------------------------------------------------------
    % รูปที่ 1: Characteristic Curve (Voltage vs Mass in kg) พร้อม Error Bar และ Linear Regression
    % -------------------------------------------------------------
    f1 = figure('Name', 'LoadCell_Voltage_vs_Mass', 'Color', 'w', 'Position', [100, 100, 850, 600]);
    hold on; grid on; box on;
    
    % คำนวณสมการถดถอยเชิงเส้น (Linear Regression)
    p_lin = polyfit(r.mass, r.voltage_mean, 1);
    m_fit = linspace(0, 11, 100);
    v_fit = polyval(p_lin, m_fit);
    ss_tot = sum((r.voltage_mean - mean(r.voltage_mean)).^2);
    ss_res = sum((r.voltage_mean - polyval(p_lin, r.mass)).^2);
    r2_val = 1 - (ss_res / ss_tot);

    % พล็อตจุดข้อมูลการวัดจริงพร้อม Error Bar
    errorbar(r.mass, r.voltage_mean, r.voltage_sd, 'o', ...
        'Color', themeColor, 'LineWidth', 1.8, ...
        'MarkerSize', 8, 'MarkerFaceColor', themeColor, ...
        'CapSize', 8, 'DisplayName', 'Measured Voltage (\mu \pm 1SD, 3 Trials)');
    
    % พล็อตเส้นฟิต Linear Regression
    plot(m_fit, v_fit, 'r-', 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Linear Fit: V_{out} = %.4f\\cdot m + %.4f\n(R^2 = %.5f, S_m = %.2f mV/kg)', ...
        p_lin(1), p_lin(2), r2_val, p_lin(1)*1000));
        
    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Lab 1.4 Load Cell: Calibration & Linear Regression Curve', ...
           'Voltage vs Applied Mass (0.988 - 9.961 kg Range)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 2.0]);
    xlim([0, 11]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1, fullfile(saveDir, 'Fig1_LoadCell_Voltage_vs_Mass.png'));
    figHandles(end+1) = f1;

    % -------------------------------------------------------------
    % รูปที่ 1b: Characteristic Curve แบบไม่มี Error Bar (Legend ขวาบน)
    % -------------------------------------------------------------
    f1b = figure('Name', 'LoadCell_Voltage_vs_Mass_Clean', 'Color', 'w', 'Position', [120, 110, 850, 600]);
    hold on; grid on; box on;
    plot(r.mass, r.voltage_mean, '-s', ...
        'Color', themeColor, 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', themeColor, ...
        'DisplayName', 'Load Cell Output V_{out}');
    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Lab 1.4 Load Cell: Output Voltage vs Applied Mass', ...
           'Static Calibration Curve (Clean View without Error Bars)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southeast', 'FontSize', 11);
    ylim([0, 2.0]);
    xlim([0, 11]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1b, fullfile(saveDir, 'Fig1b_LoadCell_Voltage_vs_Mass_No_Errorbar.png'));
    figHandles(end+1) = f1b;

    % -------------------------------------------------------------
    % รูปที่ 1c: Voltage vs Applied Force (N)
    % -------------------------------------------------------------
    f1c = figure('Name', 'LoadCell_Voltage_vs_Force', 'Color', 'w', 'Position', [140, 120, 850, 600]);
    hold on; grid on; box on;
    errorbar(r.force, r.voltage_mean, r.voltage_sd, '-^', ...
        'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0.4660 0.6740 0.1880], ...
        'CapSize', 8, 'DisplayName', 'Output Voltage vs Force (Mean \pm 1SD)');
    xlabel('Applied Force F = m\cdot g (N)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Lab 1.4 Load Cell: Output Voltage vs Applied Force', ...
           'Direct Force Calibration Characteristics (0 - 100 N Range)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 2.0]);
    xlim([0, 105]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1c, fullfile(saveDir, 'Fig1c_LoadCell_Voltage_vs_Force.png'));
    figHandles(end+1) = f1c;

    % -------------------------------------------------------------
    % รูปที่ 1d: Individual Trials Comparison (การวัดซ้ำ 3 รอบ: Trial 1, 2, 3)
    % -------------------------------------------------------------
    f1d = figure('Name', 'LoadCell_Individual_Trials', 'Color', 'w', 'Position', [160, 130, 850, 600]);
    hold on; grid on; box on;
    trialColors = {[0.65 0.65 0.65], [0.45 0.45 0.45], [0.25 0.25 0.25]};
    trialStyles = {':', '--', '-.'};
    for tr = 1:3
        validM = ~isnan(r.trial_voltages(:, tr));
        if any(validM)
            plot(r.mass(validM), r.trial_voltages(validM, tr), trialStyles{tr}, ...
                'Color', trialColors{tr}, 'LineWidth', 1.4, ...
                'DisplayName', sprintf('Trial %d', tr));
        end
    end
    plot(r.mass, r.voltage_mean, '-o', ...
        'Color', accentColor, 'LineWidth', 2.2, ...
        'MarkerSize', 8, 'MarkerFaceColor', accentColor, ...
        'DisplayName', 'Overall Mean (3 Trials)');
    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Load Cell Repeatability: Individual Experimental Trials (3 Trials) vs Mean', ...
           'High Reproducibility Across 3 Repeated Measurement Runs'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 2.0]);
    xlim([0, 11]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1d, fullfile(saveDir, 'Fig1d_LoadCell_Individual_Trials.png'));
    figHandles(end+1) = f1d;

    % -------------------------------------------------------------
    % รูปที่ 1e: ADC Raw Digital Codes vs Mass
    % -------------------------------------------------------------
    f1e = figure('Name', 'LoadCell_ADC_vs_Mass', 'Color', 'w', 'Position', [180, 140, 850, 600]);
    hold on; grid on; box on;
    errorbar(r.mass, r.adc_mean, r.adc_sd, '-d', ...
        'Color', [0.4940 0.1840 0.5560], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0.4940 0.1840 0.5560], ...
        'CapSize', 8, 'DisplayName', 'STM32 ADC Code (12-bit: 0-4095)');
    yline(4095, 'r--', 'ADC Full Scale (4095)', 'LineWidth', 1.2, 'FontSize', 10);
    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('ADC Quantized Output Code (Counts)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Load Cell Digital Acquisition: STM32 ADC Counts vs Mass', ...
           '12-Bit Quantization (3.3V / 4096 = 0.806 mV / LSB)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 4200]);
    xlim([0, 11]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1e, fullfile(saveDir, 'Fig1e_LoadCell_ADC_vs_Mass.png'));
    figHandles(end+1) = f1e;

    fprintf('สร้างกราฟหมวด Calibration สำเร็จทั้ง 5 รูป บันทึกไว้ที่: %s\n', saveDir);
end
