function figHandles = plot_realtime_schmitt_trigger(dataDir, saveDir, targetSensors)
% PLOT_REALTIME_SCHMITT_TRIGGER พล็อตและวิเคราะห์สัญญาณ Real-Time Dynamic Response
% และพฤติกรรมวงจร Schmitt Trigger (Analog Input vs Digital State)
%
% ครอบคลุม:
%   1. กราฟ Time-Domain Response: สัญญาณ Analog V_in(t) คู่กับ Digital State V_out(t)
%   2. การระบุค่า Threshold บน-ล่าง (Upper Threshold V_TH, Lower Threshold V_TL)
%   3. กราฟ Hysteresis Loop (Transfer Characteristic V_out vs V_in)
%
% Inputs:
%   dataDir       - โฟลเดอร์เก็บไฟล์ .mat (เช่น '../Lab1.1')
%   saveDir       - โฟลเดอร์สำหรับบันทึกรูปกราฟ (เช่น './output_figures')
%   targetSensors - Cell array ของเซนเซอร์ที่ต้องการพล็อต เช่น {'RAW1', 'RAW4'}
%
% ผู้พัฒนา: Antigravity AI Pair Programmer

    if nargin < 1 || isempty(dataDir)
        dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'Lab1.1');
    end
    if nargin < 2 || isempty(saveDir)
        saveDir = fullfile(fileparts(mfilename('fullpath')), 'output_figures');
    end
    if nargin < 3 || isempty(targetSensors)
        targetSensors = {'RAW1', 'RAW2', 'RAW4'};
    end
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end

    V_SUPPLY = 3.3;
    ADC_MAX  = 4095;
    figHandles = [];

    fprintf('กำลังประมวลผลข้อมูล Real-time & Schmitt Trigger...\n');

    for sIdx = 1:length(targetSensors)
        sName = targetSensors{sIdx};
        realtimeFile = fullfile(dataDir, sprintf('%s-realtime1.mat', sName));

        if ~exist(realtimeFile, 'file')
            % ลองหาไฟล์ realtime อื่นๆ
            d = dir(fullfile(dataDir, sprintf('%s*realtime*.mat', sName)));
            if ~isempty(d)
                realtimeFile = fullfile(dataDir, d(1).name);
            else
                fprintf('ไม่พบไฟล์ Realtime สำหรับ %s ข้ามไป...\n', sName);
                continue;
            end
        end

        [t, sigs, sigNames] = load_lab_data(realtimeFile);
        if isempty(sigs) || size(sigs, 2) < 1
            continue;
        end

        % ดึงสัญญาณอินพุต Analog Voltage vIn(t) จากข้อมูลที่บันทึกมา (A0 หรือ voltage(V))
        if size(sigs, 2) >= 2
            vIn = sigs(:, 1);
            if max(vIn) > 5.0
                vIn = (vIn ./ ADC_MAX) * V_SUPPLY;
            end
        else
            vIn = sigs(:, 1);
            if max(vIn) > 5.0
                vIn = (vIn ./ ADC_MAX) * V_SUPPLY;
            end
        end

        % =========================================================
        % จำลองการทำงานของวงจร Non-Inverting Op-Amp Schmitt Trigger
        % อ้างอิงจากวงจรที่มีตัวต้านทาน R = 10k Ohm และ 33k Ohm ใน schmitt.slx:
        %   - R1 (Input Resistor) = 10 kOhm
        %   - R2 (Feedback Resistor) = 33 kOhm
        %   - V_ref (Reference Voltage ขา Inverting) = 1.535 V
        %   - V_OH = 3.3 V (Logic High Level), V_OL = 0.0 V (Logic Low Level)
        % =========================================================
        R1 = 10e3;      % 10 kOhm
        R2 = 33e3;      % 33 kOhm
        V_ref = 1.535;  % 1.535 V
        V_OH = 3.3;     % 3.3 V
        V_OL = 0.0;     % 0.0 V

        % คำนวณขีดเริ่มเปลี่ยนตามทฤษฎีวงจร Op-Amp:
        % V_TH = (1 + R1/R2)*V_ref - (R1/R2)*V_OL = (1 + 10/33)*1.535 = 2.00 V
        % V_TL = (1 + R1/R2)*V_ref - (R1/R2)*V_OH = 2.00 - (10/33)*3.3 = 1.00 V
        vTH = (1 + R1/R2) * V_ref - (R1/R2) * V_OL;
        vTL = (1 + R1/R2) * V_ref - (R1/R2) * V_OH;

        % จำลองสถานะ Output ดิจิทัล (0/1) ที่ผ่านวงจร Op-Amp Schmitt Trigger
        vOut_norm = zeros(size(vIn));
        curState = double(vIn(1) >= vTH);
        for k = 1:length(vIn)
            if curState == 0
                if vIn(k) >= vTH
                    curState = 1;
                end
            else
                if vIn(k) <= vTL
                    curState = 0;
                end
            end
            vOut_norm(k) = curState;
        end

        vTH_est = vTH;
        vTL_est = vTL;

        % ---------------------------------------------------------
        % รูปที่ 9: Time-Domain Waveforms (Analog V_in vs Digital State)
        % ---------------------------------------------------------
        fTime = figure('Name', sprintf('Realtime_Waveform_%s', sName), 'Color', 'w', ...
                       'Position', [100 + sIdx*30, 80 + sIdx*30, 950, 650]);

        % ซับพล็อตบน: Analog Input Voltage
        ax1 = subplot(2, 1, 1);
        hold on; grid on; box on;
        plot(t, vIn, 'b-', 'LineWidth', 1.6, 'DisplayName', 'Analog Input V_{in}(t)');
        yMaxVal = max(vIn);
        yTop = max(4.2, max(yMaxVal, vTH_est) + 0.7);
        yBot = min(-0.2, min(vIn) - 0.2);

        yline(vTH_est, 'r--', sprintf('   Upper Threshold V_{TH} = %.2f V (R_1=10k, R_2=33k)', vTH_est), ...
              'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', ...
              'LabelVerticalAlignment', 'top', 'FontSize', 10, ...
              'HandleVisibility', 'off');
        yline(vTL_est, 'g--', sprintf('   Lower Threshold V_{TL} = %.2f V (R_1=10k, R_2=33k)', vTL_est), ...
              'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', ...
              'LabelVerticalAlignment', 'top', 'FontSize', 10, ...
              'HandleVisibility', 'off');
        ylabel('Analog Voltage (V)', 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('Real-Time Op-Amp Schmitt Trigger (R_1=10k\\Omega, R_2=33k\\Omega): %s', sName), ...
              'FontSize', 12, 'FontWeight', 'bold');
        legend('Location', 'northeast', 'FontSize', 10);
        ylim([yBot, yTop]);
        set(gca, 'FontSize', 10, 'LineWidth', 1.1);

        % ซับพล็อตล่าง: Digital Schmitt Trigger State
        ax2 = subplot(2, 1, 2);
        hold on; grid on; box on;
        plot(t, vOut_norm, 'r-', 'LineWidth', 2.0, 'DisplayName', 'Digital State (Op-Amp Output)');
        ylabel('Digital Output State', 'FontSize', 11, 'FontWeight', 'bold');
        xlabel('Time (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
        ylim([-0.2, 1.2]);
        yticks([0, 1]);
        yticklabels({'LOW (0)', 'HIGH (1)'});
        legend('Location', 'northeast', 'FontSize', 10);
        set(gca, 'FontSize', 10, 'LineWidth', 1.1);

        linkaxes([ax1, ax2], 'x');
        saveas(fTime, fullfile(saveDir, sprintf('Fig9_Realtime_Waveform_%s.png', sName)));
        figHandles(end+1) = fTime; %#ok<AGROW>

        % ---------------------------------------------------------
        % รูปที่ 10: Hysteresis Characteristic Loop (V_out vs V_in)
        % ---------------------------------------------------------
        fHyst = figure('Name', sprintf('Schmitt_Hysteresis_%s', sName), 'Color', 'w', ...
                       'Position', [150 + sIdx*30, 100 + sIdx*30, 800, 550]);
        hold on; grid on; box on;
        scatter(vIn, vOut_norm, 18, [0.1 0.4 0.8], 'filled', 'MarkerFaceAlpha', 0.5, ...
                'DisplayName', 'Operating Trajectory');
        xline(vTH_est, 'r--', sprintf('V_{TH} = %.2f V', vTH_est), ...
              'LineWidth', 1.5, 'LabelOrientation', 'aligned', 'FontSize', 10);
        xline(vTL_est, 'g--', sprintf('V_{TL} = %.2f V', vTL_est), ...
              'LineWidth', 1.5, 'LabelOrientation', 'aligned', 'FontSize', 10);
        h_band = vTH_est - vTL_est;
        text((vTH_est + vTL_est)/2, 0.5, ...
             sprintf('\\leftarrow Hysteresis \\Delta V_H = %.2f V \\rightarrow\\newline[R_1 = 10 k\\Omega, R_2 = 33 k\\Omega, V_{ref} = 1.535 V]', h_band), ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', 'BackgroundColor', 'y');
        xlabel('Input Voltage V_{in} (V)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Op-Amp Output State', 'FontSize', 12, 'FontWeight', 'bold');
        title(sprintf('Op-Amp Schmitt Trigger Hysteresis Loop: %s (R_1=10k, R_2=33k)', sName), 'FontSize', 12, 'FontWeight', 'bold');
        ylim([-0.2, 1.2]);
        yticks([0, 1]);
        yticklabels({'LOW (0)', 'HIGH (1)'});
        set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'TickDir', 'out');
        saveas(fHyst, fullfile(saveDir, sprintf('Fig10_Schmitt_Hysteresis_%s.png', sName)));
        figHandles(end+1) = fHyst; %#ok<AGROW>
    end

    fprintf('สร้างกราฟ Real-Time และ Schmitt Trigger เรียบร้อย บันทึกไว้ที่: %s\n', saveDir);
end
