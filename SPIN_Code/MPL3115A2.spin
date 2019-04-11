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
''*  MPL3115A2 datasheets can be found at:                                        *
''*  https://www.deathstarinspace.com/blog/MPL3115A2 *
''*                                                                                 *  
''*  Based off the ??? by ??? of ????                                               *
''*  www.                                                                           *
''*  Revisions:                                                                     *
''*  - Mark I (Dec 24, 2018): Initial release                                     * 
''***********************************************************************************                                                    
}}

CON 'Global Constants

  MAX_DATA_COLLECTION_DURATION = 180 ' 180 data points
  
  MPL3115A2_ADDRESS = $60     'Default I2C address 1100000


  'MPL3115A2 registers
  MAX_NUM_OF_COMBINED_REGISTERS = 3
  
  MPL3115A2_REGISTER_STATUS = $60      

  MPL3115A2_REGISTER_PRESSURE_MSB = $01
  MPL3115A2_REGISTER_PRESSURE_CSB = $02
  MPL3115A2_REGISTER_PRESSURE_LSB = $03

  MPL3115A2_REGISTER_TEMP_MSB     =  $04
  MPL3115A2_REGISTER_TEMP_LSB     =  $05

  MPL3115A2_REGISTER_DR_STATUS    =  $06

  MPL3115A2_OUT_P_DELTA_MSB       =  $07
  MPL3115A2_OUT_P_DELTA_CSB       =  $08
  MPL3115A2_OUT_P_DELTA_LSB       =  $09

  MPL3115A2_OUT_T_DELTA_MSB       =  $0A
  MPL3115A2_OUT_T_DELTA_LSB       =  $0B

  MPL3115A2_WHOAMI                =  $0C

  MPL3115A2_BAR_IN_MSB            =  $14
  MPL3115A2_BAR_IN_LSB            =  $15
  
OBJ 'Additional files you would like imported / included   
 
  'Used to read and write data from the onboard 256KB EEPROM.
  I2C        : "Basic_I2C_Driver"
  'I2C        : "AD7706-2wire-fast"
  
  'Used to output debugging statments to the Serial Terminal
  'Custom PSP file updating http://obex.parallax.com/object/521 
  DEBUG         : "GDB-SerialMirror"
  
PUB Initialize


PUB GetTemperature(tempUnits) : temp  | rawData

  ''     Action: Get temperature as measured from inside Death Star on white core PCB  
  '' Parameters: tempUnits - Char variable to select which temperature units function will return                                 
  ''    Results: Uses I2C to get temperature information from MPL3115A2 IC                  
  ''Readds/Uses: TODO: MAX_DATA_COLLECTION_DURATION constant from the MPL3115A2.spin object                                               
  ''     Writes: To experimentData{} array if storeDataToMemory parameter EQUALS true
  '' Local Vars: rawData - Raw data read from MPL3115A2 register(s)
  ''Local Const: None                                 
  ''      Calls: ReadRegister(registerAddressMSB, numOfRegisters)
  ''        URL: https://www.deathstarinspace.com/blog/MPL3115A2

  case tempUnits
    "C": 'User selected degrees celsius 
    "c":
      rawData := ReadRegister(MPL3115A2_REGISTER_TEMP_MSB, 2)
      temp := rawData * 3  
    "F": 'User selected degrees fahrenheit
    "f": 
      'Stop     
    "K": 'User selected kelvin     
    "k":
      'Stop   
  
  return temp
  
PUB GetPressure(pressureUnits): pres
  'TODO DONT REPEAT CASE CODE ABOVE C, F, K, A, B, P, F, M
  return pres
  
PUB CalculateAltitude(altitudeUnits) : alt

  return alt
  
PRI ReadRegister(registerAddressMSB, numOfRegisters) | data[MAX_NUM_OF_COMBINED_REGISTERS], offset 
  
  repeat offset from 0 to (numOfRegisters - 1)
    data[offset] := I2C.Write(DEBUG#I2C_SCL, (registerAddressMSB + offset))
  
PRI WiteRegister(registerAddress)  

