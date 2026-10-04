function [t, sigs, sigNames] = load_lab_data(matFilePath)
% LOAD_LAB_DATA โหลดข้อมูลจากการทดลองในไฟล์ .mat อย่างปลอดภัยและครอบคลุม
% รองรับรูปแบบ Simulink Dataset, timeseries, struct และ matrix
%
% Inputs:
%   matFilePath - พาธแบบเต็มหรือแบบสัมพัทธ์ของไฟล์ .mat
%
% Outputs:
%   t        - เวกเตอร์เวลา (Nx1 double)
%   sigs     - เมทริกซ์สัญญาณ (NxM double) โดยแต่ละคอลัมน์คือ 1 ช่องสัญญาณ
%   sigNames - รายชื่อสัญญาณ (1xM cell array of char)
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% สำหรับวิชา RMX / FRA Lab: Sensors - Lab 1.4

    t = [];
    sigs = [];
    sigNames = {};

    if ~exist(matFilePath, 'file')
        warning('ไม่พบไฟล์ข้อมูล: %s', matFilePath);
        return;
    end

    % โหลดข้อมูลจากไฟล์ .mat
    loadedData = load(matFilePath);
    varNames = fieldnames(loadedData);
    if isempty(varNames)
        warning('ไฟล์ไม่มีตัวแปร: %s', matFilePath);
        return;
    end

    % ใช้ตัวแปรตัวแรก (โดยปกติคือ data หรือ ans หรือ simout)
    targetVar = loadedData.(varNames{1});

    % ตรวจสอบว่าเป็น Simulink.SimulationData.Dataset หรือไม่
    if isa(targetVar, 'Simulink.SimulationData.Dataset')
        numElements = targetVar.numElements;
        for i = 1:numElements
            element = targetVar.get(i);
            sName = element.Name;
            if isempty(sName)
                sName = sprintf('Signal_%d', i);
            end

            if isprop(element, 'Values') && ~isempty(element.Values)
                valObj = element.Values;
                if isa(valObj, 'timeseries')
                    if isempty(t)
                        t = double(valObj.Time);
                    end
                    vData = double(squeeze(valObj.Data));
                    if size(vData, 2) > 1 && size(vData, 1) == 1
                        vData = vData(:); % แปลงเป็น column vector
                    end
                    sigs = [sigs, vData]; %#ok<AGROW>
                    sigNames{end+1} = sName; %#ok<AGROW>
                elseif isnumeric(valObj)
                    sigs = [sigs, double(valObj(:))]; %#ok<AGROW>
                    sigNames{end+1} = sName; %#ok<AGROW>
                end
            end
        end

    % ตรวจสอบกรณีเป็น timeseries โดยตรง
    elseif isa(targetVar, 'timeseries')
        t = double(targetVar.Time);
        vData = double(squeeze(targetVar.Data));
        if size(vData, 2) > 1 && size(vData, 1) == 1
            vData = vData(:);
        end
        sigs = vData;
        sName = targetVar.Name;
        if isempty(sName), sName = 'Signal_1'; end
        sigNames = {sName};

    % ตรวจสอบกรณีเป็น struct (โครงสร้างจาก To Workspace ใน Simulink)
    elseif isstruct(targetVar)
        if isfield(targetVar, 'time') && isfield(targetVar, 'signals')
            t = double(targetVar.time);
            if isfield(targetVar.signals, 'values')
                sigs = double(targetVar.signals.values);
            end
            if isfield(targetVar.signals, 'label')
                sigNames = {targetVar.signals.label};
            else
                sigNames = arrayfun(@(k) sprintf('Signal_%d', k), 1:size(sigs,2), 'UniformOutput', false);
            end
        elseif isfield(targetVar, 'Time') && isfield(targetVar, 'Data')
            t = double(targetVar.Time);
            sigs = double(targetVar.Data);
            sigNames = {'Signal_1'};
        else
            % struct ทั่วไป ดึงค่าฟิลด์ที่เป็นตัวเลข
            f = fieldnames(targetVar);
            for k = 1:length(f)
                val = targetVar.(f{k});
                if isnumeric(val)
                    sigs = [sigs, double(val(:))]; %#ok<AGROW>
                    sigNames{end+1} = f{k}; %#ok<AGROW>
                end
            end
        end

    % ตรวจสอบกรณีเป็น numeric array
    elseif isnumeric(targetVar)
        sigs = double(targetVar);
        t = (0:size(sigs, 1) - 1)';
        sigNames = arrayfun(@(k) sprintf('Signal_%d', k), 1:size(sigs,2), 'UniformOutput', false);
    end

    % ถ้ายังไม่มีเวลา (Time vector) ให้สร้างขึ้นมาจาก index
    if isempty(t) && ~isempty(sigs)
        t = (0:size(sigs, 1) - 1)';
    end
end
