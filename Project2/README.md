# Project 2
            

# Simple RISC Verilog Processor 

A Simple multi-cycle RISC Verilog processor with architecture similar to MIPS

---

🔗 | [Project Description](Project-2-Spring+-2022-2023.pdf)  <br>




---

## Data Path

![datapath block diagram](./Path.png)


## Code

  ```assembly
  ADDI R1, R0, 'b1000
  ADDI R2, R0, 'b1110
  BEQ R1, R2, 8; not taken (R1 != R2) so R1 becomes 1110
  ADDI R1, R0, 'b1110
  BEQ R1, R2, 8; taken (R1 == R2)
  ADDI R4, R0, 'b1; dead code
  ADDI R5, R0, 'b2; executed
  ```

## Waveform
  ![code waveform](./WaveCode.png)
  
 ## Partners

```
• Osaid Hamza     1200875
• Mohammad Odeh   1200089
• Mahmoud Hamdan  1201134
```
