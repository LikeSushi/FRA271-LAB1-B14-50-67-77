# ชุดสคริปต์ MATLAB Visualize ข้อมูลการทดลอง Lab 1.1: Potentiometers & Schmitt Trigger

ชุดเครื่องมือ MATLAB สำหรับประมวลผล วิเคราะห์ และสร้างภาพข้อมูล (Data Visualization) อัตโนมัติจากไฟล์ข้อมูล `.mat` ทั้งหมด 192 ไฟล์ของการทดลอง **Lab 1.1: Potentiometer** (วิชา RMX / FRA: Sensors) ออกแบบมาให้ได้กราฟคุณภาพระดับสิ่งพิมพ์ทางวิชาการ (Publication-Quality Figures) และตารางสถิติสรุปผลที่พร้อมนำไปวางในรายงานการทดลอง (Word / PDF) ได้ทันที

---

## 📁 โครงสร้างไฟล์ในโฟลเดอร์นี้

```text
MATLAB Visualize/
├── main_visualize_all.m           % สคริปต์หลัก (Master Script) สั่งรันทุกอย่างในขั้นตอนเดียว
├── load_lab_data.m                % ฟังก์ชันโหลดและแยกสัญญาณจากไฟล์ .mat (รองรับ Simulink Dataset)
├── process_static_data.m          % ฟังก์ชันประมวลผลสถิติการวัด (Mean, SD, แปลง ADC -> Voltage)
├── plot_rotary_potentiometers.m   % วิเคราะห์และพล็อตเซนเซอร์วัดมุม Rotary (RAW1, RAW2, RAW3)
├── plot_linear_potentiometers.m   % วิเคราะห์และพล็อตเซนเซอร์วัดระยะทาง Linear Slide (RAW4, RAW5)
├── plot_realtime_schmitt_trigger.m% วิเคราะห์สัญญาณ Real-Time Dynamic และวงจร Schmitt Trigger
├── export_summary_tables.m        % ส่งออกตารางสรุปข้อมูลสถิติและตัวชี้วัดเป็นไฟล์ .csv และ .mat
├── output_figures/                % โฟลเดอร์จัดเก็บรูปภาพกราฟที่สร้างขึ้น (.png)
└── output_tables/                 % โฟลเดอร์จัดเก็บตารางสรุปผล (.csv)
```

---

## 🚀 วิธีการรันโค้ดใน MATLAB

1. เปิดโปรแกรม **MATLAB**
2. ในหน้าต่าง Current Folder ของ MATLAB ให้เข้าไปที่โฟลเดอร์:
   `C:\Users\User\Downloads\LAB_RMX\Lab1.1-20260930T132419Z-1-001\MATLAB Visualize`
3. เปิดไฟล์ `main_visualize_all.m` แล้วกดปุ่ม **▶ Run** (หรือพิมพ์ `main_visualize_all` ใน Command Window แล้วกด Enter)
4. สคริปต์จะประมวลผลข้อมูลและสร้างรูปภาพกราฟทั้งหมดลงในโฟลเดอร์ `output_figures/` และตารางสรุปผลลงใน `output_tables/` โดยอัตโนมัติ

---

## 📊 รายการกราฟที่ได้และคำอธิบายสำหรับใส่ในรายงาน

### 1. หมวด Rotary Potentiometers (RAW1, RAW2, RAW3: มุม 0° - 100°)
* **`Fig1_Rotary_Voltage_vs_Angle.png`**
  * **เนื้อหา:** กราฟความสัมพันธ์ระหว่างแรงดันไฟฟ้าขาออก $V_{out}$ (V) กับมุมการหมุน $\theta$ (องศา) พร้อม Error Bar ($\mu \pm 1\text{SD}$) ของการวัดซ้ำ 3 รอบ
  * **การนำไปใช้ในรายงาน:** แสดงคุณลักษณะการถ่ายโอนสัญญาณ (Transfer Characteristics) และความสามารถในการวัดซ้ำ (Repeatability / Precision)
