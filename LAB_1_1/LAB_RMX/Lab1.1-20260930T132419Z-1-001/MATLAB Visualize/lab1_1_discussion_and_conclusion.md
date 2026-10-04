# 📝 เอกสารสรุปและอภิปรายผลการทดลอง (Conclusion & Discussion)
## การทดลอง Lab 1.1: Potentiometers & Schmitt Trigger Circuit
**วิชา:** RMX / FRA: Sensors and Transducers  

---

## 📌 ส่วนที่ 1: การสรุปผลและอภิปรายตามหัวข้อวิเคราะห์ (Analysis Criteria)

### 1. การระบุชนิดและคุณสมบัติของ Sensor (Sensor Identification & Linearity)

#### 1.1 การจำแนกชนิดของ Potentiometer ทั้งหมดในชุดทดลอง
จากการประมวลผลข้อมูลแรงดันไฟฟ้าขาออก ($V_{out}$) เทียบกับระยะทางการหมุน/เลื่อนทางกายภาพ ทั้งหมด 5 ตัว สามารถจำแนกชนิดของ Resistance Taper Profile ตามมาตรฐานอุตสาหกรรมได้ดังนี้:

| ชื่อเซนเซอร์ | รูปแบบการวัด | ชนิด Taper (Taper Profile) | รหัสทางอุตสาหกรรม | สัมประสิทธิ์ $R^2$ | Maximum Linearity Error (%FS) |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **RAW1** | Rotary (0° - 100°) | **Type C** (Reverse Audio / Anti-Log) | Anti-Logarithmic | 0.8569 | 23.58 %FS |
| **RAW2** | Rotary (0° - 100°) | **Type B** (Linear Taper) | Linear | **0.9883** | **8.57 %FS** |
| **RAW3** | Rotary (0° - 100°) | **Type A** (Audio / Logarithmic) | Logarithmic | 0.7839 | 25.77 %FS |
| **RAW4** | Linear (0.0 - 6.0 cm) | **Type A** (Audio / Logarithmic) | Bourns PTA6043-2015DPA103 | 0.8595 | 21.14 %FS |
| **RAW5** | Linear (0.0 - 6.0 cm) | **Type B** (Linear Taper) | Bourns PTA6043-2015DPB103 | **0.9961** | **5.73 %FS** |

#### 1.2 การตรวจสอบความเป็นเชิงเส้น (Linearity Analysis)
* **เซนเซอร์แบบเชิงเส้น (Type B - RAW2 และ RAW5):**
  * **RAW5 (Linear Slide):** มีความเป็นเชิงเส้นสูงสุด โดยมีค่าสัมประสิทธิ์การตัดสินใจ $R^2 = 0.9961$ และความผิดพลาดเชิงเส้นต่ำที่สุดเพียง **5.73% FS** สมการการสอบเทียบย้อนกลับ (Inverse Calibration Equation) คือ:
    $$d(\text{cm}) = -1.825 \cdot V_{out} + 5.998$$
  * **RAW2 (Rotary):** มีความเป็นเชิงเส้นสูง $R^2 = 0.9883$ และค่า Linearity Error เท่ากับ **8.57% FS** สมการการฟิตเส้นตรงคือ:
    $$V_{out}(\text{V}) = -0.0329 \cdot \theta + 3.288$$
* **เซนเซอร์แบบไม่เป็นเชิงเส้น (Type A & Type C - RAW1, RAW3, RAW4):**
  * **Type A (Logarithmic / Audio Taper - RAW3, RAW4):** กราฟมีลักษณะความชันสูงในช่วงแรก และค่อยๆ ชะลอความชันลงในช่วงปลาย ค่า $R^2$ ต่ำกว่า 0.86
  * **Type C (Reverse Logarithmic Taper - RAW1):** กราฟมีความชันต่ำในช่วงแรก และมีความชันสูงมากในช่วงท้าย ($60^\circ - 100^\circ$)

---

### 2. การวิเคราะห์การตอบสนองของ Potentiometer แต่ละชนิด (Sensor Response Analysis)

