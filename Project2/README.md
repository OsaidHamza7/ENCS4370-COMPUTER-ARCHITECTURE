# Project 2
            

# Simple RISC Verilog Processor 

A Simple multi-cycle RISC Verilog processor with architecture similar to MIPS

---

🔗 | [Project Description](./Project-2-Spring+-2022-2023.pdf)  <br>




---

## Data Path

![datapath block diagram](./Data_Path_Diagram.png)


## Code

  ```assembly
  SLLV R2,R1,R0
  JAL 12
  SLL R1,R0,1
  LW R2,1(R2)
  ADDI R0,R1,1
  SLLV R2,R1,R0
  SLR R1,R0,1
  SLL R1,R0,1
  SW R1,4(R2) 
  ```

## Waveform
  ![code waveform](./WaveCode.png)
  
 ## Partners
___________________________________________________________
🔗 | [Osaid Hamza](https://github.com/OsaidHamza7)  
🔗 | [Mohammad Odeh](https://github.com/M7mdOdeh1) <br>
🔗 | [Mahmoud Hamdan](https://github.com/mahmoudbzu)
___________________________________________________________
