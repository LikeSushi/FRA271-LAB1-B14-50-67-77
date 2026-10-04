function export_summary_tables(dataDir, tableDir)
% EXPORT_SUMMARY_TABLES ส่งออกตารางสรุปผลการทดลองเป็นไฟล์ CSV และ MAT
% พร้อมสำหรับนำไปวางในรายงาน (Word / Excel)
%
% ไฟล์ที่จะส่งออก:
%   1. Table_Rotary_Summary.csv - ค่าเฉลี่ย, SD ของ RAW1, RAW2, RAW3 ทุกมุม
%   2. Table_Linear_Summary.csv - ค่าเฉลี่ย, SD ของ RAW4, RAW5 ทุกระยะทาง
%   3. Table_Sensor_Performance_Metrics.csv - ค่า Sensitivity, R^2, Linearity Error (%FS)
%
% Inputs:
%   dataDir  - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.1')
%   tableDir - โฟลเดอร์สำหรับบันทึกไฟล์ตาราง (เช่น './output_tables')
%
% ผู้พัฒนา: Antigravity AI Pair Programmer

    if nargin < 1 || isempty(dataDir)
        dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'Lab1.1');
    end
    if nargin < 2 || isempty(tableDir)
        tableDir = fullfile(fileparts(mfilename('fullpath')), 'output_tables');
    end
    if ~exist(tableDir, 'dir')
        mkdir(tableDir);
    end

    fprintf('กำลังสร้างตารางสรุปผลการทดลอง...\n');

    conv_trials = @(r) (r.trial_vals .* (r.is_adc * (3.3 / 4095) + ~r.is_adc * 1));

    % 1. ประมวลผล Rotary Sensors
    r1 = process_static_data(dataDir, 'RAW1', 'rotary');
    r2 = process_static_data(dataDir, 'RAW2', 'rotary');
    r3 = process_static_data(dataDir, 'RAW3', 'rotary');

    r1_t = conv_trials(r1);
    r2_t = conv_trials(r2);
    r3_t = conv_trials(r3);

    angles = r1.x;
    rotaryTable = table(angles, ...
        r1_t(:,1), r1_t(:,2), r1_t(:,3), r1.voltage, r1.voltage_sd, ...
        r2_t(:,1), r2_t(:,2), r2_t(:,3), r2.voltage, r2.voltage_sd, ...
        r3_t(:,1), r3_t(:,2), r3_t(:,3), r3.voltage, r3.voltage_sd, ...
        'VariableNames', {'Angle_deg', ...
                          'RAW1_Trial1_V', 'RAW1_Trial2_V', 'RAW1_Trial3_V', 'RAW1_Mean_V', 'RAW1_SD_V', ...
                          'RAW2_Trial1_V', 'RAW2_Trial2_V', 'RAW2_Trial3_V', 'RAW2_Mean_V', 'RAW2_SD_V', ...
                          'RAW3_Trial1_V', 'RAW3_Trial2_V', 'RAW3_Trial3_V', 'RAW3_Mean_V', 'RAW3_SD_V'});

    csvRotary = fullfile(tableDir, 'Table_Rotary_Summary.csv');
    try
        writetable(rotaryTable, csvRotary);
        fprintf('บันทึกตาราง Rotary: %s\n', csvRotary);
    catch ME
        warning('ไม่สามารถเขียนไฟล์ %s ได้ (อาจเปิดอยู่ใน Excel): %s', csvRotary, ME.message);
    end

    % 2. ประมวลผล Linear Sensors
    r4 = process_static_data(dataDir, 'RAW4', 'linear');
    r5 = process_static_data(dataDir, 'RAW5', 'linear');

    r4_t = conv_trials(r4);
    r5_t = conv_trials(r5);

    dist = r4.x;
    linearTable = table(dist, ...
        r4_t(:,1), r4_t(:,2), r4_t(:,3), r4.voltage, r4.voltage_sd, ...
        r5_t(:,1), r5_t(:,2), r5_t(:,3), r5.voltage, r5.voltage_sd, ...
        'VariableNames', {'Distance_cm', ...
                          'RAW4_Trial1_V', 'RAW4_Trial2_V', 'RAW4_Trial3_V', 'RAW4_Mean_V', 'RAW4_SD_V', ...
                          'RAW5_Trial1_V', 'RAW5_Trial2_V', 'RAW5_Trial3_V', 'RAW5_Mean_V', 'RAW5_SD_V'});

    csvLinear = fullfile(tableDir, 'Table_Linear_Summary.csv');
    try
        writetable(linearTable, csvLinear);
        fprintf('บันทึกตาราง Linear: %s\n', csvLinear);
    catch ME
        warning('ไม่สามารถเขียนไฟล์ %s ได้ (อาจเปิดอยู่ใน Excel): %s', csvLinear, ME.message);
    end

    % 3. ตาราง Metrics ภาพรวม (Performance Metrics)
    allSensors = {r1, r2, r3, r4, r5};
    sNames     = {'RAW1', 'RAW2', 'RAW3', 'RAW4', 'RAW5'};
    sTypes     = {'Rotary Potentiometer', 'Rotary Potentiometer', 'Rotary Potentiometer', ...
                  'Linear Slide Potentiometer', 'Linear Slide Potentiometer'};

    colName         = {};
    colType         = {};
    colSensitivity  = [];
    colSensUnit     = {};
    colR2           = [];
    colLinErrPct    = [];
    colTaperEstimate= {};

    for k = 1:5
        obj = allSensors{k};
        colName{k, 1} = sNames{k};
        colType{k, 1} = sTypes{k};

        x = obj.x;
        v = obj.voltage;
        valid = ~isnan(v);
        xv = x(valid);
        yv = v(valid);

        % คำนวณ R^2
        p = polyfit(xv, yv, 1);
        yfit = polyval(p, xv);
        ss_tot = sum((yv - mean(yv)).^2);
        ss_res = sum((yv - yfit).^2);
        r2 = 1 - (ss_res / ss_tot);
        colR2(k, 1) = r2;

        % Linearity Error (%FS)
        fs_range = max(yv) - min(yv);
        lin_err = max(abs(yv - yfit)) / fs_range * 100;
        colLinErrPct(k, 1) = lin_err;

        % Average Sensitivity
        avg_sens = (max(yv) - min(yv)) / (max(xv) - min(xv));
        if contains(obj.sensorType, 'rotary')
            colSensitivity(k, 1) = avg_sens * 1000; % mV/deg
            colSensUnit{k, 1} = 'mV/degree';
        else
            colSensitivity(k, 1) = avg_sens; % V/cm
            colSensUnit{k, 1} = 'V/cm';
        end

        % ประมาณการ Taper
        if r2 > 0.98
            colTaperEstimate{k, 1} = 'Type B (Linear)';
        elseif mean(yv(1:round(end/2))) < 0.3 * max(yv)
            colTaperEstimate{k, 1} = 'Type A (Audio / Log)';
        else
            colTaperEstimate{k, 1} = 'Type C (Reverse Log)';
        end
    end

    metricsTable = table(colName, colType, colTaperEstimate, colSensitivity, colSensUnit, ...
                         colR2, colLinErrPct, ...
                         'VariableNames', {'Sensor', 'Type', 'Identified_Taper', ...
                                           'Avg_Sensitivity', 'Sensitivity_Unit', ...
                                           'R_Squared', 'Max_Linearity_Error_pctFS'});

    csvMetrics = fullfile(tableDir, 'Table_Sensor_Performance_Metrics.csv');
    try
        writetable(metricsTable, csvMetrics);
        fprintf('บันทึกตาราง Performance Metrics: %s\n', csvMetrics);
    catch ME
        warning('ไม่สามารถเขียนไฟล์ %s ได้ (อาจเปิดอยู่ใน Excel): %s', csvMetrics, ME.message);
        % ลองบันทึกด้วยชื่อใหม่
        altCsv = fullfile(tableDir, 'Table_Sensor_Performance_Metrics_New.csv');
        writetable(metricsTable, altCsv);
        fprintf('บันทึกสำรองไว้ที่: %s\n', altCsv);
    end

    % บันทึกผลลัพธ์เป็น .mat ด้วย เพื่อความสะดวกในการโหลดกลับมาใช้ใน MATLAB
    matSummary = fullfile(tableDir, 'Lab_Summary_Data.mat');
    save(matSummary, 'rotaryTable', 'linearTable', 'metricsTable', 'r1', 'r2', 'r3', 'r4', 'r5');
    fprintf('บันทึก Lab_Summary_Data.mat สำเร็จ: %s\n', matSummary);
end
