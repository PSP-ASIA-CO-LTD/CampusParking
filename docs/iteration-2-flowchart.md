# Iteration 2 — Flow Chart (เพิ่ม validation)

ย้ายมาจาก `README.md` หัวข้อ Iteration 2 Changes

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