#### 2.1 ความไวในการตอบสนอง (Sensitivity Analysis: $S = \frac{\Delta V}{\Delta x}$)
* **Type B (Linear):** มีค่าความไวเฉพาะจุด ($S$) ที่**ค่อนข้างคงที่ตลอดช่วงการวัด**
  * RAW2 มีความไวเฉลี่ยอยู่ที่ $S \approx 32.88\text{ mV/degree}$
  * RAW5 มีความไวเฉลี่ยอยู่ที่ $S \approx 0.548\text{ V/cm}$ (หรือ $54.8\text{ mV/mm}$)
  ทำให้ประมวลผลสัญญาณได้ง่าย ไม่ต้องใช้สมการชดเชยที่ซับซ้อน เหมาะสำหรับใช้เป็น Angular & Displacement Feedback Sensor ในระบบหุ่นยนต์
* **Type A & Type C (Non-Linear):** มีค่าความไว **แปรผันตามตำแหน่ง (Position-Dependent Sensitivity)**
  * RAW3 (Type A) มีความไวสูงมากในช่วง $0^\circ - 30^\circ$ ($S > 60\text{ mV/degree}$) แต่ความไวจะลดลงเหลือเกือบ $0\text{ mV/degree}$ ที่ช่วงปลาย
  * RAW1 (Type C) มีความไวต่ำในช่วงต้น แต่พุ่งสูงขึ้นเป็น $> 80\text{ mV/degree}$ ในช่วง $60^\circ - 80^\circ$

#### 2.2 ความสามารถในการวัดซ้ำและความแน่นอน (Repeatability & Measurement Precision)
* **RAW1 และ RAW3:** มีส่วนเบี่ยงเบนมาตรฐานระหว่างรอบ ($SD_{repeatability}$) ต่ำมากเพียง **$\approx 0.8\text{ mV}$ (0.0008 V)** บ่งบอกถึงความแม่นยำและความเสถียรของหน้าสัมผัสภายในเซนเซอร์ที่สูงมาก
* **RAW2:** มีค่า SD เฉลี่ยอยู่ที่ **17.2 mV (0.0172 V)** และพบค่า Outlier ที่มุม $90^\circ$ ($SD = 0.1465\text{ V}$) ซึ่งเกิดจาก **Human Positioning Error** ในการหมุนปรับองศาด้วยมือในรอบการทดลองที่ 1

---

### 3. การจำลองวงจร Schmitt Trigger (Simulink Simulation & Threshold Analysis)

#### 3.1 วงจร Schmitt Trigger ใน Simulink และวัตถุประสงค์
ในระบบจริง สัญญาณอะนาล็อกที่ออกจาก Potentiometer มักจะถูกรบกวนด้วย High-Frequency Noise หากใช้ Comparator ขีดเริ่มเปลี่ยนเดียว (Single Threshold Comparator) จะทำให้เกิดปรากฏการณ์ **Chattering / Signal Bouncing** (สัญญาณสลับ 0 และ 1 ไปมาอย่างรวดเร็วใกล้จุดตัด) 

การออกแบบวงจร **Schmitt Trigger** ใน Simulink โดยใช้โครงสร้างแบบ Dual Threshold จึงช่วยแก้ปัญหานี้ได้อย่างมีประสิทธิภาพ

#### 3.2 การกำหนดค่า Threshold บน-ล่างที่เหมาะสม (Upper & Lower Thresholds)
จากการประมวลผลข้อมูลสัญญาณ Real-Time Dynamic Response ข้อมูลจริงของวงจร Schmitt Trigger มีค่าขีดเริ่มเปลี่ยนดังนี้:

* **Upper Threshold ($V_{TH}$):** มีค่าเท่ากับ **$2.20\text{ V}$** (จุดที่สัญญาณเปลี่ยนสถานะจาก 0 เป็น 1 ขณะแรงดันเพิ่มขึ้น)
* **Lower Threshold ($V_{TL}$):** มีค่าเท่ากับ **$1.65\text{ V}$** (จุดที่สัญญาณเปลี่ยนสถานะจาก 1 เป็น 0 ขณะแรงดันลดลง)
* **ช่วงย่านฮิสเทอรีซิส (Hysteresis Band Width: $\Delta V_H$):**
  $$\Delta V_H = V_{TH} - V_{TL} = 2.20\text{ V} - 1.65\text{ V} = 0.55\text{ V}$$

