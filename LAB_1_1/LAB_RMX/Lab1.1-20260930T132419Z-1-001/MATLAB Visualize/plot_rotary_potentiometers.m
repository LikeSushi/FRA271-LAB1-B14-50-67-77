function figHandles = plot_rotary_potentiometers(dataDir, saveDir)
% PLOT_ROTARY_POTENTIOMETERS สร้างกราฟวิเคราะห์สำหรับ Rotary Potentiometers (RAW1, RAW2, RAW3)
%
% ครอบคลุม:
%   1. กราฟ Calibration & Characteristic Curve (Voltage vs Angle พร้อม Error Bars)
%   2. กราฟเปรียบเทียบ Taper Characteristics (% Full Scale vs % Rotation)
%   3. กราฟวิเคราะห์ความไว (Sensitivity S = dV/dtheta ในหน่วย mV/degree)
%   4. กราฟวิเคราะห์ความเป็นเชิงเส้น (Linearity Analysis & Linearity Error %FS)
%
% Inputs:
%   dataDir - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.1')
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ (เช่น './output_figures')
%
% ผู้พัฒนา: Antigravity AI Pair Programmer

    if nargin < 1 || isempty(dataDir)
        dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'Lab1.1');
    end
    if nargin < 2 || isempty(saveDir)
        saveDir = fullfile(fileparts(mfilename('fullpath')), 'output_figures');
    end
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    % ประมวลผลข้อมูล RAW1, RAW2, RAW3
    fprintf('กำลังประมวลผลข้อมูล Rotary Potentiometers (RAW1, RAW2, RAW3)...\n');
    r1 = process_static_data(dataDir, 'RAW1', 'rotary');
    r2 = process_static_data(dataDir, 'RAW2', 'rotary');
    r3 = process_static_data(dataDir, 'RAW3', 'rotary');

    sensors = {r1, r2, r3};
    names   = {'RAW1', 'RAW2', 'RAW3'};
    colors  = {[0.8500 0.3250 0.0980], [0 0.4470 0.7410], [0.4660 0.6740 0.1880]};
    markers = {'o', 's', '^'};

    % ตรวจสอบชนิด Taper จากความชัน / รูปทรงของกราฟ
    % Type B (Linear) จะมีค่า R^2 สูงที่สุดเมื่อฟิตด้วยสมการเส้นตรง
    r2_scores = zeros(1, 3);
    for k = 1:3
        validIdx = ~isnan(sensors{k}.voltage);
        if sum(validIdx) >= 2
            p = polyfit(sensors{k}.x(validIdx), sensors{k}.voltage(validIdx), 1);
            yfit = polyval(p, sensors{k}.x(validIdx));
            ss_tot = sum((sensors{k}.voltage(validIdx) - mean(sensors{k}.voltage(validIdx))).^2);
            ss_res = sum((sensors{k}.voltage(validIdx) - yfit).^2);
            r2_scores(k) = 1 - (ss_res / ss_tot);
        end
    end
    [~, linearIdx] = max(r2_scores);

    figHandles = [];

    % -------------------------------------------------------------
    % รูปที่ 1: Characteristic Curves (Voltage vs Angle) พร้อม Error Bar
    % -------------------------------------------------------------
    f1 = figure('Name', 'Rotary_Characteristics', 'Color', 'w', 'Position', [100, 100, 850, 600]);
    hold on; grid on; box on;
    for k = 1:3
        errorbar(sensors{k}.x, sensors{k}.voltage, sensors{k}.voltage_sd, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
            'CapSize', 8, 'DisplayName', sprintf('%s (Mean \\pm 1SD)', names{k}));
    end
    xlabel('Rotation Angle \theta (degrees)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Rotary Potentiometers: Output Voltage vs Rotation Angle', ...
           'Comparison of RAW1, RAW2, and RAW3 across 0^\circ - 100^\circ'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 3.5]);
    xlim([-2, 102]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1, fullfile(saveDir, 'Fig1_Rotary_Voltage_vs_Angle.png'));
    figHandles(end+1) = f1;

    % -------------------------------------------------------------
    % รูปที่ 1b: Characteristic Curves (Voltage vs Angle) แบบไม่มี Error Bar (Legend ขวาบน)
    % -------------------------------------------------------------
    f1b = figure('Name', 'Rotary_Characteristics_No_Errorbar', 'Color', 'w', 'Position', [120, 110, 850, 600]);
    hold on; grid on; box on;
    for k = 1:3
        plot(sensors{k}.x, sensors{k}.voltage, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', names{k});
    end
    xlabel('Rotation Angle \theta (degrees)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Rotary Potentiometers: Output Voltage vs Rotation Angle', ...
           'Comparison of RAW1, RAW2, and RAW3 across 0^\circ - 100^\circ'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11);
    ylim([0, 3.5]);
    xlim([-2, 102]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1b, fullfile(saveDir, 'Fig1b_Rotary_Voltage_vs_Angle_No_Errorbar.png'));
    figHandles(end+1) = f1b;

    % -------------------------------------------------------------
    % รูปที่ 1c: กราฟแยกเดี่ยว 3 รูป สำหรับ RAW1, RAW2, RAW3
    % -------------------------------------------------------------
    taper_types_rotary = {'Type A (Audio Log)', 'Type B (Linear)', 'Type C (Reverse Audio)'};
    for k = 1:3
        f_ind = figure('Name', sprintf('Rotary_%s_Characteristics', names{k}), ...
                       'Color', 'w', 'Position', [130 + k*30, 110 + k*20, 850, 600]);
        hold on; grid on; box on;
        
        if sensors{k}.is_adc
            trials_v = (sensors{k}.trial_vals ./ 4095) * 3.3;
        else
            trials_v = sensors{k}.trial_vals;
        end
        
        plot(sensors{k}.x, trials_v(:, 1), ':', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.2, 'DisplayName', 'Trial 1');
        plot(sensors{k}.x, trials_v(:, 2), '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.2, 'DisplayName', 'Trial 2');
        plot(sensors{k}.x, trials_v(:, 3), '-.', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.2, 'DisplayName', 'Trial 3');
        
        plot(sensors{k}.x, sensors{k}.voltage, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 2.2, ...
            'MarkerSize', 8, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('%s (Mean)', names{k}));
            
        p_cur = polyfit(sensors{k}.x, sensors{k}.voltage, 1);
        yfit_cur = polyval(p_cur, sensors{k}.x);
        r2_cur = r2_scores(k);

        if k == linearIdx
            % พล็อตเส้นฟิตตรงสำหรับเซนเซอร์ Linear
            plot(sensors{k}.x, yfit_cur, 'r--', 'LineWidth', 1.8, ...
                'DisplayName', sprintf('Linear Fit: V_{out} = %.4f\\theta + %.4f', p_cur(1), p_cur(2)));
            
            % กล่องข้อความแสดงสมการเส้นตรงและ R^2
            text(0.05, 0.22, ...
                {'\bfLinear Model Equation:', ...
                 sprintf('\\rmV_{out}(\\theta) = %.4f\\cdot\\theta + %.4f (V)', p_cur(1), p_cur(2)), ...
                 sprintf('R^2 = %.4f (Linearity: %.2f%%)', r2_cur, r2_cur*100)}, ...
                'Units', 'normalized', 'FontSize', 11, ...
                'BackgroundColor', [1 1 1 0.92], 'EdgeColor', [0.85 0.2 0.2], 'LineWidth', 1.3);
        else
            % กล่องข้อความระบุ R^2 และ Taper Type
            text(0.05, 0.22, ...
                {sprintf('\\bf%s', taper_types_rotary{k}), ...
                 sprintf('\\rmLinear Fit R^2 = %.4f', r2_cur)}, ...
                'Units', 'normalized', 'FontSize', 11, ...
                'BackgroundColor', [1 1 1 0.92], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0);
        end

        xlabel('Rotation Angle \theta (degrees)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
        title(sprintf('%s Potentiometer: Output Voltage vs Rotation Angle', names{k}), ...
               'FontSize', 13, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 10);
        ylim([0, 3.5]);
        xlim([-2, 102]);
        set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
        saveas(f_ind, fullfile(saveDir, sprintf('Fig1c_%s_Voltage_vs_Angle.png', names{k})));
        figHandles(end+1) = f_ind;
    end

    % -------------------------------------------------------------
    % รูปที่ 1d: กราฟรวม 3 Subplots (1x3 Grid) สำหรับ RAW1, RAW2, RAW3
    % -------------------------------------------------------------
    f_sub = figure('Name', 'Rotary_3Subplots', 'Color', 'w', 'Position', [100, 100, 1280, 480]);
    for k = 1:3
        subplot(1, 3, k);
        hold on; grid on; box on;
        plot(sensors{k}.x, sensors{k}.voltage, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 2.0, ...
            'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('%s Data', names{k}));
            
        p_cur = polyfit(sensors{k}.x, sensors{k}.voltage, 1);
        yfit_cur = polyval(p_cur, sensors{k}.x);
        
        if k == linearIdx
            plot(sensors{k}.x, yfit_cur, 'r--', 'LineWidth', 1.6, ...
                'DisplayName', sprintf('Fit: y=%.3fx+%.3f', p_cur(1), p_cur(2)));
            title({sprintf('%s [%s]', names{k}, taper_types_rotary{k}), ...
                   sprintf('\\color{red}V_{out} = %.4f\\theta + %.4f (R^2 = %.4f)', p_cur(1), p_cur(2), r2_scores(k))}, ...
                   'FontSize', 11, 'FontWeight', 'bold');
        else
            title({sprintf('%s [%s]', names{k}, taper_types_rotary{k}), ...
                   sprintf('Linear Fit R^2 = %.4f', r2_scores(k))}, ...
                   'FontSize', 11, 'FontWeight', 'bold');
        end
        xlabel('Angle \theta (degrees)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Voltage V_{out} (V)', 'FontSize', 10, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 9);
        ylim([0, 3.5]);
        xlim([-2, 102]);
        set(gca, 'FontSize', 10, 'LineWidth', 1.1);
    end
    sgtitle('Rotary Potentiometers: Characteristics with R^2 & Linear Model Equations', ...
            'FontSize', 13, 'FontWeight', 'bold');
    saveas(f_sub, fullfile(saveDir, 'Fig1d_Rotary_3Subplots.png'));
    figHandles(end+1) = f_sub;

    % -------------------------------------------------------------
    % รูปที่ 2: Normalized Taper Curves (% Full Scale vs % Rotation)
    % -------------------------------------------------------------
    f2 = figure('Name', 'Rotary_Taper_Curves', 'Color', 'w', 'Position', [150, 120, 850, 600]);
    hold on; grid on; box on;
    for k = 1:3
        v = sensors{k}.voltage;
        v_norm = (v - nanmin(v)) / (nanmax(v) - nanmin(v)) * 100;
        x_norm = sensors{k}.x / max(sensors{k}.x) * 100;
        plot(x_norm, v_norm, ['-', markers{k}], 'Color', colors{k}, ...
            'LineWidth', 2.0, 'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('%s (Norm)', names{k}));
    end
    % เส้นตรงอุดมคติ (Ideal Linear Reference)
    plot([0, 100], [0, 100], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear (100%)');
    xlabel('Rotation Travel (% of 100^\circ)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Normalized Output (% Full Scale)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Potentiometer Resistance Taper Curves', ...
           'Comparison with Standard Taper Profiles (Audio Log, Linear, Reverse Log)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    xlim([0, 100]); ylim([0, 105]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f2, fullfile(saveDir, 'Fig2_Rotary_Taper_Curves.png'));
    figHandles(end+1) = f2;

    % -------------------------------------------------------------
    % รูปที่ 3: Sensitivity Analysis (S = dV/dtheta in mV/deg)
    % -------------------------------------------------------------
    f3 = figure('Name', 'Rotary_Sensitivity', 'Color', 'w', 'Position', [200, 140, 850, 600]);
    hold on; grid on; box on;
    for k = 1:3
        x = sensors{k}.x;
        v = sensors{k}.voltage;
        % คำนวณอนุพันธ์ความไว dV/dtheta
        dx = diff(x);
        dv = diff(v);
        sens = (dv ./ dx) * 1000; % แปลงเป็น mV/degree
        x_mid = x(1:end-1) + dx/2;
        plot(x_mid, sens, ['-o'], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 6, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('Sensitivity: %s', names{k}));
    end
    xlabel('Angle Interval Midpoint \theta (degrees)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensitivity S = \Delta V / \Delta\theta (mV / degree)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Rotary Potentiometers: Local Sensitivity across Angular Range', ...
           'Evaluation of Linearity and Rate of Voltage Change'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 11);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f3, fullfile(saveDir, 'Fig3_Rotary_Sensitivity.png'));
    figHandles(end+1) = f3;

    % -------------------------------------------------------------
    % รูปที่ 4: Linearity Analysis & Error Plot สำหรับตัวที่เป็น Linear
    % -------------------------------------------------------------
    f4 = figure('Name', 'Rotary_Linearity_Analysis', 'Color', 'w', 'Position', [250, 160, 950, 500]);
    linObj = sensors{linearIdx};
    linName = names{linearIdx};

    validIdx = ~isnan(linObj.voltage);
    x_val = linObj.x(validIdx);
    y_val = linObj.voltage(validIdx);
    p_fit = polyfit(x_val, y_val, 1);
    y_fit = polyval(p_fit, x_val);
    residuals = (y_val - y_fit);
    fs_range = max(y_val) - min(y_val);
    linearity_err_pct = (residuals / fs_range) * 100;
    max_lin_err = max(abs(linearity_err_pct));

    % Subplot 1: Linear Fit
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot(x_val, y_val, 'bo', 'MarkerSize', 7, 'MarkerFaceColor', 'b', 'DisplayName', 'Measured Data');
    plot(x_val, y_fit, 'r-', 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Linear Fit: y = %.4fx + %.3f\n(R^2 = %.4f)', p_fit(1), p_fit(2), r2_scores(linearIdx)));
    xlabel('Angle \theta (degrees)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Linear Regression: %s', linName), 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Residual Error %FS
    subplot(1, 2, 2);
    hold on; grid on; box on;
    stem(x_val, linearity_err_pct, 'filled', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5, ...
        'DisplayName', 'Linearity Error');
    yline(0, 'k--', 'LineWidth', 1.2);
    yline(max_lin_err, 'r:', sprintf('Max +%.2f%%', max_lin_err), 'LineWidth', 1.2);
    yline(-max_lin_err, 'r:', sprintf('Max -%.2f%%', max_lin_err), 'LineWidth', 1.2);
    xlabel('Angle \theta (degrees)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Linearity Error (% Full Scale)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Residual Linearity Error (Max = %.2f%% FS)', max_lin_err), 'FontSize', 12, 'FontWeight', 'bold');
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    saveas(f4, fullfile(saveDir, 'Fig4_Rotary_Linearity_Error.png'));
    figHandles(end+1) = f4;

    fprintf('สร้างกราฟ Rotary Potentiometers สำเร็จทั้ง 5 รูป บันทึกไว้ที่: %s\n', saveDir);
end
