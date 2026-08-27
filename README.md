สมมติว่า เป็นที่จอดรถของมหาลัยขนาดเล็ก
เช่นมหาวิทยาลัยกรุงเทพ วิทยาเขตกล้วยน้ำไทย ที่มีประตูทางเข้าออกตึกที่จอดรถทางเดียว


--Input--
plate
vehicle type (car/motorcycle)
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

สูตรคิดแบบปัดขึ้น ceil()
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

สูตรคิดแบบปัดขึ้น ceil()
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


==============================================
Iteration-1: basic parking fee
::จะยังไม่มีการนำเอาส่วนลดสมาชิกมาลดเพราะเป็นการคำนวณค่าที่จอดรถเบื้องต้น
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

ถ้าต้องเพิ่ม vehicle type ใหม่อีกหนึ่งประเภท โค้ดปัจจุบันต้องแก้กี่ตำแหน่ง?  
-- ส่วนรับ/เลือกประเภท
-- ส่วนคำนวณค่าจอด
   
การแก้หลายตำแหน่งบอกอะไรเกี่ยวกับ design ของโปรแกรม?
-- vehicle type ถูกกระจายอยู่หลายจุดใน code ถ้ามี Vehicle Type เพิ่มขึ้นเรื่อย ๆ โค้ดจะต้องแก้หลายที่ และมีโอกาส ลืมแก้บางจุดหรือเกิด bug ได้ง่าย
   ในอนาคตเราสามารถ refactor ให้ vehicle type และ parking fee rules แยกออกจาก main flow

===========================================
iteration-2: validation and special rules

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