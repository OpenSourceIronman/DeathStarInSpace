{{
''***********************************************************************************
''*  Title:                                                                         *
''*  OPV300.spin                                                                    *
''*  With this object you can control the on & off state on a OV300 laser diode.    *
''*  Author: Blaze Sanders [blaze.sanders@solarsystemexpress.com]                   *
''*  Copyright (c) 2015 PongSat Parts LLC                                           *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the duration and power of OPV300 laser diodes, by           *
''*  controlling the amount of current sourced to the laser diodes through a MOSFET *
''*  transistor via a 100 Hz Pulse Width Modulated signal.                          *
''*                                                                                 *
''*  A circuit diagram with a OPV300 can be found at:                               * 
''*  https://upverter.com/META.Blaze/5e7beb8b16d39c0e/DSIL-Mark-I/                  *
''*                                                                                 *
''*  www.electro-tech-online.com/imgcache/10173-571px-mosfet_n-ch_circuit.svg.png   *
''*                                                                                 *
''*  INSET CIRCUIT HERE???                                                          *
''*                                                                                 *
''*                                                                                 *
''*  OPV300 Max Power Draw: 5 V @ 250 mA  = 1.25 W                                  *
''*                                                                                 *
''*  OPV300 Datasheet can be found at:                                              *
''*  http://www.wavespectrum-laser.com/product/productInfo_36.html                                                                               *
''*                                                                                 *
''*  Revision:                                                                      *
''*  - Mark I (March 18, 2015): Initial release                                     * 
 ''********************************************************************************** 

''***********************************************************************************                                                        



''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the open source hardware of the EMIC2 Text to Voice         *
''*  multi-language voice synthesizer that converts a stream of digital text into   *
''*  natural sounding speech. Please refer to the Emic 2 product manual for full    *
''*  details of functionality and capabilities.                                     *   
''*                                                                                 * 
''*  EMIC 2 circuit diagram can be found at:                                        *
''*  http://www.parallax.com/downloads/emic-2-text-speech-module-schematic          *
''*                                                                                 *
''*  SP+     ────── 8 Ohm speaker positive terminal                               *
''*  SP-     ────── 8 Ohm speaker negative terminal                               *                                                    
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
                                                      

     


                                        Suggested Circuit (Sol-X)
                            
  ┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬ (anade) LASER DIODE (cathode) ─┬       
  │   │   │   │   │   │   │   │   │   │   │   │                                │
                                     (Twelve 1300 Ohm resistors)   │                                                                                             
  │   │   │   │   │   │   │   │   │   │   │   │                                │                                                                           
  ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻   ┻                                 
  P0  P1  P2  P3  P4  P5  P6  P7  P8  P9  P10 P11                             0v                                              

}}

CON 'Global Constants 

  '---Useful constants--- 
  HIGH = 1
  LOW = 0

  OUTPUT = 1
  INPUT = 0

  LASER_DRIVER_PIN = 3
  LASER_MOSFET_PIN = 4

VAR

  'Boolean variable holding the state of the self destruct button
  byte selfDestruct 

  'Boolean variable monitoring the location of Luke SkyWalker near the Death Star   
  byte lukeSkyWalker 

OBJ

  'Used to output debugging statments to the Serial Terminal
  'Custom PSP file updating http://obex.parallax.com/object/521 
  DEBUG            : "GDB-SerialMirror"

  'Used to control CPU clock timing functions
  'Source URL - http://obex.parallax.com/object/173
  TIMING           : "Clock"

PUB Start

  Initialize
{{ 
  goodFire := true
  while (not goodFire)
    goodFire := Fire(100, 2)
}}

PUB Initialize 'Initializes all the laser diodes

  selfDestruct := false
  lukeSkyWalker := false    

