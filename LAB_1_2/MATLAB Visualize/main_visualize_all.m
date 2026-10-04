%% MAIN_VISUALIZE_ALL.M
% =========================================================================
% สคริปต์หลักสำหรับประมวลผลและสร้างรูปกราฟ / ตารางสรุปผลการทดลองสนามแม่เหล็ก
% วิชา RMX / FRA Lab: Magnetic Field Sensors & Shielding
% =========================================================================
% ชุดข้อมูลครอบคลุม:
%   - RAW C - No Shield, RAW C - Shield (Sensor C: 0.0 - 3.0 ซม., 3 รอบซ้ำ)
%   - RAW D - No Shield, RAW D - Shield (Sensor D: 0.0 - 3.0 ซม., 3 รอบซ้ำ)
%
% วิธีใช้งาน:
%   กดปุ่ม "Run" ใน MATLAB หรือพิมพ์คำสั่ง main_visualize_all ใน Command Window
% =========================================================================

clear; clc; close all;

fprintf('====================================================\n');
fprintf('  เริ่มต้นการวิเคราะห์ข้อมูลและสร้างกราฟรายงาน Magnetic Sensors\n');
fprintf('====================================================\n\n');

currentScriptDir = fileparts(mfilename('fullpath'));
dataDir  = fullfile(currentScriptDir, '..');
saveDir  = fullfile(currentScriptDir, 'output_figures');
tableDir = fullfile(currentScriptDir, 'output_tables');

if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end
if ~exist(tableDir, 'dir')
    mkdir(tableDir);
end

fprintf('1. ตำแหน่งโฟลเดอร์ข้อมูล: %s\n', dataDir);
fprintf('2. โฟลเดอร์บันทึกรูปกราฟ : %s\n', saveDir);
fprintf('3. โฟลเดอร์บันทึกตาราง   : %s\n\n', tableDir);

%% 1. ประมวลผลข้อมูล Static Data (0.0 - 3.0 cm)
fprintf('----------------------------------------------------\n');
fprintf('[Step 1/4] ประมวลผลข้อมูลวัดระยะทางและค่าสถิติ...\n');
summary = process_static_data(dataDir);

%% 2. สร้างกราฟคุณลักษณะเซนเซอร์ (Sensors C & D)
fprintf('----------------------------------------------------\n');
fprintf('[Step 2/4] สร้างรูปกราฟ 4 รูปหลักและกราฟรวม 4 ช่อง (Sensors C & D)...\n');
fMagnetic = plot_magnetic_sensors(summary, saveDir);

%% 3. สร้างกราฟประสิทธิภาพการกำบังสนามแม่เหล็ก (Shielding Performance)
fprintf('----------------------------------------------------\n');
fprintf('[Step 3/4] วิเคราะห์และพล็อตประสิทธิภาพการกำบังสนามแม่เหล็ก...\n');
fShielding = plot_shielding_performance(summary, saveDir);

%% 4. พล็อตสัญญาณ Time-Domain Real-Time Waveforms
fprintf('----------------------------------------------------\n');
fprintf('[Step 4/4] สร้างกราฟสัญญาณ Realtime Time-Domain...\n');
fRealtime = plot_realtime_waveforms(dataDir, saveDir);

%% 5. ส่งออกตารางสรุปผลการทดลอง (CSV / MAT)
fprintf('----------------------------------------------------\n');
fprintf('[Step 5/5] ส่งออกตารางข้อมูลสรุปและค่าสถิติ (CSV / MAT)...\n');
export_summary_tables(summary, tableDir);

%% แสดงข้อความสรุปผล
fprintf('\n====================================================\n');
fprintf('  การประมวลผลข้อมูลเสร็จสมบูรณ์เรียบร้อย 100%% !\n');
fprintf('====================================================\n');
fprintf('รูปภาพทั้งหมดถูกบันทึกไว้ที่: \n  %s\n', saveDir);
fprintf('ตาราง CSV ทั้งหมดถูกบันทึกไว้ที่: \n  %s\n\n', tableDir);
fprintf('รายการรูปภาพที่สร้างขึ้นสำหรับนำไปใส่ในรายงาน:\n');
fprintf('  1. Fig1_Sensor_C_Magnetic_Flux_vs_Distance.png - กราฟ Magnetic Flux Density vs Distance (Sensor C)\n');
fprintf('  2. Fig2_Sensor_C_Voltage_vs_Distance.png       - กราฟ Voltage vs Distance (Sensor C)\n');
fprintf('  3. Fig3_Sensor_D_Magnetic_Flux_vs_Distance.png - กราฟ Magnetic Flux Density vs Distance (Sensor D)\n');
fprintf('  4. Fig4_Sensor_D_Voltage_vs_Distance.png       - กราฟ Voltage vs Distance (Sensor D)\n');
fprintf('  5. Fig5_Sensor_C_D_4_Graphs_Comparison_Grid.png- กราฟรวม 4 ช่อง (Sensors C & D ทั้ง Flux และ Voltage)\n');
fprintf('  6. Fig6_Shielding_Attenuation_Efficiency.png  - กราฟประสิทธิภาพการกำบังสนามแม่เหล็ก (%% Shielding Rate)\n');
fprintf('  7. Fig7_Sensor_Sensitivity_Comparison.png    - กราฟเปรียบเทียบความไว (Sensitivity Characteristics)\n');
fprintf('  8. Fig8_Realtime_Time_Domain_Waveforms.png   - กราฟสัญญาณ Waveform ย่านเวลา\n\n');
