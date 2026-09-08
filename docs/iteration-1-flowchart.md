# Iteration 1 — Flow Chart

ย้ายมาจาก `README.md` หัวข้อ Iteration 1 Design

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
