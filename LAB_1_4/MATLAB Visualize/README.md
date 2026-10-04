# ชุดสคริปต์ MATLAB Visualize ข้อมูลการทดลอง Lab 1.4: Load Cell & Strain Gauge Calibration

ชุดเครื่องมือ MATLAB สำหรับประมวลผล วิเคราะห์ และสร้างภาพข้อมูล (Data Visualization) อัตโนมัติ โดยประมวลผลข้อมูลการทดลองวัดซ้ำ 3 รอบ (Trial 1, 2, 3 รวม 33 ไฟล์) ของการทดลอง **Lab 1.4: Single Point Load Cell with INA125 Instrumentation Amplifier** (วิชา RMX / FRA271: Sensors)

พัฒนาขึ้นโดยอิงโครงสร้างไฟล์ตามมาตรฐาน **Lab 1.1** และออกแบบเนื้อหากราฟและตารางให้ตรงตามเกณฑ์การให้คะแนนใน **`manual_lab1.pdf`** ครบถ้วน 100% (เกณฑ์คะแนนเต็ม 12.5 คะแนน)

---

## 📁 โครงสร้างไฟล์ในโฟลเดอร์นี้

```text
MATLAB Visualize/
├── main_visualize_all.m             % สคริปต์หลัก (Master Script) สั่งรันทุกขั้นตอนอัตโนมัติในคลิกเดียว
├── load_lab_data.m                  % ฟังก์ชันโหลดและแยกสัญญาณจากไฟล์ .mat (รองรับ Simulink Dataset)
├── process_static_data.m            % ฟังก์ชันประมวลผลสถิติ 3 รอบซ้ำ (Mean, SD, ADC, แรง N, ขจัด Transient)
├── plot_loadcell_calibration.m      % กราฟเส้นโค้งการสอบเทียบ (V vs Mass, V vs Force, Trials 1-3, ADC)
├── plot_loadcell_characteristics.m  % กราฟวิเคราะห์คุณลักษณะ (Normalized Transfer, Sensitivity, Linearity, Poly Fit)
├── plot_loadcell_noise_dynamic.m    % กราฟวิเคราะห์สัญญาณรบกวนและพลวัต (Time-Domain Waveforms, Gaussian Fit, SNR)
├── plot_digital_scale_comparison.m  % กราฟเปรียบเทียบเครื่องชั่ง Digital, Saturation Analysis & Real-Time SI Units
├── export_summary_tables.m          % ส่งออกตารางสรุปผลและสถิติเป็นไฟล์ .csv และ .mat
├── output_figures/                  % โฟลเดอร์เก็บไฟล์รูปภาพกราฟความละเอียดสูง (.png) ทั้งหมด 17 รูป
├── output_tables/                   % โฟลเดอร์เก็บไฟล์ตารางสรุปผล (.csv) และ Workspace รวม (.mat)
└── README.md                        % เอกสารคู่มือและแนวทางการเขียนอภิปรายผลในเล่มรายงาน
```

---

## 🎯 สรุปสิ่งที่คู่มือ `manual_lab1.pdf` กำหนดให้ทำกราฟเปรียบเทียบและวิเคราะห์

จากเอกสาร **`manual_lab1.pdf`** ในส่วน **Criteria Lab 1.4 Load Cell** (หน้า 4 และ หน้า 23) และหัวข้อ **"สิ่งที่ต้องการให้วิเคราะห์"** (หน้า 22) กำหนดข้อกำหนดที่ต้องมีในการทดลองดังนี้:

| หัวข้อตาม Criteria ในคู่มือ | คะแนน | กราฟและตารางที่สอดคล้องในโฟลเดอร์นี้ |
| :--- | :---: | :--- |
| **1. การเปรียบเทียบค่าที่ได้กับเครื่องชั่ง Digital** | 0.5 | **`Fig10_Digital_Scale_vs_LoadCell.png`** (กราฟเทียบ 1:1 Line) |
| **2. การอธิบายสาเหตุของความคลาดเคลื่อน** | 1.0 | **`Fig11_Digital_Scale_Error_Analysis.png`** (Absolute Error & % Error) |
| **3. การวิเคราะห์ Saturation ที่เกิดขึ้น** | 1.0 | **`Fig12_LoadCell_Saturation_Analysis.png`** (Threshold & Gain Drop) |
| **4. Output แบบ Real Time ในหน่วย SI Derived (kg, N)** | 1.0 | **`Fig13_Realtime_SI_Units_Waveforms.png`** (Mass in kg & Force in N) |
| **5. การตอบสนองต่อแรงที่เปลี่ยนไป (Response Curves)** | 1.0 | **`Fig1_LoadCell_Voltage_vs_Mass.png`**, **`Fig1c_Voltage_vs_Force.png`** |
| **6. การแสดงการทำซ้ำ (Repeatability / Precision)** | 0.5 | **`Fig1d_LoadCell_Individual_Trials.png`** (Trial 1–3 vs Mean) |
| **7. การวิเคราะห์ Sensitivity และ Linearity Error** | 1.0 | **`Fig3_LoadCell_Sensitivity.png`**, **`Fig4_LoadCell_Linearity_Error.png`** |
| **8. กระบวนการ Signal Conditioning & Calibration** | 1.0 | **`Fig5_Inverse_Calibration_Model.png`**, **`Fig6_Polynomial_Fit.png`** |

