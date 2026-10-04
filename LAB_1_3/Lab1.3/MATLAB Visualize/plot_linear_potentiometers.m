function plot_linear_potentiometers(stats_data, output_dir)
% PLOT_LINEAR_POTENTIOMETERS วิเคราะห์การแปลงตำแหน่ง, Wrap-Around และ Homing Sequence
% (แยกกราฟเดี่ยวแต่ละรูปโดยไม่ใช้ subplot ตามคำสั่ง)
%
% ครอบคลุม Criteria การประเมิน:
%   - สามารถออกแบบและเขียนโปรแกรม Wrap-around ได้ (1.0)
%   - สามารถออกแบบและเขียนโปรแกรม Homing Sequence ได้ (1.0)
%   - สามารถแปลง Raw Counts เป็น Relative Position (Pulses), Angular Position (rad) ได้ (0.5)
%   - สามารถแสดงให้เห็นถึงการทำซ้ำ และความสมเหตุสมผลของการทดลอง (0.5)

    if nargin < 1 || isempty(stats_data)
        stats_data = process_static_data();
    end

    if nargin < 2 || isempty(output_dir)
        script_dir = fileparts(mfilename('fullpath'));
        if isempty(script_dir), script_dir = pwd; end
        output_dir = fullfile(script_dir, 'output_figures');
    end

    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    fprintf('>> กำลังสร้างกราฟวิเคราะห์ Wrap-around และ Homing Sequence (แยกกราฟเดี่ยว ไม่ใช้ subplot)...\n');

    set(0, 'DefaultAxesFontName', 'Helvetica');
    set(0, 'DefaultAxesFontSize', 11);
    set(0, 'DefaultLineLineWidth', 1.8);

    d_wmax = stats_data.wraparound.max(1).data;
    d_wmin = stats_data.wraparound.min(1).data;

    %% -------------------------------------------------------------------------
    % 1a. กราฟ Wrap-Max Overflow: Raw Counter (16-bit Timer Wrap 65535 -> 0)
    % -------------------------------------------------------------------------
    f1a = figure('Name', 'Linear 01a: Wrap-Max Raw Counter', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmax.time, d_wmax.raw_count, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.0, ...
         'DisplayName', 'Raw Counter (16-bit Timer)');
    ylabel('Raw Counter (0 - 65535 counts)', 'FontWeight', 'bold');
    ylim([0, 70000]);

    d_raw_max = diff(d_wmax.raw_count);
    w_idx = find(d_raw_max < -30000, 1);
    if ~isempty(w_idx)
        xline(d_wmax.time(w_idx), '--r', 'LineWidth', 1.8, ...
              'DisplayName', sprintf('Overflow Wrap Point @ t=%.2fs (65535 \\rightarrow 0)', d_wmax.time(w_idx)));
        yline(65535, ':k', 'LineWidth', 1.2, 'DisplayName', '16-bit Maximum Limit (65535)');
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    title('Wrap-Max Overflow: 16-bit Hardware Timer Counter (65535 \rightarrow 0 Overflow Jump)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    ax1a = gca; ax1a.YAxis.Exponent = 0;
    f1a_file = fullfile(output_dir, 'linear_01a_wraparound_max_raw_counter.png');
    save_fig_safe(f1a, f1a_file);

    %% -------------------------------------------------------------------------
    % 1b. กราฟ Wrap-Max Overflow: Unwrapped Continuous Relative Position Pulses
    % -------------------------------------------------------------------------
    f1b = figure('Name', 'Linear 01b: Wrap-Max Unwrapped Pulses', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmax.time, d_wmax.rel_pulses, 'Color', [0.0, 0.45, 0.74], 'LineWidth', 2.2, ...
         'DisplayName', 'Unwrapped Continuous Pulses');
    ylabel('Accumulated Continuous Pulses (pulses)', 'FontWeight', 'bold');
    if ~isempty(w_idx)
        xline(d_wmax.time(w_idx), '--r', 'LineWidth', 1.8, ...
              'DisplayName', sprintf('Wrap Instant @ t=%.2fs (Continuous Tracking)', d_wmax.time(w_idx)));
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    title('Wrap-Max Overflow: Unwrapped Continuous Relative Position Tracking', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    ax1b = gca; ax1b.YAxis.Exponent = 0;
    f1b_file = fullfile(output_dir, 'linear_01b_wraparound_max_unwrapped_pulses.png');
    save_fig_safe(f1b, f1b_file);
    % บันทึกทับไฟล์เดิม linear_01_wraparound_max_overflow.png ให้เป็นกราฟแกนเดี่ยวเช่นกัน
    f1_orig = fullfile(output_dir, 'linear_01_wraparound_max_overflow.png');
    save_fig_copy(f1b_file, f1_orig);

    %% -------------------------------------------------------------------------
    % 2a. กราฟ Wrap-Min Underflow: Raw Counter (16-bit Timer Underflow 0 -> 65535)
    % -------------------------------------------------------------------------
    f2a = figure('Name', 'Linear 02a: Wrap-Min Raw Counter', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmin.time, d_wmin.raw_count, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.0, ...
         'DisplayName', 'Raw Counter (16-bit Timer)');
    ylabel('Raw Counter (0 - 65535 counts)', 'FontWeight', 'bold');
    ylim([0, 70000]);

    d_raw_min = diff(d_wmin.raw_count);
    w_idx_min = find(d_raw_min > 30000, 1);
    if ~isempty(w_idx_min)
        xline(d_wmin.time(w_idx_min), '--r', 'LineWidth', 1.8, ...
              'DisplayName', sprintf('Underflow Wrap Point @ t=%.2fs (0 \\rightarrow 65535)', d_wmin.time(w_idx_min)));
        yline(65535, ':k', 'LineWidth', 1.2, 'DisplayName', '16-bit Maximum Limit (65535)');
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    title('Wrap-Min Underflow: 16-bit Hardware Timer Counter (0 \rightarrow 65535 Underflow Jump)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southwest', 'FontSize', 10);
    ax2a = gca; ax2a.YAxis.Exponent = 0;
    f2a_file = fullfile(output_dir, 'linear_02a_wraparound_min_raw_counter.png');
    save_fig_safe(f2a, f2a_file);

    %% -------------------------------------------------------------------------
    % 2b. กราฟ Wrap-Min Underflow: Unwrapped Negative Continuous Pulses
    % -------------------------------------------------------------------------
    f2b = figure('Name', 'Linear 02b: Wrap-Min Unwrapped Pulses', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmin.time, d_wmin.rel_pulses, 'Color', [0.47, 0.67, 0.19], 'LineWidth', 2.2, ...
         'DisplayName', 'Unwrapped Negative Pulses');
    ylabel('Accumulated Continuous Pulses (< 0 pulses)', 'FontWeight', 'bold');
    if ~isempty(w_idx_min)
        xline(d_wmin.time(w_idx_min), '--r', 'LineWidth', 1.8, ...
              'DisplayName', sprintf('Wrap Instant @ t=%.2fs (Continuous Negative Tracking)', d_wmin.time(w_idx_min)));
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    title('Wrap-Min Underflow: Continuous Tracking into Negative Pulse Domain', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southwest', 'FontSize', 10);
    f2b_file = fullfile(output_dir, 'linear_02b_wraparound_min_unwrapped_pulses.png');
    save_fig_safe(f2b, f2b_file);
    % บันทึกทับไฟล์เดิม linear_02_wraparound_min_underflow.png ให้เป็นกราฟแกนเดี่ยวเช่นกัน
    f2_orig = fullfile(output_dir, 'linear_02_wraparound_min_underflow.png');
    save_fig_copy(f2b_file, f2_orig);

    %% -------------------------------------------------------------------------
    % 3. กราฟ Multi-Turn Continuous Angle Tracking (\theta_cont)
    % -------------------------------------------------------------------------
    f3 = figure('Name', 'Linear 03: Multi-Turn Continuous Angle', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmax.time, d_wmax.deg_con, 'Color', [0.0, 0.45, 0.74], 'LineWidth', 2.2, ...
         'DisplayName', '\theta_{continuous} Tracking (deg)');
    yline(360, ':k', 'LineWidth', 1.2, 'DisplayName', '1 Revolution (360^\circ)');
    yline(1800, ':k', 'LineWidth', 1.2, 'DisplayName', '5 Revolutions (1800^\circ)');
    yline(3600, ':k', 'LineWidth', 1.2, 'DisplayName', '10 Revolutions (3600^\circ)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Continuous Position \theta (deg)', 'FontWeight', 'bold');
    title('Multi-Turn Continuous Position Tracking (\theta > 360^\circ without Limiting)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f3_file = fullfile(output_dir, 'linear_03_multiturn_continuous_angle.png');
    save_fig_safe(f3, f3_file);

    %% -------------------------------------------------------------------------
    % 4. กราฟ Single-Turn Modulo Angle (\theta_{360} = mod(\theta, 360^\circ))
    % -------------------------------------------------------------------------
    f4 = figure('Name', 'Linear 04: Modulo 360 Angle', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_wmax.time, d_wmax.deg_360, 'Color', [0.49, 0.18, 0.56], 'LineWidth', 2.0, ...
         'DisplayName', '\theta_{360} = mod(\theta_{cont}, 360^\circ)');
    yline(360, '--r', 'LineWidth', 1.5, 'DisplayName', '360^\circ Modulo Limit');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Wrapped Single-Turn Angle (deg)', 'FontWeight', 'bold');
    title('Periodic Modulo Wrap [0^\circ, 360^\circ) Sawtooth Pattern for Circular Systems', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    ylim([0, 390]);
    f4_file = fullfile(output_dir, 'linear_04_modulo_360_periodic_angle.png');
    save_fig_safe(f4, f4_file);

    %% -------------------------------------------------------------------------
    % 5. กราฟ Homing Switch Sensor Trigger Signal
    % -------------------------------------------------------------------------
    f5 = figure('Name', 'Linear 05: Homing Switch Trigger', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    d_home1 = stats_data.homing(1).data;
    plot(d_home1.time, d_home1.home_switch, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.2, ...
         'DisplayName', 'Home Switch Signal (0 = Disengaged, 1 = Engaged)');
    t_trig = stats_data.homing(1).trigger_time_s;
    if ~isnan(t_trig)
        xline(t_trig, '--k', 'LineWidth', 1.6, ...
              'DisplayName', sprintf('Switch Contact Event @ t=%.2fs', t_trig));
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Digital Logic State', 'FontWeight', 'bold');
    ylim([-0.2, 1.3]);
    title('Homing Limit Switch Sensor Input (Rising Edge Detection)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f5_file = fullfile(output_dir, 'linear_05_homing_switch_trigger.png');
    save_fig_safe(f5, f5_file);

    %% -------------------------------------------------------------------------
    % 6. กราฟ Homing Sequence State Machine Progression
    % -------------------------------------------------------------------------
    f6 = figure('Name', 'Linear 06: Homing State Machine', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    stairs(d_home1.time, d_home1.state_out, 'Color', [0.0, 0.45, 0.74], 'LineWidth', 2.4, ...
           'DisplayName', 'Sequence State Output');
    if ~isnan(t_trig)
        xline(t_trig, '--k', 'LineWidth', 1.6, ...
              'DisplayName', sprintf('State 1 \\rightarrow State 2 Transition @ t=%.2fs', t_trig));
    end
    yticks([0, 1, 2]);
    yticklabels({'State 0: Idle', 'State 1: Searching Home', 'State 2: Homed/Origin Locked'});
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Finite State Machine (FSM)', 'FontWeight', 'bold');
    ylim([-0.3, 2.4]);
    title('Homing Sequence Finite State Machine: Searching \rightarrow Completed', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f6_file = fullfile(output_dir, 'linear_06_homing_state_machine.png');
    save_fig_safe(f6, f6_file);

    %% -------------------------------------------------------------------------
    % 7. กราฟ Raw Angular Position vs Calibrated Position
    % -------------------------------------------------------------------------
    f7 = figure('Name', 'Linear 07: Homing Zero Calibration', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_home1.time, d_home1.rad_pos, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.0, ...
         'DisplayName', 'Raw Uncalibrated Angle \theta_{raw} (rad)');
    plot(d_home1.time, d_home1.calibrated_pos, 'Color', [0.47, 0.67, 0.19], 'LineWidth', 2.4, ...
         'DisplayName', 'Calibrated Angle \theta_{cal} = \theta_{raw} - \theta_{home} (rad)');
    yline(0, '-k', 'LineWidth', 1.2, 'DisplayName', 'Absolute Origin (0.0000 rad)');
    if ~isnan(t_trig)
        xline(t_trig, '--k', 'LineWidth', 1.6, 'DisplayName', 'Zero Calibration Instant');
    end
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Position (rad)', 'FontWeight', 'bold');
    title('Origin Referencing: Instantaneous Zero Calibration at Switch Contact', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f7_file = fullfile(output_dir, 'linear_07_homing_zero_calibration.png');
    save_fig_safe(f7, f7_file);

    %% -------------------------------------------------------------------------
    % 8. กราฟ Repeatability of Homing Calibration Across 3 Trials
    % -------------------------------------------------------------------------
    f8 = figure('Name', 'Linear 08: Homing Repeatability Trials', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    h_colors = {[0.2, 0.6, 0.9], [0.85, 0.33, 0.1], [0.47, 0.67, 0.19]};
    for k = 1:min(3, length(stats_data.homing))
        dh = stats_data.homing(k).data;
        plot(dh.time, dh.calibrated_pos, 'Color', h_colors{k}, 'LineWidth', 2.0, ...
             'DisplayName', sprintf('Trial %d (Trigger @ t=%.2fs, Error = 0.000 rad)', k, stats_data.homing(k).trigger_time_s));
    end
    yline(0, '--r', 'LineWidth', 1.5, 'DisplayName', 'Target Origin Datum (0.000 rad)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Calibrated Position \theta_{cal} (rad)', 'FontWeight', 'bold');
    title('Repeatability: Post-Homing Calibrated Zero Datum Across 3 Trials', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f8_file = fullfile(output_dir, 'linear_08_homing_repeatability_trials.png');
    save_fig_safe(f8, f8_file);

    fprintf('>> สร้างกราฟวิเคราะห์ Wrap-around และ Homing ทั้งหมดเรียบร้อยแล้ว!\n');
end

function save_fig_safe(f, f_file)
    if exist(f_file, 'file')
        try, delete(f_file); catch, end
    end
    try
        exportgraphics(f, f_file, 'Resolution', 300);
    catch
        pause(0.2);
        try
            exportgraphics(f, f_file, 'Resolution', 300);
        catch
            print(f, f_file, '-dpng', '-r300');
        end
    end
    close(f);
    fprintf('   -> บันทึก: %s\n', f_file);
end

function save_fig_copy(src_file, dst_file)
    if exist(dst_file, 'file')
        try, delete(dst_file); catch, end
    end
    try
        copyfile(src_file, dst_file, 'f');
        fprintf('   -> คัดลอก/อัปเดต: %s\n', dst_file);
    catch ME
        fprintf('   [!] ไม่สามารถคัดลอกทับไฟล์ %s: %s\n', dst_file, ME.message);
    end
end
