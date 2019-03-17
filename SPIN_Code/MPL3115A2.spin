{{
''***********************************************************************************
''*  Title:                                                                         *
''*  MPL3115A2.spin                                                                 *
''*  This object allows the measurement of temp and pressure to calculate altitude. * 
''*  Author: Blaze Sanders [blaze.s.a.sanders@gmail.com]                            *
''*  Copyright (c) 2018                                                             *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the 23 x 23 x 2.2 mm, 1.3 gram, and 1350 Hz YEI 3-Space IMU *
''*  using a SPI or UART interface. Please refer to the YEI 3-Space product manual  *
''*  for full details of functionality and capabilities.                            *                                      
''*                                                                                 * 
''*  YEI 3-Space subsystem circuit diagram can be found at:                         *
''*  ???                  *
''*                                                                                 *
''*  SCK  ────── MicroController Pin # 3.3V TTL-level interface                   *
''*  MISO ────── MicroController Pin # 3.3V TTL-level interface                   *                                                   
''*  MOSI ────── MicroController Pin # 3.3V TTL-level interface                   *                                                        
''*  /SS  ────── MicroController Pin # 3.3V TTL-level interface                   *
''*  TxD  ────── MicroController Pin # 3.3V TTL-level interface                   *
''*  RxD  ────── MicroController Pin # 3.3V TTL-level interface                   *
''*  VCC  ────── +5V(VDD)                                                         *
''*  GND  ──────┐                                                                  *
''*                                                                                *
''*             GND (VSS)                                                           *
''*                                                                                 *
''*  YEI 3-Space Max Power Draw: 5 V @ 60 mA  = 0.3 W                               *
''*                                                                                 *             
''*  YEI 3-Space datasheets can be found at:                                        *
''*  yeitechnology.com/sites/default/files/YEI_TSS_Users_Manual_3.0_r1_4Nov2014.pdf *
''*                                                                                 *  
''*  Based off the ??? by ??? of ????                                               *
''*  www.                                                                           *
''*  Revisions:                                                                     *
''*  - Mark I (Dec 24, 2018): Initial release                                     * 
''***********************************************************************************                                                    
}}

CON 'Global Constants

  MPL3115A2_ADDRESS = 0h60     'Default I2C address 1100000


  'MPL3115A2 registers

  MPL3115A2_REGISTER_STATUS = 0h60      

  MPL3115A2_REGISTER_PRESSURE_MSB     =    (0x01),
  MPL3115A2_REGISTER_PRESSURE_CSB    =     (0x02),
  MPL3115A2_REGISTER_PRESSURE_LSB    =     (0x03),

  MPL3115A2_REGISTER_TEMP_MSB       =      (0x04),
  MPL3115A2_REGISTER_TEMP_LSB      =       (0x05),

  MPL3115A2_REGISTER_DR_STATUS     =       (0x06),

  MPL3115A2_OUT_P_DELTA_MSB        =       (0x07),
  MPL3115A2_OUT_P_DELTA_CSB        =       (0x08),
  MPL3115A2_OUT_P_DELTA_LSB        =       (0x09),

  MPL3115A2_OUT_T_DELTA_MSB        =       (0x0A),
  MPL3115A2_OUT_T_DELTA_LSB        =       (0x0B),

  MPL3115A2_WHOAMI            =            (0x0C),

  MPL3115A2_BAR_IN_MSB         =           (0x14),
  MPL3115A2_BAR_IN_LSB         =           (0x15),