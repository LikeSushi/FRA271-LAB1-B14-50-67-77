# MATLAB Data Processing & Visualization System
**วิชา RMX / FRA Lab: Magnetic Field Sensors & Shielding Performance**

ระบบประมวลผลข้อมูลอัตโนมัติและสร้างรูปกราฟรายงานผลการทดลองสนามแม่เหล็ก (Magnetic Flux Density) และแรงดันไฟฟ้า (Voltage Output)

---

## 📁 โครงสร้างโฟลเดอร์ (Project Structure)

```text
MATLAB Visualize/
├── main_visualize_all.m           # สคริปต์หลักสำหรับรันประมวลผลทั้งหมด
├── load_lab_data.m                # ฟังก์ชันโหลดไฟล์ .mat อย่างปลอดภัย
├── process_static_data.m          # โมดูลคำนวณค่าสถิติ Mean, Std, Peak, Attenuation
├── plot_magnetic_sensors.m        # โมดูลพล็อต 4 กราฟหลัก และ 4-Graph Grid Layout
├── plot_shielding_performance.m   # โมดูลพล็อต Shielding Efficiency (%) & Sensitivity
├── plot_realtime_waveforms.m      # โมดูลพล็อต Time-domain Signal Waveforms
├── export_summary_tables.m        # โมดูลส่งออกตารางข้อมูลสรุป (CSV / MAT)
├── output_figures/                # โฟลเดอร์จัดเก็บรูปกราฟ (.png และ .fig)
└── output_tables/                 # โฟลเดอร์จัดเก็บตารางสรุปข้อมูล (.csv และ .mat)
```

---

## 🚀 วิธีเปิดใช้งาน (Execution Guide)

1. เปิดโปรแกรม **MATLAB**
2. ตั้งค่า Current Folder ไปยังโฟลเดอร์ `MATLAB Visualize`:
   ```matlab
   cd('C:\Users\Chard\Downloads\เก็บใหม่จากไนซ์-20261003T020828Z-1-001\MATLAB Visualize');
   ```
3. รันสคริปต์หลักด้วยคำสั่ง:
   ```matlab
   main_visualize_all
   ```

---

## 📊 รายการรูปภาพผลลัพธ์ (Output Figures)

| รูปภาพ (Figure File) | รายละเอียดข้อมูล |
| :--- | :--- |
| `Fig1_Sensor_C_Magnetic_Flux_vs_Distance.png` | กราฟความหนาแน่นฟลักซ์แม่เหล็ก (mT) vs ระยะทาง (cm) ของ Sensor C |
| `Fig2_Sensor_C_Voltage_vs_Distance.png` | กราฟแรงดันไฟฟ้า (V) vs ระยะทาง (cm) ของ Sensor C |
| `Fig3_Sensor_D_Magnetic_Flux_vs_Distance.png` | กราฟความหนาแน่นฟลักซ์แม่เหล็ก (mT) vs ระยะทาง (cm) ของ Sensor D |
| `Fig4_Sensor_D_Voltage_vs_Distance.png` | กราฟแรงดันไฟฟ้า (V) vs ระยะทาง (cm) ของ Sensor D |
| `Fig5_Sensor_C_D_4_Graphs_Comparison_Grid.png` | **กราฟรวม 4 ช่อง (Grid Layout)** เปรียบเทียบ Shield vs No Shield ทั้ง Sensor C และ D |
| `Fig6_Shielding_Attenuation_Efficiency.png` | กราฟอัตราการกำบังสนามแม่เหล็ก (% Attenuation) vs ระยะทาง |
| `Fig7_Sensor_Sensitivity_Comparison.png` | กราฟเปรียบเทียบความไวการตอบสนองของเซนเซอร์ |
| `Fig8_Realtime_Time_Domain_Waveforms.png` | กราฟสัญญาณย่านเวลา (Time-Domain Waveform) |

---

## 📋 รายการตารางข้อมูลสรุป (Exported CSV Tables)

| ตารางข้อมูล (CSV File) | เนื้อหาข้อมูล |
| :--- | :--- |
| `Table_Sensor_C_Summary.csv` | ค่าเฉลี่ยและส่วนเบี่ยงเบนมาตรฐาน (Mean/Std) ของ Sensor C ทุกระยะ |
| `Table_Sensor_D_Summary.csv` | ค่าเฉลี่ยและส่วนเบี่ยงเบนมาตรฐาน (Mean/Std) ของ Sensor D ทุกระยะ |
| `Table_Shielding_Attenuation_Summary.csv` | ตารางคำนวณประสิทธิภาพการกำบัง (% Attenuation) Sensor C และ D |
| `Lab_Summary_Data.mat` | ข้อมูล Data Structure รวมสำหรับนำไปประมวลผลต่อใน MATLAB |
