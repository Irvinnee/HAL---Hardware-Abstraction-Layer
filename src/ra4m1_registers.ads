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
   PWPR_Address : constant Address := To_Address (16#4004_0D03#);

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

end RA4M1_Registers;
