# -*- coding: utf-8 -*-
"""
Script to generate the complete formal laboratory report in Microsoft Word (.docx)
format for Lab 1.4: Single Point Load Cell with INA125 Instrumentation Amplifier.
Complies with FIBO FRA271 report format:
- Margins: Moderate (0.75 in / 1.91 cm)
- Font: TH Sarabun New (Headings: 18/16 pt Bold, Body: 16 pt Regular, Tables/Captions: 14 pt)
- Line Spacing: 1.0
- Paragraph Alignment: Justified (Thai Distributed)
- Maximum length: <= 10 pages
"""

import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_border(cell, **kwargs):
    """
    Set cell borders: top, bottom, left, right
    """
    tcPr = cell._tc.get_or_add_tcPr()
    tcBorders = parse_xml(
        f'<w:tcBorders {nsdecls("w")}>\n'
        f'<w:top w:val="{kwargs.get("top", "single")}" w:sz="{kwargs.get("top_sz", "4")}" w:space="0" w:color="{kwargs.get("top_color", "CCCCCC")}"/>\n'
        f'<w:left w:val="{kwargs.get("left", "none")}" w:sz="{kwargs.get("left_sz", "4")}" w:space="0" w:color="{kwargs.get("left_color", "CCCCCC")}"/>\n'
        f'<w:bottom w:val="{kwargs.get("bottom", "single")}" w:sz="{kwargs.get("bottom_sz", "4")}" w:space="0" w:color="{kwargs.get("bottom_color", "CCCCCC")}"/>\n'
        f'<w:right w:val="{kwargs.get("right", "none")}" w:sz="{kwargs.get("right_sz", "4")}" w:space="0" w:color="{kwargs.get("right_color", "CCCCCC")}"/>\n'
        f'</w:tcBorders>'
    )
    tcPr.append(tcBorders)

def set_cell_shading(cell, color_hex):
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def add_page_number_to_header(section):
    header = section.header
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    hp.paragraph_format.space_before = Pt(0)
    hp.paragraph_format.space_after = Pt(0)
    
    # Add page number run
    fldSimple = parse_xml(f'<w:fldSimple {nsdecls("w")} w:instr="PAGE"/>')
    hp._p.append(fldSimple)
    for run in hp.runs:
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(14)
        run.font.color.rgb = RGBColor(100, 100, 100)

