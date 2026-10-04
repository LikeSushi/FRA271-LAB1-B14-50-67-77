function stats_data = process_static_data(data_dir)
% PROCESS_STATIC_DATA ประมวลผลสถิติการวัดและตัวชี้วัดของ Incremental Encoder
%
% Usage:
%   stats_data = process_static_data([data_dir])
%
% Inputs:
%   data_dir - (Optional) โฟลเดอร์ที่เก็บข้อมูล lab1.3/lab1.3
%
% Outputs:
%   stats_data - struct ประกอบด้วยผลการคำนวณ PPR, Resolution, Repeatability,
%                Speed effects, Schmitt Trigger & Homing/Wrap-around metrics

    % 1. ตรวจสอบและค้นหาโฟลเดอร์เก็บข้อมูล
    if nargin < 1 || isempty(data_dir)
        % ลองค้นหาตามลำดับ
        candidate_dirs = {
            fullfile(pwd, 'lab1.3', 'lab1.3'), ...
            fullfile(pwd, '..', 'lab1.3', 'lab1.3'), ...
            'C:\Users\Chard\Downloads\Lab1.3-20261004T101211Z-1-001\Lab1.3\lab1.3\lab1.3' ...
        };
        found = false;
        for c = 1:length(candidate_dirs)
            if exist(candidate_dirs{c}, 'dir')
                data_dir = candidate_dirs{c};
                found = true;
                break;
            end
        end
        if ~found
            error('ไม่พบโฟลเดอร์เก็บข้อมูล lab1.3/lab1.3');
        end
    end

    fprintf('>> กำลังประมวลผลข้อมูลจาก: %s\n', data_dir);

    stats_data = struct();
    stats_data.data_dir = data_dir;

    %% 2. การวิเคราะห์คุณลักษณะ Encoder (PPR, CPR, Angular Resolution, Repeatability)
    modes = {'X1', 'X2', 'X4'};
    mode_multipliers = [1, 2, 4];
    encoders = {'B', 'W'};
    enc_names = {'Encoder B (Low PPR)', 'Encoder W (High PPR)'};

    spec_table = struct();

    for e = 1:length(encoders)
        enc = encoders{e};
        spec_table.(enc) = struct();

        for m = 1:length(modes)
            mode = modes{m};
            mult = mode_multipliers(m);
            folder_name = sprintf('%s_%s', mode, enc);
            folder_path = fullfile(data_dir, folder_name);

            cw_counts = zeros(1, 3);
            ccw_counts = zeros(1, 3);
            cw_data_list = cell(1, 3);
            ccw_data_list = cell(1, 3);

            for trial = 1:3
                % โหลด CW
                cw_file = dir(fullfile(folder_path, sprintf('*CW(%d).mat', trial)));
                if isempty(cw_file)
                    cw_file = dir(fullfile(folder_path, sprintf('*CW_%d.mat', trial)));
                end
                if ~isempty(cw_file)
                    d = load_lab_data(fullfile(folder_path, cw_file(1).name));
                    cw_counts(trial) = max(d.raw_count) - min(d.raw_count);
                    cw_data_list{trial} = d;
                end

                % โหลด CCW
                ccw_file = dir(fullfile(folder_path, sprintf('*CCW(%d).mat', trial)));
                if isempty(ccw_file)
                    ccw_file = dir(fullfile(folder_path, sprintf('*CCW_%d.mat', trial)));
                end
                if ~isempty(ccw_file)
                    d = load_lab_data(fullfile(folder_path, ccw_file(1).name));
                    ccw_counts(trial) = max(d.raw_count) - min(d.raw_count);
                    ccw_data_list{trial} = d;
                end
            end

            % คำนวณสถิติ
            mean_cw = mean(cw_counts);
            std_cw = std(cw_counts);
            cv_cw = (std_cw / max(mean_cw, 1e-6)) * 100.0;

            mean_ccw = mean(ccw_counts);
            std_ccw = std(ccw_counts);
            cv_ccw = (std_ccw / max(mean_ccw, 1e-6)) * 100.0;

            % วัดค่า CPR จากค่าเฉลี่ย
            cpr_measured = mean_cw;
            % คำนวณ PPR = CPR / mode_multiplier
            ppr_measured = cpr_measured / mult;

            % สำหรับ Encoder B: ออกแบบ PPR = 24
            % สำหรับ Encoder W: ออกแบบ PPR = 2000
            if strcmp(enc, 'B')
                ppr_nominal = 24;
            else
                ppr_nominal = 2000;
            end
            cpr_nominal = ppr_nominal * mult;

            % คำนวณ Angular Resolution
            res_deg = 360.0 / cpr_measured;
            res_rad = (2.0 * pi) / cpr_measured;
            res_deg_nom = 360.0 / cpr_nominal;
            res_rad_nom = (2.0 * pi) / cpr_nominal;

            % บันทึกค่าลงใน struct
            spec_table.(enc).(mode).mult = mult;
            spec_table.(enc).(mode).ppr_nominal = ppr_nominal;
            spec_table.(enc).(mode).cpr_nominal = cpr_nominal;
            spec_table.(enc).(mode).cpr_measured = cpr_measured;
            spec_table.(enc).(mode).ppr_measured = ppr_measured;
            spec_table.(enc).(mode).res_deg = res_deg;
            spec_table.(enc).(mode).res_rad = res_rad;
            spec_table.(enc).(mode).res_deg_nom = res_deg_nom;
            spec_table.(enc).(mode).res_rad_nom = res_rad_nom;
            spec_table.(enc).(mode).cw_counts = cw_counts;
            spec_table.(enc).(mode).ccw_counts = ccw_counts;
            spec_table.(enc).(mode).mean_cw = mean_cw;
            spec_table.(enc).(mode).std_cw = std_cw;
            spec_table.(enc).(mode).cv_cw = cv_cw;
            spec_table.(enc).(mode).mean_ccw = mean_ccw;
            spec_table.(enc).(mode).std_ccw = std_ccw;
            spec_table.(enc).(mode).cv_ccw = cv_ccw;
            spec_table.(enc).(mode).cw_data = cw_data_list;
            spec_table.(enc).(mode).ccw_data = ccw_data_list;
        end
    end
    stats_data.specifications = spec_table;

    %% 3. การวิเคราะห์ผลของความเร็วต่อสัญญาณ (Speed Effects: Slow, Normal, Fast)
    speed_results = struct();
    for e = 1:length(encoders)
        enc = encoders{e};
        speed_results.(enc) = struct();
        folder_x4 = fullfile(data_dir, sprintf('X4_%s', enc));

        % ค้นหาไฟล์ความเร็วต่างๆ
        f_slow = dir(fullfile(folder_x4, '*slow*.mat'));
        f_norm = dir(fullfile(folder_x4, '*CW(1).mat'));
        if isempty(f_norm)
            f_norm = dir(fullfile(folder_x4, '*CW_1.mat'));
        end
        f_fast = dir(fullfile(folder_x4, '*fast*.mat'));

        speeds_info = {
            'Slow', f_slow; ...
            'Normal', f_norm; ...
            'Fast', f_fast ...
        };

        for s = 1:size(speeds_info, 1)
            s_name = speeds_info{s, 1};
            s_file = speeds_info{s, 2};
            if ~isempty(s_file)
                d = load_lab_data(fullfile(folder_x4, s_file(1).name));
                vel_abs = abs(d.rad_vel);
                % ตัดช่วงที่หยุดนิ่งออกเพื่อหาค่าเฉลี่ยขณะหมุนจริง
                moving_idx = vel_abs > 0.05 * max(vel_abs);
                if any(moving_idx)
                    mean_vel = mean(vel_abs(moving_idx));
                else
                    mean_vel = mean(vel_abs);
                end
                max_vel = max(vel_abs);
                cpr = spec_table.(enc).X4.cpr_nominal;
                pulse_freq_max = (max_vel / (2 * pi)) * cpr;
                pulse_freq_mean = (mean_vel / (2 * pi)) * cpr;

                speed_results.(enc).(s_name).filename = s_file(1).name;
                speed_results.(enc).(s_name).duration = d.duration;
                speed_results.(enc).(s_name).max_vel_rad_s = max_vel;
                speed_results.(enc).(s_name).mean_vel_rad_s = mean_vel;
                speed_results.(enc).(s_name).max_vel_rpm = max_vel * 60 / (2 * pi);
                speed_results.(enc).(s_name).mean_vel_rpm = mean_vel * 60 / (2 * pi);
                speed_results.(enc).(s_name).max_pulse_freq_hz = pulse_freq_max;
                speed_results.(enc).(s_name).mean_pulse_freq_hz = pulse_freq_mean;
                speed_results.(enc).(s_name).data = d;
            end
        end
    end
    stats_data.speed_analysis = speed_results;

    %% 4. การวิเคราะห์สัญญาณ Optical Analog และ Schmitt Trigger (ADC -> Voltage)
    analog_dir = fullfile(data_dir, 'analog');
    analog_results = struct();

    for e = 1:length(encoders)
        enc = encoders{e};
        analog_results.(enc) = struct();

        for d_dir = {'CW', 'CCW'}
            dir_str = d_dir{1};
            fname = sprintf('%s-%s(1).mat', enc, dir_str);
            fpath = fullfile(analog_dir, fname);
            if exist(fpath, 'file')
                d = load_lab_data(fpath);

                % สถิติ Channel A (ADC 0-4095 -> Voltage 0-3.3V)
                v_A = d.voltage_A;
                v_B = d.voltage_B;

                vA_min = min(v_A);
                vA_max = max(v_A);
                vA_pp  = vA_max - vA_min;
                vA_mean = mean(v_A);
                vA_std  = std(v_A);

                vB_min = min(v_B);
                vB_max = max(v_B);
                vB_pp  = vB_max - vB_min;
                vB_mean = mean(v_B);
                vB_std  = std(v_B);

                % ประเมิน Schmitt Trigger Thresholds (30% และ 70% ของช่วงสัญญาณ)
                th_low_A = vA_min + 0.3 * vA_pp;
                th_high_A = vA_min + 0.7 * vA_pp;
                th_low_B = vB_min + 0.3 * vB_pp;
                th_high_B = vB_min + 0.7 * vB_pp;

                % คำนวณ Cross-Correlation เพื่อประเมิน Phase Shift
                % คัดเลือกช่วงที่มีการเคลื่อนไหว
                cA = v_A - mean(v_A);
                cB = v_B - mean(v_B);
                [r_xcorr, lags] = xcorr(cA, cB, 50, 'coeff');
                [~, max_lag_idx] = max(r_xcorr);
                phase_lag_samples = lags(max_lag_idx);

                analog_results.(enc).(dir_str).filename = fname;
                analog_results.(enc).(dir_str).vA_min = vA_min;
                analog_results.(enc).(dir_str).vA_max = vA_max;
                analog_results.(enc).(dir_str).vA_pp = vA_pp;
                analog_results.(enc).(dir_str).vA_mean = vA_mean;
                analog_results.(enc).(dir_str).vA_std = vA_std;
                analog_results.(enc).(dir_str).vB_min = vB_min;
                analog_results.(enc).(dir_str).vB_max = vB_max;
                analog_results.(enc).(dir_str).vB_pp = vB_pp;
                analog_results.(enc).(dir_str).vB_mean = vB_mean;
                analog_results.(enc).(dir_str).vB_std = vB_std;
                analog_results.(enc).(dir_str).th_low_A = th_low_A;
                analog_results.(enc).(dir_str).th_high_A = th_high_A;
                analog_results.(enc).(dir_str).th_low_B = th_low_B;
                analog_results.(enc).(dir_str).th_high_B = th_high_B;
                analog_results.(enc).(dir_str).phase_lag_samples = phase_lag_samples;
                analog_results.(enc).(dir_str).data = d;
            end
        end
    end
    stats_data.analog_schmitt = analog_results;

    %% 5. การวิเคราะห์ Homing Sequence (State 0, 1, 2 และการชดเชยจุดศูนย์)
    homing_dir = fullfile(data_dir, 'homing');
    homing_results = struct();
    h_files = dir(fullfile(homing_dir, 'homing(*).mat'));
    if isempty(h_files)
        h_files = dir(fullfile(homing_dir, '*.mat'));
    end

    homing_trials = [];
    for k = 1:length(h_files)
        d = load_lab_data(fullfile(homing_dir, h_files(k).name));
        % ค้นหาจุด Trigger สวิตช์ Home
        t_switch = [];
        if ~isempty(d.home_switch)
            d_sw = diff(d.home_switch);
            trig_idx = find(d_sw > 0, 1);
            if ~isempty(trig_idx)
                t_trig = d.time(trig_idx + 1);
                raw_at_trig = d.rad_pos(trig_idx + 1);
                cal_at_trig = d.calibrated_pos(trig_idx + 1);
            else
                trig_idx = find(d.state_out == 2, 1);
                t_trig = d.time(trig_idx);
                raw_at_trig = d.rad_pos(trig_idx);
                cal_at_trig = d.calibrated_pos(trig_idx);
            end
        else
            trig_idx = find(d.state_out == 2, 1);
            if ~isempty(trig_idx)
                t_trig = d.time(trig_idx);
                raw_at_trig = d.rad_pos(trig_idx);
                cal_at_trig = d.calibrated_pos(trig_idx);
            else
                t_trig = NaN; raw_at_trig = NaN; cal_at_trig = NaN;
            end
        end

        % ตรวจสอบค่าหลัง Homing
        idx_after = find(d.state_out == 2);
        if ~isempty(idx_after)
            cal_mean_locked = mean(d.calibrated_pos(idx_after));
            cal_sd_locked   = std(d.calibrated_pos(idx_after));
        else
            cal_mean_locked = NaN;
            cal_sd_locked = NaN;
        end

        t_info = struct();
        t_info.filename = h_files(k).name;
        t_info.trigger_time_s = t_trig;
        t_info.raw_offset_rad = raw_at_trig;
        t_info.calibrated_at_trigger = cal_at_trig;
        t_info.cal_mean_locked = cal_mean_locked;
        t_info.cal_sd_locked = cal_sd_locked;
        t_info.data = d;
        homing_trials = [homing_trials, t_info];
    end
    stats_data.homing = homing_trials;

    %% 6. การวิเคราะห์ Wrap-around Logic (Overflow 65535 -> 0 และ Underflow 0 -> 65535)
    wrap_dir = fullfile(data_dir, 'wrap_around');
    wrap_results = struct();

    % Wrap-max (Overflow)
    w_max_files = dir(fullfile(wrap_dir, 'Wrap-max*.mat'));
    wrap_max_trials = [];
    for k = 1:length(w_max_files)
        d = load_lab_data(fullfile(wrap_dir, w_max_files(k).name));
        d_raw = diff(d.raw_count);
        roll_idx = find(d_raw < -30000); % กระโดดลงจาก 65535 -> 0

        info = struct();
        info.filename = w_max_files(k).name;
        info.num_wraps = length(roll_idx);
        if ~isempty(roll_idx)
            info.first_wrap_time = d.time(roll_idx(1));
            info.raw_before = d.raw_count(roll_idx(1));
            info.raw_after  = d.raw_count(roll_idx(1) + 1);
            info.unwrapped_before = d.rel_pulses(roll_idx(1));
            info.unwrapped_after  = d.rel_pulses(roll_idx(1) + 1);
            info.continuity_error = abs((d.rel_pulses(roll_idx(1)+1) - d.rel_pulses(roll_idx(1))) - ...
                                        (info.raw_after + 65536 - info.raw_before));
        else
            info.first_wrap_time = NaN;
            info.raw_before = NaN; info.raw_after = NaN;
            info.unwrapped_before = NaN; info.unwrapped_after = NaN;
            info.continuity_error = 0;
        end
        info.peak_unwrapped_pulses = max(d.rel_pulses);
        info.peak_deg_continuous = max(d.deg_con);
        info.data = d;
        wrap_max_trials = [wrap_max_trials, info];
    end

    % Wrap-min (Underflow)
    w_min_files = dir(fullfile(wrap_dir, 'Wrap-min*.mat'));
    wrap_min_trials = [];
    for k = 1:length(w_min_files)
        d = load_lab_data(fullfile(wrap_dir, w_min_files(k).name));
        d_raw = diff(d.raw_count);
        roll_idx = find(d_raw > 30000); % กระโดดขึ้นจาก 0 -> 65535

        info = struct();
        info.filename = w_min_files(k).name;
        info.num_wraps = length(roll_idx);
        if ~isempty(roll_idx)
            info.first_wrap_time = d.time(roll_idx(1));
            info.raw_before = d.raw_count(roll_idx(1));
            info.raw_after  = d.raw_count(roll_idx(1) + 1);
            info.unwrapped_before = d.rel_pulses(roll_idx(1));
            info.unwrapped_after  = d.rel_pulses(roll_idx(1) + 1);
            info.continuity_error = abs((d.rel_pulses(roll_idx(1)+1) - d.rel_pulses(roll_idx(1))) - ...
                                        (info.raw_after - 65536 - info.raw_before));
        else
            info.first_wrap_time = NaN;
            info.raw_before = NaN; info.raw_after = NaN;
            info.unwrapped_before = NaN; info.unwrapped_after = NaN;
            info.continuity_error = 0;
        end
        info.min_unwrapped_pulses = min(d.rel_pulses);
        info.min_deg_continuous = min(d.deg_con);
        info.data = d;
        wrap_min_trials = [wrap_min_trials, info];
    end

    wrap_results.max = wrap_max_trials;
    wrap_results.min = wrap_min_trials;
    stats_data.wraparound = wrap_results;

    fprintf('>> ประมวลผลข้อมูลสถิติเสร็จสิ้นเรียบร้อย!\n');
end