* **`Fig1b_Rotary_Voltage_vs_Angle_No_Errorbar.png`**
  * **เนื้อหา:** กราฟความสัมพันธ์ $V_{out}$ กับมุมการหมุน $\theta$ แบบคลีน **ไม่มี Error Bar** พร้อมย้ายกล่อง Legend ไปมุมขวาบน (`northeast`)
  * **การนำไปใช้ในรายงาน:** ใช้กรณีต้องการรูปกราฟที่สะอาด อ่านง่าย และไม่มีเส้น Error Bar บดบังสายตา
* **`Fig1c_RAW1_Voltage_vs_Angle.png`**, **`Fig1c_RAW2_Voltage_vs_Angle.png`**, **`Fig1c_RAW3_Voltage_vs_Angle.png`**
  * **เนื้อหา:** กราฟผลการทดลอง**แยกเดี่ยว 3 รูป** สำหรับ RAW1, RAW2, และ RAW3 โดยพล็อตเส้นแสดงการวัดซ้ำทั้ง 3 รอบ (Trial 1, 2, 3) พร้อมเส้นค่าเฉลี่ยหลัก (Mean)
  * **การนำไปใช้ในรายงาน:** ใช้แยกอภิปรายคุณสมบัติของเซนเซอร์แต่ละตัวโดยละเอียดในรายงาน
* **`Fig1d_Rotary_3Subplots.png`**
  * **เนื้อหา:** กราฟสรุปผลรวมแบบ 3 ซับพล็อตเรียงข้างกัน (1x3 Subplots Grid) แสดง RAW1, RAW2, RAW3 ในรูปเดียว
  * **การนำไปใช้ในรายงาน:** เหมาะสำหรับวางเปรียบเทียบในเล่มรายงานแนวนอน หรือใส่ในสไลด์นำเสนอ (Presentation)
* **`Fig2_Rotary_Taper_Curves.png`**
  * **เนื้อหา:** กราฟมาตรฐานเปรียบเทียบ Taper Profile (% Full Scale vs % Rotation) เทียบกับเส้นตรงอุดมคติ
  * **การนำไปใช้ในรายงาน:** จำแนกประเภทของ Potentiometer ตาม Datasheet ได้แก่:
    * **Type A (Audio / Logarithmic Taper):** กราฟค่อยๆ ชันขึ้นในช่วงท้าย (มักใช้ในระบบควบคุมเสียง)
    * **Type B (Linear Taper):** กราฟเป็นเส้นตรง ความชันคงที่ตลอดช่วง (เหมาะสำหรับใช้เป็นเซนเซอร์วัดตำแหน่ง)
    * **Type C (Reverse Audio / Anti-Log Taper):** กราฟชันมากในช่วงแรกและค่อยๆ ชะลอตัวลง
* **`Fig3_Rotary_Sensitivity.png`**
  * **เนื้อหา:** กราฟความไวเฉพาะจุด $S = \frac{\Delta V}{\Delta \theta}$ (mV/degree) ตลอดช่วงการหมุน
  * **การนำไปใช้ในรายงาน:** พิสูจน์ว่า Type B มีความไวคงที่ สม่ำเสมอ ในขณะที่ Type A และ Type C มีความไวที่แปรผันตามมุม
* **`Fig4_Rotary_Linearity_Error.png`**
  * **เนื้อหา:** การฟิตสมการเส้นตรง (Linear Regression $y = mx + c$), ค่าสัมประสิทธิ์การตัดสินใจ ($R^2$), และกราฟแท่งแสดง Linearity Error (% Full Scale)
  * **การนำไปใช้ในรายงาน:** ใช้ประเมินความคลาดเคลื่อนเชิงเส้นสูงสุด (Maximum Linearity Error %FS) ของเซนเซอร์วัดมุมเชิงเส้น

---

