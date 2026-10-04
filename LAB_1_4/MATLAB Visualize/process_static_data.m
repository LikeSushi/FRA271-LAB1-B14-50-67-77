function result = process_static_data(dataDir, discardTransientSec)
% PROCESS_STATIC_DATA ประมวลผลข้อมูลการทดลองสถิติของ Lab 1.4: Load Cell / Force Sensor
%
% Inputs:
%   dataDir             - โฟลเดอร์ที่เก็บไฟล์ .mat ของ Lab 1.4 (เช่น '../Lab1.4')
%   discardTransientSec - เวลา (วินาที) ที่ตัดทิ้งช่วงเริ่มต้นเพื่อขจัด Transient (ค่าเริ่มต้น: 0.10 s)
%
% Outputs:
%   result - Struct รวบรวมผลการประมวลผลทางสถิติ:
%       .mass               - มวลที่ทดสอบในหน่วย kg (11x1)
%       .force              - แรงกด / น้ำหนักในหน่วย N (11x1) โดย F = m * g (g = 9.80665 m/s^2)
%       .voltage_mean       - ค่าเฉลี่ยแรงดันไฟฟ้าแต่ละจุดวัดระหว่างรอบ (V) (11x1)
%       .voltage_sd         - ส่วนเบี่ยงเบนมาตรฐานแรงดันไฟฟ้าระหว่างรอบ (Repeatability SD) (V) (11x1)
%       .adc_mean           - ค่าเฉลี่ยรหัส ADC (12-bit STM32: 0-4095) (11x1)
%       .adc_sd             - ส่วนเบี่ยงเบนมาตรฐาน ADC ระหว่างรอบ (11x1)
%       .trial_voltages     - ค่าเฉลี่ยแรงดันในแต่ละรอบย่อย 3 รอบ (11x3)
%       .trial_adcs         - ค่าเฉลี่ย ADC ในแต่ละรอบย่อย 3 รอบ (11x3)
%       .temporal_noise_v   - ส่วนเบี่ยงเบนมาตรฐานสัญญาณรบกวนภายในสัญญาณ (Within-trial Noise SD in V) (11x1)
%       .num_trials         - จำนวนรอบที่วัดได้ในแต่ละพิกัดน้ำหนัก (11x1)
%       .sample_rate        - อัตราการสุ่มตัวอย่างโดยเฉลี่ย (Hz)
%       .raw_signals        - Cell array เก็บข้อมูลสัญญาณเวลาตัวแทนสำหรับการพล็อต Dynamic
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% สำหรับวิชา RMX / FRA Lab: Sensors - Lab 1.4

    if nargin < 1 || isempty(dataDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentScriptDir, '..', 'Lab1.4');
        if ~exist(dataDir, 'dir')
            altDir = 'C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\Lab1.4';
            if exist(altDir, 'dir')
                dataDir = altDir;
            end
        end
    end

    if nargin < 2 || isempty(discardTransientSec)
        discardTransientSec = 0.10; % ขจัดทรานเชียนต์ 0.10 วินาทีแรก
    end

    g_accel = 9.80665; % ความเร่งเนื่องจากแรงโน้มถ่วง (m/s^2)
    V_SUPPLY = 3.3;    % แรงดันอ้างอิงระบบ (V)
    ADC_MAX  = 4095;   % ค่าสูงสุด 12-bit ADC

    % รายการมวลน้ำหนักทั้งหมด 11 จุดวัด
    massPoints = [0.988, 1.923, 2.932, 3.913, 4.901, 5.868, 6.837, 7.821, 8.790, 9.783, 9.961]';
    numPoints  = length(massPoints);
    maxTrials  = 3; % กำหนดให้ใช้ข้อมูลการทดลอง 3 รอบเท่านั้น (Trial 1, 2, 3)

    trialVoltages = nan(numPoints, maxTrials);
    trialADCs     = nan(numPoints, maxTrials);
    withinNoiseV  = nan(numPoints, maxTrials);
    trialsCount   = zeros(numPoints, 1);
    rawSignals    = cell(numPoints, 1);
    sampleRate    = 1000;

    for i = 1:numPoints
        m = massPoints(i);
        foundCount = 0;

        for trial = 1:maxTrials
            % รูปแบบการค้นหาชื่อไฟล์
            candidatePatterns = {
                sprintf('kg%.3f(%d).mat', m, trial),
                sprintf('kg%g(%d).mat', m, trial),
                sprintf('kg%.2f(%d).mat', m, trial)
            };

            targetFile = '';
            for p = 1:length(candidatePatterns)
                candidatePath = fullfile(dataDir, candidatePatterns{p});
                if exist(candidatePath, 'file')
                    targetFile = candidatePath;
                    break;
                end
            end

            % Wildcard search หากยังไม่พบตรงเป๊ะ
            if isempty(targetFile)
                wildcard = sprintf('*%.2f*(%d)*.mat', m, trial);
                d = dir(fullfile(dataDir, wildcard));
                if ~isempty(d)
                    targetFile = fullfile(dataDir, d(1).name);
                end
            end

            if ~isempty(targetFile) && exist(targetFile, 'file')
                [t, sigs, ~] = load_lab_data(targetFile);
                if ~isempty(sigs) && size(sigs, 2) >= 1
                    foundCount = foundCount + 1;
                    
                    % คำนวณช่วงเวลา steady state โดยตัด transient ออก
                    if length(t) > 1
                        dt = mean(diff(t));
                        if dt > 0
                            sampleRate = round(1 / dt);
                        end
                        cutIdx = max(1, round(discardTransientSec / dt));
                    else
                        cutIdx = 1;
                    end

                    if cutIdx < size(sigs, 1)
                        steadySigV   = sigs(cutIdx:end, 1);
                        if size(sigs, 2) >= 2
                            steadySigADC = sigs(cutIdx:end, 2);
                        else
                            steadySigADC = (steadySigV / V_SUPPLY) * ADC_MAX;
                        end
                    else
                        steadySigV   = sigs(:, 1);
                        if size(sigs, 2) >= 2
                            steadySigADC = sigs(:, 2);
                        else
                            steadySigADC = (steadySigV / V_SUPPLY) * ADC_MAX;
                        end
                    end

                    trialVoltages(i, trial) = mean(steadySigV);
                    trialADCs(i, trial)     = mean(steadySigADC);
                    withinNoiseV(i, trial)  = std(steadySigV);

                    % บันทึกสัญญาณดิบของรอบที่ 1 เก็บไว้
                    if trial == 1
                        rawSignals{i}.t = t;
                        rawSignals{i}.voltage = sigs(:, 1);
                        if size(sigs, 2) >= 2
                            rawSignals{i}.adc = sigs(:, 2);
                        else
                            rawSignals{i}.adc = (sigs(:, 1) / V_SUPPLY) * ADC_MAX;
                        end
                    end
                end
            end
        end
        trialsCount(i) = foundCount;
    end

    % คำนวณค่าสถิติภาพรวม
    vMean   = nanmean(trialVoltages, 2);
    vStd    = nanstd(trialVoltages, 0, 2);
    adcMean = nanmean(trialADCs, 2);
    adcStd  = nanstd(trialADCs, 0, 2);
    tempNoiseMean = nanmean(withinNoiseV, 2);

    % เติมค่าหากกรณีมีจุดวัดเดียว (ป้องกัน std เป็น nan)
    vStd(isnan(vStd)) = 0;
    adcStd(isnan(adcStd)) = 0;

    % รวบรวมข้อมูลลง struct
    result.mass             = massPoints;
    result.force            = massPoints .* g_accel;
    result.voltage_mean     = vMean;
    result.voltage_sd       = vStd;
    result.adc_mean         = adcMean;
    result.adc_sd           = adcStd;
    result.trial_voltages   = trialVoltages;
    result.trial_adcs       = trialADCs;
    result.temporal_noise_v = tempNoiseMean;
    result.num_trials       = trialsCount;
    result.sample_rate      = sampleRate;
    result.raw_signals      = rawSignals;
    result.v_supply         = V_SUPPLY;
    result.adc_max          = ADC_MAX;

    fprintf('ประมวลผลข้อมูลการทดสอบ Load Cell สำเร็จ: %d พิกัดน้ำหนัก (%d ไฟล์)\n', ...
        numPoints, sum(trialsCount));
end
