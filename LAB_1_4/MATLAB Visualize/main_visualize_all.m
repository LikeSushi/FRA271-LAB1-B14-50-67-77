%% MAIN_VISUALIZE_ALL.M
% =========================================================================
% สคริปต์หลักสำหรับประมวลผลและสร้างรูปกราฟ / ตารางสรุปผลการทดลอง
% วิชา RMX / FRA Lab: Sensors - Lab 1.4 Single Point Load Cell & INA125
% =========================================================================
% ครอบคลุมตามข้อกำหนดใน manual_lab1.pdf:
%   - Calibration & Sensitivity Curves
%   - เปรียบเทียบค่าที่ได้กับเครื่องชั่ง Digital (Criteria ข้อ 7)
%   - วิเคราะห์ Saturation ที่เกิดขึ้น (Criteria ข้อ 6)
%   - สัญญาณ Output แปรผันตาม Input แบบ Real Time ในหน่วย SI Derived (Criteria ข้อ 9)
%   - วิเคราะห์ความเที่ยงตรงและการทำซ้ำ Repeatability (Criteria ข้อ 10)
%
% วิธีใช้งาน:
%   กดปุ่ม "Run" ใน MATLAB หรือพิมพ์คำสั่ง main_visualize_all ใน Command Window
% =========================================================================

clear; clc; close all;

fprintf('====================================================\n');
fprintf('  เริ่มต้นการวิเคราะห์ข้อมูลและสร้างกราฟรายงาน Lab 1.4\n');
fprintf('  (Single Point Load Cell with INA125 Amplifier)\n');
fprintf('  อ้างอิงตามเกณฑ์การประเมินผล: manual_lab1.pdf\n');
fprintf('====================================================\n\n');

% กำหนดตำแหน่งโฟลเดอร์ข้อมูลและโฟลเดอร์สำหรับบันทึกผล
currentScriptDir = fileparts(mfilename('fullpath'));
dataDir  = fullfile(currentScriptDir, '..', 'Lab1.4');
saveDir  = fullfile(currentScriptDir, 'output_figures');
tableDir = fullfile(currentScriptDir, 'output_tables');

if ~exist(dataDir, 'dir')
    % กรณีรันจากตำแหน่งอื่น ลองค้นหา Lab1.4 จาก Absolute Path
    altDir = 'C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\Lab1.4';
    if exist(altDir, 'dir')
        dataDir = altDir;
    else
        error('ไม่พบโฟลเดอร์ข้อมูล Lab1.4 กรุณาตรวจสอบตำแหน่งโฟลเดอร์');
    end
end

fprintf('1. ตำแหน่งโฟลเดอร์ข้อมูล: %s\n', dataDir);
fprintf('2. โฟลเดอร์บันทึกรูปกราฟ : %s\n', saveDir);
fprintf('3. โฟลเดอร์บันทึกตาราง   : %s\n\n', tableDir);

%% 1. สร้างกราฟ Calibration Curves (Fig 1, 1b, 1c, 1d, 1e)
fprintf('----------------------------------------------------\n');
fprintf('[Step 1/5] สร้างกราฟเส้นโค้งการสอบเทียบ (Calibration Curves)...\n');
fCalib = plot_loadcell_calibration(dataDir, saveDir);

%% 2. สร้างกราฟวิเคราะห์คุณลักษณะเชิงลึก (Fig 2, 3, 4, 5, 6)
fprintf('----------------------------------------------------\n');
fprintf('[Step 2/5] วิเคราะห์คุณลักษณะเชิงลึก (Sensitivity & Linearity)...\n');
fChar = plot_loadcell_characteristics(dataDir, saveDir);

%% 3. สร้างกราฟสัญญาณรบกวนและพลวัต (Fig 7, 8, 9)
fprintf('----------------------------------------------------\n');
fprintf('[Step 3/5] วิเคราะห์สัญญาณรบกวนและพลวัต (Dynamic & Noise Analysis)...\n');
fNoise = plot_loadcell_noise_dynamic(dataDir, saveDir);

