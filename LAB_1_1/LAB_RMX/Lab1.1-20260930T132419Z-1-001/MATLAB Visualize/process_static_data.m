function result = process_static_data(dataDir, rawPrefix, sensorType)
% PROCESS_STATIC_DATA ประมวลผลข้อมูลการวัดสถิติ (Static Measurement)
% สำหรับเซนเซอร์ประเภท Rotary (RAW1, RAW2, RAW3) หรือ Linear (RAW4, RAW5)
%
% Inputs:
%   dataDir    - โฟลเดอร์ที่เก็บไฟล์ .mat (เช่น '../Lab1.1')
%   rawPrefix  - คำนำหน้าชื่อเซนเซอร์ เช่น 'RAW1', 'RAW2', 'RAW3', 'RAW4', 'RAW5'
%   sensorType - ชนิดของเซนเซอร์: 'rotary' (มุม) หรือ 'linear' (ระยะทาง)
%
% Outputs:
%   result - โครงสร้างผลลัพธ์ (struct) ประกอบด้วย:
%       .x          - ค่าอินพุต (องศา หรือ เซนติเมตร)
%       .x_unit     - หน่วยอินพุต ('degree' หรือ 'cm')
%       .mean_val   - ค่าเฉลี่ยสัญญาณของแต่ละจุดวัด (Nx1)
%       .std_val    - ส่วนเบี่ยงเบนมาตรฐานระหว่างรอบ (Repeatability SD) (Nx1)
%       .trial_vals - ค่าเฉลี่ยในแต่ละรอบ (Nx3)
%       .is_adc     - เป็นค่า Raw ADC หรือไม่ (true/false)
%       .voltage    - ค่าแปลงเป็นแรงดันไฟฟ้า (V) (Nx1)
%       .voltage_sd - ค่าความคลาดเคลื่อนแรงดันไฟฟ้า (V) (Nx1)
%
% ผู้พัฒนา: Antigravity AI Pair Programmer

    if nargin < 3
        if contains(rawPrefix, 'RAW4') || contains(rawPrefix, 'RAW5')
            sensorType = 'linear';
        else
            sensorType = 'rotary';
        end
    end

    V_SUPPLY = 3.3;      % แรงดันไฟเลี้ยงระบบ (V)
    ADC_MAX  = 4095;     % ความละเอียด ADC 12-bit ของ STM32

    if strcmpi(sensorType, 'rotary')
        % มุม 0 ถึง 100 องศา ทีละ 10 องศา
        xVals = (0:10:100)';
        xUnit = 'degree';
    else
        % ระยะทาง 0.0 ถึง 6.0 cm ทีละ 0.5 cm
        xVals = (0.0:0.5:6.0)';
        xUnit = 'cm';
    end

    numPts = length(xVals);
    trialVals = nan(numPts, 3);
    withinTrialStd = nan(numPts, 3);

    for i = 1:numPts
        x = xVals(i);
        for trial = 1:3
            % ค้นหาไฟล์ที่ตรงกับเงื่อนไข
            foundFile = '';
            if strcmpi(sensorType, 'rotary')
                candidatePatterns = {
                    sprintf('%s-%ddegree.(%d).mat', rawPrefix, round(x), trial),
                    sprintf('%s-%.1fdegree.(%d).mat', rawPrefix, x, trial)
                };
            else
                candidatePatterns = {
                    sprintf('%s-%.1fcm.(%d).mat', rawPrefix, x, trial),
                    sprintf('%s-%gcm.(%d).mat', rawPrefix, x, trial),
                    sprintf('%s-%dcm.(%d).mat', rawPrefix, round(x), trial)
                };
            end

            for p = 1:length(candidatePatterns)
                fullPath = fullfile(dataDir, candidatePatterns{p});
                if exist(fullPath, 'file')
                    foundFile = fullPath;
                    break;
                end
            end

            % หากยังไม่พบ ให้ค้นหาด้วย dir แบบ wildcard
            if isempty(foundFile)
                if strcmpi(sensorType, 'rotary')
                    wildcard = sprintf('%s*%d*degree*(%d)*.mat', rawPrefix, round(x), trial);
                else
                    wildcard = sprintf('%s*%g*cm*(%d)*.mat', rawPrefix, x, trial);
                end
                d = dir(fullfile(dataDir, wildcard));
                if ~isempty(d)
                    foundFile = fullfile(dataDir, d(1).name);
                end
            end

            if ~isempty(foundFile)
                [~, sigs, ~] = load_lab_data(foundFile);
                if ~isempty(sigs)
                    % ใช้ช่องสัญญาณหลักช่องแรก (สัญญาณจากเซนเซอร์)
                    mainSig = sigs(:, 1);
                    trialVals(i, trial) = mean(mainSig);
                    withinTrialStd(i, trial) = std(mainSig);
                end
            end
        end
    end

    % คำนวณสถิติภาพรวม
    meanVal = nanmean(trialVals, 2);
    stdVal  = nanstd(trialVals, 0, 2);

    % ตรวจสอบว่าเป็น Raw ADC หรือ Voltage
    maxMeasured = nanmax(meanVal(:));
    if maxMeasured > 5.0
        isADC = true;
        voltage = (meanVal ./ ADC_MAX) * V_SUPPLY;
        voltageSD = (stdVal ./ ADC_MAX) * V_SUPPLY;
    else
        isADC = false;
        voltage = meanVal;
        voltageSD = stdVal;
    end

    % บันทึกผลลัพธ์ลงใน struct
    result = struct();
    result.name       = rawPrefix;
    result.sensorType = sensorType;
    result.x          = xVals;
    result.x_unit     = xUnit;
    result.trial_vals = trialVals;
    result.mean_val   = meanVal;
    result.std_val    = stdVal;
    result.is_adc     = isADC;
    result.voltage    = voltage;
    result.voltage_sd = voltageSD;
    result.noise_sd   = nanmean(withinTrialStd, 2);
end