---

## 📊 รายการรูปภาพกราฟทั้ง 17 รูป (ใน `output_figures/`)

### หมวดที่ 1: กราฟเปรียบเทียบเครื่องชั่ง Digital และวิเคราะห์ Saturation (เกณฑ์หลักในคู่มือ)
1. **`Fig10_Digital_Scale_vs_LoadCell.png`**
   * **เนื้อหา:** กราฟเปรียบเทียบระหว่างค่าน้ำหนักที่สอบเทียบได้จาก Load Cell ($m_{LoadCell}$) กับค่าน้ำหนักอ้างอิงที่ชั่งจากเครื่องชั่ง Digital ($m_{Digital}$) เทียบกับเส้นอุดมคติ $y = x$ (1:1 Agreement Line)
   * **การนำไปใช้ในรายงาน:** ยืนยันความแม่นยำ (Accuracy) ของโหลดเซลล์ตลอดช่วง 0.988 ถึง 9.961 kg
2. **`Fig11_Digital_Scale_Error_Analysis.png`**
   * **เนื้อหา:** กราฟแท่ง 2 ซับพล็อต: ซับพล็อตซ้ายแสดง Absolute Error ($m_{LoadCell} - m_{Digital}$ ในหน่วยกรัม) และซับพล็อตขวาแสดง Relative Percentage Error (% Error)
   * **การนำไปใช้ในรายงาน:** อภิปรายสาเหตุความคลาดเคลื่อน เช่น การวางถุงทรายไม่ตรงจุดกึ่งกลาง (Off-center load), ผลของแรงดึงในสายไฟ หรือการบิดตัวของชิ้นงาน 3D-Printed
3. **`Fig12_LoadCell_Saturation_Analysis.png`**
   * **เนื้อหา:** วิเคราะห์พฤติกรรมการเกิด Saturation ที่บริเวณปลายพิกัด (~9.78 - 9.96 kg) โดยแสดงการแยกย่าน Linear Operating Range ออกจาก Saturation Region และซับพล็อตขวาแสดงอัตราความชัน $\frac{\Delta V}{\Delta m}$ ที่ตกลงอย่างชัดเจน
   * **การนำไปใช้ในรายงาน:** อภิปรายข้อจำกัดของโหลดเซลล์เมื่อเข้าใกล้พิกัดพิกัดสูงสุด (10 kg) ทั้งจาก Mechanical Limit (การแตะของชิ้นส่วนคาน) และข้อจำกัดแรงดันเอาต์พุตของไอซี INA125
4. **`Fig13_Realtime_SI_Units_Waveforms.png`**
   * **เนื้อหา:** กราฟแสดงสัญญาณเวลาจริง (Real-time Time-Domain) 0-15 วินาที ที่ผ่านสมการ Calibration แปลงเอาต์พุตออกมาเป็น **น้ำหนักในหน่วย SI Derived โดยตรง** ได้แก่ มวลในหน่วยกิโลกรัม ($\text{kg}$) ที่แกนซ้าย และแรงกดในหน่วยนิวตัน ($\text{N}$) ที่แกนขวา
   * **การนำไปใช้ในรายงาน:** ตรงตาม Criteria ข้อ 9 ของคู่มือ แสดงให้เห็นว่าระบบสามารถรายงานค่าน้ำหนักจริงทางฟิสิกส์ได้อย่างต่อเนื่อง