%% 4. สร้างกราฟเปรียบเทียบเครื่องชั่ง Digital และวิเคราะห์ Saturation (Fig 10, 11, 12, 13)
fprintf('----------------------------------------------------\n');
fprintf('[Step 4/5] เปรียบเทียบกับเครื่องชั่ง Digital, วิเคราะห์ Saturation & Real-Time SI Units...\n');
fComp = plot_digital_scale_comparison(dataDir, saveDir);

%% 5. ส่งออกตารางสรุปผลการทดลอง (CSV / MAT)
fprintf('----------------------------------------------------\n');
fprintf('[Step 5/5] ส่งออกตารางข้อมูลสรุปและค่าสถิติ...\n');
export_summary_tables(dataDir, tableDir);

%% แสดงข้อความสรุปผล
fprintf('\n====================================================\n');
fprintf('  การประมวลผลข้อมูล Lab 1.4 เสร็จสมบูรณ์เรียบร้อย 100%% !\n');
fprintf('====================================================\n');
fprintf('รูปภาพทั้งหมดถูกบันทึกไว้ที่: \n  %s\n', saveDir);
fprintf('ตาราง CSV ทั้งหมดถูกบันทึกไว้ที่: \n  %s\n\n', tableDir);
fprintf('รายการรูปภาพทั้งหมดตามเกณฑ์ Criteria ใน manual_lab1:\n');
fprintf('  1. Fig1_LoadCell_Voltage_vs_Mass.png          - กราฟ V vs Mass (kg) พร้อม Error Bar\n');
fprintf('  2. Fig1b_LoadCell_Voltage_vs_Mass_No_Errorbar.png - กราฟ V vs Mass คลีน (ไม่มี Error Bar)\n');
fprintf('  3. Fig1c_LoadCell_Voltage_vs_Force.png         - กราฟ V vs Force (0 - 100 N)\n');
fprintf('  4. Fig1d_LoadCell_Individual_Trials.png        - กราฟเทียบการวัดซ้ำ 3 รอบ (Trial 1,2,3 vs Mean)\n');
fprintf('  5. Fig1e_LoadCell_ADC_vs_Mass.png              - กราฟรหัส ADC ดิบ (12-bit STM32) vs Mass\n');
fprintf('  6. Fig2_LoadCell_Normalized_Transfer_Curve.png - กราฟ Normalized Transfer Curve เทียบ Ideal Line\n');
fprintf('  7. Fig3_LoadCell_Sensitivity.png               - กราฟความไวเฉพาะช่วง S(m) [mV/kg] และ S(F) [mV/N]\n');
fprintf('  8. Fig4_LoadCell_Linearity_Error.png           - กราฟ Linear Regression และ Linearity Error %%FS\n');
fprintf('  9. Fig5_LoadCell_Inverse_Calibration_Model.png - สมการสอบเทียบผกผัน m = f(V) และ Residual Error\n');
fprintf(' 10. Fig6_LoadCell_Polynomial_Fit_Comparison.png - เปรียบเทียบ 1st-Order Linear vs 2nd-Order Polynomial\n');
fprintf(' 11. Fig7_LoadCell_Dynamic_Waveforms.png         - รูปคลื่นเวลาจริง (Time-Domain Waveforms 0-15s)\n');
fprintf(' 12. Fig8_LoadCell_Noise_Distribution.png       - การแจกแจงสัญญาณรบกวน Histogram & Gaussian Fit\n');
fprintf(' 13. Fig9_LoadCell_SNR_and_Noise_Floor.png       - กราฟอัตราส่วน SNR (dB) และ Noise Floor (mV)\n');
fprintf(' 14. Fig10_Digital_Scale_vs_LoadCell.png        - เปรียบเทียบ Load Cell vs เครื่องชั่ง Digital (1:1 Line)\n');
fprintf(' 15. Fig11_Digital_Scale_Error_Analysis.png     - วิเคราะห์ Error เทียบเครื่องชั่ง Digital (Absolute & %% Error)\n');
fprintf(' 16. Fig12_LoadCell_Saturation_Analysis.png     - วิเคราะห์สภาวะ Saturation และ Linear Operating Range\n');
fprintf(' 17. Fig13_Realtime_SI_Units_Waveforms.png      - สัญญาณ Real-time ในหน่วย SI Derived (kg และ N)\n\n');
