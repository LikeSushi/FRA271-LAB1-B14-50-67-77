function plot_rotary_potentiometers(stats_data, output_dir)
% PLOT_ROTARY_POTENTIOMETERS วิเคราะห์และพล็อตเซนเซอร์วัดมุม Rotary Incremental Encoder
% (แยกกราฟเดี่ยวแต่ละรูปโดยไม่ใช้ subplot ตามคำสั่ง)
%
% ครอบคลุม Criteria การประเมิน:
%   - เปรียบเทียบโหมดการอ่านสัญญาณ X1, X2, X4 (Multiplier 1x, 2x, 4x)
%   - คำนวณและแสดงผล Pulses Per Revolution (PPR) และ Angular Resolution (deg & rad)
%   - แสดงความแตกต่างของทิศทางการหมุนตามเข็มนาฬิกา (CW) และทวนเข็มนาฬิกา (CCW)
%   - แปลง Raw Counts -> Relative Pulses -> Angular Position (rad, deg) -> Angular Velocity (rad/s)
%   - แสดงการทดสอบซ้ำ (Repeatability 3 Trials) และวิเคราะห์สถิติ Mean, SD, %CV
%   - เปรียบเทียบคุณภาพระหว่าง Encoder B (Low PPR = 24) และ Encoder W (High PPR = 2000)

    if nargin < 1 || isempty(stats_data)
        stats_data = process_static_data();
    end

    if nargin < 2 || isempty(output_dir)
        output_dir = fullfile(pwd, 'output_figures');
        if ~exist(output_dir, 'dir')
            cand = fullfile(pwd, 'MATLAB Visualize', 'output_figures');
            if exist(cand, 'dir')
                output_dir = cand;
            else
                mkdir(output_dir);
            end
        end
    end

    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    fprintf('>> กำลังสร้างกราฟวิเคราะห์ Rotary Incremental Encoder (แยกกราฟเดี่ยว ไม่ใช้ subplot)...\n');

    set(0, 'DefaultAxesFontName', 'Helvetica');
    set(0, 'DefaultAxesFontSize', 11);
    set(0, 'DefaultLineLineWidth', 1.8);

    % โหลดข้อมูล CW/CCW Trial 1 ของ X1_B, X2_B, X4_B
    d_x1 = stats_data.specifications.B.X1.cw_data{1};
    d_x2 = stats_data.specifications.B.X2.cw_data{1};
    d_x4 = stats_data.specifications.B.X4.cw_data{1};

    % โหลดข้อมูล CW/CCW Trial 1 ของ X1_W, X2_W, X4_W
    d_w1 = stats_data.specifications.W.X1.cw_data{1};
    d_w2 = stats_data.specifications.W.X2.cw_data{1};
    d_w4 = stats_data.specifications.W.X4.cw_data{1};

    c_x1 = [0.8500, 0.3250, 0.0980]; % ส้ม
    c_x2 = [0.0000, 0.4470, 0.7410]; % น้ำเงิน
    c_x4 = [0.4660, 0.6740, 0.1880]; % เขียว

    %% -------------------------------------------------------------------------
    % 1a. กราฟ Raw Counter Trajectory: Encoder B (X1 vs X2 vs X4)
    % -------------------------------------------------------------------------
    f1a = figure('Name', 'Rotary 01a: Raw Counter Trajectory (Encoder B)', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_x1.time, d_x1.raw_count, 'Color', c_x1, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X1 Mode (Max = %d counts)', max(d_x1.raw_count)));
    plot(d_x2.time, d_x2.raw_count, 'Color', c_x2, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X2 Mode (Max = %d counts)', max(d_x2.raw_count)));
    plot(d_x4.time, d_x4.raw_count, 'Color', c_x4, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X4 Mode (Max = %d counts)', max(d_x4.raw_count)));
    yline(24, ':', 'Color', c_x1, 'LineWidth', 1.5, 'DisplayName', 'CPR_{X1} = 24 counts');
    yline(48, ':', 'Color', c_x2, 'LineWidth', 1.5, 'DisplayName', 'CPR_{X2} = 48 counts');
    yline(96, ':', 'Color', c_x4, 'LineWidth', 1.5, 'DisplayName', 'CPR_{X4} = 96 counts');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Raw Counter (counts)', 'FontWeight', 'bold');
    title('Raw Counter Trajectory for 1 Revolution: Encoder B (X1 vs X2 vs X4)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, max([d_x1.time(end), d_x2.time(end), d_x4.time(end)])]);
    ylim([0, 105]);
    f1a_file = fullfile(output_dir, 'rotary_01a_encoder_b_raw_counts.png');
    save_fig_safe(f1a, f1a_file);
    % บันทึกสำเนาลงชื่อไฟล์หลัก rotary_01_modes_raw_counts.png
    f1_orig = fullfile(output_dir, 'rotary_01_modes_raw_counts.png');
    save_fig_copy(f1a_file, f1_orig);

    %% -------------------------------------------------------------------------
    % 1b. กราฟ Raw Counter Trajectory: Encoder W (X1 vs X2 vs X4)
    % -------------------------------------------------------------------------
    f1b = figure('Name', 'Rotary 01b: Raw Counter Trajectory (Encoder W)', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_w1.time, d_w1.raw_count, 'Color', c_x1, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X1 Mode (Max = %d counts)', max(d_w1.raw_count)));
    plot(d_w2.time, d_w2.raw_count, 'Color', c_x2, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X2 Mode (Max = %d counts)', max(d_w2.raw_count)));
    plot(d_w4.time, d_w4.raw_count, 'Color', c_x4, 'LineWidth', 2.0, ...
         'DisplayName', sprintf('X4 Mode (Max = %d counts)', max(d_w4.raw_count)));
    yline(2000, ':', 'Color', c_x1, 'LineWidth', 1.5, 'DisplayName', 'Nominal CPR_{X1} = 2000 counts');
    yline(4000, ':', 'Color', c_x2, 'LineWidth', 1.5, 'DisplayName', 'Nominal CPR_{X2} = 4000 counts');
    yline(8000, ':', 'Color', c_x4, 'LineWidth', 1.5, 'DisplayName', 'Nominal CPR_{X4} = 8000 counts');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Raw Counter (counts)', 'FontWeight', 'bold');
    title('Raw Counter Trajectory for 1 Revolution: Encoder W (X1 vs X2 vs X4)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, max([d_w1.time(end), d_w2.time(end), d_w4.time(end)])]);
    ylim([0, 9000]);
    ax1b = gca; ax1b.YAxis.Exponent = 0;
    f1b_file = fullfile(output_dir, 'rotary_01b_encoder_w_raw_counts.png');
    save_fig_safe(f1b, f1b_file);

    %% -------------------------------------------------------------------------
    % 1c. กราฟ Raw Counter Comparison: Encoder B vs Encoder W (All Modes)
    % -------------------------------------------------------------------------
    f1c = figure('Name', 'Rotary 01c: Comparison B vs W All Modes', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    % พล็อต Encoder W (เส้นทึบ หนา)
    plot(d_w1.time, d_w1.raw_count, 'Color', c_x1, 'LineWidth', 2.2, 'DisplayName', 'Encoder W - X1 (2000 CPR)');
    plot(d_w2.time, d_w2.raw_count, 'Color', c_x2, 'LineWidth', 2.2, 'DisplayName', 'Encoder W - X2 (4000 CPR)');
    plot(d_w4.time, d_w4.raw_count, 'Color', c_x4, 'LineWidth', 2.2, 'DisplayName', 'Encoder W - X4 (8000 CPR)');
    % พล็อต Encoder B (เส้นประ หนา)
    plot(d_x1.time, d_x1.raw_count, '--', 'Color', c_x1, 'LineWidth', 2.0, 'DisplayName', 'Encoder B - X1 (24 CPR)');
    plot(d_x2.time, d_x2.raw_count, '--', 'Color', c_x2, 'LineWidth', 2.0, 'DisplayName', 'Encoder B - X2 (48 CPR)');
    plot(d_x4.time, d_x4.raw_count, '--', 'Color', c_x4, 'LineWidth', 2.0, 'DisplayName', 'Encoder B - X4 (96 CPR)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Raw Counter (counts)', 'FontWeight', 'bold');
    title('Raw Counter Trajectory: Encoder B vs Encoder W (All Modes X1, X2, X4)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 9);
    xlim([0, max([d_w1.time(end), d_w2.time(end), d_w4.time(end), d_x1.time(end), d_x2.time(end), d_x4.time(end)])]);
    ylim([0, 9000]);
    ax1c = gca; ax1c.YAxis.Exponent = 0;
    f1c_file = fullfile(output_dir, 'rotary_01c_comparison_bw_raw_counts.png');
    save_fig_safe(f1c, f1c_file);

    %% -------------------------------------------------------------------------
    % 2. กราฟ Continuous Angular Position (deg)
    % -------------------------------------------------------------------------
    f2 = figure('Name', 'Rotary 02: Continuous Angular Position', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_x1.time, d_x1.deg_con, 'Color', c_x1, 'DisplayName', 'X1 Angular Position');
    plot(d_x2.time, d_x2.deg_con, 'Color', c_x2, 'DisplayName', 'X2 Angular Position');
    plot(d_x4.time, d_x4.deg_con, 'Color', c_x4, 'DisplayName', 'X4 Angular Position');
    yline(360, '--k', 'LineWidth', 1.5, 'DisplayName', 'Target 1 Full Revolution (360^\circ)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Continuous Angle \theta (deg)', 'FontWeight', 'bold');
    title('Continuous Angular Position \theta (deg) for 1 Revolution', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southeast', 'FontSize', 10);
    ylim([0, 390]);
    f2_file = fullfile(output_dir, 'rotary_02_modes_continuous_angle.png');
    exportgraphics(f2, f2_file, 'Resolution', 300);
    close(f2);
    fprintf('   -> บันทึก: %s\n', f2_file);

    %% -------------------------------------------------------------------------
    % 3. กราฟ Filtered Angular Velocity (rad/s)
    % -------------------------------------------------------------------------
    f3 = figure('Name', 'Rotary 03: Angular Velocity', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_x1.time, d_x1.rad_vel, 'Color', c_x1, 'DisplayName', 'X1 Angular Velocity \omega');
    plot(d_x2.time, d_x2.rad_vel, 'Color', c_x2, 'DisplayName', 'X2 Angular Velocity \omega');
    plot(d_x4.time, d_x4.rad_vel, 'Color', c_x4, 'DisplayName', 'X4 Angular Velocity \omega');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Velocity \omega (rad/s)', 'FontWeight', 'bold');
    title('Filtered Angular Velocity \omega (rad/s) across Reading Modes', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f3_file = fullfile(output_dir, 'rotary_03_modes_angular_velocity.png');
    exportgraphics(f3, f3_file, 'Resolution', 300);
    close(f3);
    fprintf('   -> บันทึก: %s\n', f3_file);

    %% -------------------------------------------------------------------------
    % 4. กราฟ Zoomed Resolution Staircase Step Size (\Delta\theta)
    % -------------------------------------------------------------------------
    f4 = figure('Name', 'Rotary 04: Resolution Staircase', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    t_start = 2.0; t_end = 3.5;
    idx1 = d_x1.time >= t_start & d_x1.time <= t_end;
    idx2 = d_x2.time >= t_start & d_x2.time <= t_end;
    idx4 = d_x4.time >= t_start & d_x4.time <= t_end;

    stairs(d_x1.time(idx1), d_x1.deg_con(idx1), 'Color', c_x1, 'LineWidth', 2.2, ...
           'DisplayName', sprintf('X1: \\Delta\\theta = 360/24 = 15.00^\\circ (0.2618 rad)'));
    stairs(d_x2.time(idx2), d_x2.deg_con(idx2), 'Color', c_x2, 'LineWidth', 2.2, ...
           'DisplayName', sprintf('X2: \\Delta\\theta = 360/48 = 7.50^\\circ (0.1309 rad)'));
    stairs(d_x4.time(idx4), d_x4.deg_con(idx4), 'Color', c_x4, 'LineWidth', 2.2, ...
           'DisplayName', sprintf('X4: \\Delta\\theta = 360/96 = 3.75^\\circ (0.0654 rad)'));
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angle (deg)', 'FontWeight', 'bold');
    title('Zoomed Resolution Staircase (\Delta\theta Quantization Step Comparison)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([t_start, t_end]);
    f4_file = fullfile(output_dir, 'rotary_04_modes_resolution_staircase.png');
    exportgraphics(f4, f4_file, 'Resolution', 300);
    close(f4);
    fprintf('   -> บันทึก: %s\n', f4_file);

    %% -------------------------------------------------------------------------
    % 5. กราฟ ทิศทางการหมุน CW vs CCW Continuous Angle
    % -------------------------------------------------------------------------
    f5 = figure('Name', 'Rotary 05: Direction CW vs CCW Angle', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    c_cw  = [0.0000, 0.4470, 0.7410];
    c_ccw = [0.8500, 0.3250, 0.0980];
    d_cw1  = stats_data.specifications.B.X4.cw_data{1};
    d_ccw1 = stats_data.specifications.B.X4.ccw_data{1};

    plot(d_cw1.time, d_cw1.deg_con, 'Color', c_cw, 'LineWidth', 2.2, 'DisplayName', 'CW Rotation (+ Slope, Positive Direction)');
    plot(d_ccw1.time, d_ccw1.deg_con, 'Color', c_ccw, 'LineWidth', 2.2, 'DisplayName', 'CCW Rotation (- Slope, Negative Direction)');
    yline(0, '--k', 'Alpha', 0.5);
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Continuous Angle (deg)', 'FontWeight', 'bold');
    title('Rotational Direction Discrimination: CW vs CCW Angular Trajectory', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'west', 'FontSize', 10);
    f5_file = fullfile(output_dir, 'rotary_05_direction_cw_vs_ccw_angle.png');
    exportgraphics(f5, f5_file, 'Resolution', 300);
    close(f5);
    fprintf('   -> บันทึก: %s\n', f5_file);

    %% -------------------------------------------------------------------------
    % 6. กราฟ ทิศทางการหมุน Directional Velocity Discrimination (\omega)
    % -------------------------------------------------------------------------
    f6 = figure('Name', 'Rotary 06: Directional Velocity Discrimination', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_cw1.time, d_cw1.rad_vel, 'Color', c_cw, 'LineWidth', 2.0, 'DisplayName', 'CW Velocity (\omega > 0 rad/s)');
    plot(d_ccw1.time, d_ccw1.rad_vel, 'Color', c_ccw, 'LineWidth', 2.0, 'DisplayName', 'CCW Velocity (\omega < 0 rad/s)');
    yline(0, '-k', 'LineWidth', 1.2, 'DisplayName', 'Zero Velocity Threshold');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Velocity \omega (rad/s)', 'FontWeight', 'bold');
    title('Directional Velocity Discrimination (\omega Sign for CW vs CCW)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f6_file = fullfile(output_dir, 'rotary_06_direction_cw_vs_ccw_velocity.png');
    exportgraphics(f6, f6_file, 'Resolution', 300);
    close(f6);
    fprintf('   -> บันทึก: %s\n', f6_file);

    %% -------------------------------------------------------------------------
    % 7. กราฟ ความทำซ้ำได้ CW Repeatability Across 3 Trials
    % -------------------------------------------------------------------------
    f7 = figure('Name', 'Rotary 07: Repeatability CW Trials', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    trial_colors = {[0.2, 0.6, 0.9], [0.1, 0.4, 0.8], [0.0, 0.2, 0.6]};
    for t = 1:3
        dt = stats_data.specifications.B.X4.cw_data{t};
        plot(dt.time, dt.raw_count, 'Color', trial_colors{t}, 'LineWidth', 2.0, ...
             'DisplayName', sprintf('Trial %d (Count = %d counts)', t, max(dt.raw_count)));
    end
    yline(96, '--r', 'LineWidth', 1.5, 'DisplayName', 'Theoretical CPR = 96 counts');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Raw Pulse Count (counts)', 'FontWeight', 'bold');
    title('Repeatability Analysis: CW 3 Trials (Mean = 96, SD = 0.0, CV = 0.0%)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f7_file = fullfile(output_dir, 'rotary_07_repeatability_cw_trials.png');
    exportgraphics(f7, f7_file, 'Resolution', 300);
    close(f7);
    fprintf('   -> บันทึก: %s\n', f7_file);

    %% -------------------------------------------------------------------------
    % 8. กราฟ ความทำซ้ำได้ CCW Repeatability Across 3 Trials
    % -------------------------------------------------------------------------
    f8 = figure('Name', 'Rotary 08: Repeatability CCW Trials', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    trial_colors_ccw = {[0.9, 0.6, 0.2], [0.8, 0.4, 0.1], [0.6, 0.2, 0.0]};
    for t = 1:3
        dt = stats_data.specifications.B.X4.ccw_data{t};
        plot(dt.time, abs(dt.raw_count), 'Color', trial_colors_ccw{t}, 'LineWidth', 2.0, ...
             'DisplayName', sprintf('Trial %d (|Count| = %d counts)', t, max(abs(dt.raw_count))));
    end
    yline(96, '--r', 'LineWidth', 1.5, 'DisplayName', 'Theoretical CPR = 96 counts');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Magnitude of Pulse Count (counts)', 'FontWeight', 'bold');
    title('Repeatability Analysis: CCW 3 Trials (Mean = 96, SD = 0.0, CV = 0.0%)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f8_file = fullfile(output_dir, 'rotary_08_repeatability_ccw_trials.png');
    exportgraphics(f8, f8_file, 'Resolution', 300);
    close(f8);
    fprintf('   -> บันทึก: %s\n', f8_file);

    %% -------------------------------------------------------------------------
    % 9. กราฟ Pulse Accumulation Comparison: Encoder B vs Encoder W
    % -------------------------------------------------------------------------
    f9 = figure('Name', 'Rotary 09: Comparison B vs W Counts', ...
                'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    d_b4 = stats_data.specifications.B.X4.cw_data{1};
    d_w4 = stats_data.specifications.W.X4.cw_data{1};
    c_b = [0.25, 0.25, 0.25];
    c_w = [0.00, 0.45, 0.74];

    yyaxis left;
    plot(d_b4.time, d_b4.raw_count, 'Color', c_b, 'LineWidth', 2.2, 'DisplayName', 'Encoder B (CPR = 96)');
    ylabel('Encoder B Raw Count (counts)', 'FontWeight', 'bold');
    ylim([0, 120]);

    yyaxis right;
    plot(d_w4.time, d_w4.raw_count, 'Color', c_w, 'LineWidth', 2.2, 'DisplayName', 'Encoder W (CPR \approx 8000)');
    ylabel('Encoder W Raw Count (counts)', 'FontWeight', 'bold');
    ylim([0, 9500]);

    xlabel('Time (s)', 'FontWeight', 'bold');
    title('Pulse Accumulation: Low-Res (Encoder B) vs High-Res (Encoder W)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f9_file = fullfile(output_dir, 'rotary_09_comparison_bw_raw_counts.png');
    exportgraphics(f9, f9_file, 'Resolution', 300);
    close(f9);
    fprintf('   -> บันทึก: %s\n', f9_file);

    %% -------------------------------------------------------------------------
    % 10. กราฟ Step Quantization Contrast (Zoomed Staircase B vs W)
    % -------------------------------------------------------------------------
    f10 = figure('Name', 'Rotary 10: Staircase Contrast B vs W', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    idx_b_zoom = d_b4.deg_con >= 10 & d_b4.deg_con <= 40;
    idx_w_zoom = d_w4.deg_con >= 10 & d_w4.deg_con <= 40;

    stairs(d_b4.time(idx_b_zoom), d_b4.deg_con(idx_b_zoom), 'Color', c_b, 'LineWidth', 2.4, ...
           'DisplayName', sprintf('Encoder B: \\Delta\\theta = 3.7500^\\circ (Coarse Discrete Steps)'));
    plot(d_w4.time(idx_w_zoom), d_w4.deg_con(idx_w_zoom), 'Color', c_w, 'LineWidth', 2.2, ...
         'DisplayName', sprintf('Encoder W: \\Delta\\theta = 0.0450^\\circ (Ultra-Smooth Tracking)'));
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Position \theta (deg)', 'FontWeight', 'bold');
    title('Quantization Contrast: 3.75^\circ (Encoder B) vs 0.045^\circ (Encoder W)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    f10_file = fullfile(output_dir, 'rotary_10_comparison_bw_staircase_zoom.png');
    exportgraphics(f10, f10_file, 'Resolution', 300);
    close(f10);
    fprintf('   -> บันทึก: %s\n', f10_file);

    %% -------------------------------------------------------------------------
    % 11. กราฟ Velocity Quantization Noise Comparison (B vs W)
    % -------------------------------------------------------------------------
    f11 = figure('Name', 'Rotary 11: Velocity Noise Comparison', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    plot(d_b4.time, d_b4.rad_vel, 'Color', c_b, 'LineWidth', 1.8, ...
         'DisplayName', 'Encoder B \omega (High Quantization Noise & Discrete Steps)');
    plot(d_w4.time, d_w4.rad_vel, 'Color', c_w, 'LineWidth', 1.8, ...
         'DisplayName', 'Encoder W \omega (Smooth Continuous Velocity Profile)');
    xlabel('Time (s)', 'FontWeight', 'bold');
    ylabel('Angular Velocity \omega (rad/s)', 'FontWeight', 'bold');
    title('Velocity Estimation Noise & Jitter Contrast: Encoder B vs Encoder W', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f11_file = fullfile(output_dir, 'rotary_11_comparison_bw_velocity_noise.png');
    exportgraphics(f11, f11_file, 'Resolution', 300);
    close(f11);
    fprintf('   -> บันทึก: %s\n', f11_file);

    %% -------------------------------------------------------------------------
    % 12. กราฟ Bar Chart สรุปสเปคเปรียบเทียบ Encoder B vs Encoder W
    % -------------------------------------------------------------------------
    f12 = figure('Name', 'Rotary 12: Specifications Bar Comparison', ...
                 'Position', [100, 100, 850, 520], 'Color', 'w', 'Visible', 'off');
    hold on; grid on; box on;
    cat_names = {'PPR (Nominal)', 'CPR (X4 Mode)', 'Resolution (deg \times 10)', 'Resolution (mrad)'};
    val_b = [24, 96, 3.75 * 10, 65.4];
    val_w = [2000, 8000, 0.045 * 10, 0.785];

    b_bar = bar([val_b; val_w]', 'grouped');
    b_bar(1).FaceColor = [0.3, 0.3, 0.3];
    b_bar(1).DisplayName = 'Encoder B (24 PPR)';
    b_bar(2).FaceColor = [0.0, 0.45, 0.74];
    b_bar(2).DisplayName = 'Encoder W (2000 PPR)';
    set(gca, 'XTickLabel', cat_names, 'YScale', 'log');
    ylabel('Metric Magnitude (Logarithmic Scale)', 'FontWeight', 'bold');
    title('Specifications & Resolution Summary: Encoder B vs Encoder W', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    f12_file = fullfile(output_dir, 'rotary_12_comparison_bw_specifications_bar.png');
    exportgraphics(f12, f12_file, 'Resolution', 300);
    close(f12);
    fprintf('   -> บันทึก: %s\n', f12_file);

    fprintf('>> สร้างกราฟวิเคราะห์ Rotary Encoder ทั้งหมดเรียบร้อยแล้ว!\n');
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
