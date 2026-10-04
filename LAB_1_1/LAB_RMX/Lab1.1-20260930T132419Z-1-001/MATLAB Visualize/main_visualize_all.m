%% MAIN_VISUALIZE_ALL.M
% =========================================================================
% สคริปต์หลักสำหรับประมวลผลและสร้างรูปกราฟ / ตารางสรุปผลการทดลอง
% วิชา RMX / FRA Lab: Sensors - Lab 1.1 Potentiometers
% =========================================================================
% ชุดข้อมูลครอบคลุม:
%   - RAW1, RAW2, RAW3: Rotary Potentiometer (0 - 100 องศา, 3 รอบซ้ำ + Realtime)
%   - RAW4, RAW5: Linear Slide Potentiometer (0.0 - 6.0 ซม., 3 รอบซ้ำ + Realtime)
%
% วิธีใช้งาน:
%   กดปุ่ม "Run" ใน MATLAB หรือพิมพ์คำสั่ง main_visualize_all ใน Command Window
% =========================================================================

clear; clc; close all;

fprintf('====================================================\n');
fprintf('  เริ่มต้นการวิเคราะห์ข้อมูลและสร้างกราฟรายงาน Lab 1.1\n');
fprintf('====================================================\n\n');

% กำหนดตำแหน่งโฟลเดอร์ข้อมูลและโฟลเดอร์สำหรับบันทึกผล
currentScriptDir = fileparts(mfilename('fullpath'));
dataDir  = fullfile(currentScriptDir, '..', 'Lab1.1');
saveDir  = fullfile(currentScriptDir, 'output_figures');
tableDir = fullfile(currentScriptDir, 'output_tables');

if ~exist(dataDir, 'dir')
    % กรณีรันจากตำแหน่งอื่น ลองค้นหา Lab1.1
    altDir = 'C:\Users\User\Downloads\LAB_RMX\Lab1.1-20260930T132419Z-1-001\Lab1.1';
    if exist(altDir, 'dir')
        dataDir = altDir;
    else
        error('ไม่พบโฟลเดอร์ข้อมูล Lab1.1 กรุณาตรวจสอบตำแหน่งโฟลเดอร์');
    end
end

fprintf('1. ตำแหน่งโฟลเดอร์ข้อมูล: %s\n', dataDir);
fprintf('2. โฟลเดอร์บันทึกรูปกราฟ : %s\n', saveDir);
fprintf('3. โฟลเดอร์บันทึกตาราง   : %s\n\n', tableDir);

%% 1. สร้างกราฟ Rotary Potentiometers (RAW1, RAW2, RAW3)
fprintf('----------------------------------------------------\n');
fprintf('[Step 1/4] วิเคราะห์และสร้างกราฟ Rotary Potentiometers...\n');
fRotary = plot_rotary_potentiometers(dataDir, saveDir);

%% 2. สร้างกราฟ Linear Slide Potentiometers (RAW4, RAW5)
fprintf('----------------------------------------------------\n');
fprintf('[Step 2/4] วิเคราะห์และสร้างกราฟ Linear Potentiometers...\n');
fLinear = plot_linear_potentiometers(dataDir, saveDir);

%% 3. สร้างกราฟ Real-Time Dynamic & Schmitt Trigger
fprintf('----------------------------------------------------\n');
fprintf('[Step 3/4] วิเคราะห์สัญญาณ Real-Time และ Schmitt Trigger...\n');
fRealtime = plot_realtime_schmitt_trigger(dataDir, saveDir, {'RAW1', 'RAW2', 'RAW4', 'RAW5'});

%% 4. ส่งออกตารางสรุปผลการทดลอง (CSV / MAT)
fprintf('----------------------------------------------------\n');
fprintf('[Step 4/4] ส่งออกตารางข้อมูลสรุปและค่าสถิติ...\n');
export_summary_tables(dataDir, tableDir);

%% แสดงข้อความสรุปผล
fprintf('\n====================================================\n');
fprintf('  การประมวลผลข้อมูลเสร็จสมบูรณ์เรียบร้อย 100%% !\n');
fprintf('====================================================\n');
fprintf('รูปภาพทั้งหมดถูกบันทึกไว้ที่: \n  %s\n', saveDir);
fprintf('ตาราง CSV ทั้งหมดถูกบันทึกไว้ที่: \n  %s\n\n', tableDir);
fprintf('รายการรูปภาพที่สามารถนำไปใส่ในรายงาน:\n');
fprintf('  1. Fig1_Rotary_Voltage_vs_Angle.png  - กราฟ V vs Angle พร้อม Error Bar\n');
fprintf('  2. Fig2_Rotary_Taper_Curves.png      - กราฟเทียบคุณลักษณะ Taper A, B, C\n');
fprintf('  3. Fig3_Rotary_Sensitivity.png       - กราฟความไวของเซนเซอร์ (mV/deg)\n');
fprintf('  4. Fig4_Rotary_Linearity_Error.png   - กราฟสมการเส้นตรงและ Linearity Error %%FS\n');
fprintf('  5. Fig5_Linear_Voltage_vs_Distance.png - กราฟ V vs Distance (0-6 cm) พร้อม Error Bar\n');
fprintf('  6. Fig6_Linear_Taper_Curves.png      - กราฟเทียบ Taper ของ Slide Potentiometer\n');
fprintf('  7. Fig7_Linear_Sensitivity.png       - กราฟความไวเชิงระยะทาง (V/cm)\n');
fprintf('  8. Fig8_Linear_Calibration_Error.png - กราฟสมการสอบเทียบตำแหน่ง d = f(V)\n');
fprintf('  9. Fig9_Realtime_Waveform_*.png      - กราฟ Time-domain Analog vs Digital State\n');
fprintf(' 10. Fig10_Schmitt_Hysteresis_*.png    - กราฟ Hysteresis Loop และ Thresholds\n\n');