PUB Fire(powerPercentage, duration) : laserFired | i, j, onTime, offTime 'Turns on a 1.5 mW OPV300 laser diode

  ''     Action: Turns on a 1.5 mW OPV300 laser diode      
  '' Parameters: powerPercentage -   
  ''             Duration - Time is seconds the laser should stay on
  ''             NumberOfPins - Number of (12 / NumberOfPins) mA I/O pins connected to laser diode (1 to 12)                             
  ''    Results: Moons get destoryed (hopefully)                      
  ''+Reads/Uses: None                                               
  ''    +Writes: None
  '' Local Vars: None                                     
  ''      Calls: None
  ''        URL: http://www.solarsystemexpress.com/death-star-in-leo.html

  if (selfDestruct == true OR lukeSkyWalker == true )
    laserFired := false

  else
    if(powerPercentage < 10 OR powerPercentage > 100 )
      laserFired := false

      DEBUG.Str(STRING("Power percentage must be equal to or greater than 10% and less than or equal to 100%", DEBUG#CR))
      DEBUG.Str(STRING("Fire misfunction!", DEBUG#CR)) 
    else
      laserFired := true
    
      'Power UP with 100 Hz PWM 
      onTime := powerPercentage / 10   'units mS
      offTime := 10 - onTime           'units mS
      DIRA[LASER_DRIVER_PIN] := OUTPUT  
    Repeat i from 1 to duration
      Repeat j from 1 to 10
        OUTA[LASER_DRIVER_PIN] := HIGH
        TIMING.PauseuSec(onTime*100)
        OUTA[LASER_MOSFET_PIN] := LOW   
        TIMING.PauseSec(offTime*100)
      
  return laserFired

PUB SetLukeSkyWalkersNearDeathStar(location) : islukeSkyWalkerNear 

  ''     Action: Determines whether Luke SkyWalker is closer by :)     
  '' Parameters: location - Boolean variable of Luke SkyWalker;s presence on DS-1                        
  ''    Results: Returns true if Luke SkyWalker is nearby causing Death Star to explode                      
  ''+Reads/Uses: None                                               
  ''    +Writes: None
  '' Local Vars: None                                     
  ''      Calls: None
  ''        URL: https://youtu.be/qniy8aDSFLA

  if (location)
    islukeSkyWalkerNear := true
  else
    islukeSkyWalkerNear := false

  return islukeSkyWalkerNear   

PUB SetSelfDestructButton(state)

  return selfDestruct := state

PUB SendMorseCode(Char)

  case Char
    "A": 

PRI UnitTest

  'Morse Code for "S" - 3 shorts
  Fire(50, 1)
  Fire(50, 1)
  Fire(50, 1)

  SetLukeSkyWalkersNearDeathStar(false)

  'Morse Code for "O" - 3 longs  
  Fire(50, 2)
  Fire(50, 2)
  Fire(50, 2)

  'Morse Code for "S" - 3 shorts  
  Fire(50, 1)
  Fire(50, 1)
  Fire(50, 1)'

  SetLukeSkyWalkersNearDeathStar(true)

  Fire(100, 3) 'Should not fire

  SetLukeSkyWalkersNearDeathStar(false)

  Fire(25, 4) 'Should not fire

  SetSelfDestructButton(true)

  Fire(75, 5) 'Should not fire

  return

{{

┌───────────────────────────────────────────────────────────────────────────┐
│               Terms of use: MIT License                                   │
├───────────────────────────────────────────────────────────────────────────┤ 
│  Permission is hereby granted, free of charge, to any person obtaining a  │
│ copy of this software and associated documentation files (the "Software"),│
│ to deal in the Software without restriction, including without limitation │
│ the rights to use, copy, modify, merge, publish, distribute, sublicense,  │
│   and/or sell copies of the Software, and to permit persons to whom the   │
│   Software is furnished to do so, subject to the following conditions:    │
│                                                                           │
│  The above copyright notice and this permission notice shall be included  │
│          in all copies or substantial portions of the Software.           │
│                                                                           │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR │
│ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE│
│  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER   │
│ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING   │
│   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER     │
│                      DEALINGS IN THE SOFTWARE.                            │
└───────────────────────────────────────────────────────────────────────────┘ 

}}