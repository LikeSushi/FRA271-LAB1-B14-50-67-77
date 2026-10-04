function lab_data = load_lab_data(filepath)
% LOAD_LAB_DATA โหลดและแยกสัญญาณจากไฟล์ .mat (รองรับ Simulink Dataset)
%
% Usage:
%   lab_data = load_lab_data(filepath)
%
% Inputs:
%   filepath - ที่อยู่ไฟล์ .mat เต็ม หรือ สัมพัทธ์
%
% Outputs:
%   lab_data - struct ประกอบด้วยสัญญาณต่างๆ จากแบบจำลอง Simulink

    if ~exist(filepath, 'file')
        error('ไม่พบไฟล์ข้อมูล: %s', filepath);
    end

    raw_mat = load(filepath);
    if ~isfield(raw_mat, 'data')
        error('ไฟล์ %s ไม่มีตัวแปร dataset "data"', filepath);
    end

    ds = raw_mat.data;
    if ~isa(ds, 'Simulink.SimulationData.Dataset')
        error('ตัวแปร "data" ไม่ใช่ Simulink.SimulationData.Dataset');
    end

    % กำหนดค่าเริ่มต้นให้กับ struct
    lab_data = struct();
    lab_data.filepath = filepath;
    [~, fname, fext] = fileparts(filepath);
    lab_data.filename = [fname, fext];

    % สกัดเวลาจาก element แรกที่มีค่า
    elem1 = ds{1};
    if isa(elem1, 'Simulink.SimulationData.Signal') && isa(elem1.Values, 'timeseries')
        lab_data.time = elem1.Values.Time;
    else
        lab_data.time = [];
    end

    if ~isempty(lab_data.time)
        lab_data.Ts = mean(diff(lab_data.time));
        lab_data.duration = lab_data.time(end) - lab_data.time(1);
    else
        lab_data.Ts = 0.001;
        lab_data.duration = 0;
    end

    % ตัวแปรเก็บสัญญาณหลัก
    lab_data.raw_count = [];
    lab_data.raw_name = '';
    lab_data.A = [];
    lab_data.B = [];
    lab_data.PPR = [];
    lab_data.deg_360 = [];
    lab_data.deg_con = [];
    lab_data.rad_pos = [];
    lab_data.rad_vel = [];
    lab_data.rel_pulses = [];
    lab_data.calibrated_pos = [];
    lab_data.state_out = [];
    lab_data.home_switch = [];

    % วนลูปอ่านทุกสัญญาณใน Dataset
    for k = 1:ds.numElements
        elem = ds{k};
        if ~isa(elem, 'Simulink.SimulationData.Signal') || ~isa(elem.Values, 'timeseries')
            continue;
        end

        sName = strtrim(elem.Name);
        sData = elem.Values.Data;

        switch sName
            case 'A'
                lab_data.A = double(sData);
            case 'B'
                lab_data.B = double(sData);
            case 'PPR'
                lab_data.PPR = double(sData);
            case 'deg_360'
                lab_data.deg_360 = double(sData);
            case 'deg_con'
                lab_data.deg_con = double(sData);
            case 'rad_pos'
                lab_data.rad_pos = double(sData);
            case 'rad_vel'
                lab_data.rad_vel = double(sData);
            case 'rel_pulses'
                lab_data.rel_pulses = double(sData);
            case 'calibrated_pos'
                lab_data.calibrated_pos = double(sData);
            case 'state_out'
                lab_data.state_out = double(sData);
            case {'EncoderX1', 'EncoderX2', 'EncoderX4'}
                lab_data.raw_count = double(sData);
                lab_data.raw_name = sName;
            otherwise
                % สัญญาณไม่มีชื่อ หรือเป็นสวิตช์ Manual Switch
                if isempty(sName) || strcmp(sName, '')
                    % เช็ค BlockPath ว่าเป็น Switch หรือไม่
                    if contains(elem.BlockPath.getBlock(1), 'Manual Switch')
                        lab_data.home_switch = double(sData);
                    end
                end
        end
    end

    % หากยังไม่ได้ระบุ raw_count ให้ค้นหาจากชื่อที่คล้าย Encoder
    if isempty(lab_data.raw_count)
        for k = 1:ds.numElements
            elem = ds{k};
            if isa(elem, 'Simulink.SimulationData.Signal')
                if startsWith(elem.Name, 'Encoder')
                    lab_data.raw_count = double(elem.Values.Data);
                    lab_data.raw_name = elem.Name;
                    break;
                end
            end
        end
    end

    % แปลงสัญญาณ ADC (0-4095) เป็น Voltage (0-3.3V) สำหรับ Channel A และ B
    if ~isempty(lab_data.A)
        lab_data.voltage_A = (lab_data.A / 4095.0) * 3.3;
    else
        lab_data.voltage_A = [];
    end

    if ~isempty(lab_data.B)
        lab_data.voltage_B = (lab_data.B / 4095.0) * 3.3;
    else
        lab_data.voltage_B = [];
    end

    % คำนวณสรุปพื้นฐาน
    if ~isempty(lab_data.raw_count)
        lab_data.count_delta = lab_data.raw_count(end) - lab_data.raw_count(1);
        lab_data.count_range = [min(lab_data.raw_count), max(lab_data.raw_count)];
    else
        lab_data.count_delta = 0;
        lab_data.count_range = [0, 0];
    end
end
