function figHandles = plot_linear_potentiometers(dataDir, saveDir)
% PLOT_LINEAR_POTENTIOMETERS สร้างกราฟวิเคราะห์สำหรับ Linear Slide Potentiometers (RAW4, RAW5)
%
% ครอบคลุม:
%   1. กราฟ Calibration & Characteristic Curve (Voltage vs Distance พร้อม Error Bars)
%   2. กราฟเปรียบเทียบ Taper Characteristics (% Full Scale vs % Stroke)
%   3. กราฟวิเคราะห์ความไว (Sensitivity S = dV/dd ในหน่วย V/cm และ mV/mm)
%   4. กราฟสมการการสอบเทียบตำแหน่ง (Calibration Line d = f(V)) และ Linearity Error (%FS)
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

    % ประมวลผลข้อมูล RAW4, RAW5
    fprintf('กำลังประมวลผลข้อมูล Linear Potentiometers (RAW4, RAW5)...\n');
    r4 = process_static_data(dataDir, 'RAW4', 'linear');
    r5 = process_static_data(dataDir, 'RAW5', 'linear');

    sensors = {r4, r5};
    names   = {'RAW4', 'RAW5'};
    colors  = {[0.4940 0.1840 0.5560], [0.9290 0.6940 0.1250]};
    markers = {'d', 'p'};

    % ประเมินหาตัวที่เป็น Linear (Type B)
    r2_scores = zeros(1, 2);
    for k = 1:2
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
    % รูปที่ 5: Characteristic Curves (Voltage vs Distance in cm)
    % -------------------------------------------------------------
    f1 = figure('Name', 'Linear_Characteristics', 'Color', 'w', 'Position', [120, 100, 850, 600]);
    hold on; grid on; box on;
    for k = 1:2
        errorbar(sensors{k}.x, sensors{k}.voltage, sensors{k}.voltage_sd, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 8, 'MarkerFaceColor', colors{k}, ...
            'CapSize', 8, 'DisplayName', sprintf('%s (Mean \\pm 1SD)', names{k}));
    end
    xlabel('Displacement Distance d (cm)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Linear Slide Potentiometers: Output Voltage vs Displacement', ...
           'Comparison of RAW4 and RAW5 across 0.0 - 6.0 cm Travel Range'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    ylim([0, 3.5]);
    xlim([-0.2, 6.2]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1, fullfile(saveDir, 'Fig5_Linear_Voltage_vs_Distance.png'));
    figHandles(end+1) = f1;

    % -------------------------------------------------------------
    % รูปที่ 5b: Characteristic Curves (Voltage vs Distance) แบบไม่มี Error Bar (Legend ขวาบน)
    % -------------------------------------------------------------
    f1b = figure('Name', 'Linear_Characteristics_No_Errorbar', 'Color', 'w', 'Position', [140, 110, 850, 600]);
    hold on; grid on; box on;
    for k = 1:2
        plot(sensors{k}.x, sensors{k}.voltage, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 8, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', names{k});
    end
    xlabel('Displacement Distance d (cm)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Linear Slide Potentiometers: Output Voltage vs Displacement', ...
           'Comparison of RAW4 and RAW5 across 0.0 - 6.0 cm Travel Range'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 11);
    ylim([0, 3.5]);
    xlim([-0.2, 6.2]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f1b, fullfile(saveDir, 'Fig5b_Linear_Voltage_vs_Distance_No_Errorbar.png'));
    figHandles(end+1) = f1b;

    % -------------------------------------------------------------
    % รูปที่ 5c: กราฟแยกเดี่ยว 2 รูป สำหรับ RAW4 และ RAW5
    % -------------------------------------------------------------
    taper_types_linear = {'Type A (Audio Log)', 'Type B (Linear)'};
    for k = 1:2
        f_ind = figure('Name', sprintf('Linear_%s_Characteristics', names{k}), ...
                       'Color', 'w', 'Position', [140 + k*30, 110 + k*20, 850, 600]);
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
            % สำหรับตัวที่เป็น Linear ให้พล็อตเส้น Linear Fit สีแดงประ
            plot(sensors{k}.x, yfit_cur, 'r--', 'LineWidth', 1.8, ...
                'DisplayName', sprintf('Linear Fit: V_{out} = %.4fd + %.4f', p_cur(1), p_cur(2)));
            
            % กล่องข้อความแสดงสมการเส้นตรงและ R^2
            text(0.05, 0.22, ...
                {'\bfLinear Model Equation:', ...
                 sprintf('\\rmV_{out}(d) = %.4f\\cdot d + %.4f (V)', p_cur(1), p_cur(2)), ...
                 sprintf('R^2 = %.4f (Linearity: %.2f%%)', r2_cur, r2_cur*100)}, ...
                'Units', 'normalized', 'FontSize', 11, ...
                'BackgroundColor', [1 1 1 0.92], 'EdgeColor', [0.85 0.2 0.2], 'LineWidth', 1.3);
        else
            % กล่องข้อความระบุ R^2 และ Taper Type
            text(0.05, 0.22, ...
                {sprintf('\\bf%s', taper_types_linear{k}), ...
                 sprintf('\\rmLinear Fit R^2 = %.4f', r2_cur)}, ...
                'Units', 'normalized', 'FontSize', 11, ...
                'BackgroundColor', [1 1 1 0.92], 'EdgeColor', [0.5 0.5 0.5], 'LineWidth', 1.0);
        end

        xlabel('Displacement Distance d (cm)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Output Voltage V_{out} (V)', 'FontSize', 12, 'FontWeight', 'bold');
        title(sprintf('%s Slide Potentiometer: Output Voltage vs Displacement', names{k}), ...
               'FontSize', 13, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 10);
        ylim([0, 3.5]);
        xlim([-0.2, 6.2]);
        set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
        saveas(f_ind, fullfile(saveDir, sprintf('Fig5c_%s_Voltage_vs_Distance.png', names{k})));
        figHandles(end+1) = f_ind;
    end

    % -------------------------------------------------------------
    % รูปที่ 5d: กราฟรวม 2 Subplots (1x2 Grid) สำหรับ RAW4 และ RAW5
    % -------------------------------------------------------------
    f_sub = figure('Name', 'Linear_2Subplots', 'Color', 'w', 'Position', [100, 100, 950, 480]);
    for k = 1:2
        subplot(1, 2, k);
        hold on; grid on; box on;
        plot(sensors{k}.x, sensors{k}.voltage, ...
            ['-', markers{k}], 'Color', colors{k}, 'LineWidth', 2.0, ...
            'MarkerSize', 8, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('%s Data', names{k}));
            
        p_cur = polyfit(sensors{k}.x, sensors{k}.voltage, 1);
        yfit_cur = polyval(p_cur, sensors{k}.x);
        
        if k == linearIdx
            plot(sensors{k}.x, yfit_cur, 'r--', 'LineWidth', 1.6, ...
                'DisplayName', sprintf('Fit: y=%.3fx+%.3f', p_cur(1), p_cur(2)));
            title({sprintf('%s [%s]', names{k}, taper_types_linear{k}), ...
                   sprintf('\\color{red}V_{out} = %.4fd + %.4f (R^2 = %.4f)', p_cur(1), p_cur(2), r2_scores(k))}, ...
                   'FontSize', 11, 'FontWeight', 'bold');
        else
            title({sprintf('%s [%s]', names{k}, taper_types_linear{k}), ...
                   sprintf('Linear Fit R^2 = %.4f', r2_scores(k))}, ...
                   'FontSize', 11, 'FontWeight', 'bold');
        end
        xlabel('Displacement d (cm)', 'FontSize', 10, 'FontWeight', 'bold');
        ylabel('Voltage V_{out} (V)', 'FontSize', 10, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 9);
        ylim([0, 3.5]);
        xlim([-0.2, 6.2]);
        set(gca, 'FontSize', 10, 'LineWidth', 1.1);
    end
    sgtitle('Linear Slide Potentiometers: Characteristics with R^2 & Linear Model Equations', ...
            'FontSize', 13, 'FontWeight', 'bold');
    saveas(f_sub, fullfile(saveDir, 'Fig5d_Linear_2Subplots.png'));
    figHandles(end+1) = f_sub;

    % -------------------------------------------------------------
    % รูปที่ 6: Normalized Taper Curves (% Full Scale vs % Stroke)
    % -------------------------------------------------------------
    f2 = figure('Name', 'Linear_Taper_Curves', 'Color', 'w', 'Position', [170, 120, 850, 600]);
    hold on; grid on; box on;
    for k = 1:2
        v = sensors{k}.voltage;
        v_norm = (v - nanmin(v)) / (nanmax(v) - nanmin(v)) * 100;
        x_norm = sensors{k}.x / max(sensors{k}.x) * 100;
        plot(x_norm, v_norm, ['-', markers{k}], 'Color', colors{k}, ...
            'LineWidth', 2.0, 'MarkerSize', 8, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('%s Normalized', names{k}));
    end
    plot([0, 100], [0, 100], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Reference');
    xlabel('Slide Travel Stroke (% of 6.0 cm)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Normalized Output (% Full Scale)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Slide Potentiometer Resistance Taper Curves', ...
           'Bourns PTA6043 Series Taper Comparison (Linear vs Audio Log)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    xlim([0, 100]); ylim([0, 105]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f2, fullfile(saveDir, 'Fig6_Linear_Taper_Curves.png'));
    figHandles(end+1) = f2;

    % -------------------------------------------------------------
    % รูปที่ 7: Sensitivity Analysis (S = dV/dd in V/cm)
    % -------------------------------------------------------------
    f3 = figure('Name', 'Linear_Sensitivity', 'Color', 'w', 'Position', [220, 140, 850, 600]);
    hold on; grid on; box on;
    for k = 1:2
        x = sensors{k}.x;
        v = sensors{k}.voltage;
        dx = diff(x);
        dv = diff(v);
        sens = dv ./ dx; % V/cm
        x_mid = x(1:end-1) + dx/2;
        plot(x_mid, sens, ['-o'], 'Color', colors{k}, 'LineWidth', 1.8, ...
            'MarkerSize', 7, 'MarkerFaceColor', colors{k}, ...
            'DisplayName', sprintf('Sensitivity: %s', names{k}));
    end
    xlabel('Displacement Interval Midpoint d (cm)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensitivity S = \\Delta V / \\Delta d (V / cm)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Linear Slide Potentiometers: Local Sensitivity across Stroke', ...
           'Comparison of Incremental Gain S(d) = dV/dd'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 11);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f3, fullfile(saveDir, 'Fig7_Linear_Sensitivity.png'));
    figHandles(end+1) = f3;

    % -------------------------------------------------------------
    % รูปที่ 8: Calibration Line & Linearity Residual Error (%FS)
    % -------------------------------------------------------------
    f4 = figure('Name', 'Linear_Calibration_Error', 'Color', 'w', 'Position', [270, 160, 950, 500]);
    linObj = sensors{linearIdx};
    linName = names{linearIdx};

    validIdx = ~isnan(linObj.voltage);
    x_val = linObj.x(validIdx);
    v_val = linObj.voltage(validIdx);

    % สอบเทียบหาตำแหน่งจากแรงดัน: d = m*V + c
    p_calib = polyfit(v_val, x_val, 1);
    d_est = polyval(p_calib, v_val);
    pos_err = d_est - x_val; % cm
    pos_err_pct = (pos_err / max(x_val)) * 100;
    max_calib_err = max(abs(pos_err_pct));

    % Subplot 1: Sensor Calibration Equation d = f(V)
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot(v_val, x_val, 'md', 'MarkerSize', 8, 'MarkerFaceColor', 'm', 'DisplayName', 'Calibration Points');
    plot(v_val, d_est, 'k-', 'LineWidth', 1.8, ...
        'DisplayName', sprintf('Inverse Fit: d = %.3fV + %.3f\n(R^2 = %.4f)', p_calib(1), p_calib(2), r2_scores(linearIdx)));
    xlabel('Output Voltage V_{out} (V)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Position Displacement d (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Position Calibration Model (%s)', linName), 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Calibration Error (%FS)
    subplot(1, 2, 2);
    hold on; grid on; box on;
    stem(x_val, pos_err_pct, 'filled', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5, ...
        'DisplayName', 'Position Error (%FS)');
    yline(0, 'k--', 'LineWidth', 1.2);
    yline(max_calib_err, 'r:', sprintf('Max +%.2f%%', max_calib_err), 'LineWidth', 1.2);
    yline(-max_calib_err, 'r:', sprintf('Max -%.2f%%', max_calib_err), 'LineWidth', 1.2);
    xlabel('True Position d (cm)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Position Error (% Full Scale)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Calibration Linearity Error (Max = %.2f%% FS)', max_calib_err), 'FontSize', 12, 'FontWeight', 'bold');
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    saveas(f4, fullfile(saveDir, 'Fig8_Linear_Calibration_Error.png'));
    figHandles(end+1) = f4;

    fprintf('สร้างกราฟ Linear Potentiometers สำเร็จทั้ง 5 รูป บันทึกไว้ที่: %s\n', saveDir);
end
