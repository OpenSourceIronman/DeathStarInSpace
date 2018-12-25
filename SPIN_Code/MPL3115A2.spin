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