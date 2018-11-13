{{
''***********************************************************************************
''*  Title:                                                                         *
''*  TriColorLED.spin                                                               *
''*  This object allows for the color & duration control of a SMLP36RGB2W3 RGB LED. * 
''*  Author: Blaze Sanders [blaze.s.a.sanders@gmail.com]                            *
''*  Copyright (c) 2018                                                             *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the open source 100-002187-03 Interface Board hardware 
''*  allowing for the creation of 7 basic colors
''*  multi-language voice synthesizer that converts a stream of digital text into   *
''*  natural sounding speech. Please refer to the Emic 2 product manual for full    *
''*  details of functionality and capabilities.                                     *   
''*                                                                                 * 
''*  EMIC 2 subsystem circuit diagram can be found at:                              *
''*  http://www.parallax.com/downloads/emic-2-text-speech-module-schematic          *
''*                                                                                 *
''*  Green LED Anode or Cathode ────── 8 Ohm speaker positive terminal                               *
''*  P4      ────── Green LED  ────── GND (VSS)                              *                                                    
''*  SIN     ────── Pin X  Serial input from host. 3.3 to 5 V TTL-level interface *                                                        *
''*  SOUT    ────── Pin Y  Serial output to host. 5 V TTL-level interface         *                                                       *
''*  VCC     ────── +5V (VDD)                                                     *
''*  GND     ──────┐                                                               *
''*                                                                                *
''*                GND (VSS)                                                        *
''*                                                                                 *
''*  EMIC Max Power Draw: 5 V @ 220 mA  = 1.1 W                                     *
''*                                                                                 *             
''*  EMIC 2 datasheets can be found at:                                             *
''*  http://www.parallax.com/product/30016                                          *
''*                                                                                 *  
''*  Based off the EMIC2_Demo file by Joe Grand of Grandidea Studio                 *
''*  http://www.grandideastudio.com/portfolio/emic-2-text-to-speech-module/         *
''*  Revisions:                                                                     *
''*  - Mark I (November 12, 2018): Initial release                                     * 
 ''**********************************************************************************                                                        
}}

CON 'Global Constants

INFINITE = 9999999
OFF = 0
ON = 1

VAR 'Global Variables

'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
byte DEBUG_MODE

OBJ 'Additional files you would like imported / included   

'Used to output debugging statments to the Serial Terminal
'Custom PSP file updating http://obex.parallax.com/object/521 
DEBUG            : "GDB-SerialMirror"

'Used to control CPU clock timing functions
'Source URL - http://obex.parallax.com/object/173
TIMING           : "Clock"

''     Action: Initializes the EMIC2 hardware and firmware  
'' Parameters: duration - Total time LED is in the ON state 
''             flashingFreq - Frequecy in Hz that to cycle through an ON & OFF (0 Hz = constant ON)
''             voiceBaudRate - Voice data serial port baud rate                  
''    Results: Prepares the EMIC2 to start speaking                 
''+Reads/Uses: From Global Constants and Global Variables  ???                                              
''    +Writes: A lot of variables in the functions ???
'' Local Vars: None                                  
''      Calls: PST.Start(), PST.Str(), SERIAL.Start(), SERIAL.RxFlush(), SetVoice(), SendCommand()
''        URL: www.deathstarinspace.com/blog/SMLP36RGB2W3
PUB TurnOnRed(duration, flashingFreq)
mSecEslapsed = 0
while mSecEslapsed <= duration - mSecEslapsed 
  P5 = ON
  TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)
  P5 = OFF
  TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)
  mSecEslapsed += 1/flashingFreq

PUB TurnOnGreenLED()



PUB TurnOnBlueLED()



PUB TurnOnYellowLED()



PUB TurnOnLiteBluwLED()



PUB TurnOnPurpleLED()


PUB TurnOnWhiteLED()


PUB UnitTest

