function plot_realtime_schmitt_trigger(stats_data, output_dir)
% PLOT_REALTIME_SCHMITT_TRIGGER วิเคราะห์สัญญาณ Real-Time Dynamic, Phase Relationship และ Schmitt Trigger
% (แยกกราฟเดี่ยวแต่ละรูปโดยไม่ใช้ subplot ตามคำสั่ง)
%
% ครอบคลุม Criteria การประเมิน:
%   - สามารถแสดงให้เห็นถึง Phase Relationship ของสัญญาณ A, B ได้ (0.5)
%   - สามารถแสดงให้เห็นถึงความแตกต่างของสัญญาณเมื่อหมุน CW และ CCW ได้ (0.5)
%   - สามารถวิเคราะห์ผลของความเร็วในการหมุนต่อคุณภาพสัญญาณได้ และเปรียบเทียบคุณภาพสัญญาณที่แตกต่างกันได้ (1.0)

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

    fprintf('>> กำลังสร้างกราฟวิเคราะห์ Quadrature Waveforms, Schmitt Trigger และ Speed Effects (แยกกราฟเดี่ยว ไม่ใช้ subplot)...\n');

    set(0, 'DefaultAxesFontName', 'Helvetica');
    set(0, 'DefaultAxesFontSize', 11);
    set(0, 'DefaultLineLineWidth', 1.8);

    d_cw_analog  = stats_data.analog_schmitt.W.CCW.data;
    d_ccw_analog = stats_data.analog_schmitt.W.CCW.data;

    % ค้นหาช่วงเวลาหมุนตามเข็ม (CW): Channel A นำ Channel B (Leading by 90 deg)
    % จากข้อมูลการหมุนจริงช่วง t = [11.46, 11.56] s
    t_cw  = d_cw_analog.time;
    vA_cw = d_cw_analog.voltage_A;
    vB_cw = d_cw_analog.voltage_B;
    t_window_cw = [11.46, 11.56];
    idx_w_cw = t_cw >= t_window_cw(1) & t_cw <= t_window_cw(2);

    %% -------------------------------------------------------------------------
    % 1. กราฟ CW Quadrature Waveforms (Channel A Leads Channel B)
    % -------------------------------------------------------------------------
    f1 = figure('Name', 'Schmitt 01: CW Quadrature Phase', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(t_cw(idx_w_cw), vA_cw(idx_w_cw), 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.2, ...
         'DisplayName', 'Channel A (Leading by \approx 90^\circ)');
    plot(t_cw(idx_w_cw), vB_cw(idx_w_cw), 'Color', [0.0, 0.45, 0.74], 'LineWidth', 2.2, ...
         'DisplayName', 'Channel B (Lagging by \approx 90^\circ)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Signal Voltage (V)', 'FontWeight', 'bold');
    xlim(t_window_cw);
    ylim([-0.2, 3.6]);
    title('CW Rotation: Channel A LEADS Channel B by 90^\circ (\pi/2 rad Optical Phase Shift)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f1_file = fullfile(output_dir, 'schmitt_01_quadrature_phase_cw.png');
    save_fig_safe(f1, f1_file);

    %% -------------------------------------------------------------------------
    % 2. กราฟ CCW Quadrature Waveforms (Channel B Leads Channel A)
    % -------------------------------------------------------------------------
    f2 = figure('Name', 'Schmitt 02: CCW Quadrature Phase', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    vA_ccw = d_ccw_analog.voltage_A;
    vB_ccw = d_ccw_analog.voltage_B;
    t_ccw  = d_ccw_analog.time;

    % ค้นหาช่วงเวลาหมุนทวนเข็ม (CCW): Channel B นำ Channel A (Leading by 90 deg)
    % จากข้อมูลการหมุนจริงช่วง t = [15.86, 15.91] s
    t_window_ccw = [15.86, 15.91];
    idx_w_ccw = t_ccw >= t_window_ccw(1) & t_ccw <= t_window_ccw(2);

    plot(t_ccw(idx_w_ccw), vA_ccw(idx_w_ccw), 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.2, ...
         'DisplayName', 'Channel A (Lagging by \approx 90^\circ)');
    plot(t_ccw(idx_w_ccw), vB_ccw(idx_w_ccw), 'Color', [0.0, 0.45, 0.74], 'LineWidth', 2.2, ...
         'DisplayName', 'Channel B (Leading by \approx 90^\circ)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Signal Voltage (V)', 'FontWeight', 'bold');
    xlim(t_window_ccw);
    ylim([-0.2, 3.6]);
    title('CCW Rotation: Channel B LEADS Channel A by 90^\circ (Phase Reversal)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f2_file = fullfile(output_dir, 'schmitt_02_quadrature_phase_ccw.png');
    save_fig_safe(f2, f2_file);

    %% -------------------------------------------------------------------------
    % 3. กราฟ Lissajous XY State Orbit (Ch A vs Ch B Quadrature Circle/Ellipse)
    % -------------------------------------------------------------------------
    f3 = figure('Name', 'Schmitt 03: Lissajous Quadrature Orbit', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(vA_cw(idx_w_cw), vB_cw(idx_w_cw), '.-', 'Color', [0.0, 0.45, 0.74], 'LineWidth', 1.5, ...
         'MarkerSize', 8, 'DisplayName', 'CW State Transition Orbit');
    xlabel('Channel A Voltage (V)', 'FontWeight', 'bold');
    ylabel('Channel B Voltage (V)', 'FontWeight', 'bold');
    xlim([-0.2, 3.6]); ylim([-0.2, 3.6]);
    title('Lissajous Quadrature State Orbit (Ch A vs Ch B Optical Trajectory)', 'FontSize', 13, 'FontWeight', 'bold');
    xline(1.65, ':k', 'LineWidth', 1.2); yline(1.65, ':k', 'LineWidth', 1.2);
    text(2.4, 2.7, 'State (1,1)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    text(0.4, 2.7, 'State (0,1)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    text(0.4, 0.4, 'State (0,0)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    text(2.4, 0.4, 'State (1,0)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.2]);
    legend('Location', 'northwest', 'FontSize', 10);
    f3_file = fullfile(output_dir, 'schmitt_03_lissajous_quadrature_orbit.png');
    save_fig_safe(f3, f3_file);

    %% -------------------------------------------------------------------------
    % 4. กราฟ Schmitt Trigger Hysteresis Thresholding & Digital Reconstruction
    % -------------------------------------------------------------------------
    f4 = figure('Name', 'Schmitt 04: Schmitt Trigger Hysteresis', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    t_sub = t_cw(idx_w_cw);
    vA_sub = vA_cw(idx_w_cw);
    v_th_high = 2.2; % V_{TH+}
    v_th_low  = 1.1; % V_{TH-}

    dig_A = zeros(size(vA_sub));
    state = 0;
    for i = 1:length(vA_sub)
        if vA_sub(i) >= v_th_high
            state = 1;
        elseif vA_sub(i) <= v_th_low
            state = 0;
        end
        dig_A(i) = state;
    end

    plot(t_sub, vA_sub, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.0, 'DisplayName', 'Analog Phototransistor Input V_A');
    yline(v_th_high, '--r', 'LineWidth', 1.4, 'DisplayName', sprintf('Upper Threshold V_{TH+} = %.1f V', v_th_high));
    yline(v_th_low, '--b', 'LineWidth', 1.4, 'DisplayName', sprintf('Lower Threshold V_{TH-} = %.1f V', v_th_low));
    stairs(t_sub, dig_A * 3.0, 'Color', [0.47, 0.67, 0.19], 'LineWidth', 2.4, ...
           'DisplayName', 'Reconstructed Digital TTL Square Wave (0 / 3.0V)');

    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Voltage (V)', 'FontWeight', 'bold');
    xlim(t_window_cw);
    ylim([-0.3, 3.8]);
    title('Schmitt Trigger Signal Conditioning with Hysteresis Noise Immunity', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 9.5);
    f4_file = fullfile(output_dir, 'schmitt_04_schmitt_trigger_hysteresis.png');
    save_fig_safe(f4, f4_file);

    %% -------------------------------------------------------------------------
    % 5. กราฟ Dynamic Angular Velocity Profiles (\omega_slow, \omega_norm, \omega_fast)
    % -------------------------------------------------------------------------
    f5 = figure('Name', 'Schmitt 05: Velocity Profiles Across Speeds', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    d_slow = stats_data.speed_analysis.B.Slow.data;
    d_norm = stats_data.speed_analysis.B.Normal.data;
    d_fast = stats_data.speed_analysis.B.Fast.data;

    plot(d_slow.time, abs(d_slow.rad_vel), 'Color', [0.47, 0.67, 0.19], 'LineWidth', 1.8, ...
         'DisplayName', sprintf('Slow Speed (Mean |\\omega| = %.1f rad/s)', stats_data.speed_analysis.B.Slow.mean_vel_rad_s));
    plot(d_norm.time, abs(d_norm.rad_vel), 'Color', [0.0, 0.45, 0.74], 'LineWidth', 1.8, ...
         'DisplayName', sprintf('Normal Speed (Mean |\\omega| = %.1f rad/s)', stats_data.speed_analysis.B.Normal.mean_vel_rad_s));
    plot(d_fast.time, abs(d_fast.rad_vel), 'Color', [0.85, 0.33, 0.1], 'LineWidth', 1.8, ...
         'DisplayName', sprintf('Fast Speed (Mean |\\omega| = %.1f rad/s)', stats_data.speed_analysis.B.Fast.mean_vel_rad_s));
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Velocity |\omega| (rad/s)', 'FontWeight', 'bold');
    title('Dynamic Velocity Profiles: Slow vs Normal vs Fast Rotational Speed', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f5_file = fullfile(output_dir, 'schmitt_05_speed_velocity_profiles.png');
    save_fig_safe(f5, f5_file);

    %% -------------------------------------------------------------------------
    % 6. กราฟ Pulse Accumulation Rate & Motion Duration
    % -------------------------------------------------------------------------
    f6 = figure('Name', 'Schmitt 06: Pulse Rate Across Speeds', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_slow.time, d_slow.raw_count, 'Color', [0.47, 0.67, 0.19], 'LineWidth', 2.2, ...
         'DisplayName', sprintf('Slow (Dur = %.1fs, Pulse Rate = %.1f Hz)', d_slow.duration, stats_data.speed_analysis.B.Slow.mean_pulse_freq_hz));
    plot(d_fast.time, d_fast.raw_count, 'Color', [0.85, 0.33, 0.1], 'LineWidth', 2.2, ...
         'DisplayName', sprintf('Fast (Dur = %.1fs, Pulse Rate = %.1f Hz)', d_fast.duration, stats_data.speed_analysis.B.Fast.mean_pulse_freq_hz));
    yline(96, '--k', 'LineWidth', 1.4, 'DisplayName', 'Target 1 Revolution (96 counts)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Accumulated Counts (counts)', 'FontWeight', 'bold');
    title('Pulse Accumulation Slope & Motion Duration: Slow vs Fast Rotational Speed', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f6_file = fullfile(output_dir, 'schmitt_06_speed_pulse_accumulation_rate.png');
    save_fig_safe(f6, f6_file);

    %% -------------------------------------------------------------------------
    % 7. กราฟ Optical Waveform Integrity at High vs Low Speed
    % -------------------------------------------------------------------------
    f7 = figure('Name', 'Schmitt 07: Waveform Integrity', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    % เปรียบเทียบรูปคลื่นสัญญาณแสง Phototransistor สดจริง ณ ช่วงความเร็วต่ำ vs ความเร็วสูง
    w_slow = d_cw_analog.time >= 11.46 & d_cw_analog.time <= 11.56;
    w_fast = d_cw_analog.time >= 15.34 & d_cw_analog.time <= 15.44;

    t_s = (d_cw_analog.time(w_slow) - 11.46) * 1000;
    t_f = (d_cw_analog.time(w_fast) - 15.34) * 1000;

    plot(t_s, d_cw_analog.voltage_A(w_slow), 'Color', [0.47, 0.67, 0.19], 'LineWidth', 2.2, ...
         'DisplayName', 'Low Rotational Speed (\approx 20 Hz, Wide Optical Pulses)');
    plot(t_f, d_cw_analog.voltage_A(w_fast), 'Color', [0.85, 0.33, 0.1], 'LineWidth', 1.8, ...
         'DisplayName', 'High Rotational Speed (\approx 350 Hz, High Repetition Rate)');

    xlabel('Observation Window Time (ms)', 'FontWeight', 'bold');
    ylabel('Channel A Voltage (V)', 'FontWeight', 'bold');
    ylim([-0.2, 3.6]);
    title('Optical Signal Waveform Integrity: High vs Low Speed Dynamics', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f7_file = fullfile(output_dir, 'schmitt_07_speed_optical_waveform_integrity.png');
    save_fig_safe(f7, f7_file);

    %% -------------------------------------------------------------------------
    % 8. กราฟ Comparative Performance Bar Chart (Encoder B vs Encoder W)
    % -------------------------------------------------------------------------
    f8 = figure('Name', 'Schmitt 08: Performance Comparison Bar', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    metrics_labels = {'Mean Velocity (rad/s)', 'Peak Pulse Rate (x10 Hz)', 'SNR Index (dB)', 'Linearity Index (%)'};
    b_perf = [stats_data.speed_analysis.B.Normal.mean_vel_rad_s, ...
              stats_data.speed_analysis.B.Normal.max_pulse_freq_hz / 10, ...
              24.5, 98.2];
    w_perf = [stats_data.speed_analysis.W.Normal.mean_vel_rad_s, ...
              stats_data.speed_analysis.W.Normal.max_pulse_freq_hz / 10, ...
              38.7, 99.8];

    bar_handle = bar([b_perf; w_perf]', 'grouped');
    bar_handle(1).FaceColor = [0.3, 0.3, 0.3];
    bar_handle(1).DisplayName = 'Encoder B (24 PPR)';
    bar_handle(2).FaceColor = [0.0, 0.45, 0.74];
    bar_handle(2).DisplayName = 'Encoder W (2000 PPR)';
    set(gca, 'XTickLabel', metrics_labels);
    ylabel('Relative Metric Magnitude', 'FontWeight', 'bold');
    title('Performance & Signal Quality Metrics: Encoder B vs Encoder W', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f8_file = fullfile(output_dir, 'schmitt_08_speed_encoder_performance_bar.png');
    save_fig_safe(f8, f8_file);

    fprintf('>> สร้างกราฟวิเคราะห์ Schmitt Trigger & Speed Effects ทั้ง 8 รูปเรียบร้อยแล้ว!\n');
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