### หมวดที่ 2: เส้นโค้งการสอบเทียบ (Calibration Curves)
5. **`Fig1_LoadCell_Voltage_vs_Mass.png`**: กราฟ $V_{out}$ vs Mass (kg) พร้อมเส้น Error Bar ($\mu \pm 1\text{SD}$)
6. **`Fig1b_LoadCell_Voltage_vs_Mass_No_Errorbar.png`**: กราฟ $V_{out}$ vs Mass คลีนไม่มี Error Bar (Legend ขวาล่าง)
7. **`Fig1c_LoadCell_Voltage_vs_Force.png`**: กราฟ $V_{out}$ vs Applied Force $F = m \cdot g$ ในหน่วยนิวตัน (0 - 97.68 N)
8. **`Fig1d_LoadCell_Individual_Trials.png`**: กราฟเปรียบเทียบการวัดซ้ำ 3-5 รอบ (Trial 1–5 vs Mean) แสดงความเที่ยงตรง (Repeatability $\text{SD} < 1.9\text{ mV}$)
9. **`Fig1e_LoadCell_ADC_vs_Mass.png`**: กราฟรหัสข้อมูลดิจิทัลดิบจาก ADC 12-bit ของ STM32 (0 - 4095 Counts)

### หมวดที่ 3: คุณลักษณะเชิงลึก (Sensitivity & Linearity Analysis)
10. **`Fig2_LoadCell_Normalized_Transfer_Curve.png`**: กราฟ Normalized Transfer Curve (%FS vs %Load) เทียบเส้นตรงอุดมคติ
11. **`Fig3_LoadCell_Sensitivity.png`**: กราฟความไวเฉพาะช่วง (Dual Y-Axis) $S_m = \frac{\Delta V}{\Delta m}$ (mV/kg) และ $S_F = \frac{\Delta V}{\Delta F}$ (mV/N)
12. **`Fig4_LoadCell_Linearity_Error.png`**: สมการเส้นตรง $V = 0.1702 \cdot m + 0.0578\text{ V}$ ($R^2 = 0.99527$) และ Linearity Residual Error (%FS)
13. **`Fig5_LoadCell_Inverse_Calibration_Model.png`**: สมการสอบเทียบผกผัน $m = 5.8477 \cdot V - 0.3109\text{ kg}$ สำหรับเขียนลง MCU Firmware
14. **`Fig6_LoadCell_Polynomial_Fit_Comparison.png`**: เปรียบเทียบ Linear Fit vs 2nd-Order Polynomial Fit ($R^2 = 0.99839$) ชดเชยการโก่งตัวของคาน

### หมวดที่ 4: สัญญาณรบกวนและพลวัต (Dynamic Stability & Noise Analysis)
15. **`Fig7_LoadCell_Dynamic_Waveforms.png`**: สัญญาณเวลาจริง (0 - 15 s ที่ 1,000 Hz) ของ 3 ระดับน้ำหนัก (ต่ำ: ~1 kg, กลาง: ~5 kg, สูง: ~10 kg)
16. **`Fig8_LoadCell_Noise_Distribution.png`**: การกระจายตัวของสัญญาณรบกวน Histogram PDF พร้อม Gaussian Fit ($\sigma_{noise} \approx 2.64\text{ mV}$)
17. **`Fig9_LoadCell_SNR_and_Noise_Floor.png`**: อัตราส่วนสัญญาณต่อสัญญาณรบกวน $\text{SNR}$ (37.74 dB ถึง 56.27 dB) และ Noise Floor

---

## 📑 ตารางข้อมูลสรุปผล (ใน `output_tables/`)

1. **`Table_LoadCell_Summary.csv`**: ตารางมวล $m$, แรง $F$, แรงดันเฉลี่ย $V$, Repeatability SD, ค่า ADC, และผลแยก Trial 1–3 ทั้งหมด 11 จุดวัด
2. **`Table_LoadCell_Performance_Metrics.csv`**: ตารางสรุปตัวชี้วัดสมรรถนะ:
   * **Full Scale Capacity:** $9.961\text{ kg}$ ($97.68\text{ N}$)
   * **Mean Sensitivity:** $170.16\text{ mV/kg}$ ($17.35\text{ mV/N}$)
   * **Linear Fit Equation:** $V = 0.1702 \cdot m + 0.0580\text{ V}$ ($R^2 = 0.99525$)
   * **Max Linearity Error:** $4.55\% \text{ FS}$
   * **2nd-Order Polynomial $R^2$:** $0.99839$ (Max Error $2.75\% \text{ FS}$)
   * **Max Repeatability SD:** $1.76\text{ mV}$ ($0.11\% \text{ FS}$)
   * **Inverse Calibration Function:** $m = 5.8490 \cdot V - 0.3117\text{ kg}$
   * **Average Noise Floor:** $2.59\text{ mV}$
   * **Peak SNR:** $56.29\text{ dB}$
3. **`Table_LoadCell_Noise_Analysis.csv`**: ตาราง RMS Noise, Estimated $V_{pp}$, SNR (dB), และ ENOB
4. **`Lab1_4_Summary_Data.mat`**: ไฟล์ MATLAB Workspace รวมข้อมูลทั้งหมด
