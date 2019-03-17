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
''*  This code controls the Death Star in Space 100-002187-03 Interface PCB allowing*  
''*  for the creation of 7 colors (Red, Green, Blue, Yellow, Cyan, Purple, & White) *
''*                                                                                 *            
''*  100-002187-03 circuit diagram can be found at:                                 *
''*  https://www.deathstarinspace.com/engineering                                   *
''*                                                                                 *
''*  P4  ────── Green LED Anode Vf = 3.1 & Max Current Draw = 4.9 mA              *
''*  P5  ────── Red LED Anode   Vf = 2.1 & Max Current draw = 5.0 mA              *
'''  P4  ────── Blue LED Anode  Vf = 3.0 & Max Current draw = 4.9 mA              *
''*                                                                                 *
''*                                                                                 *
''*  LED Max Power Draw (all three colors on): 3.3 V @ 15 mA  = 0.049 W             *
''*                                                                                 *             
''*  SMLP36RGB2W3 datasheet can be found at:                                        * 
''*  https://www.rohm.com/datasheet/SMLP36RGB2W(R)                                  *
''*                                                                                 *  
''*  Revisions:                                                                     *
''*  - Mark I (March 13, 2019): Initial release                                  * 
 ''**********************************************************************************                                                        
}}

CON 'Global Constants

INFINITE = 4,294,967,295  '(Max unsigned 32 bit value)
OFF = 0
ON = 1
LIGTHSABER_FREQ = 776     'Units of Hz 

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


PUB TurnOnRed(duration, flashingFreq) | mSecEslapsed
{{
mSecEslapsed := 0
while mSecEslapsed <= duration - mSecEslapsed 
  P5 = ON
  TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)
  P5 = OFF
  TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)
  mSecEslapsed += 1/flashingFreq
  
TurnOffAll()  
  
PUB TurnOffRed()

PUB TurnOnGreen()



PUB TurnOnBlue()



PUB TurnOnYellow()



PUB TurnOnLiteBlue()



PUB TurnOnPurple()


PUB TurnOnWhite()

PUB TurnOffAll()
PUB UnitTest
}}