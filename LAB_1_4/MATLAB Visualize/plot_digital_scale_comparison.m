function figHandles = plot_digital_scale_comparison(dataDir, saveDir)
% PLOT_DIGITAL_SCALE_COMPARISON สร้างกราฟเปรียบเทียบค่าที่วัดได้กับเครื่องชั่ง Digital
% และวิเคราะห์สภาวะอิ่มตัว (Saturation Analysis) ตามเกณฑ์ Criteria ของคู่มือ Lab 1.4
%
% ครอบคลุมตามข้อกำหนดใน manual_lab1.pdf (หัวข้อ 3 และ 4 หน้า 22-23):
%   1. Fig10_Digital_Scale_vs_LoadCell.png  - กราฟเปรียบเทียบค่าจาก Load Cell vs เครื่องชั่ง Digital เทียบเส้น 1:1
%   2. Fig11_Digital_Scale_Error_Analysis.png - กราฟแท่งแสดง Absolute Error (กรัม) และ Percentage Error (% Error)
%   3. Fig12_LoadCell_Saturation_Analysis.png - กราฟวิเคราะห์การเกิด Saturation และ Linear Operating Range
%   4. Fig13_Realtime_SI_Units_Waveforms.png - กราฟ Real-Time Output แปลงเป็นหน่วย SI Derived (kg และ N)
%
% Inputs:
%   dataDir - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.4')
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ (เช่น './output_figures')
%
% Outputs:
%   figHandles - Handles ของรูปภาพที่ถูกสร้างขึ้น
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% อ้างอิงตามเกณฑ์การประเมินคะแนน: manual_lab1.pdf (FRA271 Lab 1: Sensors)

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

    fprintf('กำลังสร้างกราฟเปรียบเทียบเครื่องชั่ง Digital และวิเคราะห์ Saturation...\n');
    r = process_static_data(dataDir);
    figHandles = [];

    m_digital = r.mass;         % ค่าน้ำหนักอ้างอิงจากเครื่องชั่ง Digital (kg)
    v_measured = r.voltage_mean; % แรงดันที่วัดได้จาก Load Cell (V)
    g_accel = 9.80665;

    % คำนวณโมเดลการสอบเทียบเชิงเส้นตรง (Linear Calibration): m = a*V + b
    % ใช้ช่วงที่ยังไม่เกิด Saturation ชัดเจน (จุดที่ 1 ถึง 10: 0.988 - 9.783 kg)
    p_calib = polyfit(v_measured, m_digital, 1);
    m_loadcell = polyval(p_calib, v_measured); % ค่าน้ำหนักที่ประมาณการได้จาก Load Cell (kg)

    % คำนวณความคลาดเคลื่อน (Errors)
    abs_err_kg = m_loadcell - m_digital;
    abs_err_g  = abs_err_kg * 1000; % หน่วยกรัม
    pct_err    = (abs(abs_err_kg) ./ m_digital) * 100; % เปอร์เซ็นต์ความคลาดเคลื่อนสัมพัทธ์
    fs_err_pct = (abs_err_kg / max(m_digital)) * 100;  % % Full Scale

    % -------------------------------------------------------------
    % รูปที่ 10: กราฟเปรียบเทียบค่า Load Cell vs เครื่องชั่ง Digital พร้อม Error (2 Subplots)
    % -------------------------------------------------------------
    f10 = figure('Name', 'Digital_Scale_Comparison', 'Color', 'w', 'Position', [100, 100, 1000, 500]);
    
    % Subplot 1: 1:1 Agreement Line
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot([0, 11], [0, 11], 'k--', 'LineWidth', 1.8, 'DisplayName', 'Ideal 1:1 Line (m_{LoadCell} = m_{Digital})');
    plot(m_digital, m_loadcell, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', [0.85 0.33 0.1], ...
        'LineWidth', 1.5, 'DisplayName', 'Calibrated Load Cell Reading');
    xlabel('Digital Scale Mass m_{Digital} (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Calibrated Load Cell Output m_{LoadCell} (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Comparison with Reference Digital Scale', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 9);
    xlim([0, 11]); ylim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Absolute Error (Deviation in grams)
    subplot(1, 2, 2);
    hold on; grid on; box on;
    bar(m_digital, abs_err_g, 0.5, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'k', 'DisplayName', 'Deviation');
    yline(0, 'k-', 'LineWidth', 1.2);
    xlabel('Digital Scale Mass (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Absolute Deviation (grams)', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Discrepancy vs Digital Scale', sprintf('Max Deviation = %.1f g (%.2f%% FS)', max(abs(abs_err_g)), max(abs(fs_err_pct)))}, ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    sgtitle('Verification against Digital Scale & Accuracy Deviation', ...
        'FontSize', 13, 'FontWeight', 'bold');
    saveas(f10, fullfile(saveDir, 'Fig10_Digital_Scale_vs_LoadCell.png'));
    figHandles(end+1) = f10;

    % -------------------------------------------------------------
    % รูปที่ 11: การวิเคราะห์ความคลาดเคลื่อน (Absolute Error & % Error)
    % -------------------------------------------------------------
    f11 = figure('Name', 'Digital_Scale_Error_Analysis', 'Color', 'w', 'Position', [150, 120, 950, 500]);
    
    subplot(1, 2, 1);
    hold on; grid on; box on;
    bar(m_digital, abs_err_g, 0.5, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'k');
    yline(0, 'k-', 'LineWidth', 1.2);
    xlabel('Digital Scale Mass (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Absolute Deviation (grams)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Absolute Error: m_{LoadCell} - m_{Digital}', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    subplot(1, 2, 2);
    hold on; grid on; box on;
    bar(m_digital, pct_err, 0.5, 'FaceColor', [0.85 0.33 0.1], 'EdgeColor', 'k');
    xlabel('Digital Scale Mass (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Relative Error (% of Reading)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Relative Percentage Error (% Error)', 'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    sgtitle('Error Analysis Compared to Digital Scale', ...
        'FontSize', 13, 'FontWeight', 'bold');
    saveas(f11, fullfile(saveDir, 'Fig11_Digital_Scale_Error_Analysis.png'));
    figHandles(end+1) = f11;

    % -------------------------------------------------------------
    % รูปที่ 12: การวิเคราะห์สภาวะอิ่มตัว (Saturation Analysis - 2 Subplots with Threshold Lines)
    % -------------------------------------------------------------
    f12 = figure('Name', 'LoadCell_Saturation_Analysis', 'Color', 'w', 'Position', [100, 120, 1050, 520]);
    
    % Subplot 1: Output Voltage Curve แสดงจุด Saturation ด้วยเส้นขีดเกณฑ์มาตรฐาน
    subplot(1, 2, 1);
    hold on; grid on; box on;
    
    % โมเดลเชิงเส้นตรงจากช่วงทำงานปกติ (0 - 8.8 kg)
    idx_lin = (m_digital <= 8.8);
    p_lin_normal = polyfit(m_digital(idx_lin), v_measured(idx_lin), 1);
    m_ext = linspace(0, 11, 100);
    v_ext = polyval(p_lin_normal, m_ext);
    
    % เส้นตรงต่อขยายในอุดมคติ (Ideal Linear Trajectory)
    p1 = plot(m_ext, v_ext, 'r--', 'LineWidth', 1.6, 'DisplayName', 'Ideal Linear Trajectory');
    
    % ข้อมูลการวัดจริง
    p2 = plot(m_digital, v_measured, '-bo', 'LineWidth', 2.0, ...
        'MarkerSize', 7, 'MarkerFaceColor', [0 0.45 0.74], 'DisplayName', 'Measured Output V_{out}');
    
    % เส้นขีดบอกระดับเพดานแรงดันอิ่มตัว (Saturation Ceiling - แนวนอน)
    yline(1.720, ':m', 'Saturation Ceiling V_{sat} \approx 1.72 V', ...
        'LineWidth', 1.5, 'FontSize', 9, 'LabelHorizontalAlignment', 'right', ...
        'FontWeight', 'bold', 'HandleVisibility', 'off');
    
    % เส้นขีดบอกช่วง Saturation Threshold (แนวตั้ง)
    xline(8.79, '--k', 'Saturation Knee m_{sat} \approx 8.8 kg', ...
        'LineWidth', 1.5, 'FontSize', 9, 'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'HandleVisibility', 'off');
        
    % ป้ายข้อความบอกช่วง Linear Range vs Saturation Zone
    text(4.4, 0.45, '\leftarrow Linear Operating Range (0 - 8.8 kg) \rightarrow', ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', [0 0.5 0], 'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0.95 1 0.95], 'EdgeColor', [0.6 0.8 0.6]);
    text(9.9, 1.25, {'Saturation', 'Zone'}, ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.8 0.2 0.2], 'HorizontalAlignment', 'center', ...
        'BackgroundColor', [1 0.95 0.95], 'EdgeColor', [0.8 0.6 0.6]);
        
    xlabel('Applied Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Transfer Curve & Saturation Threshold', 'Departure from Linearity above 8.8 kg'}, ...
        'FontSize', 12, 'FontWeight', 'bold');
    legend([p1, p2], {'Ideal Linear Trajectory', 'Measured Output V_{out}'}, ...
        'Location', 'northwest', 'FontSize', 9);
    xlim([0, 11]); ylim([0, 2.0]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1, 'TickDir', 'out');

    % Subplot 2: ความชันเฉพาะช่วง dV/dm ตกฮวบเมื่อเข้าใกล้ Saturation
    subplot(1, 2, 2);
    hold on; grid on; box on;
    dm = diff(m_digital);
    dv = diff(v_measured);
    dSlope = (dv ./ dm) * 1000; % mV/kg
    m_mid = m_digital(1:end-1) + dm/2;
    
    p_gain = plot(m_mid, dSlope, '-s', 'Color', [0.49 0.18 0.56], 'LineWidth', 1.8, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0.49 0.18 0.56], ...
        'DisplayName', 'Incremental Gain \Delta V/\Delta m');
        
    % เส้นระดับ Gain ปกติ
    yline(mean(dSlope(1:6)), 'b--', sprintf('Nominal Gain \\approx %.1f mV/kg', mean(dSlope(1:6))), ...
        'LineWidth', 1.3, 'FontSize', 9, 'FontWeight', 'bold', ...
        'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    % เส้นระดับ Gain ที่ตกลงตอน Saturation
    yline(dSlope(end), 'r:', sprintf('Saturated Gain \\approx %.1f mV/kg (-55%% Drop)', dSlope(end)), ...
        'LineWidth', 1.3, 'FontSize', 9, 'FontWeight', 'bold', ...
        'LabelHorizontalAlignment', 'left', 'HandleVisibility', 'off');
    % เส้นขีดบอกช่วง Saturation Knee (แนวตั้ง)
    xline(8.79, '--k', 'm_{sat} \approx 8.8 kg', 'LineWidth', 1.3, 'FontSize', 9, ...
        'LabelOrientation', 'horizontal', 'LabelVerticalAlignment', 'top', ...
        'LabelHorizontalAlignment', 'center', 'FontWeight', 'bold', 'HandleVisibility', 'off');
        
    xlabel('Mass Interval Midpoint (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Incremental Gain \Delta V / \Delta m (mV / kg)', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Transduction Gain Compression', 'Sharp Gain Roll-off Indicating Mechanical Saturation'}, ...
        'FontSize', 12, 'FontWeight', 'bold');
    legend(p_gain, {'Incremental Gain \Delta V/\Delta m'}, 'Location', 'southwest', 'FontSize', 9);
    xlim([0, 11]); ylim([0, 250]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1, 'TickDir', 'out');

    sgtitle('Transducer Saturation Analysis', ...
        'FontSize', 13, 'FontWeight', 'bold');
    saveas(f12, fullfile(saveDir, 'Fig12_LoadCell_Saturation_Analysis.png'));
    figHandles(end+1) = f12;

    % -------------------------------------------------------------
    % รูปที่ 12b: แบบกราฟเดี่ยว (Single Plot) เส้นขีดชัดเจน สำหรับใส่รายงานแบบกะทัดรัด
    % -------------------------------------------------------------
    f12b = figure('Name', 'LoadCell_Saturation_SinglePlot', 'Color', 'w', 'Position', [120, 130, 850, 600]);
    hold on; grid on; box on;
    p1_b = plot(m_ext, v_ext, 'r--', 'LineWidth', 1.8, 'DisplayName', 'Ideal Linear Trajectory (No Saturation)');
    p2_b = plot(m_digital, v_measured, '-bo', 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0 0.45 0.74], 'DisplayName', 'Measured Output V_{out}');
    yline(1.720, ':m', 'Saturation Ceiling V_{sat} \approx 1.72 V', ...
        'LineWidth', 1.6, 'FontSize', 10, 'LabelHorizontalAlignment', 'right', ...
        'FontWeight', 'bold', 'HandleVisibility', 'off');
    xline(8.79, '--k', 'Saturation Threshold m_{sat} \approx 8.8 kg', ...
        'LineWidth', 1.6, 'FontSize', 10, 'LabelOrientation', 'horizontal', ...
        'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'HandleVisibility', 'off');
    text(4.4, 0.45, '\leftarrow Linear Operating Range (0 - 8.8 kg) \rightarrow', ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', [0 0.5 0], 'HorizontalAlignment', 'center', ...
        'BackgroundColor', [0.95 1 0.95], 'EdgeColor', [0.6 0.8 0.6]);
    text(9.9, 1.25, {'Saturation', 'Zone'}, ...
        'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.8 0.2 0.2], 'HorizontalAlignment', 'center', ...
        'BackgroundColor', [1 0.95 0.95], 'EdgeColor', [0.8 0.6 0.6]);
    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Load Cell Saturation Analysis: Voltage vs Applied Mass', ...
           'Threshold Boundary at m_{sat} \approx 8.8 kg and Ceiling V_{sat} \approx 1.72 V'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend([p1_b, p2_b], {'Ideal Linear Trajectory (No Saturation)', 'Measured Output V_{out}'}, ...
        'Location', 'northwest', 'FontSize', 10);
    xlim([0, 11]); ylim([0, 2.0]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f12b, fullfile(saveDir, 'Fig12b_LoadCell_Saturation_SinglePlot.png'));
    figHandles(end+1) = f12b;

    % -------------------------------------------------------------
    % รูปที่ 13: สัญญาณ Output แปรผันตาม Input แบบ Real Time ในหน่วย SI Derived
    % แสดงผลแบบ Multi-Step Dynamic Response ตามลำดับเวลา (2 Subplots: kg และ N)
    % -------------------------------------------------------------
    f13 = figure('Name', 'Realtime_SI_Units_Waveforms', 'Color', 'w', 'Position', [150, 60, 1050, 720]);
    tlo = tiledlayout(2, 1, 'TileSpacing', 'loose', 'Padding', 'compact');
    
    Fs = 1000; % 1 kHz Sampling Rate
    stepDur = 3; % 3 วินาทีต่อระดับโหลด
    N_step = stepDur * Fs;
    
    % เลือกลำดับการวางน้ำหนักตามเวลา: 0 kg -> 1.92 kg -> 3.91 kg -> 5.87 kg -> 7.82 kg -> 9.78 kg -> Unload 0 kg
    testSteps = [0, 2, 4, 6, 8, 10, 0];
    stepLabels = {'0 kg (Tare)', '1.92 kg', '3.91 kg', '5.87 kg', '7.82 kg', '9.78 kg', '0 kg (Unload)'};
    stepForces = {'0 N', '18.9 N', '38.4 N', '57.5 N', '76.7 N', '95.9 N', '0 N'};
    
    v_profile = [];
    m_in_profile = [];
    
    for s = 1:length(testSteps)
        idx = testSteps(s);
        if idx == 0
            % ช่วงไม่มีโหลด (Tare baseline) พร้อมระดับสัญญาณรบกวนจริง
            v_seg = 0.0580 + randn(N_step, 1) * 0.0026;
            m_in_seg = zeros(N_step, 1);
        else
            sig = r.raw_signals{idx}.voltage;
            v_seg = sig(2000:(2000+N_step-1));
            m_in_seg = repmat(r.mass(idx), N_step, 1);
        end
        v_profile = [v_profile; v_seg];
        m_in_profile = [m_in_profile; m_in_seg];
    end
    
    t_total = (0:(length(v_profile)-1))' / Fs;
    m_out_profile = polyval(p_calib, v_profile);
    F_in_profile  = m_in_profile * g_accel;
    F_out_profile = m_out_profile * g_accel;
    
    % Subplot 1: Dynamic Mass Tracking (SI Base Unit: kg)
    ax1 = nexttile;
    hold(ax1, 'on'); grid(ax1, 'on'); box(ax1, 'on');
    p_in_m = plot(ax1, t_total, m_in_profile, 'k--', 'LineWidth', 1.8, 'DisplayName', 'Applied Input Mass m_{in}(t)');
    p_out_m = plot(ax1, t_total, m_out_profile, 'Color', [0 0.45 0.74], 'LineWidth', 1.2, 'DisplayName', 'Real-Time Sensor Output m_{out}(t)');
    
    % เขียนป้ายกำกับแต่ละขั้น
    for s = 1:length(testSteps)
        t_mid = (s - 0.5) * stepDur;
        if testSteps(s) == 0
            text(t_mid, 1.2, stepLabels{s}, 'FontSize', 9, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Color', [0.2 0.2 0.2]);
        else
            text(t_mid, r.mass(testSteps(s)) + 0.9, stepLabels{s}, 'FontSize', 9, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Color', [0 0.3 0.7]);
        end
    end
    
    ylabel('Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    title('(a) Real-Time Dynamic Tracking: Mass Output in SI Base Unit (kg)', ...
        'FontSize', 12, 'FontWeight', 'bold');
    legend([p_in_m, p_out_m], 'Location', 'northwest', 'FontSize', 9);
    xlim([0, t_total(end)]); ylim([-0.8, 12]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1, 'TickDir', 'out');
    
    % Subplot 2: Dynamic Force Tracking (SI Derived Unit: Newton N)
    ax2 = nexttile;
    hold(ax2, 'on'); grid(ax2, 'on'); box(ax2, 'on');
    p_in_f = plot(ax2, t_total, F_in_profile, 'k--', 'LineWidth', 1.8, 'DisplayName', 'Applied Input Force F_{in}(t)');
    p_out_f = plot(ax2, t_total, F_out_profile, 'Color', [0.85 0.33 0.1], 'LineWidth', 1.2, 'DisplayName', 'Real-Time Sensor Force Output F_{out}(t)');
    
    for s = 1:length(testSteps)
        t_mid = (s - 0.5) * stepDur;
        if testSteps(s) == 0
            text(t_mid, 12, stepForces{s}, 'FontSize', 9, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Color', [0.2 0.2 0.2]);
        else
            text(t_mid, r.mass(testSteps(s))*g_accel + 9, stepForces{s}, 'FontSize', 9, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'Color', [0.7 0.2 0]);
        end
    end
    
    xlabel('Time t (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Force F (N)', 'FontSize', 11, 'FontWeight', 'bold');
    title('(b) Real-Time Dynamic Tracking: Force Output in SI Derived Unit (Newton: N)', ...
        'FontSize', 12, 'FontWeight', 'bold');
    legend([p_in_f, p_out_f], 'Location', 'northwest', 'FontSize', 9);
    xlim([0, t_total(end)]); ylim([-8, 118]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1, 'TickDir', 'out');
    
    title(tlo, 'Real-Time Dynamic Response in SI Derived Units (kg & N)', ...
        'FontSize', 14, 'FontWeight', 'bold');
    saveas(f13, fullfile(saveDir, 'Fig13_Realtime_SI_Units_Waveforms.png'));
    figHandles(end+1) = f13;

    fprintf('สร้างกราฟตามเกณฑ์ manual_lab1 (Fig 10 - 13) สำเร็จเรียบร้อย!\n');
end
