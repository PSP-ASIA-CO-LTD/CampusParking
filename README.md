# Campus Parking Fee & Session Management System

โปรแกรม CLI สำหรับเจ้าหน้าที่ลานจอดรถ ใช้คำนวณค่าจอดรถ ออกใบเสร็จ และสรุปยอดประจำวันแบบ iterative 4 รอบ

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
car
| ระยะเวลาจอด        |         ค่าจอด         |
|--------------------|----------------------:|
| 0–15 นาที           |          ฟรี           |
| 16–60 นาที          |          20           |
| หลังจาก 60 นาที      | +20 บาทต่อทุกชั่วโมงที่เริ่มต้น|
| สูงสุดต่อ transaction |         100 บาท       |


| นาที  | ชั่วโมงที่คิดเงิน       | ค่าจอด  |
| ---: | ----------------: | -----: |
|   16 |                 1 |     20 |
|   60 |                 1 |     20 |
|   61 |                 2 |     40 |
|  120 |                 2 |     40 |
|  121 |                 3 |     60 |
|  180 |                 3 |     60 |
|  181 |                 4 |     80 |
|  240 |                 4 |     80 |
|  241 |                 5 |    100 |

Motorcycles 
| ระยะเวลาจอด        |         ค่าจอด         |
|--------------------|----------------------:|
| 0–15 นาที           |          ฟรี           |
| 16–60 นาที          |          10           |
| หลังจาก 60 นาที      | +10 บาทต่อทุกชั่วโมงที่เริ่มต้น|
| สูงสุดต่อ transaction |          50 บาท       |


| นาที  | ชั่วโมงที่คิดเงิน       | ค่าจอด  |
| ---: | ----------------: | -----: |
|   16 |                 1 |     10 |
|   60 |                 1 |     10 |
|   61 |                 2 |     20 |
|  120 |                 2 |     20 |
|  121 |                 3 |     30 |
|  180 |                 3 |     30 |
|  181 |                 4 |     40 |
|  240 |                 4 |     40 |
|  241 |                 5 |     50 |


Other (vehicle type ที่เพิ่มเข้ามาเองนอกเหนือจากโจทย์ — stretch goal: third vehicle type)
| ระยะเวลาจอด        |         ค่าจอด         |
|--------------------|----------------------:|
| 0–15 นาที           |          ฟรี           |
| 16–60 นาที          |          30           |
| หลังจาก 60 นาที      | +30 บาทต่อทุกชั่วโมงที่เริ่มต้น|
| สูงสุดต่อ transaction |         150 บาท       |


| นาที  | ชั่วโมงที่คิดเงิน       | ค่าจอด  |
| ---: | ----------------: | -----: |
|   16 |                 1 |     30 |
|   60 |                 1 |     30 |
|   61 |                 2 |     60 |
|  120 |                 2 |     60 |
|  121 |                 3 |     90 |
|  181 |                 4 |    120 |
|  241 |                 5 |    150 |


--MEMBER DISCOUNT--
สมาชิกได้ส่วนลด 20% โดยคิดจากค่าจอด "หลังใช้ maximum cap แล้ว"


--LOST TICKET FEE--
| ประเภทรถ     | ค่าปรับบัตรหาย |
|--------------|-----------: |
| car          |         200 |
| motorcycle   |         100 |
| other        |         300 |

ค่าปรับบัตรหายใช้แทนค่าจอดปกติทั้งหมด คือไม่คิดตามระยะเวลา ไม่ใช้ maximum cap และไม่ได้ส่วนลดสมาชิก


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
│   └── parking_summary.dart          # ยอดสะสมประจำวัน
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

