{{
''***********************************************************************************
''*  Title:                                                                         *
''*  TriColorLED.spin                                                               *
''*  This object allows for the color & duration control of a SMLP36RGB2W3 RGB LED. * 
''*  Author: Blaze Sanders [deathstarinspace@gmail.com]                            *
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
'''  P6  ────── Blue LED Anode  Vf = 3.0 & Max Current draw = 4.9 mA              *
''*                                                                                 *
''*                                                                                 *
''*  LED Max Power Draw (all three colors on): 3.3 V @ 15 mA  = 0.049 W             *
''*                                                                                 *             
''*  SMLP36RGB2W3 datasheet can be found at:                                        * 
''*  https://www.rohm.com/datasheet/SMLP36RGB2W(R)                                  *
''*                                                                                 *  
''*  Revisions:                                                                     *
''*  - Mark I (March 13, 2019): Initial release                                     * 
''*  - Mark II (Apr 08, 2019): Refactored TurnOnRed(?, ?) to TurnOnLED(RED, ?, ?)   * 
''***********************************************************************************                                                        
}}

CON 'Global Constants

  STAY_ON = 4,294,967,295  'Max unsigned 32 bit value
  OFF = 0
  ON = 1
  LIGTHSABER_FREQ = 776    'Units of Hz
                          
  '--LED binary pin number constants--                        
  RED    = %010000 '= P5
  GREEN  = %001000 '= P4
  BLUE   = %100000 '= P6
  WHITE  = %111000 '= P5 + P4 +P6
  PURPLE = %110000 '= P5 + P6
  YELLOW = %011000 '= P5 + P4
  CYAN   = %101000 '= P6 + P4
                   '
                   '
VAR 'Global Variables

  'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
  byte DEBUG_MODE


OBJ 'Additional files you would like imported / included   

  'Used to control CPU clock timing functions
  'Source URL - http://obex.parallax.com/object/173
  TIMING           : "Clock"


PUB TurnOnLED(color, duration, flashingFreq) | mSecEslapsed

  ''     Action: Control color output of RGB LED 
  '' Parameters: color - Color of LED to change (on, off, flash, etc) 
  ''             duration - Total time LED is in the ON state 
  ''             flashingFreq - Frequecy in Hz that to cycle through an ON & OFF (0 Hz = constant ON)                            
  ''             TODO: Add brigthness control using duty cycle percentage 
  ''    Results: Turns on or off one of three LEDs to generate seven different colors                
  ''+Reads/Uses: ON and OFF global constants from this object 
  '' Local Vars: mSecEslapsed - Time in milliSecond that has pasted since function was last called                                 
  ''      Calls: TIMING.PauseMSec() 
  ''        URL: www.deathstarinspace.com/blog/SMLP36RGB2W3

  mSecEslapsed := 0
  if duration == STAY_ON
    OUT[color] = ON
    return
  else 
    while mSecEslapsed <= duration - mSecEslapsed 
      OUTA[color] = ON
      TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)  'TODO: Add duty cycle ON percentage 
      OUTA[color] = OFF
      TIMING.PauseMSec(1/(flashingFreq* 1_000)/2)  'TODO: Add duty cycle OFF percentage 
      mSecEslapsed += 1/flashingFreq
    
    TurnOffLED()'A specified duration of time has passed (i.e. NOT STAY ON)
    return
    
PUB TurnOffLED() 

  ''     Action: Control output status of RGB LED 
  '' Parameters: None
  ''    Results: Turns off all three LEDs, thus turning off all seven possible colors              
  ''+Reads/Uses: OFF global constants from this object 
  '' Local Vars: None
  ''      Calls: Nothing
  ''        URL: www.deathstarinspace.com/blog/SMLP36RGB2W3

  OUTA[RED] = OFF
  OUTA[GREEN] = OFF
  OUTA[BLUE] = OFF

 
PUB UnitTest() 'Test the control of RGB LED and sequencing of seven differnet colors
  
  'Test lower limit of human eye frame rate with 10 Hz flashing
  TurnOnLED(RED, 5, 10) 
  TurnOnLED(RED, 5, LIGTHSABER_FREQ)
  TurnOffLED()
  
  TurnOnLED(GREEN, STAY_ON, 30)
  TIMING.PauseSec(5) 
  TurnOffLED()
  
  TurnOnLED(BLUE, 2, 30)
  TIMING.PauseSec(5) 
  TurnOnLED(WHITE, 3, 60)
  TurnOffLED()
  
  TurnOnLED(PURPLE, 3, 60)
  TurnOnLED(CYAN, 3, 60)
  TurnOnLED(YELLOW, 3, 60)
  TurnOnLED(YELLOW, 9, 30)
  TurnOnLED(BLUE, 2, 120)
  TurnOnLED(BLUE, 2, 10)
  
  TurnOffLED