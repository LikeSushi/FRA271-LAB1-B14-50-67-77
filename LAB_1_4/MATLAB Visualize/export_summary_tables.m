function export_summary_tables(dataDir, tableDir)
% EXPORT_SUMMARY_TABLES ส่งออกตารางสรุปผลการทดลอง Lab 1.4 เป็นไฟล์ CSV และ MAT
% พร้อมสำหรับนำไปวางในรายงานการทดลอง (Word / Excel / PDF) ได้ทันที
%
% ไฟล์ที่จะส่งออก:
%   1. Table_LoadCell_Summary.csv             - ค่าเฉลี่ย, SD, ค่าแยกแต่ละ Trial และ ADC ครบทุกจุดวัด
%   2. Table_LoadCell_Performance_Metrics.csv - ตารางตัวชี้วัดสมรรถนะเซนเซอร์ (Sensitivity, R^2, Linearity, Repeatability)
%   3. Table_LoadCell_Noise_Analysis.csv      - ตารางวิเคราะห์สัญญาณรบกวน (Noise RMS, V_pp, SNR, ENOB)
%   4. Lab1_4_Summary_Data.mat                - ไฟล์ข้อมูลรวมสำหรับเรียกใช้ใน MATLAB
%
% Inputs:
%   dataDir  - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.4')
%   tableDir - โฟลเดอร์สำหรับบันทึกไฟล์ตาราง (เช่น './output_tables')
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% สำหรับวิชา RMX / FRA Lab: Sensors - Lab 1.4

    if nargin < 1 || isempty(dataDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentScriptDir, '..', 'Lab1.4');
    end
    if nargin < 2 || isempty(tableDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        tableDir = fullfile(currentScriptDir, 'output_tables');
    end
    if ~exist(tableDir, 'dir')
        mkdir(tableDir);
    end

    fprintf('กำลังสร้างตารางสรุปผลการทดลอง Lab 1.4...\n');
    r = process_static_data(dataDir);

    m = r.mass;
    F = r.force;
    v = r.voltage_mean;
    v_sd = r.voltage_sd;
    adc = r.adc_mean;
    adc_sd = r.adc_sd;

    % -------------------------------------------------------------
    % 1. ตารางที่ 1: Table_LoadCell_Summary.csv
    % -------------------------------------------------------------
    t1 = r.trial_voltages(:, 1);
    t2 = r.trial_voltages(:, 2);
    t3 = r.trial_voltages(:, 3);

    summaryTable = table(m, F, v, v_sd, adc, adc_sd, t1, t2, t3, ...
        'VariableNames', {'Mass_kg', 'Force_N', 'Voltage_Mean_V', 'Repeatability_SD_V', ...
                          'ADC_Mean_Counts', 'ADC_SD_Counts', ...
                          'Trial_1_V', 'Trial_2_V', 'Trial_3_V'});

    csvSummary = fullfile(tableDir, 'Table_LoadCell_Summary.csv');
    try
        writetable(summaryTable, csvSummary);
        fprintf('1. บันทึกตารางสรุปการวัด (3 Trials): %s\n', csvSummary);
    catch me
        warning('ไม่สามารถเขียน %s: %s', csvSummary, me.message);
    end

    % -------------------------------------------------------------
    % 2. ตารางที่ 2: Table_LoadCell_Performance_Metrics.csv
    % -------------------------------------------------------------
    % การวิเคราะห์การถดถอยเชิงเส้น (Linear Regression)
    p_lin = polyfit(m, v, 1);
    v_fit = polyval(p_lin, m);
    ss_tot = sum((v - mean(v)).^2);
    ss_res = sum((v - v_fit).^2);
    r2_lin = 1 - (ss_res / ss_tot);
    fs_span = max(v) - min(v);
    max_lin_err_pct = max(abs(v - v_fit)) / fs_span * 100;

    % 2nd-Order Polynomial
    p_poly2 = polyfit(m, v, 2);
    v_poly2 = polyval(p_poly2, m);
    r2_poly2 = 1 - (sum((v - v_poly2).^2) / ss_tot);
    max_poly_err_pct = max(abs(v - v_poly2)) / fs_span * 100;

    % Repeatability Error (%FS)
    max_rep_err_pct = max(v_sd) / fs_span * 100;

    % Inverse Calibration
    p_inv = polyfit(v, m, 1);
    m_est = polyval(p_inv, v);
    max_inv_err_pct = max(abs(m_est - m)) / max(m) * 100;

    metricNames = {
        'Sensor Type';
        'Rated Capacity (Full Scale)';
        'Operating Supply Voltage';
        'ADC Resolution';
        'Mean Sensitivity (Mass)';
        'Mean Sensitivity (Force)';
        'Zero-Load Offset Voltage';
        'Linear Regression Equation';
        'Linearity Determination R^2';
        'Maximum Linearity Error';
        '2nd-Order Polynomial R^2';
        'Maximum Polynomial Error';
        'Maximum Repeatability SD';
        'Maximum Repeatability Error';
        'Inverse Calibration Equation';
        'Maximum Calibration Error';
        'Average RMS Noise Floor';
        'Peak Signal-to-Noise Ratio (SNR)'
    };

    metricValues = {
        'Strain Gauge Load Cell (Piezoresistive Full Bridge)';
        sprintf('%.3f kg (%.2f N)', max(m), max(F));
        '3.30 V (STM32 Regulated Rail)';
        '12-bit (0.806 mV / LSB)';
        sprintf('%.2f mV/kg (%.4f V/kg)', p_lin(1)*1000, p_lin(1));
        sprintf('%.2f mV/N (%.5f V/N)', (p_lin(1)/9.80665)*1000, p_lin(1)/9.80665);
        sprintf('%.4f V (Offset b)', p_lin(2));
        sprintf('V = %.4f*m + %.4f', p_lin(1), p_lin(2));
        sprintf('%.5f', r2_lin);
        sprintf('%.2f %% FS', max_lin_err_pct);
        sprintf('%.5f', r2_poly2);
        sprintf('%.2f %% FS', max_poly_err_pct);
        sprintf('%.4f V (%.2f mV)', max(v_sd), max(v_sd)*1000);
        sprintf('%.2f %% FS', max_rep_err_pct);
        sprintf('m = %.4f*V - %.4f', p_inv(1), abs(p_inv(2)));
        sprintf('%.2f %% FS', max_inv_err_pct);
        sprintf('%.2f mV', mean(r.temporal_noise_v)*1000);
        sprintf('%.2f dB', max(20*log10(v ./ r.temporal_noise_v)))
    };

    metricsTable = table(metricNames, metricValues, ...
        'VariableNames', {'Metric_Parameter', 'Value_Description'});
    csvMetrics = fullfile(tableDir, 'Table_LoadCell_Performance_Metrics.csv');
    writetable(metricsTable, csvMetrics);
    fprintf('2. บันทึกตารางตัวชี้วัดประสิทธิภาพ: %s\n', csvMetrics);

    % -------------------------------------------------------------
    % 3. ตารางที่ 3: Table_LoadCell_Noise_Analysis.csv
    % -------------------------------------------------------------
    noise_rms_mv = r.temporal_noise_v * 1000;
    noise_vpp_est = 6 * noise_rms_mv; % 6-sigma peak to peak (99.7% confidence)
    snr_db = 20 * log10(v ./ r.temporal_noise_v);
    enob = (snr_db - 1.76) / 6.02;

    noiseTable = table(m, F, v, noise_rms_mv, noise_vpp_est, snr_db, enob, ...
        'VariableNames', {'Mass_kg', 'Force_N', 'Voltage_Mean_V', ...
                          'Temporal_Noise_RMS_mV', 'Estimated_Vpp_mV', ...
                          'SNR_dB', 'Effective_Number_of_Bits_ENOB'});
    csvNoise = fullfile(tableDir, 'Table_LoadCell_Noise_Analysis.csv');
    writetable(noiseTable, csvNoise);
    fprintf('3. บันทึกตารางวิเคราะห์สัญญาณรบกวน: %s\n', csvNoise);

    % -------------------------------------------------------------
    % 4. บันทึกเป็นไฟล์ MAT Workspace รวม
    % -------------------------------------------------------------
    matSummary = fullfile(tableDir, 'Lab1_4_Summary_Data.mat');
    save(matSummary, 'r', 'summaryTable', 'metricsTable', 'noiseTable', ...
         'p_lin', 'p_inv', 'p_poly2', 'r2_lin', 'r2_poly2');
    fprintf('4. บันทึกข้อมูล MATLAB รวม: %s\n', matSummary);
end