```text
Flow Chart
            car in <----------------------------------+
               |                                      |
               |                                      |
               v                                      |
           Read Plate                                 |
               |                                      |
               |                                      |
               v                                      |
      Which vehicle type                              |
               |                                      |
    +----------+-----------+                          |
    |                      |                          |
   car                 motorcycle                     |                 
     \                    /                           |
      \                  /                            |
       \                /                             |                
        \              /                              |
         \            /                               |
          \          /                                |
           \        /                                 |
            \      /                                  |  
             \    /                                   |
              \  /                                    |
               v                                      |  
               |                                      |
               v                                      |
      Parking duration(min)                           |
               |                                      |                   
               |                                      |
               v                                      |
           Final fee                                  | 
               |                                      |
               |                                      |
               v                                      | 
            Car Out                                   |
               |                                      |
               |                                      |
               v                                      |
          New vehicle?                                |   
    +----------+-----------+                          |
    |                      |                          |
    No                    Yes                         |
    |                      |__________________________+
   Exit                   


   ลำดับโครงสร้าง
 1. Car In
 2. Read Plate
 3. Vehicle Type
 4. Parking Duration
 5. Final Fee
 6. Car Out
 7. New Vehicle? / Exit

 Step 1 - Do forever loop << ต้องทำซ้ำจนกว่าจะ exit
 Step 2 — Read Plate
 Step 3 - Vehicle Type
 Step 4 — Parking Duration
 Step 5 - Declare Fee
 Step 6 - Calculate parking fee
 Step 7 - Car and Motorcycle
 Step 8 - Final Fee
```

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

```text

            +--------------------------------------+
            |                                      |
            v                                      |
          Car In                                   |
            |                                      |
            v                                      |
        Read Plate                                 |
            |                                      |
            v                                      |
  +-> Validate Plate?                              |
  |     /          \                               |
  |    No           Yes                            |
  |    |             |                             |
Show Error           v                             |
               Which vehicle type                  |
                     |                             | 
                     v                             |
        +-----> Validate Vehicle?                  |
        |        /          \                      |
        |      No           Yes                    |
        |      |           /   \                   |
       Show Error         /     \                  |
                       Car       Motorcycle        |
                         \          /              |
                          \        /               |
                           v      v                |
                       Parking Duration            |
                              |                    |
                              v                    |
                +----> Validate Duration?          |
                |        /            \            |
                |      No              Yes         |
                |      |                |          |
               Show Error               |          |
                                        v          |
                                 Special Rules     |
                                    (member)       |
                                       |           |
                                       |           |
                                       |           |
                                       v           |
                                  Final Fee        |
                                       |           |
                                       v           |
                                    Car Out        |
                                       |           |
                                       v           |
                                 New vehicle?      |
                                  /        \       |
                                No          Yes    |
                                |            |     |
                               Exit          +-----+
```

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


## ลำดับกฎ (pseudo-code)

- เริ่มจากตรวจสอบ Lost Ticket ก่อน เพราะ Lost Ticket เป็นกรณีพิเศษที่มีค่าปรับตามประเภทรถ และไม่ต้องสนใจระยะเวลาที่จอด

- ถ้าไม่ได้ Lost Ticket จึงตรวจสอบระยะเวลาจอด ถ้าจอดไม่เกิน 15 นาที จะไม่เสียค่าจอด

- ถ้าเกิน 15 นาที จะคำนวณจำนวนชั่วโมงโดยปัดขึ้น แล้วคูณกับอัตราค่าจอดตามประเภทรถ จากนั้นจึงใช้ maximum fee ตามกฎ

- หลังจากได้ค่าจอดที่ผ่าน maximum fee แล้ว จึงตรวจสอบว่าเป็นสมาชิกหรือไม่ ถ้าเป็นสมาชิกจึงลด 20% จากค่าที่ผ่าน cap แล้ว

* ดังนั้น ลำดับของกฎมีผลต่อผลลัพธ์ และไม่สามารถสลับลำดับได้ตามใจ

- โครงคร่าว ๆ ที่ต้องครอบคลุม:
```text
IF lost ticket THEN
   ... (ค่าปรับตามประเภทรถ, ไม่สนใจ duration, ไม่ใช้ cap, ไม่ลดสมาชิก)
ELSE
   IF duration <= 15 THEN
       ...
   ELSE
       ... คิดชั่วโมงแบบปัดขึ้น
       ... คูณอัตราตามประเภทรถ
       ... ใช้ maximum cap
   END IF
   IF member THEN
       ... ลด 20% จากค่าที่ผ่าน cap แล้ว
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