#### 3.3 การวิเคราะห์ผลวงรอบ Hysteresis Loop
* เมื่อสัญญาณขาเข้า $V_{in}(t)$ เพิ่มขึ้นจาก 0V สถานะขาออก $V_{out}(t)$ จะคงเป็น `0 (LOW)` จนกว่า $V_{in}$ จะพุ่งข้าม $V_{TH} = 2.20\text{ V}$ สถานะจึงเปลี่ยนเป็น `1 (HIGH)`
* เมื่อ $V_{in}(t)$ ลดลง สถานะขาออกจะยังคงค้างอยู่ที่ `1 (HIGH)` และจะไม่ยอมเปลี่ยนกลับเป็น `0 (LOW)` จนกว่า $V_{in}$ จะลดลงต่ำกว่า $V_{TL} = 1.65\text{ V}$
* ช่วงระยะห่าง $\Delta V_H = 0.55\text{ V}$ นี้ ทำหน้าที่เป็น **Noise Immunity Margin** ซึ่งป้องกันไม่ให้สัญญาณรบกวนที่มีขนาดน้อยกว่า 0.55V p-p ส่งผลกระทบต่อสถานะดิจิทัลขาออก ทำให้ได้สัญญาณดิจิทัลที่สะอาด ปลอดภัยต่อการนำไปใช้อ่านค่าด้วย Interrupt Pin ของไมโครคอนโทรลเลอร์ (STM32 / Arduino)

---

## 📌 ส่วนที่ 2: สรุปผลการทดลอง (Conclusion)

1. **การจำแนกชนิด Potentiometer:**
   * เซนเซอร์วัดมุมหมุน Rotary: RAW1 เป็นชนิด **Type C (Reverse Log)**, RAW2 เป็นชนิด **Type B (Linear)**, และ RAW3 เป็นชนิด **Type A (Logarithmic)**
   * เซนเซอร์วัดระยะทาง Linear Slide: RAW4 เป็นชนิด **Type A (Logarithmic)** และ RAW5 เป็นชนิด **Type B (Linear)**
2. **คุณสมบัติเชิงเส้นและความไว:**
   * เซนเซอร์ **Type B (RAW2, RAW5)** มีความเป็นเชิงเส้นสูงที่สุด ($R^2 > 0.988$) มีค่าความไวคงที่ เหมาะสำหรับงานวัดตำแหน่งและระยะทางความละเอียดสูง
   * เซนเซอร์ **Type A และ C (RAW1, RAW3, RAW4)** มีความไวแปรผันตามตำแหน่ง เหมาะกับงานควบคุมเสียง (Audio Volume Control) หรือระบบที่ต้องการความไวเฉพาะย่าน
3. **การจำลองวงจร Schmitt Trigger:**
   * วงจร Schmitt Trigger ที่สร้างขึ้นใน Simulink ด้วยค่า $V_{TH} = 2.20\text{ V}$ และ $V_{TL} = 1.65\text{ V}$ ($\Delta V_H = 0.55\text{ V}$) สามารถแปลงสัญญาณอะนาล็อกเป็นดิจิทัลได้แม่นยำ และช่วยกำจัดสัญญาณรบกวนปะปน (Chattering Elimination) ได้อย่างสมบูรณ์

---

## 📌 ส่วนที่ 3: ข้อเสนอแนะและแนวทางการอภิปรายเพิ่มเติม (Discussion Highlights)

* **อภิปรายด้าน Human Uncertainty:** ค่า SD ที่โดดเด่นใน RAW2 ที่มุม $90^\circ$ ควรระบุในรายงานว่าเกิดจาก Human Positioning Error ในการปรับหมุนองศาด้วยมือ ซึ่งแก้ไขได้โดยการใช้ Jig/Fixture หรือมอเตอร์เกียร์ควบคุมมุมแทนการบิดด้วยมือ
* **อภิปรายด้านการประยุกต์ใช้งาน (Applications):** 
  * ควรเลือกใช้ RAW5/RAW2 เมื่อต้องการเขียนโปรแกรมไมโครคอนโทรลเลอร์คำนวณตำแหน่งตรงๆ ($d = m\cdot V + c$)
  * หากจำเป็นต้องใช้ Type A หรือ Type C ในการวัดตำแหน่ง จะต้องสร้าง Look-up Table (LUT) หรือใช้สมการโพลีโนเมียลในการสอบเทียบย้อนกลับ (Polynomial Inverse Fitting)