### 2. หมวด Linear Slide Potentiometers (RAW4, RAW5: ระยะ 0.0 - 6.0 ซม.)
* **`Fig5_Linear_Voltage_vs_Distance.png`**
  * **เนื้อหา:** กราฟแรงดันไฟฟ้าขาออก $V_{out}$ (V) กับระยะทางการเลื่อน $d$ (cm) พร้อม Error Bar
  * **การนำไปใช้ในรายงาน:** แสดงความสัมพันธ์ของสไลด์โพเทนชิโอมิเตอร์แบบชักตรง (Bourns PTA6043 Series, ระยะชัก 60 mm)
* **`Fig5b_Linear_Voltage_vs_Distance_No_Errorbar.png`**
  * **เนื้อหา:** กราฟความสัมพันธ์ $V_{out}$ กับระยะทาง $d$ แบบคลีน **ไม่มี Error Bar** พร้อมย้ายกล่อง Legend ไปมุมขวาบน (`northeast`)
  * **การนำไปใช้ในรายงาน:** ใช้กรณีต้องการรูปกราฟที่สะอาด อ่านง่าย และไม่มีเส้น Error Bar บดบังสายตา
* **`Fig5c_RAW4_Voltage_vs_Distance.png`**, **`Fig5c_RAW5_Voltage_vs_Distance.png`**
  * **เนื้อหา:** กราฟผลการทดลอง**แยกเดี่ยว 2 รูป** สำหรับ RAW4 และ RAW5 โดยพล็อตเส้นแสดงการวัดซ้ำทั้ง 3 รอบ (Trial 1, 2, 3) พร้อมเส้นค่าเฉลี่ยหลัก (Mean)
  * **การนำไปใช้ในรายงาน:** ใช้แยกอภิปรายคุณสมบัติของ Linear Slide Potentiometer แต่ละตัวโดยละเอียด
* **`Fig5d_Linear_2Subplots.png`**
  * **เนื้อหา:** กราฟสรุปผลรวมแบบ 2 ซับพล็อตเรียงข้างกัน (1x2 Subplots Grid) แสดง RAW4 และ RAW5 ในรูปเดียว
  * **การนำไปใช้ในรายงาน:** เหมาะสำหรับวางเปรียบเทียบในเล่มรายงานแนวนอน หรือใส่ในสไลด์นำเสนอ (Presentation)
* **`Fig6_Linear_Taper_Curves.png`**
  * **เนื้อหา:** กราฟเปรียบเทียบ Taper Curve ของ RAW4 และ RAW5
  * **การนำไปใช้ในรายงาน:** ยืนยันว่าโมเดล PTA6043-2015DPB103 เป็น Type B (Linear) และ PTA6043-2015DPA103 เป็น Type A
* **`Fig7_Linear_Sensitivity.png`**
  * **เนื้อหา:** ความไวในการเปลี่ยนตำแหน่ง $S = \frac{\Delta V}{\Delta d}$ ในหน่วย V/cm และ mV/mm
  * **การนำไปใช้ในรายงาน:** คำนวณอัตราขยายการแปลงสัญญาณทางกายภาพเป็นสัญญาณไฟฟ้า
* **`Fig8_Linear_Calibration_Error.png`**
  * **เนื้อหา:** โมเดลการสอบเทียบแบบย้อนกลับ (Inverse Calibration Function $d = m \cdot V + c$) ที่ใช้เขียนในโปรแกรมไมโครคอนโทรลเลอร์ (STM32) เพื่อแปลงค่าแรงดันกลับเป็นระยะทาง พร้อมกราฟความผิดพลาดตำแหน่ง (%FS)

---

### 3. หมวด Real-Time Dynamic & Schmitt Trigger
* **`Fig9_Realtime_Waveform_*.png`**
  * **เนื้อหา:** กราฟสัญญาณตามเวลาจริง (Time-Domain) แบ่งเป็น 2 ซับพล็อต:
    1. ด้านบน: สัญญาณ Analog Voltage $V_{in}(t)$ พร้อมเส้นประระบุระดับขีดเริ่มเปลี่ยนบน ($V_{TH}$) และขีดเริ่มเปลี่ยนล่าง ($V_{TL}$)
    2. ด้านล่าง: สถานะสัญญาณดิจิทัลขาออก $V_{out}(t)$ (สถานะ 0 / 1)
  * **การนำไปใช้ในรายงาน:** แสดงการทำงานของวงจร Schmitt Trigger ใน Simulink ที่ช่วยแปลงสัญญาณอะนาล็อกเป็นดิจิทัลได้อย่างแม่นยำ
