# Campus Parking Fee & Session Management System

โปรแกรม CLI สำหรับเจ้าหน้าที่ลานจอดรถ ใช้คำนวณค่าจอดรถ ออกใบเสร็จ และสรุปยอดประจำวันแบบ iterative 4 รอบ

## สรุปย่อ

| หัวข้อ | รายละเอียด |
|---|---|
| ทำอะไร | โปรแกรม CLI คำนวณค่าจอดรถ ออกใบเสร็จ และสรุปยอดประจำวัน |
| รันยังไง | `dart run bin/main.dart` |
| รองรับรถ | car / motorcycle / other |
| กฎการคิดเงิน | ฟรี 15 นาทีแรก, คิดเป็นชั่วโมงแบบปัดขึ้น, มีเพดานราคาต่อครั้ง, ส่วนลดสมาชิก 20%, ค่าปรับบัตรหาย |
| โครงสร้าง | `bin/main.dart` 52 บรรทัด ทำหน้าที่ CLI อย่างเดียว • `lib/` 4 class แยกความรับผิดชอบ |
| การทดสอบ | 19 unit test อัตโนมัติ (`dart test`) + 42 manual test case |
| คุณภาพโค้ด | `dart format` ผ่าน • `dart analyze` ไม่มี issue • GitHub Actions รันเทสทุกครั้งที่ push |

## สารบัญ

