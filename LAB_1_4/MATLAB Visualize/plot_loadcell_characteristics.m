function figHandles = plot_loadcell_characteristics(dataDir, saveDir)
% PLOT_LOADCELL_CHARACTERISTICS วิเคราะห์และสร้างกราฟคุณลักษณะเชิงลึกของโหลดเซลล์
% (Lab 1.4: Load Cell Sensitivity, Linearity, and Calibration Models)
%
% ครอบคลุม:
%   1. Fig2_LoadCell_Normalized_Transfer_Curve.png   - กราฟ Normalized Transfer Curve (%FS vs %Load) เทียบเส้นอุดมคติ
%   2. Fig3_LoadCell_Sensitivity.png                 - กราฟวิเคราะห์ความไวแบบช่วง (Local Sensitivity S = \Delta V / \Delta m และ \Delta V / \Delta F)
%   3. Fig4_LoadCell_Linearity_Error.png             - กราฟฟิตสมการเชิงเส้นตรง V = f(m) และ Linearity Error (%FS)
%   4. Fig5_LoadCell_Inverse_Calibration_Model.png   - โมเดลการสอบเทียบแบบผกผัน m = f(V) สำหรับเขียนลงเฟิร์มแวร์ไมโครคอนโทรลเลอร์
%   5. Fig6_LoadCell_Polynomial_Fit_Comparison.png   - กราฟเปรียบเทียบ Linear Fit vs 2nd-Order Polynomial Fit เพื่อชดเชย Non-linearity
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

    fprintf('กำลังวิเคราะห์คุณลักษณะเชิงลึก (Sensitivity & Linearity Analysis)...\n');
    r = process_static_data(dataDir);

    m = r.mass;
    v = r.voltage_mean;
    F = r.force;
    figHandles = [];

    % -------------------------------------------------------------
    % รูปที่ 2: Normalized Transfer Curve (% Full Scale vs % Load)
    % -------------------------------------------------------------
    f2 = figure('Name', 'LoadCell_Normalized_Transfer_Curve', 'Color', 'w', 'Position', [150, 120, 850, 600]);
    hold on; grid on; box on;
    v_norm = (v - min(v)) / (max(v) - min(v)) * 100;
    m_norm = (m - min(m)) / (max(m) - min(m)) * 100;
    plot(m_norm, v_norm, '-o', 'Color', [0.8500 0.3250 0.0980], ...
        'LineWidth', 2.2, 'MarkerSize', 8, 'MarkerFaceColor', [0.8500 0.3250 0.0980], ...
        'DisplayName', 'Measured Normalized Transfer Curve');
    plot([0, 100], [0, 100], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Ideal Linear Reference (100% Linear)');
    xlabel('Applied Load (% of Tested Range)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Sensor Output (% Full Scale Range)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Normalized Transfer Characteristics of Strain Gauge Load Cell', ...
           'Comparison with Ideal Theoretical Linear Response'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 11);
    xlim([0, 100]); ylim([0, 105]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
    saveas(f2, fullfile(saveDir, 'Fig2_LoadCell_Normalized_Transfer_Curve.png'));
    figHandles(end+1) = f2;

    % -------------------------------------------------------------
    % รูปที่ 3: Incremental Sensitivity Analysis (S = dV/dm และ dV/dF)
    % -------------------------------------------------------------
    f3 = figure('Name', 'LoadCell_Sensitivity', 'Color', 'w', 'Position', [200, 140, 850, 600]);
    hold on; grid on; box on;
    dm = diff(m);
    dv = diff(v);
    sens_m = (dv ./ dm) * 1000; % mV/kg
    m_mid  = m(1:end-1) + dm/2;

    yyaxis left
    plot(m_mid, sens_m, '-o', 'Color', [0 0.4470 0.7410], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0 0.4470 0.7410], ...
        'DisplayName', 'Mass Sensitivity S_m (mV / kg)');
    ylabel('Mass Sensitivity S_m = \Delta V / \Delta m (mV / kg)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 250]);

    yyaxis right
    dF = diff(F);
    sens_F = (dv ./ dF) * 1000; % mV/N
    plot(m_mid, sens_F, '-^', 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0.4660 0.6740 0.1880], ...
        'DisplayName', 'Force Sensitivity S_F (mV / N)');
    ylabel('Force Sensitivity S_F = \Delta V / \Delta F (mV / N)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 25]);

    xlabel('Applied Mass Midpoint m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Load Cell Incremental Sensitivity across Load Span', ...
           'Evaluation of Local Transduction Gain S(m) and S(F)'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southwest', 'FontSize', 11);
    xlim([1, 10]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    saveas(f3, fullfile(saveDir, 'Fig3_LoadCell_Sensitivity.png'));
    figHandles(end+1) = f3;

    % -------------------------------------------------------------
    % รูปที่ 4: Linearity Analysis & Linearity Error (%FS)
    % -------------------------------------------------------------
    f4 = figure('Name', 'LoadCell_Linearity_Analysis', 'Color', 'w', 'Position', [250, 160, 950, 500]);
    
    % Linear Regression: V = p(1)*m + p(2)
    p_lin = polyfit(m, v, 1);
    v_fit = polyval(p_lin, m);
    ss_tot = sum((v - mean(v)).^2);
    ss_res = sum((v - v_fit).^2);
    r2_lin = 1 - (ss_res / ss_tot);

    fs_span = max(v) - min(v);
    lin_res = v - v_fit;
    lin_err_pct = (lin_res / fs_span) * 100;
    max_lin_err = max(abs(lin_err_pct));

    % Subplot 1: Linear Fit
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot(m, v, 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'DisplayName', 'Experimental Data');
    plot(m, v_fit, 'r-', 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Linear Fit: V = %.4f\\cdot m + %.4f\n(R^2 = %.5f, S = %.2f mV/kg)', ...
        p_lin(1), p_lin(2), r2_lin, p_lin(1)*1000));
    xlabel('Applied Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Output Voltage V_{out} (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Linear Regression Model V = f(m)', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, 11]); ylim([0, 2.0]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Linearity Residual Error (%FS)
    subplot(1, 2, 2);
    hold on; grid on; box on;
    stem(m, lin_err_pct, 'filled', 'Color', [0.85 0.33 0.1], 'LineWidth', 1.8, ...
        'MarkerSize', 7, 'DisplayName', 'Residual Linearity Error');
    yline(0, 'k--', 'LineWidth', 1.2);
    yline(max_lin_err, 'r:', sprintf('Max +%.2f%%', max_lin_err), 'LineWidth', 1.2);
    yline(-max_lin_err, 'r:', sprintf('Max -%.2f%%', max_lin_err), 'LineWidth', 1.2);
    xlabel('Applied Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Linearity Error (% Full Scale)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Residual Linearity Error (Max = \\pm%.2f%% FS)', max_lin_err), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, 11]);
    ylim([-max_lin_err*1.3, max_lin_err*1.3]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    saveas(f4, fullfile(saveDir, 'Fig4_LoadCell_Linearity_Error.png'));
    figHandles(end+1) = f4;

    % -------------------------------------------------------------
    % รูปที่ 5: Inverse Calibration Model m = f(V) สำหรับเขียนโปรแกรม
    % -------------------------------------------------------------
    f5 = figure('Name', 'LoadCell_Inverse_Calibration', 'Color', 'w', 'Position', [270, 170, 950, 500]);
    
    p_inv = polyfit(v, m, 1);
    m_est = polyval(p_inv, v);
    m_res_kg = m_est - m;
    m_res_pct = (m_res_kg / max(m)) * 100;
    max_calib_err = max(abs(m_res_pct));

    % Subplot 1: Inverse Function
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot(v, m, 'md', 'MarkerSize', 8, 'MarkerFaceColor', 'm', 'DisplayName', 'Measured Points');
    plot(v, m_est, 'k-', 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Inverse Equation:\nm = %.3f\\cdot V - %.3f\n(R^2 = %.5f)', ...
        p_inv(1), abs(p_inv(2)), r2_lin));
    xlabel('Output Voltage V_{out} (V)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Estimated Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Microcontroller Calibration Function m = f(V)', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, 2.0]); ylim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Calibration Residual Error (%FS & grams)
    subplot(1, 2, 2);
    hold on; grid on; box on;
    stem(m, m_res_pct, 'filled', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.8, ...
        'MarkerSize', 7, 'DisplayName', 'Calibration Error (%FS)');
    yline(0, 'k--', 'LineWidth', 1.2);
    yline(max_calib_err, 'r:', sprintf('Max +%.2f%%', max_calib_err), 'LineWidth', 1.2);
    yline(-max_calib_err, 'r:', sprintf('Max -%.2f%%', max_calib_err), 'LineWidth', 1.2);
    xlabel('True Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Estimation Error (% Full Scale)', 'FontSize', 11, 'FontWeight', 'bold');
    title(sprintf('Mass Estimation Residuals (Max = \\pm%.2f%% FS)', max_calib_err), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlim([0, 11]);
    ylim([-max_calib_err*1.3, max_calib_err*1.3]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    saveas(f5, fullfile(saveDir, 'Fig5_LoadCell_Inverse_Calibration_Model.png'));
    figHandles(end+1) = f5;

    % -------------------------------------------------------------
    % รูปที่ 6: Polynomial Fit (2nd-Order) vs Linear Fit Comparison
    % -------------------------------------------------------------
    f6 = figure('Name', 'LoadCell_Poly_Comparison', 'Color', 'w', 'Position', [290, 180, 950, 500]);
    
    % 2nd-Order Polynomial Fit: V = a*m^2 + b*m + c
    p_poly2 = polyfit(m, v, 2);
    m_dense = linspace(min(m), max(m), 200)';
    v_dense_lin = polyval(p_lin, m_dense);
    v_dense_poly2 = polyval(p_poly2, m_dense);

    v_fit_poly2 = polyval(p_poly2, m);
    ss_res_poly2 = sum((v - v_fit_poly2).^2);
    r2_poly2 = 1 - (ss_res_poly2 / ss_tot);
    lin_err_poly2 = ((v - v_fit_poly2) / fs_span) * 100;

    % Subplot 1: Model Comparison Curves
    subplot(1, 2, 1);
    hold on; grid on; box on;
    plot(m, v, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'y', 'DisplayName', 'Data Points');
    plot(m_dense, v_dense_lin, 'r--', 'LineWidth', 1.8, ...
        'DisplayName', sprintf('1st-Order (Linear): R^2 = %.5f', r2_lin));
    plot(m_dense, v_dense_poly2, 'b-', 'LineWidth', 2.0, ...
        'DisplayName', sprintf('2nd-Order (Poly): R^2 = %.5f', r2_poly2));
    xlabel('Applied Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Voltage V_{out} (V)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Model Comparison: Linear vs 2nd-Order Polynomial', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, 11]); ylim([0, 2.0]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Comparison of Residual Errors
    subplot(1, 2, 2);
    hold on; grid on; box on;
    bar_width = 0.35;
    b1 = bar(m - bar_width/2, lin_err_pct, bar_width, 'FaceColor', [0.85 0.33 0.1], 'DisplayName', 'Linear Error (%FS)');
    b2 = bar(m + bar_width/2, lin_err_poly2, bar_width, 'FaceColor', [0.0 0.5 0.8], 'DisplayName', '2nd-Order Poly Error (%FS)');
    yline(0, 'k-', 'LineWidth', 1.0);
    xlabel('Applied Mass m (kg)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Residual Error (% Full Scale)', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Non-Linearity Compensation Benefit', ...
           sprintf('Error reduced from %.2f%% to %.2f%% FS', max_lin_err, max(abs(lin_err_poly2)))}, ...
           'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 10);
    xlim([0, 11]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    saveas(f6, fullfile(saveDir, 'Fig6_LoadCell_Polynomial_Fit_Comparison.png'));
    figHandles(end+1) = f6;

    fprintf('สร้างกราฟหมวด Characteristics สำเร็จทั้ง 5 รูป บันทึกไว้ที่: %s\n', saveDir);
end