* **`Fig10_Schmitt_Hysteresis_*.png`**
  * **เนื้อหา:** กราฟวงรอบฮิสเทอรีซิส (Hysteresis Loop: $V_{out}$ vs $V_{in}$) พร้อมระบุความกว้างของย่านฮิสเทอรีซิส $\Delta V_H = V_{TH} - V_{TL}$
  * **การนำไปใช้ในรายงาน:** อภิปรายความสำคัญของช่วง Hysteresis Band ในการกำจัดปัญหาการกระเพื่อมของสัญญาณรบกวน (Chattering / Bounce Elimination) เมื่อสัญญาณอินพุตมีสัญญาณรบกวนปะปนใกล้จุดขีดเริ่มเปลี่ยน

---

## 📑 ตารางข้อมูลสรุปผล (ในโฟลเดอร์ `output_tables/`)

1. **`Table_Rotary_Summary.csv`**: ตารางมุม 0° - 100° พร้อมค่า Mean (V) และ SD (V) ของ RAW1, RAW2, RAW3 ครบทั้ง 3 รอบ
2. **`Table_Linear_Summary.csv`**: ตารางระยะ 0.0 - 6.0 cm พร้อมค่า Mean (V) และ SD (V) ของ RAW4, RAW5 ครบทั้ง 3 รอบ
3. **`Table_Sensor_Performance_Metrics.csv`**: ตารางเปรียบเทียบคุณสมบัติเชิงประสิทธิภาพ:
   * ชนิดเซนเซอร์ (Rotary / Linear)
   * ผลการระบุ Taper Profile (Type A / B / C)
   * ความไวเฉลี่ย (Average Sensitivity)
   * ค่าสัมประสิทธิ์ความเป็นเชิงเส้น ($R^2$)
   * ความคลาดเคลื่อนเชิงเส้นสูงสุด (Max Linearity Error %FS)

---

## 💡 แนวทางการเขียน "อภิปรายผล" (Discussion) ในเล่มรายงาน

* **ด้านความเที่ยงตรง (Precision & Repeatability):** ค่า Standard Deviation (SD) ของทั้ง 3 รอบการวัดมีค่าน้อยมาก (น้อยกว่า 0.01V) บ่งบอกว่าโพเทนชิโอมิเตอร์มีความสามารถในการวัดซ้ำได้ดีมาก ความไม่แน่นอนของการวัดส่วนใหญ่มาจากความคลาดเคลื่อนในการจัดตำแหน่งมุม/ระยะทางด้วยมือ (Human Positioning Uncertainty)
* **ด้านความเป็นเชิงเส้น (Linearity):** เซนเซอร์ Type B มีค่า $R^2 > 0.999$ แสดงความเป็นเชิงเส้นที่ยอดเยี่ยม เหมาะสำหรับใช้งานเป็น Angular / Displacement Feedback Sensor ในระบบเมคาทรอนิกส์และหุ่นยนต์ ส่วน Type A และ Type C ออกแบบมาให้ไม่เป็นเชิงเส้นเพื่อตอบสนองการรับรู้ของมนุษย์ (เช่น ความดังของเสียงที่เป็น Logarithmic ตามการได้ยิน)
* **ด้านวงจร Schmitt Trigger:** การใช้ Threshold คู่ ($V_{TH}$ และ $V_{TL}$) ช่วยป้องกันการสลับสถานะไปมาอย่างรวดเร็ว (Chattering) ที่มักเกิดขึ้นในการใช้ Single Comparator แบบธรรมดา ทำให้ได้สัญญาณดิจิทัลที่สะอาดและปลอดภัยต่อการนำไปใช้งานเป็นสัญญาณทริกเกอร์หรืออินเตอร์รัปต์ในไมโครคอนโทรลเลอร์