- [Project Overview](#project-overview) — โจทย์ ข้อมูลเข้า-ออก และกฎการคิดเงิน
- [How to Run](#how-to-run) — คำสั่งรันและโครงสร้างโปรเจกต์
- [Iteration 1 Design](#iteration-1-design) — การออกแบบรอบแรก
- [Iteration 2 Changes](#iteration-2-changes) — เพิ่ม validation และกฎพิเศษ
- [Iteration 3 Changes](#iteration-3-changes) — หลาย transaction และยอดสรุป
- [Iteration 4 Refactoring](#iteration-4-refactoring) — จัดโครงสร้างและคุณภาพโค้ด
- [Class Responsibilities](#class-responsibilities) — หน้าที่ของแต่ละ class
- [Business Rule Precedence](#business-rule-precedence) — ลำดับของกฎและเหตุผล
- [Dart Documentation Researched](#dart-documentation-researched) — เอกสารที่ค้นและนำมาใช้
- [Effective Dart Guidelines Used](#effective-dart-guidelines-used) — แนวปฏิบัติที่นำมาใช้จริง
- [Test Matrix](#test-matrix) — ผลทดสอบ 42 เคส

เอกสารประกอบเพิ่มเติมอยู่ในโฟลเดอร์ [`docs/`](docs/)

---

# Project Overview

สมมติว่า เป็นที่จอดรถของมหาลัยขนาดเล็ก
เช่นมหาวิทยาลัยกรุงเทพ วิทยาเขตกล้วยน้ำไทย ที่มีประตูทางเข้าออกตึกที่จอดรถทางเดียว


--Input--
plate
vehicle type (car / motorcycle / other)
parking duration(in minutes)
member? (y/n)
lost ticket? (y/n)

--Output--
page 1 PARKING RECEIPT
Plate            
Vehicle type     
Duration         
Normal fee       
Member discount  
Final fee        

page 2 DAILY SUMMARY
Total transactions 
Cars                
Motorcycles         
Other               
Members            
Lost tickets        
Total revenue     

--BUSINESS RULES--

| ประเภทรถ | 0–15 นาที | 16–60 นาที | หลังจากนั้น | สูงสุดต่อ transaction |
|---|---|---:|---|---:|
| car | ฟรี | 20 | +20 ต่อทุกชั่วโมงที่เริ่มต้น | 100 |
| motorcycle | ฟรี | 10 | +10 ต่อทุกชั่วโมงที่เริ่มต้น | 50 |
| other | ฟรี | 30 | +30 ต่อทุกชั่วโมงที่เริ่มต้น | 150 |

- **สมาชิก** ลด 20% คิดจากค่าจอดหลังใช้เพดานราคาแล้ว
- **บัตรหาย** คิดค่าปรับ car 200 / motorcycle 100 / other 300 แทนค่าจอดทั้งหมด ไม่คิดตามเวลา ไม่ใช้เพดาน และไม่ลดสมาชิก
- `other` เป็นประเภทที่เพิ่มเข้ามาเองนอกเหนือจากโจทย์ (stretch goal)

📄 ตารางฉบับเต็มพร้อมตัวอย่างการคิดเงินทีละช่วงเวลา: **[docs/business-rules.md](docs/business-rules.md)**


---

# How to Run

ต้องมี Dart SDK 3.13 ขึ้นไป

```bash
# ติดตั้ง dependency (เฉพาะ package test สำหรับ dev)
dart pub get

# รันโปรแกรม
dart run bin/main.dart

# รัน unit test
dart test

# ตรวจ format และ analyzer ก่อนส่งงาน
dart format .
dart analyze
```

โครงสร้างโปรเจกต์:

```text
CampusParking/
├── bin/
│   └── main.dart                     # entry point: menu loop + รับ input + แสดงผล
├── lib/
│   ├── parking_transaction.dart      # จอด 1 ครั้ง
│   ├── parking_fee_calculator.dart   # business rules การคิดค่าจอด
│   ├── parking_receipt.dart          # การแสดงใบเสร็จ
│   ├── parking_summary.dart          # ยอดสะสมประจำวัน
│   └── parking_menu.dart             # เมนูและยอดสรุปที่แสดงบนหน้าจอ
├── test/
│   └── parking_fee_calculator_test.dart
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

# Iteration 1 Design

**Iteration-1: basic parking fee**

::จะยังไม่มีการนำเอาส่วนลดสมาชิกมาลดเพราะเป็นการคำนวณค่าที่จอดรถเบื้องต้น

📄 Flow chart ของ iteration นี้: **[docs/iteration-1-flowchart.md](docs/iteration-1-flowchart.md)**

## คำถามก่อนเขียน implementation

### A. Input ของระบบมีอะไรบ้าง?

plate / vehicle type / duration / member / lost ticket

### B. Output ของระบบมีอะไรบ้าง?

Parking Receipt / Daily Summary

### C. Business rules มีอะไรบ้าง?

ดูตารางค่าจอดในหัวข้อ Project Overview

### D. Responsibility ใดควรอยู่ใน object?

ParkingTransaction > เก็บข้อมูลการจอด 1 ครั้ง เช่น plate, vehicleType, duration, member, lostTicket
ParkingFeeCalculator > คำนวณค่าจอดตาม Business Rules
ParkingFeeResult > เก็บผลลัพธ์การคำนวณ เช่น normalFee, discount, lostTicketFee, finalFee
ParkingSummary > เก็บและสะสมยอดรวมของทั้งวัน เช่น จำนวน transaction, จำนวนรถแต่ละประเภท, จำนวนสมาชิก, จำนวน lost ticket และ total revenue
ParkingReceipt > แสดงใบเสร็จของ transaction หนึ่งรายการจากข้อมูลใน ParkingTransaction และ ParkingFeeResult

### E. Responsibility ใดควรอยู่ใน CLI?

CLI รับผิดชอบการติดต่อกับผู้ใช้ เช่น แสดงเมนู ถามคำถาม รับ input จาก stdin, validate input เบื้องต้น, วน loop เมนู และแสดง Parking Receipt / Daily Summary

### F. ถ้าพรุ่งนี้เปลี่ยนราคาค่าจอด ควรต้องแก้ที่ส่วนใดของโปรแกรม?

แก้ที่ ParkingFeeCalculator ในส่วนที่กำหนด Business Rules ของค่าจอด โดยไม่ควรต้องแก้ bin/main.dart หรือส่วน CLI

## Reflection หลัง Iteration 1


ถ้าต้องเพิ่ม vehicle type ใหม่อีกหนึ่งประเภท โค้ดปัจจุบันต้องแก้กี่ตำแหน่ง?  
-- ส่วนรับ/เลือกประเภท
-- ส่วนคำนวณค่าจอด
   
การแก้หลายตำแหน่งบอกอะไรเกี่ยวกับ design ของโปรแกรม?
-- vehicle type ถูกกระจายอยู่หลายจุดใน code ถ้ามี Vehicle Type เพิ่มขึ้นเรื่อย ๆ โค้ดจะต้องแก้หลายที่ และมีโอกาส ลืมแก้บางจุดหรือเกิด bug ได้ง่าย
   ในอนาคตเราสามารถ refactor ให้ vehicle type และ parking fee rules แยกออกจาก main flow


---

# Iteration 2 Changes

**iteration-2: validation and special rules**

📄 Flow chart ของ iteration นี้: **[docs/iteration-2-flowchart.md](docs/iteration-2-flowchart.md)**

## สิ่งที่เปลี่ยนจาก Iteration 1

- เพิ่ม validation เช่น trim(), toLowerCase(), int.tryParse() และตรวจค่าติดลบ เพื่อป้องกัน input ที่ไม่ถูกต้อง โดย validation ที่เกี่ยวกับ input อยู่ใน CLI
- เพิ่ม field ใน ParkingTransaction เพื่อรองรับข้อมูลที่มากขึ้น เช่น plate, vehicleType, duration, isMember และ lostTicket
- ผลการคำนวณเปลี่ยนจากตัวเลขค่าจอดเพียงตัวเดียว เป็น ParkingFeeResult ที่เก็บรายละเอียดของผลลัพธ์ เช่น normalFee, discount, lostTicketFee และ finalFee เพราะระบบต้องแสดงรายละเอียดของค่าจอดและส่วนลดได้

---

# Iteration 3 Changes

**iteration-3: multi-transaction summary**

## สิ่งที่เปลี่ยนจาก Iteration 2

- เพิ่ม menu loop เพื่อให้ผู้ใช้สามารถทำหลาย parking transactions ได้ภายในการรันโปรแกรมครั้งเดียว
- เพิ่มการเก็บ daily summary เช่น จำนวน transaction, จำนวนรถแต่ละประเภท, จำนวนสมาชิก, lost ticket และ total revenue
- เพิ่มตัวแปร counter และ totalRevenue เพื่อสะสมข้อมูลของ transaction ที่สำเร็จ
- แยกความรับผิดชอบระหว่าง transaction / fee calculation / CLI ให้ชัดเจนมากขึ้น

## คำถามเชิงออกแบบของ Iteration 3

1. **Object ใดควรรู้ยอด revenue?**
- `ParkingSummary` ควรเป็น object เดียวที่รู้ยอด revenue เพราะเป็นผู้รับผิดชอบข้อมูลระดับ "ทั้งวัน"
- `ParkingTransaction` เก็บข้อมูลของการจอดเพียง 1 ครั้ง จึงไม่ควรรู้ยอดรวมของหลายรายการ

2. **Object ที่คำนวณ fee ควรรู้ยอด revenue ทั้งวันหรือไม่?**
- ไม่ควรรู้ เพราะ ParkingFeeCalculator มีหน้าที่แค่ คำนวณค่าจอดของ transaction หนึ่งรายการ และไม่ควรมี state สำหรับเก็บยอด revenue ทั้งวัน

3. **Parking transaction ควรแก้ counter ของตัวเองหรือไม่?**
- ไม่ควร ถ้า transaction ไปแก้ counter เอง จะทำให้ object หนึ่งตัวมีหลาย responsibility

4. **ใครควรเป็นผู้ตัดสินว่า transaction "สำเร็จแล้ว"?**
- CLI / Application Flow ควรเป็นผู้ตัดสินว่า transaction สำเร็จ หลังจากรับ input ครบ, validation ผ่าน และคำนวณผลลัพธ์เรียบร้อยแล้ว

5. **ถ้ามี transaction ถูก cancel ระบบจะป้องกัน counter ผิดได้อย่างไร?**
- อัปเดต counter และ revenue เฉพาะเมื่อ transaction สำเร็จแล้วเท่านั้น

## Constraint ที่ทำตาม

ไม่เก็บ transaction ทุกตัวไว้ใน `List` — เก็บเฉพาะค่าสะสม
(`totalTransactions`, `carCount`, `motorcycleCount`, `otherCount`, `memberCount`, `lostTicketCount`, `totalRevenue`)
ใน `ParkingSummary` เพราะ summary ต้องการเพียงยอดรวมเท่านั้น

---

# Iteration 4 Refactoring

**iteration-4: refactor and final cleanup**

- ย้าย logic ที่เกี่ยวกับการคำนวณและการจัดการข้อมูลออกจาก main.dart เพื่อให้ main.dart เหลือหน้าที่หลักในการควบคุม flow ของโปรแกรมและการรับ-แสดงผล
- แยก class ออกเป็นไฟล์ใน lib/ ตามหน้าที่ ได้แก่ ParkingTransaction, ParkingFeeCalculator, ParkingReceipt และ ParkingSummary โดย ParkingFeeResult วางไว้ในไฟล์เดียวกับ ParkingFeeCalculator เพราะเป็นผลลัพธ์ที่ผูกกับการคำนวณโดยตรง
- เปลี่ยน field บางส่วนเป็น private และใช้ getter สำหรับการเข้าถึงข้อมูล เพื่อควบคุมการแก้ไขข้อมูลจากภายนอก object
- เพิ่ม analysis_options.yaml เพื่อกำหนดกฎสำหรับตรวจสอบคุณภาพและรูปแบบของโค้ด
- ใช้ dart analyze เพื่อตรวจสอบปัญหาของโค้ด และแก้ไข warning/error ที่พบจนโค้ดผ่านการตรวจสอบ

---

# Class Responsibilities


## Class: ParkingTransaction

- **Responsibility:** เก็บข้อมูลของการจอดรถ หนึ่ง transaction ให้ครบถ้วน
- **Important fields:** `plate`, `vehicleType`, `duration`, `isMember`, `lostTicket` (ทั้งหมดเป็น `final`)
- **Important methods:** มีเพียง constructor
- **Why this class exists:** เพื่อรวมข้อมูลที่เกี่ยวข้องกับการจอดรถหนึ่งครั้งไว้ใน object เดียว ทำให้สามารถส่งข้อมูล transaction ไปให้ส่วนอื่น เช่น ParkingFeeCalculator ได้ง่ายขึ้น
- **What this class should NOT be responsible for:** ไม่ควรรับผิดชอบเรื่องการคำนวณราคา ไม่ควรรู้ราคาค่าจอด และไม่ควรรู้ยอดรวมของทั้งวัน เพราะหน้าที่ของมันคือเก็บข้อมูลของ transaction หนึ่งครั้งเท่านั้น


## Class: ParkingFeeCalculator

- **Responsibility:** คำนวณค่าจอดของ ParkingTransaction หนึ่งรายการตาม Business Rules และคืนผลลัพธ์เป็น ParkingFeeResult
- **Important fields:** ไม่มี state (stateless)
- **Important methods:** `calculateFee(ParkingTransaction) -> ParkingFeeResult`
- **Why this class exists:** เพื่อแยก Business Logic เรื่องการคำนวณค่าจอดออกจากส่วนที่รับ input และออกจาก ParkingTransaction ทำให้สามารถแก้หรือทดสอบกฎการคิดค่าจอดได้ง่ายขึ้น
- **What this class should NOT be responsible for:** ไม่ควรรับผิดชอบการรับ input การแสดงผล ไม่ควรควบคุม menu และไม่ควรเก็บยอด revenue หรือ counter ของทั้งวัน เพราะหน้าที่หลักคือคำนวณค่าจอดของ transaction ที่ส่งเข้ามา


## Class: ParkingSummary

- **Responsibility:** รับผิดชอบการเก็บและสะสมข้อมูลของ transaction ที่สำเร็จทั้งหมดในแต่ละวัน เช่น จำนวน transaction, จำนวนรถแต่ละประเภท, จำนวนสมาชิก, จำนวน lost ticket และรายได้รวม
- **Important fields:** `totalTransactions`, `carCount`, `motorcycleCount`, `otherCount`, `memberCount`, `lostTicketCount`, `totalRevenue`
- **Important methods:** `addTransaction(transaction, feeResult)`
- **Why this class exists:** เพราะระบบต้องรองรับหลาย transaction และต้องสรุปข้อมูลรวมของทั้งวัน จึงแยกความรับผิดชอบเรื่อง Daily Summary ออกมาโดยเฉพาะ ไม่ให้ ParkingTransaction หรือ ParkingFeeCalculator ต้องรู้เรื่องยอดรวม
- **What this class should NOT be responsible for:** ไม่ควรรับผิดชอบการคำนวณค่าจอด และไม่ควรรับ input หรือแสดงผลกับผู้ใช้ เพราะการคำนวณเป็นหน้าที่ของ ParkingFeeCalculator ส่วนการรับและแสดงผลเป็นหน้าที่ของ CLI


## Class: ParkingReceipt

- **Responsibility:** รับผิดชอบการแสดงผลใบเสร็จของ transaction หนึ่งรายการ โดยนำข้อมูลจาก transaction และ feeResult มาแสดง
- **Important fields:** ไม่มี state
- **Important methods:** `printReceipt(transaction, feeResult)`
- **Why this class exists:** เพื่อแยกส่วนการแสดง Parking Receipt ออกจาก Business Logic ทำให้ ParkingFeeCalculator ไม่ต้องรับผิดชอบเรื่องการ print และทำให้โค้ดแต่ละส่วนมีหน้าที่ชัดเจน
- **What this class should NOT be responsible for:** ไม่ควรคำนวณค่าจอด ไม่ควรแก้ไขข้อมูลของ transaction และไม่ควรสะสมยอด revenue หรือ counter ของทั้งวัน


## Class ที่คิดจะสร้างแต่ไม่ได้สร้าง

- ตอนออกแบบเคยคิดว่าจะแยก Class เพิ่มสำหรับจัดการเรื่องต่าง ๆ เช่น ParkingManager หรือ InputValidator
- แต่สุดท้ายไม่ได้สร้าง เพราะความรับผิดชอบของแต่ละส่วนยังไม่มากพอที่จะต้องมี Class แยก และบางส่วนสามารถจัดการใน CLI ได้โดยไม่ทำให้ Business Logic ปะปนกัน


---

# Business Rule Precedence

## ลำดับกฎ (pseudo-code)

- เริ่มจากตรวจสอบ Lost Ticket ก่อน เพราะ Lost Ticket เป็นกรณีพิเศษที่มีค่าปรับตามประเภทรถ และไม่ต้องสนใจระยะเวลาที่จอด

- ถ้าไม่ได้ Lost Ticket จึงตรวจสอบระยะเวลาจอด ถ้าจอดไม่เกิน 15 นาที จะไม่เสียค่าจอด

- ถ้าเกิน 15 นาที จะคำนวณจำนวนชั่วโมงโดยปัดขึ้น แล้วคูณกับอัตราค่าจอดตามประเภทรถ จากนั้นจึงใช้ maximum fee ตามกฎ

- หลังจากได้ค่าจอดที่ผ่าน maximum fee แล้ว จึงตรวจสอบว่าเป็นสมาชิกหรือไม่ ถ้าเป็นสมาชิกจึงลด 20% จากค่าที่ผ่าน cap แล้ว

* ดังนั้น ลำดับของกฎมีผลต่อผลลัพธ์ และไม่สามารถสลับลำดับได้ตามใจ

เขียนเป็น pseudo-code ได้ดังนี้:

```text
IF lost ticket THEN
    lost-ticket fee = 200 (car) / 100 (motorcycle) / 300 (other)
    normal fee      = 0
    member discount = 0
    final fee       = lost-ticket fee
ELSE
    IF duration <= 15 THEN
        normal fee = 0
    ELSE
        hours      = ceiling(duration / 60)
        normal fee = hours * rate        (car 20 / motorcycle 10 / other 30)
        IF normal fee > maximum THEN     (car 100 / motorcycle 50 / other 150)
            normal fee = maximum
        END IF
    END IF

    IF member THEN
        final fee = normal fee * 0.8
        discount  = normal fee - final fee
    ELSE
        final fee = normal fee
        discount  = 0
    END IF
END IF
```


## คำถามที่ต้องตอบ
1. **Lost ticket ควรถูกตรวจสอบตอนไหน?**
- ควรตรวจสอบเป็นอันดับแรก ก่อนคำนวณ duration เพราะ Lost Ticket เป็น Business Rule พิเศษที่ไม่สนใจว่าจอดมากี่นาที และใช้ค่าปรับตามประเภทรถโดยตรง

2. **Member discount ควรเกิดก่อนหรือหลัง maximum fee?**
- เพราะ Business Rule กำหนดให้คำนวณค่าจอดก่อน แล้วจำกัดด้วย maximum fee จากนั้นจึงนำราคาที่ผ่าน cap แล้วมาลดสมาชิก 20%

3. **ถ้าจอดฟรี 10 นาทีและเป็นสมาชิก ผลลัพธ์ควรเป็นเท่าไร?**
- 0 บาท เพราะจอดไม่เกิน 15 นาที จึงฟรีอยู่แล้ว ดังนั้น member discount 20% ไม่มีผลเพิ่มเติม

4. Business rules เหล่านี้ควรอยู่ใน CLI หรือ core logic?
- เพราะ CLI มีหน้าที่รับ input และแสดงผล ส่วน ParkingFeeCalculator มีหน้าที่ตัดสินว่าควรคิดค่าจอดเท่าไรตาม Business Rules

5. Validation ของ user input กับ validation ของ business object เป็นเรื่องเดียวกันหรือไม่?
- ไม่ใช่เรื่องเดียวกัน
- Input Validation = "ข้อมูลที่กรอกมาใช้ได้ไหม?"
- Business Rule = "ถ้าข้อมูลใช้ได้แล้ว ระบบต้องทำอะไรกับมัน?"
---

# Dart Documentation Researched

| หัวข้อที่ค้น | เอกสารอ้างอิง | ใช้ตรงไหนในโปรเจกต์ |
|---|---|---|
| `stdin.readLineSync()` | https://api.dart.dev/dart-io/Stdin/readLineSync.html | `readPlate()` / `readVehicleType()` / `readDuration()` / `readYesNo()` ใน `bin/main.dart` |
| `dart:io` | https://api.dart.dev/dart-io/ | `stdout.write()` สำหรับพิมพ์คำถามโดยไม่ขึ้นบรรทัดใหม่ |
| `int.tryParse()` | https://api.dart.dev/dart-core/int/tryParse.html | `readDuration()` — แปลงนาทีจากข้อความ |
| `String.trim()` | https://api.dart.dev/dart-core/String/trim.html | ทุกช่องรับ input ก่อนตรวจความถูกต้อง |
| `String.toLowerCase()` | https://api.dart.dev/dart-core/String/toLowerCase.html | `readVehicleType()` / `readYesNo()` และการตรวจคำสั่ง cancel |
| `String.isNotEmpty` | https://api.dart.dev/dart-core/String/isNotEmpty.html | `readPlate()` — ตรวจทะเบียนว่าง |
| Operator `~/` (truncating division) | https://dart.dev/language/operators | `ParkingFeeCalculator` — คำนวณชั่วโมงแบบปัดขึ้น |
| Classes / Constructors | https://dart.dev/language/classes | ทั้ง 4 class ใน `lib/` |
| Getters | https://dart.dev/language/methods#getters-and-setters | `ParkingSummary` — เปิดให้อ่านค่าโดยไม่ให้เขียนทับ |
| Null safety | https://dart.dev/null-safety | `String?` / `int?` / `bool?` ที่ฟังก์ชันรับ input คืนกลับมา |
| Package layout (`bin/` vs `lib/`) | https://dart.dev/tools/pub/package-layout | เหตุผลที่ import ด้วย `package:campus_parking/...` |

## คำถามที่ต้องตอบ

**1. `stdin.readLineSync()` return type คืออะไร และทำไมจึงเกี่ยวข้องกับ null safety?**

> readLineSync() มี return type เป็น String? เพราะมีกรณีที่ไม่มีบรรทัดให้อ่านจริง ๆ เช่น เมื่อ input หมดจากการกด Ctrl+D หรือการ pipe ข้อมูลเข้ามาแล้วข้อมูลหมดกรณีนี้ต่างจากการกด Enter เปล่า เพราะ Enter เปล่ายังได้ String ที่เป็นค่าว่าง ('') กลับมา เครื่องหมาย ? เป็นส่วนหนึ่งของ Dart null safety ซึ่งหมายความว่าค่านี้สามารถเป็น null ได้ และไม่สามารถนำไปใช้เป็น String โดยตรงโดยไม่จัดการกรณี null ก่อน ในโปรแกรมนี้ ดัก null ไว้ตอนรับ input และถือว่าเป็นการยกเลิกรายการ เพื่อไม่ให้โปรแกรมนำค่า null ไปใช้งานต่อ

**2. `tryParse()` ต่างจาก `parse()` อย่างไร และแบบใดเหมาะกับ user input ที่อาจผิด?**

> สำหรับ user input หนูเลือกใช้ tryParse() เพราะเหมาะกับกรณีที่ผู้ใช้อาจกรอกข้อมูลไม่ถูกต้อง parse() จะ throw FormatException เมื่อไม่สามารถแปลงค่าได้ เช่น ถ้าผู้ใช้กรอก abc แทนตัวเลข โปรแกรมจะเกิด exception และถ้าไม่ได้จัดการด้วย try/catch ก็อาจทำให้โปรแกรมหยุดทำงาน ในทางกลับกัน tryParse() จะคืนค่า null เมื่อแปลงไม่ได้ ทำให้สามารถตรวจสอบด้วย if และแจ้งให้ผู้ใช้กรอกข้อมูลใหม่ได้ โดยในโปรแกรมนี้ใช้กับการรับระยะเวลาจอดใน readDuration().

**3. ทำไมการใช้ `!` ทุกครั้งที่เจอ nullable value จึงไม่ใช่วิธีแก้ปัญหาที่ดี?**

> ! เป็นการยืนยันกับ compiler ว่าค่านั้นไม่เป็น null หากค่าที่เราคิดว่าไม่เป็น null กลับเป็น null จริง โปรแกรมจะเกิด runtime error ดังนั้นการใช้ ! เป็นการย้ายปัญหาจากการตรวจสอบในตอน compile ไปให้เกิดขึ้นตอน runtime ซึ่งไม่เหมาะกับ user input ที่อาจมีค่าที่ไม่คาดคิด ในโปรแกรมนี้ใช้การตรวจสอบ null แล้ว return ออกไปก่อน เช่น:

String? line = stdin.readLineSync();

if (line == null) {
  return null;
}

String input = line.trim();

> หลังจากตรวจสอบแล้ว Dart สามารถรู้ได้ว่า line ไม่เป็น null และสามารถใช้เป็น String ได้โดยไม่ต้องใช้ ! นอกจากนี้ทั้งโปรเจกต์ไม่มีการใช้ ! แม้แต่จุดเดียว เพราะเลือกจัดการ nullable value ด้วย null check แทน

---

# Effective Dart Guidelines Used

อ้างอิง: https://dart.dev/effective-dart

> หมายเหตุ: เนื้อหาด้านล่างบันทึกจากสิ่งที่แก้จริงในโปรเจกต์นี้ ควรอ่านทวนแล้วเรียบเรียงเป็นคำของตัวเองก่อนส่ง เพราะเป็นหัวข้อที่อาจถูกถามปากเปล่า

## Guideline 1 — PREFER making declarations private

- **Guideline:** https://dart.dev/effective-dart/design#prefer-making-declarations-private
- **นำมาใช้ตรงไหน:** `lib/parking_summary.dart`
- **ก่อนปรับ:** field ทั้ง 7 ตัวเป็น public เช่น `int totalTransactions = 0;` ทำให้โค้ดส่วนใดก็ได้เขียนทับยอดรวมได้โดยตรง เช่น `summary.totalRevenue = 9999;`
- **หลังปรับ:** เปลี่ยนเป็น `_totalTransactions` แล้วเปิดเฉพาะ getter สำหรับอ่าน ทางเดียวที่ยอดจะเปลี่ยนได้คือผ่าน `addTransaction()` — โค้ดที่เรียกใช้ไม่ต้องแก้เลยสักบรรทัด เพราะ getter เรียกใช้เหมือน field

## Guideline 2 — DON'T use a relative import if it reaches into lib

- **Guideline:** https://dart.dev/effective-dart/usage#dont-use-a-relative-import-if-it-reaches-into-lib (lint: `avoid_relative_lib_imports`)
- **นำมาใช้ตรงไหน:** `bin/main.dart` และ `test/parking_fee_calculator_test.dart`
- **ก่อนปรับ:** `import '../lib/parking_fee_calculator.dart';` ซึ่ง `dart analyze` รายงานเป็น issue
- **หลังปรับ:** `import 'package:campus_parking/parking_fee_calculator.dart';` — Dart มองเป็นไฟล์เดียวกับที่ import จากที่อื่น ไม่เกิดปัญหาไฟล์ซ้ำสองชุด และ analyzer ไม่มี issue เหลือ

## Guideline 3 — AVOID using `!` / จัดการ nullable ให้ตรงความหมาย

- **Guideline:** https://dart.dev/null-safety/understanding-null-safety
- **นำมาใช้ตรงไหน:** ฟังก์ชันรับ input ทั้ง 4 ตัวใน `bin/main.dart`
- **ก่อนปรับ:** ใช้ `(stdin.readLineSync() ?? '')` ซึ่งกลบกรณี `null` ให้กลายเป็นค่าว่าง ทำให้ตอนที่ไม่มี input เหลือ โปรแกรมเข้าใจผิดว่าผู้ใช้กด Enter เปล่า แล้ววนถามใหม่ไม่รู้จบ
- **หลังปรับ:** รับเป็น `String?` แล้วดัก `if (line == null) return null;` ก่อน จากนั้น Dart จะ promote ตัวแปรเป็น `String` ให้เอง — ทั้งไฟล์จึงไม่มี `!` เลย และแยกความหมายของ "ไม่มีคนกรอกแล้ว" ออกจาก "กรอกค่าว่าง" ได้

---

# Test Matrix

รวม 42 เคส แบ่งตามที่โจทย์ข้อ 23 กำหนด (boundary / invalid input / business-rule interaction / application state)

**ผลการทดสอบ: ผ่านทั้งหมด 42 เคส** (รันเมื่อ 8 กันยายน 2026 ด้วย Dart SDK 3.13)

## วิธีรัน

รันทีละเคสด้วยการป้อน input ล่วงหน้า:

```bash
printf '1\nABC123\ncar\n16\nn\nn\n3\n' | dart run bin/main.dart
```

หรือรันทั้งหมดรวดเดียวด้วยสคริปต์ช่วยที่อยู่ใน root ของโปรเจกต์:

```bash
bash run_tests.sh              # รันทุกเคส
bash run_tests.sh T26          # รันเฉพาะเคสเดียว
bash run_tests.sh > result.txt # เก็บผลไว้เป็นไฟล์
```

ลำดับที่โปรแกรมถามคือ เมนู → ทะเบียน → ประเภทรถ → นาที → Member → Lost ticket → กลับเมนู

## Boundary cases

| ID   |    Input / Scenario   |   Expected  | Actual | Pass? |
|------|-----------------------|-------------|--------|-------|
| T01 | car, 0 min | 0.00 | 0.00 | Pass |
| T02 | car, 15 min | 0.00 | 0.00 | Pass |
| T03 | car, 16 min | 20.00 | 20.00 | Pass |
| T04 | car, 60 min | 20.00 | 20.00 | Pass |
| T05 | car, 61 min | 40.00 | 40.00 | Pass |
| T06 | car, 120 min | 40.00 | 40.00 | Pass |
| T07 | car, 121 min | 60.00 | 60.00 | Pass |
| T08 | car, 500 min | 100.00(cap) | 100.00 | Pass |
| T09 | motorcycle, 15 min | 0.00 | 0.00 | Pass |
| T10 | motorcycle, 16 min | 10.00 | 10.00 | Pass |
| T11 | motorcycle, 61 min | 20.00 | 20.00 | Pass |
| T12 | motorcycle, 121 min | 30.00 | 30.00 | Pass |
| T13 | motorcycle, 500 min | 50.00 (cap) | 50.00 | Pass |
| T14 | car, 999999 min | 100.00 (cap) | 100.00 | Pass |

## Invalid input

|  ID |      Input / Scenario   |              Expected              | Actual | Pass? |
|-----|-------------------------|------------------------------------|--------|-------|
| T15 | vehicle type = `CAR` | รับเป็น car, 20.00 | รับเป็น car, 20.00 | Pass |
| T16 | vehicle type = ` car ` | รับเป็น car, 20.00 | รับเป็น car, 20.00 | Pass |
| T17 | vehicle type = `truck` | Invalid vehicle type แล้วถามใหม่ | Invalid vehicle type แล้วถามใหม่ | Pass |
| T18 | vehicle type = (ว่าง) | Invalid vehicle type แล้วถามใหม่ | Invalid vehicle type แล้วถามใหม่ | Pass |
| T19 | duration = `abc` | Invalid number แล้วถามใหม่ ไม่ crash | Invalid number แล้วถามใหม่ | Pass |
| T20 | duration = `-1` | Duration cannot be negative | Duration cannot be negative | Pass |
| T21 | duration = (ว่าง) | Invalid number แล้วถามใหม่ | Invalid number แล้วถามใหม่ | Pass |
| T22 | duration = `0` | ยอมรับ, 0.00 | 0.00 | Pass |
| T23 | member = `x` | Please enter y or n | Please enter y or n | Pass |
| T24 | เมนู = `9` | Invalid choice, ไม่ crash | Invalid choice, ไม่ crash | Pass |

## Business-rule interaction

| ID | Input / Scenario | Expected | Actual | Pass? |
|---|---|---|---|---|
| T25 | car 500 min, non-member | 100.00 | 100.00 | Pass |
| T26 | car 500 min, member | normal 100 / discount 20 / final 80.00 | normal 100 / discount 20 / final 80.00 | Pass |
| T27 | motorcycle 500 min, member | normal 50 / discount 10 / final 40.00 | normal 50 / discount 10 / final 40.00 | Pass |
| T28 | car 10 min, member (ฟรี + สมาชิก) | 0.00 | 0.00 | Pass |
| T29 | car, lost ticket | 200.00 | 200.00 | Pass |
| T30 | car, member + lost ticket | 200.00 (ไม่ลดสมาชิก) | 200.00 (ไม่มีบรรทัดส่วนลด) | Pass |
| T31 | motorcycle, lost ticket | 100.00 | 100.00 | Pass |
| T32 | car 185 min, member | normal 80 / discount 16 / final 64.00 | normal 80 / discount 16 / final 64.00 | Pass |

## Application state

| ID | Input / Scenario | Expected | Actual | Pass? |
|---|---|---|---|---|
| T33 | ดู summary ก่อนทำรายการใด ๆ | ทุกค่าเป็น 0, revenue 0.00 | ทุกค่าเป็น 0, revenue 0.00 | Pass |
| T34 | 3 รายการตาม scenario ข้อ 14 | total 3 / cars 2 / motorcycles 1 / members 2 / lost 1 / revenue 244.00 | total 3 / cars 2 / motorcycles 1 / members 2 / lost 1 / revenue 244.00 | Pass |
| T35 | ยกเลิกกลางคัน แล้วดู summary | total ยังเป็น 1, revenue 20.00 | total 1, revenue 20.00 | Pass |
| T36 | ทำ 2 รายการต่อกันแล้ว Exit | ออกโปรแกรมได้ปกติ | ออกโปรแกรมได้ปกติ | Pass |

## Extra cases

| ID | Input / Scenario | Expected | Actual | Pass? |
|---|---|---|---|---|
| T37 | ทะเบียนเว้นว่าง | Plate cannot be empty แล้วถามใหม่ | Plate cannot be empty แล้วถามใหม่ | Pass |
| T38 | พิมพ์ `cancel` ที่ช่องแรก | Transaction cancelled, summary ยังเป็น 0 | Transaction cancelled, summary 0 | Pass |
| T39 | input หมดกลางคัน (ไม่มีคำสั่งออก) | ยกเลิกรายการแล้วปิดโปรแกรมเอง ไม่วนไม่รู้จบ | Transaction cancelled แล้วปิดโปรแกรมเอง | Pass |
| T40 | other, 30 นาที | 30.00 | 30.00 | Pass |
| T41 | other, 500 นาที | 150.00 (cap) | 150.00 | Pass |
| T42 | other, lost ticket | 300.00 | 300.00 | Pass |

## หมายเหตุเรื่องความซ้ำซ้อนกับ unit test

เคสในกลุ่ม Boundary และ Business-rule interaction ส่วนใหญ่มี unit test ใน `test/parking_fee_calculator_test.dart` ครอบคลุมอยู่แล้ว (19 เคส) การทดสอบด้วยมือในตารางนี้จึงเป็นการยืนยันซ้ำผ่านหน้าจอจริง ส่วนกลุ่ม Invalid input และ Application state เป็นกลุ่มที่มีเฉพาะการทดสอบด้วยมือ เพราะตรรกะ validation อยู่ในลูปเดียวกับ `stdin.readLineSync()` จึงเรียกทดสอบแยกไม่ได้

---

# Final Reflection


## Q1 — Iteration ใดทำให้ต้องเปลี่ยน design มากที่สุด เพราะอะไร?


> Iteration 4 ทำให้ต้องเปลี่ยน design มากที่สุด เพราะเป็นช่วงที่ไม่ได้เพิ่มแค่ feature ใหม่ แต่ต้องกลับมาปรับโครงสร้างของ code เดิมให้เป็นระเบียบมากขึ้น เช่น แยก logic ออกจาก main.dart และแยก responsibility ของแต่ละ class ให้ชัดเจนขึ้น จากเดิมที่ logic หลายส่วนอยู่รวมกันใน main.dart จึงต้อง refactor และจัดโครงสร้างใหม่

## Q2 — มี code ส่วนใดที่ตอนแรกอยู่ใน `main.dart` แล้วภายหลังย้ายออก? เพราะอะไร?


> ตอนแรก main.dart มีทั้งการรับ input, validation, การคำนวณค่าจอด, การจัดการ transaction และการสรุปผล ทำให้ main() ยาวมากๆ เลยต้องย้าย logic เหล่านี้ออกไปเป็น class ที่รับผิดชอบเฉพาะด้าน       main.dart เลยทำหน้าที่ควบคุม flow ของโปรแกรมเป็นหลัก และทำให้แต่ละส่วนสามารถเข้าใจและทดสอบได้ง่ายขึ้น



## Q3 — class ใดมี responsibility ชัดที่สุดในระบบ?


> ParkingFeeCalculator มี responsibility ที่ชัดที่สุด เพราะหน้าที่หลักของ class นี้คือคำนวณค่าจอดรถจากข้อมูลของ transaction โดยจัดการ business rules เช่น ระยะเวลาจอด, ประเภทรถ, maximum fee, member discount และ lost ticket


## Q4 — มี class ใดที่คิดจะสร้าง แต่สุดท้ายตัดสินใจไม่สร้าง? เพราะอะไร?


> ใตอนแรกมีแนวคิดที่จะสร้าง InputValidator สำหรับตรวจความถูกต้องของ input และ ParkingManager สำหรับควบคุม flow ของโปรแกรม แต่สุดท้ายไม่ได้สร้างทั้งสองตัว เพราะ validation ที่มีอยู่ยังไม่ซับซ้อนพอที่จะต้องมี class แยก และ main.dart ก็ทำหน้าที่ควบคุม flow ได้อยู่แล้วโดยไม่มี business logic ปนอยู่ การสร้าง class เพิ่มในตอนนี้จะเป็น abstraction ที่ยังไม่มีใครต้องการใช้ เลยเลือกให้ validation ของ input อยู่ในส่วน CLI และให้ business logic อยู่ใน class ที่รับผิดชอบเรื่องนั้นโดยตรงแทน


## Q5 — ถ้าต้องเพิ่ม `bus` เป็น vehicle type ใหม่ design ปัจจุบันรองรับได้ง่ายหรือยาก?


> Design ปัจจุบันสามารถเพิ่มได้ แต่ยังไม่ถือว่าง่ายมาก เพราะ vehicle type ยังถูกตรวจสอบและนำไปใช้ในหลายจุด เช่น การคำนวณค่าจอดและการแสดงผล summary ดังนั้นถ้าเพิ่ม bus จะต้องแก้หลายจุดที่เกี่ยวข้องกับ vehicle type เทียบกับ Reflection หลัง Iteration 1 จะเห็นว่าการออกแบบยังมี room for improvement หากในอนาคตมี vehicle type เพิ่มขึ้นหลายประเภท อาจพิจารณาใช้ enum หรือแยก vehicle-specific rules เพื่อให้การเพิ่ม type ใหม่กระทบ code เดิมน้อยลง


## Q6 — ถ้าต้องบันทึก transaction ย้อนหลัง 1,000 รายการ requirement ใหม่จะกระทบ architecture ตรงไหน?


> ที่ต้องเปลี่ยนหลัก ๆ คือ ParkingSummary เพราะปัจจุบันเก็บเฉพาะข้อมูลสรุป เช่น จำนวน transaction และรายได้รวม ไม่ได้เก็บ transaction แต่ละรายการไว้
> ถ้าต้องการดูข้อมูลย้อนหลัง 1,000 รายการ จะต้องเปลี่ยนให้มีส่วนที่เก็บ transaction ทั้งหมด เช่น List<ParkingTransaction> และอาจต้องแยก responsibility ระหว่างการเก็บข้อมูล transaction กับการคำนวณ summary ให้ชัดเจนขึ้น ถ้าข้อมูลต้องคงอยู่หลังจากปิดโปรแกรมด้วย อาจต้องเพิ่ม persistence layer เช่น file หรือ database ซึ่งจะเป็นการเปลี่ยน architecture มากกว่าการเพิ่มแค่ field ใน ParkingSummary