def create_report_document():
    doc = Document()
    
    # Page setup - Margins Moderate (0.75 in / 1.91 cm)
    for section in doc.sections:
        section.top_margin = Inches(0.75)
        section.bottom_margin = Inches(0.75)
        section.left_margin = Inches(0.75)
        section.right_margin = Inches(0.75)
        section.different_first_page_header_footer = False
        add_page_number_to_header(section)

    # Base Normal style
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'TH Sarabun New'
    normal_style.font.size = Pt(16)
    normal_style.font.color.rgb = RGBColor(0, 0, 0)
    normal_style.paragraph_format.line_spacing = 1.0
    normal_style.paragraph_format.space_before = Pt(0)
    normal_style.paragraph_format.space_after = Pt(0)

    def add_title(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(2)
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(18)
        run.bold = True
        return p

    def add_subtitle(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(2)
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(16)
        run.bold = True
        return p

    def add_meta(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(1)
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(14)
        run.italic = True
        run.font.color.rgb = RGBColor(80, 80, 80)
        return p

    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(3)
        p.paragraph_format.space_after = Pt(1)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(18)
        run.bold = True
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(1)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(16)
        run.bold = True
        return p

    def add_body(text, indent=True):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.line_spacing = 1.0
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        if indent:
            p.paragraph_format.first_line_indent = Inches(0.4)
        run = p.add_run(text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(16)
        return p

    def add_bullet(bold_prefix, text):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.line_spacing = 1.0
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        r1 = p.add_run(bold_prefix)
        r1.font.name = 'TH Sarabun New'
        r1.font.size = Pt(16)
        r1.bold = True
        r2 = p.add_run(text)
        r2.font.name = 'TH Sarabun New'
        r2.font.size = Pt(16)
        return p

    def add_numbered(num_prefix, text):
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.0
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.left_indent = Inches(0.3)
        p.paragraph_format.first_line_indent = Inches(-0.3)
        r1 = p.add_run(num_prefix)
        r1.font.name = 'TH Sarabun New'
        r1.font.size = Pt(16)
        r1.bold = True
        r2 = p.add_run(text)
        r2.font.name = 'TH Sarabun New'
        r2.font.size = Pt(16)
        return p

    def add_equation_box(eq_text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after = Pt(1)
        run = p.add_run(eq_text)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(14)
        run.bold = True
        return p

    def add_figure(img_path, caption_text, width_inches=3.8):
        if os.path.exists(img_path):
            p_img = doc.add_paragraph()
            p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img.paragraph_format.space_before = Pt(2)
            p_img.paragraph_format.space_after = Pt(1)
            p_img.paragraph_format.keep_with_next = True
            run_img = p_img.add_run()
            run_img.add_picture(img_path, width=Inches(width_inches))
            
            p_cap = doc.add_paragraph()
            p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_cap.paragraph_format.space_before = Pt(1)
            p_cap.paragraph_format.space_after = Pt(2)
            p_cap.paragraph_format.keep_with_next = False
            run_cap = p_cap.add_run(caption_text)
            run_cap.font.name = 'TH Sarabun New'
            run_cap.font.size = Pt(13)
            run_cap.italic = True
        else:
            print(f"Warning: Figure not found at {img_path}")

    def add_code_block(code_text):
        tbl = doc.add_table(rows=1, cols=1)
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        cell = tbl.cell(0, 0)
        set_cell_shading(cell, "F7F7F7")
        set_cell_border(cell, top="single", top_sz="4", top_color="CCCCCC",
                        bottom="single", bottom_sz="4", bottom_color="CCCCCC",
                        left="single", left_sz="4", left_color="CCCCCC",
                        right="single", right_sz="4", right_color="CCCCCC")
        p = cell.paragraphs[0]
        p.paragraph_format.line_spacing = 1.0
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(2)
        run = p.add_run(code_text)
        run.font.name = 'Consolas'
        run.font.size = Pt(8.5)
        return tbl

    # ==================== BUILD DOCUMENT CONTENT ====================
    base_dir = r"C:\Users\Chard\Downloads\Lab1.4-20261003T065952Z-1-001\MATLAB Visualize"
    fig_dir = os.path.join(base_dir, "output_figures")

    # Document Header
    add_title("รายงานผลการทดลอง ปฏิบัติการที่ 1.4")
    add_subtitle("Single Point Load Cell ร่วมกับวงจรขยาย INA125 Instrumentation Amplifier")
    add_meta("รายวิชา: FRA271 Robotic and Mechatronic Sensors | สถาบันวิทยาการหุ่นยนต์ภาคสนาม (FIBO)")
    add_meta("ชุดข้อมูลการทดลอง: 3 รอบซ้ำ (Trial 1, 2, 3) ครบ 11 พิกัดน้ำหนัก (0.988 - 9.961 kg)")

    # 1. Introduction
    add_h1("1. บทนำ (Introduction)")
    add_h2("1.1 ที่มาและความสำคัญ")
    add_body(
        "ในระบบหุ่นยนต์และระบบอัตโนมัติ การตรวจวัดแรงกด (Force) และน้ำหนัก (Mass) มีความสำคัญอย่างยิ่งต่อการควบคุมการจับยึดวัตถุ "
        "(Gripping Force Control) การชั่งน้ำหนัก และความปลอดภัย อุปกรณ์ตรวจวัดที่นิยมใช้คือ Single Point Load Cell ทำงานด้วยการเปลี่ยนแปลงความต้านทานตามความเครียด "
        "(Piezoresistive Effect) ของสเตรนเกจในวงจร Wheatstone Bridge อย่างไรก็ตาม สัญญาณไฟฟ้าผลต่าง (Differential Voltage) Vd = V+ - V- ที่ได้มีขนาดเล็กมากในระดับมิลลิโวลต์ "
        "(ซึ่งวัดค่าจริงในการทดลองได้ 4.3 mV) จึงจำเป็นต้องใช้วงจรขยายเครื่องมือวัด (Instrumentation Amplifier) เช่น ไอซี INA125 "
        "เพื่อขยายสัญญาณขึ้นสู่ระดับโวลต์ กำจัด Common-Mode Noise และแปลงเข้าสู่ไมโครคอนโทรลเลอร์ STM32G474RE"
    )

    add_h2("1.2 จุดประสงค์การทดลอง")
    add_numbered("1. ", "เพื่อศึกษาหลักการทำงานของ Single Point Load Cell, สเตรนเกจ, วงจร Full-Bridge Wheatstone Bridge และวงจรขยาย 2 Op-Amps ของ INA125")
    add_numbered("2. ", "เพื่อคำนวณและปรับตั้งค่า Gain ที่เหมาะสมผ่านตัวต้านทาน RG และอธิบายความสัมพันธ์ระหว่าง Gain กับค่าความต้านทาน")
    add_numbered("3. ", "เพื่อศึกษากระบวนการ Signal Conditioning และสร้างสมการการสอบเทียบ (Calibration Model) แปลงแรงดันเป็นมวล (kg) และแรง (N)")
    add_numbered("4. ", "เพื่อวิเคราะห์และระบุขอบเขตสภาวะอิ่มตัว (Saturation Analysis) ทั้งทางกลและทางไฟฟ้า")
    add_numbered("5. ", "เพื่อเปรียบเทียบความถูกต้องของโหลดเซลล์กับเครื่องชั่งดิจิทัลมาตรฐาน และวิเคราะห์สาเหตุของความคลาดเคลื่อน")
    add_numbered("6. ", "เพื่อประเมินความสามารถในการวัดซ้ำ (Repeatability) ของระบบจากการทดลอง 3 รอบซ้ำ")

    add_h2("1.3 สมมติฐานการทดลอง")
    add_numbered("1. ", "แรงดันเอาต์พุต (Vout) ของวงจรขยาย INA125 จะแปรผันตรงเป็นเชิงเส้นกับมวลที่กระทำ (m) ตลอดช่วงการทำงานปกติ (R² > 0.99)")
    add_numbered("2. ", "เมื่อภาระโหลดเข้าใกล้พิกัดสูงสุด (10 kg) ระบบจะเริ่มเบี่ยงเบนออกจากเชิงเส้นและเกิดสภาวะอิ่มตัว (Saturation) จากกลไกจำกัดเชิงกล (Mechanical Overload Gap)")
    add_numbered("3. ", "การทดลองซ้ำจำนวน 3 รอบจะให้ค่าที่มีความสอดคล้องกันสูง โดยมีค่า Repeatability Error ไม่เกิน 0.5% FS")

    add_h2("1.4 ตัวแปรการทดลอง")
    add_bullet("ตัวแปรต้น (Independent Variable): ", "มวลที่กระทำต่อโหลดเซลล์ (m) จำนวน 11 พิกัด ตั้งแต่ 0.988 kg ถึง 9.961 kg (เทียบเท่าแรงกด 9.69 - 97.68 N)")
    add_bullet("ตัวแปรตาม (Dependent Variables): ", "แรงดันเอาต์พุตแอนะล็อก (Vout), ค่าดิจิทัล ADC (Counts) และค่าน้ำหนักที่คำนวณได้ผ่านสมการสอบเทียบย้อนกลับ (m_calc)")
    add_bullet("ตัวแปรควบคุม (Controlled Variables): ", "แรงดันไฟเลี้ยงระบบ (Vsupply = 3.30 V), ค่าความต้านทาน RG ของ INA125, อุณหภูมิห้อง, และเวลาบันทึกสัญญาณ 15 s ต่อพิกัด")

    # 2. Literature Review
    add_h1("2. เอกสารและงานวิจัยที่เกี่ยวข้อง (Literature Review)")
    add_h2("2.1 โครงสร้าง Strain Gauge และ Full-Bridge Wheatstone Bridge")
    add_body(
        "โหลดเซลล์รุ่น YZC-131A เป็นคานรับแรงดัดแบบขนาน (Parallel Guided Bending Beam) ทำจากอะลูมิเนียมอัลลอยด์ ภายในติดตั้งสเตรนเกจ 4 ตัว "
        "ต่อเป็นวงจร Full-Bridge โดยมี 2 ตัวรับแรงดึง (+ΔR) และอีก 2 ตัวรับแรงอัด (-ΔR) ตามทฤษฎีของ Pallás-Areny และ Webster [7] "
        "การต่อแบบ Full-Bridge ให้ความไวสูงกว่าแบบ Quarter-Bridge ถึง 4 เท่า (Vd = Vexc · GF · ε) และมีคุณสมบัติเด่นคือการชดเชยอุณหภูมิในตัวเอง "
        "(Intrinsic Temperature Compensation) ทำให้ความต้านทานที่ยืดขยายจากความร้อนหักล้างกันเองอย่างสมบูรณ์ ปราศจาก Thermal Zero Drift"
    )

    add_h2("2.2 วงจรขยายสัญญาณ INA125 Instrumentation Amplifier")
    add_body(
        "ไอซี INA125 [2] ใช้โครงสร้างวงจรขยาย 2 Op-Amps Differential Amplifier มีคุณสมบัติเด่นคือ Input Impedance สูงมาก (> 10⁹ Ω) "
        "ทำให้ไม่เกิดผลกระทบโหลด (Loading Effect) ไปรบกวนความต้านทานของบริดจ์ และมี Common-Mode Rejection Ratio (CMRR > 100 dB) "
        "ช่วยขจัดแรงดันอ้างอิงกึ่งกลางบริดจ์ (Vexc/2 ≈ 1.65 V) และสัญญาณรบกวนร่วมได้อย่างหมดจด โดยกำหนดอัตราขยายผ่านตัวต้านทานภายนอก RG:"
    )
    add_equation_box("G = 4 + (60 kΩ / RG)")

    add_h2("2.3 กลไกการเกิด Saturation และ Gain Compression เชิงกล")
    add_body(
        "Barbato และคณะ [1] ได้ศึกษาวิจัยพฤติกรรมของสเตรนเกจโหลดเซลล์เมื่อรับภาระเกินพิกัด พบว่าโครงสร้างคานรับแรงจะมีระยะช่องว่างจำกัดเชิงกล "
        "(Mechanical Overload Protection Gap) เมื่อคานเกิดการโก่งตัวจนแตะกับฐานรองรับ ความแข็งเกร็งประสิทธิผลของโครงสร้างจะพุ่งสูงขึ้น "
        "(Non-linear Stiffening) ทำให้ความไวในการเปลี่ยนรูป (Δε/ΔF) ลดลงอย่างรวดเร็ว เกิดปรากฏการณ์บีบอัดอัตราขยาย (Gain Compression) "
        "ซึ่งต่างจาก Rail Saturation ทางไฟฟ้าของ Op-Amp [2]"
    )

    add_h2("2.4 พฤติกรรม Creep, Hysteresis, Four-Corner Error และมาตรฐาน OIML R60")
    add_body(
        "Ramos และคณะ [3] และ Ferrero และคณะ [4] ได้สร้างแบบจำลองการคืบ (Creep) และฮิสเทอรีซิสในคานอะลูมิเนียม พบว่าการคลายตัวหยุ่นหนืด "
        "(Viscoelastic Relaxation) ใต้แรงกดคงที่จะทำให้แรงดันขยับขึ้นช้าๆ ตามเวลา ด้านความคลาดเคลื่อนจากการวางน้ำหนักเยื้องศูนย์ (Four-Corner Error) "
        "ได้รับการวิเคราะห์โดย Peters และคณะ [5] และ Li และ Zhang [6] ว่าเกิดจากความไม่สมมาตรเชิงกลของจุดคอดทั้ง 4 ตำแหน่ง "
        "สำหรับมาตรฐานสากล OIML R60 [9] กำหนดให้ทดสอบทำซ้ำอย่างน้อย 3 รอบ และประเมิน Linearity เพื่อจัดชั้นความแม่นยำของโหลดเซลล์"
    )

    # 3. Apparatus & Methodology
    add_h1("3. อุปกรณ์และวิธีการทดลอง (Apparatus & Methodology)")
    add_body(
        "อุปกรณ์ประกอบด้วย Single Point Load Cell YZC-131A (10 kg), ไอซี INA125, Trimpot 100 kΩ 25 รอบ, R คงที่ 4.7 kΩ, "
        "บอร์ด Nucleo STM32G474RE, ฐานรองรับ 3D-Printed LoadCellXplorer, เครื่องชั่งดิจิทัลมาตรฐาน (0.1 g) และถุงทราย 11 พิกัดน้ำหนัก", indent=True
    )
    add_body(
        "ขั้นตอนการทดลอง: 1) ต่อวงจรบริดจ์ของโหลดเซลล์เข้ากับ INA125 โดยจ่ายไฟเลี้ยง 3.3 V 2) ปรับตั้งค่าความต้านทาน RG ให้ได้อัตราขยายที่เหมาะสม "
        "(G ≈ 500, RG ≈ 121 Ω) ผ่าน Trimpot 25 รอบ 3) เชื่อมต่อสัญญาณเอาต์พุตเข้าขาแอนะล็อก PA0 ของบอร์ด STM32 และรันโมเดล Simulink บันทึกข้อมูลที่ 1 kHz "
        "4) ชั่งน้ำหนักอ้างอิงด้วยเครื่องชั่งดิจิทัลและนำมาวางบนโหลดเซลล์ทีละพิกัด (0.988 ถึง 9.961 kg) พิกัดละ 15 วินาที "
        "และทำซ้ำจนครบ 3 รอบ (Trial 1, 2, 3) รวมทั้งสิ้น 33 ชุดข้อมูล", indent=True
    )

    # 4. Results
    add_h1("4. ผลการทดลอง (สิ่งที่เกิดขึ้นจริงในการทดลอง)")
    add_meta("*(ส่วนนี้นำเสนอเฉพาะข้อมูลเชิงประจักษ์ ตารางสถิติ และกราฟการวัดจริง โดยไม่ใส่การวิเคราะห์)*")

    add_h2("4.1 ข้อมูลการตอบสนองเชิงสถิตจากการวัดซ้ำ 3 รอบ (Static Response & Repeatability Data)")
    add_body(
        "จากการประมวลผลสัญญาณแรงดันเอาต์พุตที่สภาวะคงที่ (Steady-state) ของการทดลองซ้ำทั้ง 3 รอบ (Trial 1, 2, 3) ครบทั้ง 11 พิกัดน้ำหนัก "
        "ได้ผลการวัดค่าเฉลี่ย, ค่าเบี่ยงเบนมาตรฐาน (SD) และค่าดิจิทัลจาก ADC 12-bit ดังแสดงในตารางที่ 1"
    )

    # Add Table 1
    table_data = [
        ["มวลอ้างอิง (kg)", "แรงกด (N)", "Trial 1 (V)", "Trial 2 (V)", "Trial 3 (V)", "เฉลี่ย μV (V)", "SD (mV)", "ADC (Counts)"],
        ["0.988", "9.689", "0.1854", "0.1856", "0.1853", "0.1854", "0.121", "230.1"],
        ["1.923", "18.858", "0.3614", "0.3616", "0.3617", "0.3616", "0.145", "448.7"],
        ["2.932", "28.753", "0.5523", "0.5518", "0.5518", "0.5519", "0.272", "684.9"],
        ["3.913", "38.373", "0.7366", "0.7364", "0.7364", "0.7365", "0.102", "913.9"],
        ["4.901", "48.062", "0.9255", "0.9253", "0.9252", "0.9253", "0.112", "1148.3"],
        ["5.868", "57.545", "1.1076", "1.1077", "1.1079", "1.1077", "0.186", "1374.6"],
        ["6.837", "67.048", "1.2914", "1.2913", "1.2910", "1.2912", "0.209", "1602.3"],
        ["7.821", "76.698", "1.3630", "1.3627", "1.3631", "1.3629", "0.228", "1691.3"],
        ["8.790", "86.200", "1.5330", "1.5320", "1.5321", "1.5324", "0.514", "1901.5"],
        ["9.783", "95.938", "1.7053", "1.7049", "1.7055", "1.7052", "0.322", "2116.1"],
        ["9.961", "97.684", "1.7194", "1.7180", "1.7215", "1.7196", "1.757", "2133.9"],
    ]

    t = doc.add_table(rows=len(table_data), cols=len(table_data[0]))
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    for r_idx, row in enumerate(table_data):
        for c_idx, val in enumerate(row):
            cell = t.cell(r_idx, c_idx)
            cell.text = val
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.paragraph_format.line_spacing = 1.0
            p.paragraph_format.space_before = Pt(1)
            p.paragraph_format.space_after = Pt(1)
            run = p.runs[0]
            run.font.name = 'TH Sarabun New'
            run.font.size = Pt(13 if c_idx >= 2 else 14)
            if r_idx == 0:
                run.bold = True
                set_cell_shading(cell, "EAEAEA")
                set_cell_border(cell, top="single", top_sz="8", top_color="333333", bottom="single", bottom_sz="8", bottom_color="333333")
            elif r_idx == len(table_data) - 1:
                set_cell_border(cell, top="single", top_sz="4", top_color="CCCCCC", bottom="single", bottom_sz="8", bottom_color="333333")
            else:
                set_cell_border(cell, top="single", top_sz="4", top_color="E0E0E0", bottom="single", bottom_sz="4", bottom_color="E0E0E0")

    add_body(
        "จากตารางที่ 1 ค่าแรงดันเอาต์พุตเฉลี่ยเริ่มต้นที่ 0.1854 V ที่มวล 0.988 kg และเพิ่มขึ้นตามลำดับจนถึง 1.7196 V ที่มวล 9.961 kg "
        "โดยค่าความแปรปรวนของการวัดซ้ำ 3 รอบ (Repeatability SD) มีค่าต่ำมากระหว่าง 0.102 mV ถึง 0.514 mV ในช่วงโหลดทั่วไป และสูงสุดเพียง 1.757 mV ที่พิกัดเต็มสเกล"
    )

    add_h2("4.2 เส้นโค้งเทียบมาตรฐานและสมการถดถอยเชิงเส้น (Calibration Curve & Linear Regression)")
    add_body(
        "เมื่อนำข้อมูลแรงดันเอาต์พุตเฉลี่ยมาพล็อตกราฟเทียบกับมวลอ้างอิง พร้อมเส้นถดถอยเชิงเส้นอันดับหนึ่ง (First-order Linear Fit) ดังแสดงในรูปที่ 1"
    )
    add_figure(
        os.path.join(fig_dir, "Fig1_LoadCell_Voltage_vs_Mass.png"),
        "รูปที่ 1: กราฟความสัมพันธ์ระหว่างแรงดันเอาต์พุตเฉลี่ยกับมวลอ้างอิง พร้อมเส้นถดถอยเชิงเส้นและแถบค่าเบี่ยงเบนมาตรฐาน (μ ± 1SD)",
        width_inches=4.8
    )
    add_body(
        "ผลลัพธ์พารามิเตอร์ของระบบวัดจากการถดถอยเชิงเส้นมีดังนี้:\n"
        "• สมการการถดถอยเชิงเส้น: Vout(m) = 0.1702 · m + 0.0580 [V]\n"
        "• ค่าสัมประสิทธิ์การตัดสินใจ: R² = 0.99525\n"
        "• ความไวการวัดต่อมวล (Mass Sensitivity): Sm = 170.16 mV/kg\n"
        "• ความไวการวัดต่อแรง (Force Sensitivity): SF = 17.35 mV/N\n"
        "• แรงดันออฟเซตขณะไม่มีภาระ (Zero-Load Offset): V0 = 0.0580 V (71.9 counts)\n"
        "• สมการการสอบเทียบย้อนกลับ (Inverse Calibration Model): m(Vout) = 5.8490 · Vout - 0.3117 [kg]",
        indent=True
    )

    add_h2("4.3 พฤติกรรมสัญญาณที่พิกัดปลายสเกลและขอบเขต Saturation")
    add_body(
        "เมื่อพิจารณาพฤติกรรมของแรงดันเอาต์พุตในช่วงน้ำหนักสูงกว่า 8 kg ดังแสดงในรูปที่ 12b พบว่าช่วง 0.988 – 8.790 kg กราฟมีอัตราการเปลี่ยนแปลง "
        "ΔV/Δm ≈ 189.0 mV/kg แต่เมื่อมวลเกิน 8.790 kg ความชันเริ่มลดลงอย่างเห็นได้ชัด โดยในช่วง 9.783 ถึง 9.961 kg แรงดันเพิ่มขึ้นเพียง 0.0144 V "
        "ทำให้อัตราการเปลี่ยนแปลงลดลงเหลือ ΔV/Δm = 80.8 mV/kg (-55% Compression) และแรงดันสูงสุดหยุดอยู่ที่ระดับ Vsat = 1.7196 V ≈ 1.72 V"
    )
    add_figure(
        os.path.join(fig_dir, "Fig12b_LoadCell_Saturation_SinglePlot.png"),
        "รูปที่ 12b: พฤติกรรมการเกิดสภาวะอิ่มตัว (Saturation) ของโหลดเซลล์ที่ปลายสเกล และการจำกัดแรงดันที่ระดับ 1.72 V",
        width_inches=4.7
    )

    add_h2("4.4 ผลการเปรียบเทียบกับเครื่องชั่งดิจิทัล (Comparison with Digital Scale)")
    add_body(
        "เมื่อนำสมการ Inverse Calibration ไปคำนวณค่าน้ำหนักจริง และนำมาเปรียบเทียบกับเครื่องชั่งดิจิทัลมาตรฐาน ดังแสดงในรูปที่ 10 "
        "พบว่าค่าความคลาดเคลื่อนสัมบูรณ์เฉลี่ย (Mean Absolute Error) มีค่าเท่ากับ 150.2 g (คิดเป็น 1.51% FS) "
        "และมีค่าความคลาดเคลื่อนสัมบูรณ์สูงสุด (Maximum Absolute Error) เท่ากับ 389.2 g (3.91% FS) ที่พิกัดน้ำหนัก 9.961 kg"
    )
    add_figure(
        os.path.join(fig_dir, "Fig10_Digital_Scale_vs_LoadCell.png"),
        "รูปที่ 10: การเปรียบเทียบค่าน้ำหนักที่วัดได้กับเครื่องชั่งดิจิทัลมาตรฐาน (ซ้าย: เส้นทแยงมุม 1:1, ขวา: กราฟแท่งค่าความคลาดเคลื่อน)",
        width_inches=4.9
    )

    add_h2("4.5 สัญญาณพลวัต Real-time ในหน่วยอนุพันธ์ SI และระดับสัญญาณรบกวน")
    add_body(
        "รูปที่ 13 แสดงสัญญาณการตอบสนองพลวัตแบบ Multi-Step Dynamic Response ตามลำดับเวลาจริง (0 → 1.92 → 3.91 → 5.87 → 7.82 → 9.78 → 0 kg) "
        "พบว่าสัญญาณเอาต์พุต (เส้นทึบ) ตอบสนองติดตามสัญญาณอินพุต (เส้นประ) ได้อย่างฉับพลัน โดยแสดงผลเป็นหน่วยมวลกิโลกรัม (kg) ในกราฟบน "
        "และหน่วยแรงนิวตัน (N) ในกราฟล่างอย่างแม่นยำ พร้อมทั้งมีระดับสัญญาณรบกวน RMS Noise Floor เท่ากับ 2.59 mV (≈ 3.2 counts) "
        "และมีอัตราส่วนสัญญาณต่อสัญญาณรบกวนสูงสุด (Peak SNR) เท่ากับ 56.29 dB ที่พิกัดเต็มสเกล"
    )
    add_figure(
        os.path.join(fig_dir, "Fig13_Realtime_SI_Units_Waveforms.png"),
        "รูปที่ 13: รูปคลื่นสัญญาณตอบสนองตามเวลาจริง (Real-time Dynamic Response) ในหน่วยอนุพันธ์ SI: (a) มวล [kg] และ (b) แรงกด [N]",
        width_inches=4.9
    )

    # 5. Conclusion (อธิบายสิ่งที่เกิดขึ้นในการทดลอง)
    add_h1("5. สรุปผลการทดลอง (อธิบายสิ่งที่เกิดขึ้นในการทดลอง)")
    add_numbered("1. ", "การตอบสนองและย่านการวัด: โหลดเซลล์ YZC-131A ร่วมกับวงจรขยาย INA125 และ STM32G474RE สามารถวัดแรงกด 9.69 - 97.68 N ให้แรงดันแอนะล็อก 0.1854 - 1.7196 V โดยแปรผันตรงเป็นเชิงเส้นอย่างยอดเยี่ยม (R² = 0.99525)")
    add_numbered("2. ", "คุณลักษณะที่ได้จากการทดลอง: ระบบมีความไวต่อมวล Sm = 170.16 mV/kg, ความไวต่อแรง SF = 17.35 mV/N, แรงดันออฟเซต V0 = 0.0580 V และได้สมการสอบเทียบย้อนกลับ: m = 5.8490 · Vout - 0.3117 [kg]")
    add_numbered("3. ", "การปรับตั้งค่าอัตราขยาย: การปรับตัวต้านทาน RG ≈ 121 - 157 Ω ทำให้ได้อัตราขยาย G ≈ 387 - 500 เท่า ซึ่งให้แรงดันสวิงสูงสุดไม่เกิน 1.72 V สำรอง Headroom 50% ตามที่ออกแบบ")
    add_numbered("4. ", "พฤติกรรมสภาวะอิ่มตัว: ที่น้ำหนักเกิน 8.79 kg เกิดสภาวะอิ่มตัว (Saturation) แรงดันหยุดนิ่งที่ระดับ 1.72 V และอัตราการเปลี่ยนแปลงแรงดันลดลงเหลือ 80.8 mV/kg (ลดลง 55%)")
    add_numbered("5. ", "ความคลาดเคลื่อนและการวัดซ้ำ: ระบบมีความคลาดเคลื่อนเฉลี่ยเทียบเครื่องชั่งดิจิทัล 150.2 g (1.51% FS) สูงสุด 389.2 g ที่พิกัด 9.961 kg และการทดลองซ้ำ 3 รอบมีค่า Repeatability SD ต่ำมากเพียง 0.10 - 1.76 mV (สูงสุด 0.11% FS)")

    # 6. Discussion (วิเคราะห์สิ่งที่เกิดขึ้นในการทดลอง)
    add_h1("6. อภิปรายผล (วิเคราะห์สิ่งที่เกิดขึ้นในการทดลอง)")
    add_bullet("6.1 การตอบสนองของ Load Cell และวงจรขยาย INA125: ", 
               "การต่อ Full-Bridge สเตรนเกจ [7] ให้ความไวสูง (4x) และมี Intrinsic Temperature Compensation ทำให้แรงดันเอาต์พุตแปรผันเป็นเส้นตรงสูงมาก (R² = 0.99525) "
               "ด้าน INA125 [2] โครงสร้าง 2 Op-Amps มี Input Impedance > 10⁹ Ω ป้องกัน Loading Effect ต่อบริดจ์ และมี CMRR > 100 dB ช่วยตัด Common-Mode Voltage (1.65 V) "
               "จึงขยายสัญญาณผลต่างขนาดเล็ก Vd = V+ - V- = 4.3 mV สู่ระดับโวลต์ได้อย่างเสถียร")

    add_bullet("6.2 การคำนวณ Gain และความสัมพันธ์กับตัวต้านทาน RG: ", 
               "ผลต่างแรงดันอินพุตที่วัดได้จริงจากขาสัญญาณโหลดเซลล์คือ Vd = V+ - V- = 4.3 mV (เทียบกับพิกัดคำนวณตามทฤษฎี 3.30 mV) เพื่อสำรอง Headroom 50% ของไฟเลี้ยง 3.3 V ป้องกันสัญญาณชนขอบ จึงกำหนด Vout_max ≈ 1.72 V "
               "ได้อัตราขยายเป้าหมาย G ≈ (1.72 - 0.058) / 0.0043 ≈ 387 เท่า (และหากคำนวณตามพิกัดทฤษฎีจะได้ G ≈ 500 เท่า โดยใช้ RG ≈ 121 - 157 Ω) [2] ทั้งนี้ ความสัมพันธ์ G กับ RG "
               "เป็นฟังก์ชันผกผันไฮเพอร์โบลา (∂G/∂RG ∝ -1/RG²) ในย่าน RG ต่ำความไวต่อการเปลี่ยนค่าสูงมาก จึงจำเป็นต้องใช้ Trimpot 25 รอบปรับจูนอย่างละเอียด")

    add_bullet("6.3 กระบวนการ Signal Conditioning และ Calibration: ", 
               "ระบบทำงาน 5 ขั้นตอน: 1) Transduction แปลงแรงกดเป็นความต้านทานผ่าน Full-Bridge 2) Amplification & CMRR ขยายสัญญาณผลต่างด้วย INA125 "
               "3) Sampling & Filtering สุ่มสัญญาณด้วย ADC 12-bit (STM32) พร้อม Moving Average 4) Tare หักลบ Offset (V0 = 0.058 V) และ "
               "5) Linear Scaling แปลงเป็นมวล (m) และแรง (F) ในหน่วยอนุพันธ์ SI")

    add_bullet("6.4 การวิเคราะห์สาเหตุของสภาวะ Saturation: ", 
               "ที่มวล > 8.79 kg แรงดันคงที่อยู่ที่ Vsat ≈ 1.72 V (ความชันตกลง 55%) ซึ่งไม่ใช่ Op-Amp Rail Saturation เพราะ INA125 สวิงได้ถึง 2.1 - 3.8 V [2] "
               "แต่เกิดจาก Mechanical Overload Protection Stop [1] เมื่อคานโก่งตัวจนแตะฐานรองรับ ความแข็งเกร็งจะพุ่งสูงขึ้นทันที (Non-linear Stiffening) สเตรนเกจจึงไม่ยืดตัวเพิ่ม")

    add_bullet("6.5 การวิเคราะห์สาเหตุความคลาดเคลื่อนเทียบกับเครื่องชั่งดิจิทัล: ", 
               "Error เฉลี่ย 150.2 g (สูงสุด 389.2 g ที่ปลายสเกล) มีสาเหตุหลัก 5 ประการ: 1) Four-Corner Error จากการวางน้ำหนักเยื้องศูนย์ [5, 6] "
               "2) การคลายตัวหยุ่นหนืดเชิงกล (Creep & Hysteresis) [3, 4] 3) ความร้อนสะสมของบริดจ์ (Thermal Drift) [7, 8] "
               "4) สัญญาณรบกวนสวิตชิ่งจากบอร์ดและพอร์ต USB (2.59 mV RMS) และ 5) ความคลาดเคลื่อนจากการประมาณด้วยสมการเส้นตรงอันดับหนึ่ง [10]")

    add_bullet("6.6 ความสามารถในการวัดซ้ำเทียบกับมาตรฐาน OIML R60: ", 
               "การวัดซ้ำ 3 รอบให้ Repeatability SD สูงสุดเพียง 1.76 mV (0.11% FS) สอดคล้องตามเกณฑ์มาตรฐานสากล OIML R60 Class D [9] ยืนยันความเสถียรและความน่าเชื่อถือสูง")

    # 7. Recommendations
    add_h1("7. ข้อเสนอแนะ (Recommendations)")
    add_numbered("1. ", "Polynomial Compensation: ใช้สมการพหุนามกำลังสอง (Vout = -0.0039m² + 0.2128m - 0.0245) บน STM32 ชดเชยความโค้งปลายสเกล ลด Error เหลือ 2.75% FS [10]")
    add_numbered("2. ", "การวัดและปรับตั้งค่าความต้านทาน RG นอกวงจร: เนื่องจากการวัดค่า Trimpot ขณะต่ออยู่ในวงจร (In-Circuit) มีโอกาสคลาดเคลื่อนจากผลกระทบของวงจรภายในไอซี จึงควรวัดและปรับตั้ง Trimpot นอกวงจรก่อนนำมาต่อ หรือเปลี่ยนมาใช้ตัวต้านทานคงที่ความแม่นยำสูง (Precision Resistor 0.1%, 121 Ω) เพื่อขจัดความคลาดเคลื่อนและความไม่เสถียรของหน้าสัมผัส")
    add_numbered("3. ", "แหล่งจ่ายไฟแยกและพัลส์กระตุ้น: ใช้ไอซี LDO แยกจ่ายไฟแอนะล็อกลด USB Noise (2.59 mV) และใช้ Pulsed Excitation ลดความร้อนสะสม [7]")
    add_numbered("4. ", "Self-Centering Fixture: ปรับปรุงแท่นวาง 3D-Printed ให้มีร่องล็อกศูนย์ถ่วงเพื่อขจัด Four-Corner Error [5]")

    # 8. References (Links only as requested)
    add_h1("8. เอกสารอ้างอิง (References)")
    refs = [
        "1. Texas Instruments INA125 Datasheet: https://www.ti.com/lit/ds/symlink/ina125.pdf",
        "2. OIML R 60 Metrological Regulation for Load Cells: https://www.oiml.org/en/files/pdf_r/r060-e21.pdf",
        "3. G. Barbato et al. - Overload behavior: https://doi.org/10.1016/j.measurement.2006.09.004",
        "4. A. G. A. Ramos et al. - Creep behavior of aluminum load cells: https://doi.org/10.1016/j.measurement.2013.09.043",
        "5. C. Ferrero et al. - Creep and hysteresis in transducers: https://doi.org/10.1088/0026-1394/33/3/13",
        "6. S. J. A. M. Peters et al. - Monolithic load cell design: https://doi.org/10.1016/S0141-6359(01)00078-4",
        "7. C. Li and Y. Zhang - Off-center error analysis: https://doi.org/10.1088/1361-6501/aaa72b",
        "8. R. Pallás-Areny and J. G. Webster - Sensors and Signal Conditioning: https://www.wiley.com/en-us/Sensors+and+Signal+Conditioning%2C+2nd+Edition-p-9780471330851",
        "9. Y. Wang and G. Chen - Thermal drift analysis: https://doi.org/10.1016/j.measurement.2012.01.034",
        "10. G. Betta et al. - Software compensation of non-linearity: https://doi.org/10.1109/19.744634",
        "11. J. C. Patra et al. - Intelligent load sensor calibration: https://doi.org/10.1109/19.863934"
    ]
    for r in refs:
        p = doc.add_paragraph()
        p.paragraph_format.line_spacing = 1.0
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(1)
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.left_indent = Inches(0.25)
        p.paragraph_format.first_line_indent = Inches(-0.25)
        run = p.add_run(r)
        run.font.name = 'TH Sarabun New'
        run.font.size = Pt(13)

    # ภาคผนวก จ
    add_h1("ภาคผนวก จ: การปรับสภาพสัญญาณและการสอบเทียบโหลดเซลล์ (Lab 1.4)")

    add_h2("จ.1 การคำนวณค่า Gain ที่เหมาะสม และค่าตัวต้านทาน RG")
    add_body(
        "1) พารามิเตอร์ของโหลดเซลล์ YZC-131A: พิกัด 10 kg, ความไว 1.0 ± 0.15 mV/V, ไฟเลี้ยง Excitation Vexc = 3.30 V จะได้พิกัดทฤษฎี Vd_theory = 3.30 mV "
        "แต่สัญญาณผลต่างแรงดันที่วัดได้จริงในการทดลองคือ Vd = V+ - V- = 4.30 mV (สูงกว่าทฤษฎีเล็กน้อยจากพิกัดความเผื่อความไว บริดจ์ออฟเซตเริ่มต้น และน้ำหนักเริ่มต้นของแท่น 3D-Printed)\n"
        "2) การกำหนดช่วงแรงดันเอาต์พุต: เพื่อสำรอง Headroom ประมาณ 50% ของไฟเลี้ยง STM32 (3.3 V) ป้องกัน Clipping ขณะมีแรงกระแทก จึงเลือก Vout_max ≈ 1.72 V "
        "เมื่อหักลบ Offset ขณะไม่มีโหลด (V0 = 0.058 V) จะได้ช่วงการแกว่งสุทธิ ΔVout = 1.720 - 0.058 = 1.662 V\n"
        "3) การคำนวณ Gain เป้าหมาย: คำนวณจากค่าจริงได้ G_actual = ΔVout / Vd = 1.662 V / 0.0043 V ≈ 386.5 ≈ 387 เท่า (และกรณีคำนวณตามพิกัดทฤษฎี G_theory = 1.662 / 0.0033 ≈ 500 เท่า)\n"
        "4) การคำนวณหาค่าความต้านทาน RG จากสมการ INA125 [2]:\n"
        "   G = 4 + (60 kΩ / RG) ⟹ RG = 60,000 / (G - 4)\n"
        "   สำหรับ G = 387 เท่า: RG = 60,000 / 383 ≈ 156.7 Ω ≈ 157 Ω และสำหรับ G = 500 เท่า: RG = 60,000 / 496 ≈ 120.97 Ω ≈ 121 Ω ดังนั้นช่วงปรับตั้งคือ RG ≈ 121 - 157 Ω\n"
        "5) ความสัมพันธ์ Gain กับ RG: เป็นฟังก์ชันผกผันไฮเพอร์โบลา (dG/dRG = -60,000 / RG²) ที่ RG = 121 - 157 Ω มีความชันสูงถึง -2.4 ถึง -4.1 ต่อโอห์ม "
        "การเปลี่ยน RG เพียง 1 Ω ทำให้ Gain เปลี่ยนถึง 2.4 - 4.1 เท่า จึงจำเป็นต้องใช้ Trimpot 25 รอบ (Multi-turn) เพื่อปรับตั้งได้อย่างละเอียดและนิ่ง",
        indent=True
    )

    add_h2("จ.2 การต่อวงจรขยาย INA125 Instrumentation Amplifier")
    add_body(
        "การเชื่อมต่อวงจรระหว่าง Load Cell YZC-131A, ไอซี INA125 (16-Pin DIP) และ STM32G474RE แสดงรายละเอียดขาสัญญาณดังตารางที่ จ.1",
        indent=True
    )

    # Table J.1
    table_j_data = [
        ["ขา (Pin)", "ชื่อขา (Symbol)", "การเชื่อมต่อในวงจร", "หน้าที่การทำงาน"],
        ["1", "Vref_out", "ต่อเชื่อมเข้ากับขา 4", "เอาต์พุตแหล่งจ่ายแรงดันอ้างอิงความแม่นยำสูง"],
        ["2, 3", "Vref_com, Sense", "ต่อลงกราวด์ (GND)", "ชดเชยแรงดันตกคร่อมของแรงดันอ้างอิง"],
        ["4", "Vref3.3", "ต่อเข้ากับขา 1", "ขาเลือกแรงดันอ้างอิงระดับ 3.3 V"],
        ["5", "VIN+", "ต่อสายสีเขียว (A+) โหลดเซลล์", "อินพุตสัญญาณบริดจ์ขั้วบวก"],
        ["6", "VIN-", "ต่อสายสีแดง (A-) โหลดเซลล์", "อินพุตสัญญาณบริดจ์ขั้วลบ"],
        ["8, 9", "RG (Gain)", "ต่อคร่อมด้วย Trimpot 25 รอบ (121 - 157 Ω)", "กำหนดอัตราขยายของวงจร (G ≈ 387 - 500)"],
        ["10", "Vout", "ต่อเข้าขา PA0 ของ STM32", "เอาต์พุตแรงดันแอนะล็อกขยาย (0 - 1.72 V)"],
        ["11", "V+", "ต่อไฟเลี้ยง +3.3 V จากบอร์ด STM32", "ขั้วไฟเลี้ยงบวก (Positive Supply)"],
        ["12", "V- / GND", "ต่อลงกราวด์ (0 V) ของระบบ", "ขั้วไฟเลี้ยงลบ/กราวด์ (Single Supply GND)"],
        ["14", "IA_ref", "ต่อลงกราวด์ (0 V)", "กำหนดระดับแรงดันอ้างอิงเอาต์พุตเทียบดิน"]
    ]
    tj = doc.add_table(rows=len(table_j_data), cols=len(table_j_data[0]))
    tj.alignment = WD_TABLE_ALIGNMENT.CENTER
    for r_idx, row in enumerate(table_j_data):
        for c_idx, val in enumerate(row):
            cell = tj.cell(r_idx, c_idx)
            cell.text = val
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if c_idx <= 1 else WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.0
            p.paragraph_format.space_before = Pt(1)
            p.paragraph_format.space_after = Pt(1)
            run = p.runs[0]
            run.font.name = 'TH Sarabun New'
            run.font.size = Pt(13)
            if r_idx == 0:
                run.bold = True
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                set_cell_shading(cell, "EAEAEA")
                set_cell_border(cell, top="single", top_sz="8", top_color="333333", bottom="single", bottom_sz="8", bottom_color="333333")
            elif r_idx == len(table_j_data) - 1:
                set_cell_border(cell, top="single", top_sz="4", top_color="CCCCCC", bottom="single", bottom_sz="8", bottom_color="333333")
            else:
                set_cell_border(cell, top="single", top_sz="4", top_color="E0E0E0", bottom="single", bottom_sz="4", bottom_color="E0E0E0")

    add_body(
        "การต่อสายโหลดเซลล์ 4 เส้น: สายสีขาว (E+) ต่อ +3.3 V, สายสีดำ (E-) ต่อ GND, สายสีเขียว (A+) ต่อขา 5 (VIN+), สายสีแดง (A-) ต่อขา 6 (VIN-)",
        indent=True
    )

    add_h2("จ.3 การหาสมการ Calibration Curve เพื่อแปลง Voltage เป็นค่าน้ำหนักจริง (SI Units)")
    add_body(
        "1) เส้นโค้งเทียบมาตรฐาน (Calibration Curve): จากข้อมูล 3 รอบซ้ำ ได้สมการ Linear Fit: Vout(m) = 0.1702 · m + 0.0580 [V] "
        "โดยมีความไว Sm = 170.16 mV/kg, Offset V0 = 0.0580 V, R² = 0.99525\n"
        "2) สมการการสอบเทียบย้อนกลับ (Inverse Calibration Curve): เพื่อแปลงแรงดันกลับเป็นมวล (kg):\n"
        "   m(Vout) = (Vout - 0.0580) / 0.1702 = 5.8490 · Vout - 0.3117 [kg]\n"
        "3) การแปลงเป็นแรงกดในหน่วยอนุพันธ์ SI (Newton: N): ใช้ค่า g = 9.80665 m/s²:\n"
        "   F(Vout) = m · 9.80665 = (5.8490 · Vout - 0.3117) × 9.80665 = 57.359 · Vout - 3.057 [N] (ความไว SF = 17.35 mV/N)",
        indent=True
    )

    add_h2("จ.4 การตั้งค่าโมเดล Simulink และเฟิร์มแวร์ C-Code บน STM32G474RE")
    add_body(
        "1) การตั้งค่าฮาร์ดแวร์และโมเดล Simulink: บอร์ด Nucleo STM32G474RE ตั้งค่าโมดูล ADC1 Pin PA0 ความละเอียด 12-bit (0 – 4095 counts), "
        "ย่านแรงดัน 0 – 3.30 V, อัตราสุ่ม Sampling Rate 1 kHz (Ts = 0.001 s) โดยมี Data Acquisition Pipeline ดังนี้:\n"
        "   ADC Raw (12-bit) ⟶ Voltage Scaling (Vout = ADC/4095 × 3.3) ⟶ Inverse Calibration (m = 5.8490·Vout - 0.3117) ⟶ Force (F = m × 9.80665)\n"
        "2) โค้ดเฟิร์มแวร์ภาษา C สำหรับประมวลผลสัญญาณและ Tare Clamping บน STM32 แบบ Real-time:",
        indent=True
    )
    c_code = (
        "// Firmware Real-time Signal Conditioning & Calibration Algorithm\n"
        "// Target: STM32G474RE | ADC1 Channel 1 (Pin PA0) | Sampling Rate: 1 kHz\n"
        "#define ADC_MAX_COUNT       4095.0f\n"
        "#define V_REF               3.30f\n"
        "#define CAL_SLOPE_INV       5.8490f     // Inverse calibration slope (kg/V)\n"
        "#define CAL_OFFSET_INV      0.3117f     // Inverse offset (kg)\n"
        "#define GRAVITY_CONSTANT    9.80665f    // Standard gravity (m/s^2)\n\n"
        "void Process_LoadCell_Sample(void) {\n"
        "    // 1. อ่านค่าดิจิทัลจาก ADC 12-bit\n"
        "    uint16_t raw_adc = HAL_ADC_GetValue(&hadc1);\n"
        "    // 2. แปลงค่าดิบเป็นแรงดันไฟฟ้าแอนะล็อก (Voltage Scaling)\n"
        "    float v_out = ((float)raw_adc / ADC_MAX_COUNT) * V_REF;\n"
        "    // 3. แปลงแรงดันเป็นมวลจริงตามสมการ Inverse Calibration (SI: kg)\n"
        "    float mass_kg = (CAL_SLOPE_INV * v_out) - CAL_OFFSET_INV;\n"
        "    // Software Tare Clamping ป้องกันค่ามวลติดลบขณะไม่มีโหลด\n"
        "    if (mass_kg < 0.0f) mass_kg = 0.0f;\n"
        "    // 4. แปลงมวลเป็นแรงกดในหน่วยอนุพันธ์ SI (Force: N)\n"
        "    float force_N = mass_kg * GRAVITY_CONSTANT;\n"
        "    // 5. ส่งค่าออกไปยังระบบมอนิเตอร์และคอนโทรลเลอร์แบบ Real-time\n"
        "    Transmit_Telemetry(v_out, mass_kg, force_N);\n"
        "}"
    )
    add_code_block(c_code)

    out_path = os.path.join(base_dir, "Lab1_4_Full_Report_Document.docx")
    doc.save(out_path)
    print(f"Report document successfully generated at: {out_path}")

if __name__ == "__main__":
    create_report_document()

