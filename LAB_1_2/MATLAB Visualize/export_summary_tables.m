function export_summary_tables(summary, tableDir)
% EXPORT_SUMMARY_TABLES ส่งออกตารางสรุปผลข้อมูลการทดลองและสถิติเป็นไฟล์ CSV และ .mat
%
% Inputs:
%   summary  - Struct ข้อมูลประมวลผลจาก process_static_data
%   tableDir - โฟลเดอร์สำหรับบันทึกตาราง

    if ~exist(tableDir, 'dir')
        mkdir(tableDir);
    end

    c_ns = summary.RAW_C_No_Shield;
    c_s  = summary.RAW_C_Shield;
    d_ns = summary.RAW_D_No_Shield;
    d_s  = summary.RAW_D_Shield;

    %% 1. Table Sensor C No Shield
    T_C_NS = table(c_ns.dists(:), c_ns.meanFlux(:), c_ns.stdFlux(:), c_ns.meanVolt(:), c_ns.stdVolt(:), ...
        'VariableNames', {'Distance_cm', 'Flux_Mean_mT', 'Flux_Std_mT', 'Voltage_Mean_V', 'Voltage_Std_V'});
    writetable(T_C_NS, fullfile(tableDir, 'Table_Sensor_C_NoShield.csv'));

    %% 2. Table Sensor C Shielded
    T_C_S = table(c_s.dists(:), c_s.meanFlux(:), c_s.stdFlux(:), c_s.meanVolt(:), c_s.stdVolt(:), ...
        'VariableNames', {'Distance_cm', 'Flux_Mean_mT', 'Flux_Std_mT', 'Voltage_Mean_V', 'Voltage_Std_V'});
    writetable(T_C_S, fullfile(tableDir, 'Table_Sensor_C_Shielded.csv'));

    %% 3. Table Sensor D No Shield
    T_D_NS = table(d_ns.dists(:), d_ns.meanFlux(:), d_ns.stdFlux(:), d_ns.meanVolt(:), d_ns.stdVolt(:), ...
        'VariableNames', {'Distance_cm', 'Flux_Mean_mT', 'Flux_Std_mT', 'Voltage_Mean_V', 'Voltage_Std_V'});
    writetable(T_D_NS, fullfile(tableDir, 'Table_Sensor_D_NoShield.csv'));

    %% 4. Table Sensor D Shielded
    T_D_S = table(d_s.dists(:), d_s.meanFlux(:), d_s.stdFlux(:), d_s.meanVolt(:), d_s.stdVolt(:), ...
        'VariableNames', {'Distance_cm', 'Flux_Mean_mT', 'Flux_Std_mT', 'Voltage_Mean_V', 'Voltage_Std_V'});
    writetable(T_D_S, fullfile(tableDir, 'Table_Sensor_D_Shielded.csv'));

    %% 5. Table Shielding Attenuation Summary (Aligned on Common Distances)
    commonDistsC = intersect(c_ns.dists, c_s.dists);
    commonDistsC = commonDistsC(:);
    attenC = zeros(length(commonDistsC), 1);
    for i = 1:length(commonDistsC)
        idxNS = find(c_ns.dists == commonDistsC(i));
        idxS  = find(c_s.dists == commonDistsC(i));
        attenC(i) = (1 - c_s.meanFlux(idxS) / c_ns.meanFlux(idxNS)) * 100;
    end

    commonDistsD = intersect(d_ns.dists, d_s.dists);
    commonDistsD = commonDistsD(:);
    attenD = zeros(length(commonDistsD), 1);
    for i = 1:length(commonDistsD)
        idxNS = find(d_ns.dists == commonDistsD(i));
        idxS  = find(d_s.dists == commonDistsD(i));
        attenD(i) = (1 - d_s.meanFlux(idxS) / d_ns.meanFlux(idxNS)) * 100;
    end

    T_AttenC = table(commonDistsC(:), attenC(:), 'VariableNames', {'Distance_cm', 'Sensor_C_Attenuation_Percent'});
    writetable(T_AttenC, fullfile(tableDir, 'Table_Shielding_Attenuation_Sensor_C.csv'));

    T_AttenD = table(commonDistsD(:), attenD(:), 'VariableNames', {'Distance_cm', 'Sensor_D_Attenuation_Percent'});
    writetable(T_AttenD, fullfile(tableDir, 'Table_Shielding_Attenuation_Sensor_D.csv'));

    %% 6. Save Lab_Summary_Data.mat
    save(fullfile(tableDir, 'Lab_Summary_Data.mat'), 'summary', 'T_C_NS', 'T_C_S', 'T_D_NS', 'T_D_S', 'T_AttenC', 'T_AttenD');
end
