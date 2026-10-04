function figHandles = plot_loadcell_noise_dynamic(dataDir, saveDir)
% PLOT_LOADCELL_NOISE_DYNAMIC วิเคราะห์สัญญาณพลวัต (Time-Domain Response)
% และคุณลักษณะสัญญาณรบกวน (Sensor Noise Distribution & SNR)
% (Lab 1.4: Load Cell Dynamic Stability & Noise Analysis)
%
% ครอบคลุม:
%   1. Fig7_LoadCell_Dynamic_Waveforms.png   - กราฟรูปคลื่นตามเวลา (Time-Domain Waveforms 0 - 15 s) ที่พิกัดต่ำ กลาง สูง
%   2. Fig8_LoadCell_Noise_Distribution.png - กราฟกระจายตัวของสัญญาณรบกวน (Noise Histogram & Gaussian Fit)
%   3. Fig9_LoadCell_SNR_and_Noise_Floor.png - กราฟอัตราส่วนสัญญาณต่อสัญญาณรบกวน (SNR in dB) และ Noise Floor vs Mass
%
% Inputs:
%   dataDir - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.4')
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ (เช่น './output_figures')
%
% Outputs:
%   figHandles - Handles ของรูปภาพที่ถูกสร้างขึ้น
%
% ผู้พัฒนา: Antigravity AI Pair Programmer
% สำหรับวิชา RMX / FRA Lab: Sensors - Lab 1.4

    if nargin < 1 || isempty(dataDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        dataDir = fullfile(currentScriptDir, '..', 'Lab1.4');
    end
    if nargin < 2 || isempty(saveDir)
        currentScriptDir = fileparts(mfilename('fullpath'));
        saveDir = fullfile(currentScriptDir, 'output_figures');
    end
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    fprintf('กำลังวิเคราะห์สัญญาณรบกวนและพลวัต (Dynamic Response & Noise Analysis)...\n');
    r = process_static_data(dataDir);
    figHandles = [];

    % -------------------------------------------------------------
    % รูปที่ 7: Time-Domain Dynamic Response (Low, Mid, High Load)
    % -------------------------------------------------------------
    f7 = figure('Name', 'LoadCell_Dynamic_Waveforms', 'Color', 'w', 'Position', [100, 100, 1000, 650]);
    
    % เลือกระดับน้ำหนัก 3 ระดับ: ต่ำ (index 1: 0.988 kg), กลาง (index 5: 4.901 kg), สูง (index 11: 9.961 kg)
    selectedIndices = [1, 5, 11];
    subColors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.4660 0.6740 0.1880]};
    
    for k = 1:3
        idx = selectedIndices(k);
        sigData = r.raw_signals{idx};
        
        subplot(3, 1, k);
        hold on; grid on; box on;
        plot(sigData.t, sigData.voltage, 'Color', subColors{k}, 'LineWidth', 1.2);
        yline(mean(sigData.voltage(100:end)), 'k--', ...
            sprintf('Mean = %.4f V', mean(sigData.voltage(100:end))), ...
            'LineWidth', 1.2, 'FontSize', 9);
            
        ylabel('Voltage V_{out} (V)', 'FontSize', 10, 'FontWeight', 'bold');
        title(sprintf('Load Level %d: Mass = %.3f kg (Force = %.2f N)', ...
            k, r.mass(idx), r.force(idx)), 'FontSize', 11, 'FontWeight', 'bold');
        xlim([0, 15]);
        set(gca, 'FontSize', 10, 'LineWidth', 1.1);
        if k == 3
            xlabel('Time t (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
        end
    end
    sgtitle('Load Cell Dynamic Time-Domain Waveforms (15-Second Recording at 1,000 Hz)', ...
        'FontSize', 13, 'FontWeight', 'bold');
    saveas(f7, fullfile(saveDir, 'Fig7_LoadCell_Dynamic_Waveforms.png'));
    figHandles(end+1) = f7;

    % -------------------------------------------------------------
    % รูปที่ 8: Sensor Noise Distribution & Gaussian Fit (ณ พิกัดกึ่งกลาง 4.901 kg)
    % -------------------------------------------------------------
    f8 = figure('Name', 'LoadCell_Noise_Distribution', 'Color', 'w', 'Position', [150, 120, 950, 500]);
    midSig = r.raw_signals{5}; % 4.901 kg
    % ตัด transient ช่วงแรกออก
    steadyV = midSig.voltage(200:end);
    noise_mV = (steadyV - mean(steadyV)) * 1000; % แปลงเป็น mV
    mu_noise = mean(noise_mV);
    sigma_noise = std(noise_mV);
    v_pp = max(noise_mV) - min(noise_mV);

    % Subplot 1: Residual Noise Waveform
    subplot(1, 2, 1);
    hold on; grid on; box on;
    t_steady = midSig.t(200:end);
    plot(t_steady(1:2000), noise_mV(1:2000), 'Color', [0.2 0.4 0.8], 'LineWidth', 0.8);
    yline(0, 'k--', 'LineWidth', 1.0);
    yline(3*sigma_noise, 'r:', '+3\sigma', 'LineWidth', 1.2);
    yline(-3*sigma_noise, 'r:', '-3\sigma', 'LineWidth', 1.2);
    xlabel('Time t (seconds, first 2s window)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Noise Fluctuation \Delta V (mV)', 'FontSize', 11, 'FontWeight', 'bold');
    title({'Zero-Mean Sensor Noise Fluctuations', ...
           sprintf('RMS Noise = %.2f mV, Peak-to-Peak = %.2f mV', sigma_noise, v_pp)}, ...
           'FontSize', 11, 'FontWeight', 'bold');
    xlim([t_steady(1), t_steady(2000)]);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    % Subplot 2: Noise Probability Density Histogram vs Gaussian Fit
    subplot(1, 2, 2);
    hold on; grid on; box on;
    h = histogram(noise_mV, 50, 'Normalization', 'pdf', ...
        'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'none', 'DisplayName', 'Noise Empirical PDF');
    x_grid = linspace(min(noise_mV), max(noise_mV), 200);
    gauss_fit = normpdf(x_grid, mu_noise, sigma_noise);
    plot(x_grid, gauss_fit, 'r-', 'LineWidth', 2.0, ...
        'DisplayName', sprintf('Gaussian Fit\n(\\mu = %.2f mV, \\sigma = %.2f mV)', mu_noise, sigma_noise));
    xlabel('Noise Amplitude (mV)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Probability Density', 'FontSize', 11, 'FontWeight', 'bold');
    title('Noise Amplitude Probability Distribution', 'FontSize', 11, 'FontWeight', 'bold');
    legend('Location', 'northeast', 'FontSize', 10);
    set(gca, 'FontSize', 10, 'LineWidth', 1.1);

    sgtitle('Sensor Noise Characterization at 4.901 kg Load (Instrumentation & ADC Noise)', ...
        'FontSize', 13, 'FontWeight', 'bold');
    saveas(f8, fullfile(saveDir, 'Fig8_LoadCell_Noise_Distribution.png'));
    figHandles(end+1) = f8;

    % -------------------------------------------------------------
    % รูปที่ 9: Signal-to-Noise Ratio (SNR) and Noise Floor vs Load
    % -------------------------------------------------------------
    f9 = figure('Name', 'LoadCell_SNR_and_Noise_Floor', 'Color', 'w', 'Position', [200, 140, 850, 550]);
    hold on; grid on; box on;
    
    % คำนวณ SNR ในหน่วย dB: 20*log10( V_mean / V_noise_std )
    snr_db = 20 * log10(r.voltage_mean ./ r.temporal_noise_v);
    noise_floor_mv = r.temporal_noise_v * 1000;

    yyaxis left
    plot(r.mass, snr_db, '-s', 'Color', [0 0.4470 0.7410], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0 0.4470 0.7410], ...
        'DisplayName', 'Signal-to-Noise Ratio (SNR)');
    ylabel('Signal-to-Noise Ratio SNR (dB)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([30, 48]);

    yyaxis right
    plot(r.mass, noise_floor_mv, '-^', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 2.0, ...
        'MarkerSize', 8, 'MarkerFaceColor', [0.8500 0.3250 0.0980], ...
        'DisplayName', 'RMS Noise Floor (mV)');
    ylabel('RMS Noise Floor \sigma_{noise} (mV)', 'FontSize', 12, 'FontWeight', 'bold');
    ylim([0, 25]);

    xlabel('Applied Mass m (kg)', 'FontSize', 12, 'FontWeight', 'bold');
    title({'Load Cell Signal-to-Noise Ratio and Noise Floor vs Applied Mass', ...
           'SNR Scales from ~36 dB to >41 dB across Measurement Dynamic Range'}, ...
           'FontSize', 13, 'FontWeight', 'bold');
    legend('Location', 'southeast', 'FontSize', 11);
    xlim([0, 11]);
    set(gca, 'FontSize', 11, 'LineWidth', 1.2);
    saveas(f9, fullfile(saveDir, 'Fig9_LoadCell_SNR_and_Noise_Floor.png'));
    figHandles(end+1) = f9;

    fprintf('สร้างกราฟหมวด Noise & Dynamic สำเร็จทั้ง 3 รูป บันทึกไว้ที่: %s\n', saveDir);
end
