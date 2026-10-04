function fHandle = plot_realtime_waveforms(dataDir, saveDir)
% PLOT_REALTIME_WAVEFORMS พล็อตสัญญาณ Time-Domain ของทั้ง Magnetic Flux และ Voltage
%
% Inputs:
%   dataDir - โฟลเดอร์หลักที่มีไฟล์ .mat
%   saveDir - โฟลเดอร์สำหรับบันทึกรูปกราฟ

    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    samplePath = fullfile(dataDir, 'RAW C - No Shield', 'magnatic C No shield 0.0cm (1).mat');
    if ~exist(samplePath, 'file')
        samplePath = fullfile(dataDir, 'เก็บใหม่จากไนซ์', 'RAW C - No Shield', 'magnatic C No shield 0.0cm (1).mat');
    end

    [t, sigs, sigNames] = load_lab_data(samplePath);

    fluxData = [];
    voltData = [];
    for idx = 1:length(sigNames)
        if contains(sigNames{idx}, 'flux', 'IgnoreCase', true)
            fluxData = sigs(:, idx);
        elseif contains(sigNames{idx}, 'voltage', 'IgnoreCase', true)
            voltData = sigs(:, idx);
        end
    end

    f8 = figure('Name', 'Realtime Time-Domain Waveforms', 'Position', [100, 100, 850, 550], 'Visible', 'off');

    subplot(2, 1, 1);
    plot(t, fluxData, 'LineWidth', 1.2, 'Color', [0 0.447 0.741]);
    grid on; box on;
    xlabel('Time (s)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Magnetic Flux Density (mT)', 'FontSize', 10, 'FontWeight', 'bold');
    title('Fig 8a: Realtime Waveform - Magnetic Flux Density (Sensor C, 0.0cm)', 'FontSize', 11, 'FontWeight', 'bold');

    subplot(2, 1, 2);
    plot(t, voltData, 'LineWidth', 1.2, 'Color', [0.85 0.325 0.098]);
    grid on; box on;
    xlabel('Time (s)', 'FontSize', 10, 'FontWeight', 'bold');
    ylabel('Voltage Output (V)', 'FontSize', 10, 'FontWeight', 'bold');
    title('Fig 8b: Realtime Waveform - Voltage Output (Sensor C, 0.0cm)', 'FontSize', 11, 'FontWeight', 'bold');

    saveas(f8, fullfile(saveDir, 'Fig8_Realtime_Time_Domain_Waveforms.png'));
    saveas(f8, fullfile(saveDir, 'Fig8_Realtime_Time_Domain_Waveforms.fig'));
    fHandle = f8; close(f8);
end
