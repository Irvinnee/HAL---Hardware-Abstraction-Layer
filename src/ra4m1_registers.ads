-- RA4M1 Register Definitions for GPIO
-- Based on Renesas RA4M1 Group User's Manual
-- These will be REPLACED by svd2ada generated files.
-- This is a FALLBACK if svd2ada is not yet run.

with System;
with System.Storage_Elements;

package RA4M1_Registers is
   pragma Preelaborate;

   use System;
   use System.Storage_Elements;

   -- ===========================================================
   -- Base type for register access
   -- ===========================================================
   type UInt8  is mod 2**8  with Size => 8;
   type UInt16 is mod 2**16 with Size => 16;
   type UInt32 is mod 2**32 with Size => 32;

   -- ===========================================================
   -- PORT registers (GPIO) - Renesas RA4M1
   -- Reference: RA4M1 User's Manual Section 19 "I/O Ports"
   -- ===========================================================

   -- Port base address: 0x4004_0000
   PORT_Base : constant Address := To_Address (16#4004_0000#);

   -- Port register offsets (per port number m = 0..9)
   -- Each port group occupies 0x20 bytes

   -- PCNTR1 (Port Control Register 1) - contains PDR and PODR
   --   PDR  [31:16] - Port Direction Register (0=input, 1=output)
   --   PODR [15:0]  - Port Output Data Register
   -- Offset: 0x0000 + (port * 0x0020)

   -- PCNTR2 (Port Control Register 2) - contains EIDR and PIDR
   --   EIDR [31:16] - Event Input Data Register
   --   PIDR [15:0]  - Port Input Data Register
   -- Offset: 0x0004 + (port * 0x0020)

   -- PCNTR3 (Port Control Register 3) - contains POSR and PORR
   --   POSR [31:16] - Port Output Set Register (write 1 = set pin HIGH)
   --   PORR [15:0]  - Port Output Reset Register (write 1 = set pin LOW)
   -- Offset: 0x0008 + (port * 0x0020)

   -- PCNTR4 (Port Control Register 4) - contains EOSR and EORR
   --   EOSR [31:16] - Event Output Set Register
   --   EORR [15:0]  - Event Output Reset Register
   -- Offset: 0x000C + (port * 0x0020)

   -- Port register record
   type Port_PCNTR1_Type is record
      PODR : UInt16;  -- bits [15:0]  - Port Output Data
      PDR  : UInt16;  -- bits [31:16] - Port Direction
   end record
     with Size => 32;

   for Port_PCNTR1_Type use record
      PODR at 0 range 0 .. 15;
      PDR  at 0 range 16 .. 31;
   end record;

   type Port_PCNTR2_Type is record
      PIDR : UInt16;  -- bits [15:0]  - Port Input Data
      EIDR : UInt16;  -- bits [31:16] - Event Input Data
   end record
     with Size => 32;

   for Port_PCNTR2_Type use record
      PIDR at 0 range 0 .. 15;
      EIDR at 0 range 16 .. 31;
   end record;

   type Port_PCNTR3_Type is record
      PORR : UInt16;  -- bits [15:0]  - Port Output Reset (write 1 = LOW)
      POSR : UInt16;  -- bits [31:16] - Port Output Set (write 1 = HIGH)
   end record
     with Size => 32;

   for Port_PCNTR3_Type use record
      PORR at 0 range 0 .. 15;
      POSR at 0 range 16 .. 31;
   end record;

   -- Full port register block
   type Port_Registers_Type is record
      PCNTR1 : Port_PCNTR1_Type;  -- +0x00: PDR + PODR
      PCNTR2 : Port_PCNTR2_Type;  -- +0x04: EIDR + PIDR
      PCNTR3 : Port_PCNTR3_Type;  -- +0x08: POSR + PORR
      PCNTR4 : UInt32;            -- +0x0C: EOSR + EORR
   end record
     with Size => 128;

   for Port_Registers_Type use record
      PCNTR1 at 16#00# range 0 .. 31;
      PCNTR2 at 16#04# range 0 .. 31;
      PCNTR3 at 16#08# range 0 .. 31;
      PCNTR4 at 16#0C# range 0 .. 31;
   end record;

   -- Port register access (volatile for hardware registers)
   type Port_Registers_Access is access all Port_Registers_Type;

   -- Calculate port register address
   -- Port m is at: PORT_Base + (m * 0x20)
   function Port_Address (Port_Num : Natural) return Address is
     (PORT_Base + Storage_Offset (Port_Num * 16#20#));

   -- Port registers mapped to memory (declare as volatile)
   PORT0 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (0);
   PORT1 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (1);
   PORT2 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (2);
   PORT3 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (3);
   PORT4 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (4);
   PORT5 : aliased Port_Registers_Type
     with Import, Volatile, Address => Port_Address (5);

   -- ===========================================================
   -- PFS (Pin Function Select) Register
   -- Controls pin function: GPIO, peripheral, analog, etc.
   -- Base: 0x4004_0800
   -- ===========================================================

   PFS_Base : constant Address := To_Address (16#4004_0800#);

   type PFS_Register_Type is record
      PODR  : Boolean;   -- bit 0:  Port Output Data
      PIDR  : Boolean;   -- bit 1:  Port Input Data
      PDR   : Boolean;   -- bit 2:  Port Direction (0=in, 1=out)
      Res3  : Boolean;   -- bit 3:  Reserved
      PCR   : Boolean;   -- bit 4:  Pull-up Control
      Res5  : Boolean;   -- bit 5:  Reserved
      NCODR : Boolean;   -- bit 6:  N-Channel Open Drain
      Res7  : Boolean;   -- bit 7:  Reserved
      Res8  : UInt8;     -- bits 8-15: Reserved
      PSEL  : UInt8;     -- bits 16-20: Peripheral Select
      Res21 : UInt8;     -- bits 21-23: Reserved
      PMR   : Boolean;   -- bit 24: Port Mode (0=GPIO, 1=peripheral)
      APTS  : Boolean;   -- bit 25: Analog Pin Type Select
      ISEL  : Boolean;   -- bit 26: IRQ Input Enable
      EOFR  : Boolean;   -- bit 27: Event on Falling/Rising
      Res28 : UInt8;     -- bits 28-31: Reserved
   end record
     with Size => 32;

   -- PFS register for port m, pin n:
   -- Address: PFS_Base + (m * 0x40) + (n * 0x04)
   function PFS_Address (Port_Num : Natural; Pin_Num : Natural) return Address is
     (PFS_Base + Storage_Offset (Port_Num * 16#40# + Pin_Num * 16#04#));

   -- PFSWE (PFS Write Enable) - must write 1 before modifying PFS
   -- PWPR is at address 0x4004_0D03 (8-bit register)
   --   Bit 6 (PFSWE): PFS Write Enable  (0=protect, 1=allow PFS writes)
   --   Bit 7 (B0WI):  PFSWE Write Inhibit (0=allow PFSWE change, 1=protect)
   --
   -- Unlock sequence: write 16#00# (clear B0WI), then write 16#40# (set PFSWE)
   -- Lock sequence:   write 16#00# (clear PFSWE), then write 16#80# (set B0WI)
   PWPR_Address : constant Address := To_Address (16#4004_0D03#);

   PWPR : aliased UInt8
     with Import, Volatile, Address => To_Address (16#4004_0D03#);

   PWPR_B0WI  : constant UInt8 := 16#80#;  -- bit 7
   PWPR_PFSWE : constant UInt8 := 16#40#;  -- bit 6

   -- ===========================================================
   -- MSTP (Module Stop) - clock gating for peripherals
   -- Must enable clocks before using any peripheral
   -- ===========================================================
   MSTP_Base : constant Address := To_Address (16#4001_E610#);

   -- MSTPCRB - for SCI (UART), AGT (Timer)
   MSTPCRB : aliased UInt32
     with Import, Volatile, Address => To_Address (16#4001_E618#);

   -- MSTPCRC - for ADC
   MSTPCRC : aliased UInt32
     with Import, Volatile, Address => To_Address (16#4001_E61C#);

   -- MSTPCRD - for AGT
   MSTPCRD : aliased UInt32
     with Import, Volatile, Address => To_Address (16#4001_E620#);

   -- ===========================================================
   -- SCI (Serial Communication Interface) - UART
   -- SCI0 base: 0x4007_0000
   -- ===========================================================

   SCI0_Base : constant Address := To_Address (16#4007_0000#);

   type SCI_Registers_Type is record
      SMR  : UInt8;   -- +0x00: Serial Mode Register
      BRR  : UInt8;   -- +0x01: Bit Rate Register
      SCR  : UInt8;   -- +0x02: Serial Control Register
      TDR  : UInt8;   -- +0x03: Transmit Data Register
      SSR  : UInt8;   -- +0x04: Serial Status Register
      RDR  : UInt8;   -- +0x05: Receive Data Register
      SCMR : UInt8;   -- +0x06: Smart Card Mode Register
      SEMR : UInt8;   -- +0x07: Serial Extended Mode Register
   end record
     with Size => 64;

   for SCI_Registers_Type use record
      SMR  at 0 range 0 .. 7;
      BRR  at 1 range 0 .. 7;
      SCR  at 2 range 0 .. 7;
      TDR  at 3 range 0 .. 7;
      SSR  at 4 range 0 .. 7;
      RDR  at 5 range 0 .. 7;
      SCMR at 6 range 0 .. 7;
      SEMR at 7 range 0 .. 7;
   end record;

   SCI0 : aliased SCI_Registers_Type
     with Import, Volatile, Address => SCI0_Base;

   -- SSR bit masks
   SSR_TDRE : constant UInt8 := 16#80#;  -- Transmit Data Register Empty
   SSR_RDRF : constant UInt8 := 16#40#;  -- Receive Data Register Full
   SSR_TEND : constant UInt8 := 16#04#;  -- Transmit End

   -- SCR bit masks
   SCR_TE   : constant UInt8 := 16#20#;  -- Transmit Enable
   SCR_RE   : constant UInt8 := 16#10#;  -- Receive Enable

   -- ===========================================================
   -- ADC14 (14-bit A/D Converter)
   -- ADC0 base: 0x4005_0000
   -- ===========================================================

   ADC0_Base : constant Address := To_Address (16#4005_0000#);

   type ADC_Registers_Type is record
      ADCSR   : UInt16;  -- +0x00: ADC Control/Status
      ADANSA0 : UInt16;  -- +0x04: Channel Select A0
      ADANSA1 : UInt16;  -- +0x06: Channel Select A1
      ADADS0  : UInt16;  -- +0x08: Addition/Average Select
      ADADS1  : UInt16;  -- +0x0A: Addition/Average Select 1
      ADADC   : UInt8;   -- +0x0C: Addition/Average Count
      ADCER   : UInt16;  -- +0x0E: Control Extension
      ADSTRGR : UInt16;  -- +0x10: Start Trigger Select
   end record;

   ADC0 : aliased ADC_Registers_Type
     with Import, Volatile, Address => ADC0_Base;

   -- ADC data registers (one per channel)
   -- ADDR0-ADDR7 at 0x4005_0020 + (channel * 2)
   function ADC_Data_Address (Channel : Natural) return Address is
     (ADC0_Base + 16#20# + Storage_Offset (Channel * 2));

   -- ADCSR bits
   ADCSR_ADST : constant UInt16 := 16#8000#;  -- Start conversion
   ADCSR_ADIF : constant UInt16 := 16#0040#;  -- Conversion complete flag

   -- ===========================================================
   -- NVIC (Nested Vectored Interrupt Controller) - ARM Cortex-M4
   -- Base: 0xE000_E100
   -- ===========================================================

   NVIC_Base : constant Address := To_Address (16#E000_E100#);

   -- ISER (Interrupt Set-Enable Registers) - 8 registers, 32 bits each
   -- ISER0: IRQ 0-31, ISER1: IRQ 32-63, etc.
   NVIC_ISER0 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E100#);
   NVIC_ISER1 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E104#);
   NVIC_ISER2 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E108#);
   NVIC_ISER3 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E10C#);

   -- ICER (Interrupt Clear-Enable Registers)
   NVIC_ICER0 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E180#);
   NVIC_ICER1 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E184#);
   NVIC_ICER2 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E188#);
   NVIC_ICER3 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E18C#);

   -- ISPR (Interrupt Set-Pending Registers)
   NVIC_ISPR0 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E200#);

   -- ICPR (Interrupt Clear-Pending Registers)
   NVIC_ICPR0 : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E280#);

   -- IPR (Interrupt Priority Registers) - 8 bits per IRQ
   -- IPR0 at 0xE000_E400, each byte = priority of one IRQ
   NVIC_IPR_Base : constant Address := To_Address (16#E000_E400#);

   -- SCB (System Control Block)
   SCB_AIRCR : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_ED0C#);
   SCB_SCR : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_ED10#);

   -- SCR bits
   SCR_SLEEPDEEP : constant UInt32 := 16#0000_0004#;  -- Deep sleep enable
   SCR_SLEEPONEXIT : constant UInt32 := 16#0000_0002#;  -- Sleep on ISR exit

   -- SysTick (System Timer)
   SYST_CSR : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E010#);
   SYST_RVR : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E014#);
   SYST_CVR : aliased UInt32
     with Import, Volatile, Address => To_Address (16#E000_E018#);

   -- SysTick bits
   SYST_CSR_ENABLE    : constant UInt32 := 16#0000_0001#;
   SYST_CSR_TICKINT   : constant UInt32 := 16#0000_0002#;
   SYST_CSR_CLKSOURCE : constant UInt32 := 16#0000_0004#;
   SYST_CSR_COUNTFLAG : constant UInt32 := 16#0001_0000#;

   -- ===========================================================
   -- ICU (Interrupt Controller Unit) - RA4M1 specific
   -- Maps peripheral events to NVIC IRQ numbers
   -- Base: 0x4006_1000
   -- ===========================================================

   ICU_Base : constant Address := To_Address (16#4006_1000#);

   -- IRQCR (IRQ Control Registers) - for external pin interrupts
   -- IRQCR0..IRQCR15 at ICU_Base + n*4
   function IRQCR_Address (N : Natural) return Address is
     (ICU_Base + Storage_Offset (N * 4));

   -- IRQ detection sense
   --   00: Falling edge
   --   01: Rising edge
   --   10: Both edges
   --   11: Low level

   -- ===========================================================
   -- SPI (Serial Peripheral Interface) - uses SCI in SPI mode
   -- SCI0 in SPI mode: same registers, different SMR config
   -- SCI1 base: 0x4007_0020
   -- SCI2 base: 0x4007_0040
   -- ===========================================================

   SCI1_Base : constant Address := To_Address (16#4007_0020#);
   SCI2_Base : constant Address := To_Address (16#4007_0040#);
   SCI9_Base : constant Address := To_Address (16#4007_0120#);

   SCI1 : aliased SCI_Registers_Type
     with Import, Volatile, Address => SCI1_Base;
   SCI2 : aliased SCI_Registers_Type
     with Import, Volatile, Address => SCI2_Base;
   SCI9 : aliased SCI_Registers_Type
     with Import, Volatile, Address => SCI9_Base;

   -- SMR bits for SPI mode
   SMR_CM : constant UInt8 := 16#80#;  -- Communication Mode (1=clock sync/SPI)

   -- SCR bits for SPI
   SCR_CKE : constant UInt8 := 16#03#;  -- Clock Enable bits

   -- SPMR (SPI Mode Register) - SCI-specific extension for SPI
   -- Located at SCI base + 0x0D
   -- Not in the base SCI_Registers_Type, access separately

   -- ===========================================================
   -- IIC (I2C) - RA4M1 has dedicated IIC module
   -- IIC0 base: 0x4005_3000
   -- IIC1 base: 0x4005_3100
   -- ===========================================================

   IIC0_Base : constant Address := To_Address (16#4005_3000#);
   IIC1_Base : constant Address := To_Address (16#4005_3100#);

   type IIC_Registers_Type is record
      ICCR1  : UInt8;   -- +0x00: I2C Bus Control Register 1
      ICCR2  : UInt8;   -- +0x01: I2C Bus Control Register 2
      ICMR1  : UInt8;   -- +0x02: I2C Bus Mode Register 1
      ICMR2  : UInt8;   -- +0x03: I2C Bus Mode Register 2
      ICMR3  : UInt8;   -- +0x04: I2C Bus Mode Register 3
      ICFER  : UInt8;   -- +0x05: I2C Bus Function Enable Register
      ICSER  : UInt8;   -- +0x06: I2C Bus Status Enable Register
      ICIER  : UInt8;   -- +0x07: I2C Bus Interrupt Enable Register
      ICSR1  : UInt8;   -- +0x08: I2C Bus Status Register 1
      ICSR2  : UInt8;   -- +0x09: I2C Bus Status Register 2
      SARL0  : UInt8;   -- +0x0A: Slave Address Register L0
      SARU0  : UInt8;   -- +0x0B: Slave Address Register U0
      SARL1  : UInt8;   -- +0x0C: Slave Address Register L1
      SARU1  : UInt8;   -- +0x0D: Slave Address Register U1
      SARL2  : UInt8;   -- +0x0E: Slave Address Register L2
      SARU2  : UInt8;   -- +0x0F: Slave Address Register U2
      ICBRL  : UInt8;   -- +0x10: I2C Bus Bit Rate Low Register
      ICBRH  : UInt8;   -- +0x11: I2C Bus Bit Rate High Register
      ICDRT  : UInt8;   -- +0x12: I2C Bus Transmit Data Register
      ICDRR  : UInt8;   -- +0x13: I2C Bus Receive Data Register
   end record
     with Size => 160;

   for IIC_Registers_Type use record
      ICCR1  at 16#00# range 0 .. 7;
      ICCR2  at 16#01# range 0 .. 7;
      ICMR1  at 16#02# range 0 .. 7;
      ICMR2  at 16#03# range 0 .. 7;
      ICMR3  at 16#04# range 0 .. 7;
      ICFER  at 16#05# range 0 .. 7;
      ICSER  at 16#06# range 0 .. 7;
      ICIER  at 16#07# range 0 .. 7;
      ICSR1  at 16#08# range 0 .. 7;
      ICSR2  at 16#09# range 0 .. 7;
      SARL0  at 16#0A# range 0 .. 7;
      SARU0  at 16#0B# range 0 .. 7;
      SARL1  at 16#0C# range 0 .. 7;
      SARU1  at 16#0D# range 0 .. 7;
      SARL2  at 16#0E# range 0 .. 7;
      SARU2  at 16#0F# range 0 .. 7;
      ICBRL  at 16#10# range 0 .. 7;
      ICBRH  at 16#11# range 0 .. 7;
      ICDRT  at 16#12# range 0 .. 7;
      ICDRR  at 16#13# range 0 .. 7;
   end record;

   IIC0 : aliased IIC_Registers_Type
     with Import, Volatile, Address => IIC0_Base;
   IIC1 : aliased IIC_Registers_Type
     with Import, Volatile, Address => IIC1_Base;

   -- ICCR1 bits
   ICCR1_ICE    : constant UInt8 := 16#80#;  -- I2C Bus Interface Enable
   ICCR1_IICRST : constant UInt8 := 16#40#;  -- I2C Bus Interface Reset
   ICCR1_CLO    : constant UInt8 := 16#20#;  -- Extra SCL Clock Output
   ICCR1_SOWP   : constant UInt8 := 16#10#;  -- SCLO/SDAO Write Protect

   -- ICCR2 bits
   ICCR2_ST  : constant UInt8 := 16#02#;  -- Start Condition
   ICCR2_RS  : constant UInt8 := 16#04#;  -- Restart Condition
   ICCR2_SP  : constant UInt8 := 16#08#;  -- Stop Condition
   ICCR2_TRS : constant UInt8 := 16#20#;  -- Transmit/Receive Select (1=Tx)
   ICCR2_MST : constant UInt8 := 16#40#;  -- Master/Slave Select (1=Master)
   ICCR2_BBSY : constant UInt8 := 16#80#; -- Bus Busy

   -- ICSR2 bits
   ICSR2_TDRE : constant UInt8 := 16#80#;  -- Transmit Data Empty
   ICSR2_RDRF : constant UInt8 := 16#20#;  -- Receive Data Full
   ICSR2_NACKF : constant UInt8 := 16#10#; -- NACK detected
   ICSR2_STOP : constant UInt8 := 16#08#;  -- Stop detected
   ICSR2_START : constant UInt8 := 16#04#; -- Start detected

   -- ICIER bits
   ICIER_TIE  : constant UInt8 := 16#80#;  -- Transmit IRQ enable
   ICIER_TEIE : constant UInt8 := 16#40#;  -- Transmit End IRQ enable
   ICIER_RIE  : constant UInt8 := 16#20#;  -- Receive IRQ enable
   ICIER_NAKIE : constant UInt8 := 16#10#; -- NACK IRQ enable
   ICIER_STIE : constant UInt8 := 16#08#;  -- Stop IRQ enable

   -- ICMR3 bits
   ICMR3_WAIT : constant UInt8 := 16#40#;  -- Wait
   ICMR3_ACKWP : constant UInt8 := 16#10#; -- ACKBT Write Protect
   ICMR3_ACKBT : constant UInt8 := 16#08#; -- ACK Bit (0=ACK, 1=NACK)

   -- ===========================================================
   -- AGT (Asynchronous General Purpose Timer)
   -- AGT0 base: 0x4008_4000
   -- AGT1 base: 0x4008_4100
   -- ===========================================================

   AGT0_Base : constant Address := To_Address (16#4008_4000#);
   AGT1_Base : constant Address := To_Address (16#4008_4100#);

   type AGT_Registers_Type is record
      AGT    : UInt16;  -- +0x00: AGT Counter Register (16-bit)
      AGTCMA : UInt16;  -- +0x02: AGT Compare Match A Register
      AGTCMB : UInt16;  -- +0x04: AGT Compare Match B Register
      Pad1   : UInt16;  -- +0x06: Reserved
      AGTCR  : UInt8;   -- +0x08: AGT Control Register
      AGTMR1 : UInt8;   -- +0x09: AGT Mode Register 1
      AGTMR2 : UInt8;   -- +0x0A: AGT Mode Register 2
      Pad2   : UInt8;   -- +0x0B: Reserved
      AGTIOC : UInt8;   -- +0x0C: AGT I/O Control Register
      AGTISR : UInt8;   -- +0x0D: AGT Event Pin Select Register
      AGTCMSR : UInt8;  -- +0x0E: AGT Compare Match Function Select
      AGTIOSEL : UInt8; -- +0x0F: AGT Pin Select Register
   end record
     with Size => 128;

   for AGT_Registers_Type use record
      AGT      at 16#00# range 0 .. 15;
      AGTCMA   at 16#02# range 0 .. 15;
      AGTCMB   at 16#04# range 0 .. 15;
      Pad1     at 16#06# range 0 .. 15;
      AGTCR    at 16#08# range 0 .. 7;
      AGTMR1   at 16#09# range 0 .. 7;
      AGTMR2   at 16#0A# range 0 .. 7;
      Pad2     at 16#0B# range 0 .. 7;
      AGTIOC   at 16#0C# range 0 .. 7;
      AGTISR   at 16#0D# range 0 .. 7;
      AGTCMSR  at 16#0E# range 0 .. 7;
      AGTIOSEL at 16#0F# range 0 .. 7;
   end record;

   AGT0_Regs : aliased AGT_Registers_Type
     with Import, Volatile, Address => AGT0_Base;
   AGT1_Regs : aliased AGT_Registers_Type
     with Import, Volatile, Address => AGT1_Base;

   -- AGTCR bits
   AGTCR_TSTART : constant UInt8 := 16#01#;  -- Timer Start
   AGTCR_TCSTF  : constant UInt8 := 16#02#;  -- Timer Count Status Flag
   AGTCR_TSTOP  : constant UInt8 := 16#04#;  -- Timer Stop
   AGTCR_TEDGF  : constant UInt8 := 16#08#;  -- Edge Flag
   AGTCR_TUNDF  : constant UInt8 := 16#10#;  -- Underflow Flag
   AGTCR_TCMAF  : constant UInt8 := 16#20#;  -- Compare Match A Flag
   AGTCR_TCMBF  : constant UInt8 := 16#40#;  -- Compare Match B Flag

   -- AGTIOC bits
   AGTIOC_TOE   : constant UInt8 := 16#04#;  -- Timer Output Enable

   -- AGTMR1 bits
   -- TMOD[2:0]: Timer Mode
   --   000: Timer mode
   --   001: Pulse output mode
   --   010: Event counter mode
   --   011: Pulse width measurement mode
   --   100: Pulse period measurement mode
   -- TCK[6:4]: Count Source
   --   000: PCLKB
   --   001: PCLKB/8
   --   011: PCLKB/2
   --   100: AGTLCLK (subclock)
   --   101: AGT0 underflow
   --   110: AGTSCLK subclock

   -- ===========================================================
   -- RTC (Real Time Clock)
   -- Base: 0x4004_4000
   -- ===========================================================

   RTC_Base : constant Address := To_Address (16#4004_4000#);

   -- RTC registers (BCD format by default)
   type RTC_Registers_Type is record
      R64CNT  : UInt8;    -- +0x00: 64-Hz Counter
      Pad1    : UInt8;    -- +0x01
      RSECCNT : UInt8;    -- +0x02: Second Counter (BCD 0-59)
      Pad2    : UInt8;    -- +0x03
      RMINCNT : UInt8;    -- +0x04: Minute Counter (BCD 0-59)
      Pad3    : UInt8;    -- +0x05
      RHRCNT  : UInt8;    -- +0x06: Hour Counter (BCD 0-23)
      Pad4    : UInt8;    -- +0x07
      RWKCNT  : UInt8;    -- +0x08: Day-of-Week Counter (0-6)
      Pad5    : UInt8;    -- +0x09
      RDAYCNT : UInt8;    -- +0x0A: Day Counter (BCD 1-31)
      Pad6    : UInt8;    -- +0x0B
      RMONCNT : UInt8;    -- +0x0C: Month Counter (BCD 1-12)
      Pad7    : UInt8;    -- +0x0D
      RYRCNT  : UInt16;   -- +0x0E: Year Counter (BCD 0-99)
      RSECAR  : UInt8;    -- +0x10: Second Alarm
      Pad8    : UInt8;    -- +0x11
      RMINAR  : UInt8;    -- +0x12: Minute Alarm
      Pad9    : UInt8;    -- +0x13
      RHRAR   : UInt8;    -- +0x14: Hour Alarm
      Pad10   : UInt8;    -- +0x15
      RWKAR   : UInt8;    -- +0x16: Day-of-Week Alarm
      Pad11   : UInt8;    -- +0x17
      RDAYAR  : UInt8;    -- +0x18: Day Alarm
      Pad12   : UInt8;    -- +0x19
      RMONAR  : UInt8;    -- +0x1A: Month Alarm
      Pad13   : UInt8;    -- +0x1B
      RYRAR   : UInt16;   -- +0x1C: Year Alarm
      RYRAREN : UInt8;    -- +0x1E: Year Alarm Enable
      Pad14   : UInt8;    -- +0x1F
   end record;

   for RTC_Registers_Type use record
      R64CNT  at 16#00# range 0 .. 7;
      Pad1    at 16#01# range 0 .. 7;
      RSECCNT at 16#02# range 0 .. 7;
      Pad2    at 16#03# range 0 .. 7;
      RMINCNT at 16#04# range 0 .. 7;
      Pad3    at 16#05# range 0 .. 7;
      RHRCNT  at 16#06# range 0 .. 7;
      Pad4    at 16#07# range 0 .. 7;
      RWKCNT  at 16#08# range 0 .. 7;
      Pad5    at 16#09# range 0 .. 7;
      RDAYCNT at 16#0A# range 0 .. 7;
      Pad6    at 16#0B# range 0 .. 7;
      RMONCNT at 16#0C# range 0 .. 7;
      Pad7    at 16#0D# range 0 .. 7;
      RYRCNT  at 16#0E# range 0 .. 15;
      RSECAR  at 16#10# range 0 .. 7;
      Pad8    at 16#11# range 0 .. 7;
      RMINAR  at 16#12# range 0 .. 7;
      Pad9    at 16#13# range 0 .. 7;
      RHRAR   at 16#14# range 0 .. 7;
      Pad10   at 16#15# range 0 .. 7;
      RWKAR   at 16#16# range 0 .. 7;
      Pad11   at 16#17# range 0 .. 7;
      RDAYAR  at 16#18# range 0 .. 7;
      Pad12   at 16#19# range 0 .. 7;
      RMONAR  at 16#1A# range 0 .. 7;
      Pad13   at 16#1B# range 0 .. 7;
      RYRAR   at 16#1C# range 0 .. 15;
      RYRAREN at 16#1E# range 0 .. 7;
      Pad14   at 16#1F# range 0 .. 7;
   end record;

   RTC : aliased RTC_Registers_Type
     with Import, Volatile, Address => RTC_Base;

   -- RTC Control registers (outside the main block)
   RCR1_Address : constant Address := To_Address (16#4004_4020#);
   RCR2_Address : constant Address := To_Address (16#4004_4022#);
   RCR3_Address : constant Address := To_Address (16#4004_4024#);
   RCR4_Address : constant Address := To_Address (16#4004_4026#);

   RCR1 : aliased UInt8 with Import, Volatile, Address => RCR1_Address;
   RCR2 : aliased UInt8 with Import, Volatile, Address => RCR2_Address;
   RCR3 : aliased UInt8 with Import, Volatile, Address => RCR3_Address;
   RCR4 : aliased UInt8 with Import, Volatile, Address => RCR4_Address;

   -- RCR1 bits
   RCR1_AIE : constant UInt8 := 16#01#;  -- Alarm Interrupt Enable
   RCR1_CIE : constant UInt8 := 16#02#;  -- Carry Interrupt Enable
   RCR1_PIE : constant UInt8 := 16#04#;  -- Periodic Interrupt Enable

   -- RCR2 bits
   RCR2_START : constant UInt8 := 16#01#;  -- Start (1=counting)
   RCR2_RESET : constant UInt8 := 16#02#;  -- Reset
   RCR2_CNTMD : constant UInt8 := 16#80#;  -- Count Mode (0=BCD, 1=binary)

   -- ===========================================================
   -- SYSTEM (System Control) - for sleep/standby modes
   -- Base: 0x4001_E000
   -- ===========================================================

   SYSTEM_Base : constant Address := To_Address (16#4001_E000#);

   -- SBYCR (Standby Control Register) at 0x4001_E00C
   SBYCR : aliased UInt16
     with Import, Volatile, Address => To_Address (16#4001_E00C#);

   -- SBYCR bits
   SBYCR_SSBY : constant UInt16 := 16#8000#;  -- Software Standby (1=standby)
   SBYCR_OPE  : constant UInt16 := 16#4000#;  -- Output Port Enable in standby

   -- SNZCR (Snooze Control Register) at 0x4001_E800
   SNZCR : aliased UInt8
     with Import, Volatile, Address => To_Address (16#4001_E800#);

   -- MSTPCRA - for ports, DMA, etc.
   MSTPCRA : aliased UInt32
     with Import, Volatile, Address => To_Address (16#4001_E610#);

end RA4M1_Registers;
