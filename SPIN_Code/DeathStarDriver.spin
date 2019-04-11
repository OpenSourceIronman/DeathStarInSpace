{{
''************************************************************************************
''*  Title:                                                                          *
''*  DeathStarDriver.spin                                                            *
''*  Death Star program operation starts from the Main function in this file.        *
''*  Author: Blaze Sanders [deathstarinspace@gmail.com]                              *
''*  See end of file for terms of use.                                               *
''************************************************************************************
''*  Brief Description:                                                              *
''*  Number of cogs/CPU's used: ???6??? out of 8                                     *
''*                                                                                  *   
''*  This code controls the open source hardware of the Death Star is Space project  *
''*  creating a high level API for the control of the following pieces of hardware:  *
''*  1) One CMU5 Camera - VGA resolution (640x480) at 13 fps (2 COGS)                *    
''*  2) One WSLD-650-180m-1 LASER diode - 650 nm, 180 mW and upto 2.5 Gbps           *
''*  3) Three NCTR-M002 Magnetorquer Rods - Magnetic moment> 0.2 Am^2 at 200mW & 5V  *
''*  4) One ESP-12S wireless transceiver - 2.4 GHz @ distances up to ?300? meters    *
''*  5) Thirty solar panels - Recharging at 9V and 2500 mA & laser detection sensor  *
''*  6) One YEI 3-Space IMU - 9 axis, 850 Hz with quaternion-based QCOMP AHRS        *
''*  7) One EMIC2 - Text to voice conversion with custom and 9 static voices types   *                                                             
''*                                                                                  *
''*  Death Star Max Power Draw: 5 Volts @ 4000 mA  = 20 Watts                        *
''*                                                                                  *                                                 
''*  The Death Star plans, datasheets, and circuit diagram can be found at:          *
''*  www.deathstarinspace.com/engneering                                             *                                        
''*                                                                                  * 
''*  Revisions:                                                                      *
''*  - Mark I   (March 15, 2015): Initial release                                    *
''*  - Mark II  (August 1, 2016): Documentation update and questions marks added     *
''*  - Mark III (November 12, 2018): Implemented all 2018 MDR code requirements      * 
''*  - Mark IV  (April 10, 2019): Kickstarter update to fix major compiler errors :) *
''************************************************************************************                                                        
}}
VAR 'Global variables  

  'Stores the number of the cog / CPU running this object (0 to 7) 
  byte  cog

  'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
  'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
  long  DeathStarStackPointer[128]

  'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
  byte DEBUG_MODE

  'Boolean variable with the status of laser target Planet Alderaan (or Earth)
  byte targetDestoryed

  'Array variable with three axis direction to target
  byte targetPostion[3]

  'Boolean three axis target lock status   
  byte targetLocked[3]

  'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
  'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
  long EMIC2_StackPointer[100]
  long IMU_StackPointer[100]
  long LASER_StackPointer[100]
  long STEM_CodeStackPointer[100]

CON 'Global Constants

  'Standard clock mode * crystal frequency = 16 * 5 MHz = 80 MHz
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  'Connect / snyc to Android devices at USB 1.1 frequency of 96 MHz
  USB_Crystal = 6_000_000
  _USB_Clock_Mode = USB_Crystal * PLL16x
  
  '----General useful constants---- 
  HIGH = 1
  LOW = 0
  OUTPUT = 1
  INPUT = 0
  
  '----Aerospace constants----     
  MECO_ALTITUDE = 100_000         'Main Engine Cut Off altitude in meters
  SPACEPORT_AMERICA_PAD_MSL = 10  'Mean Sea Level of launch pad at Spaceport America in New Mexico
  ATLANTIC_OCEAN_MSL = 0          'Mean Sea Level of Atlantic Ocen off the coast of Florida
  LAUNCH_ACCELERATION_TRIGGER_LEVEL = 3 'G's = 29.43 m/s^2
                                         
  '---LASER constants---
  FULL_POWER = 100
  HALF_POWER = 50
  
  '--EMIC 2 hardware pins and constants--
  EMIC_TX        = 0             ' Serial output (connects to Emic 2 SIN)
  EMIC_RX        = 1             ' Serial input (connects to Emic 2 SOUT)
  VOICE_BAUD_RATE = 9600         ' 9600 bits per second (BPS)

  '----Propeller pin configuration for Death Star Mark IV----

  REMOVE_BEFORE_FLIGHT_PIN = 2    'Net GPIO1 = P2 on J2
                                  '
  '--I2C bus pins--
  I2C_SCL = 28
  I2C_SDA = 29
  
  '--Magnetorquer rod hardware pins and constants--
  NEGATIVE = -1
  POSITIVE = 1
  TARGETING_SLACK = 4

  '--CMU Camera hardware pins and constants--
  CAMERA_RX_PIN = 8
  CAMERA_TX_PIN = 9
  CAMERA_BAUD_RATE = 100
  AUTO = 2
  CONTRAST = 5
  BRIGHTNESS = 6
  COLOR_MODE = 18
  AUTO_EXPOSURE = 19
  PAN_START = 16
  PAN_END = 239
  TILT_START = 16
  TILT_END = 239
  PAN_STEP = 16
  TILT_STEP = 16

  '--Program debugging pins and constants--
  SURFACE_SERIAL_BUS = 31   'Only usable as GPIO when Prop Plug is NOT plugged in  
  DEBUG_OUTPUT_PIN = 31     'Only usable as GPIO when Prop Plug is NOT plugged in
  DEBUG_INPUT_PIN = 30      'Only usable as GPIO when Prop Plug is NOT plugged in
  DEBUG_BAUD_RATE = 1000000 'Make sure this matches Parallax Serial Terminal setting
  LF = 10 'LINE_FEED - Move cursor down one line, but not to the beginning of line
  CR = 13 'CARRIAGE_RETURN - Move cursor down one line and to the beginning of line


OBJ 'Additional files you would like imported / included   

  'Used to control CPU clock timing functions
  'Source URL - http://obex.parallax.com/object/173
  TIMING                  : "Clock"

  'Used to output debugging statments to the Serial Terminal
  'Custom DSiS file to updates http://obex.parallax.com/object/521 
  DEBUG                   : "GDB-SerialMirror"

  'Used to control the RGB LED color, frequency and ON duration
  LED                     : "TriColorLED"

  'Used to control the current and thus power flowing through LASER 
  LASER                   : "WSLD-650-180m-1"

  'Used to allow student code to run separate from main processing thread
  STEM                    : "STEM-Code"

  'Used to collect temperature & pressure data and calculate altitude above Mean Sea Level 
  ALTIMETER               : "MPL3115A2"

  'Used to collect 9-axis (triaxial gyroscope, accelerometer, and compass sensors) data 
  IMU                     : "YEI-3Space"

  'Used to stream video and images between two objects (distance less than ?300? meters)
  WIRELESS_MESH_NETWORK   : "ESP-12E"

  ''*  FUTURE WORK FOR MARK IV DEATH STAR
  ''***********************************************************************************************
  ''*  'Used to generate Darth Vader like audio output from text strings
  ''*  'TEXT_TO_VOICE           : "EMIC2"
  ''*
  ''*  'Used to control the current and thus magnnetic field around NSS Magnetorquer Rods 
  ''*  'ATTITUDE_CONTROL       : "NCTR-M002-Mag-Rod"
  ''*
  ''*  'Used to perform color detection, motion detection, and color classification   
  ''*  'CV_CAMERA               : "CMUCamera2"
  ''*
  ''*  'Used to stream video and images between Earth dish and LEO (distance greater then 100 km)
  ''*  'WIRELESS_SBAND         : "n2420"
  ''***********************************************************************************************

PUB Main | currentAltitude, currentAcceleration, isHardwareReady

  ''     Action: Control all Death Star hardware 3 days  before launch, until 30 minutes after launch
  '' Parameters: None                                 
  ''    Results: Puts CPU into low power mode until rocket launch                  
  ''+Reads/Uses: EVERYTHING                                               
  ''    +Writes: EVERYTHING
  '' Local Vars: isHardwareReady, currentAltitude, currentAcceleration 
  ''Local Const: None                                 
  ''      Calls: EVERYTHING
  ''        URL: https://www.deathstarinspace.com

  'Initialize hardware in a low power state (RCSLOW) to allow 144 to 168 hour runtime leading up to rocket launch
  InitializeDeathStar 
  
  'Run IMU program in parallel CPU / cog to capture launch accleration event while in RCSLOW low power mode
  'cog := cognew(IMU.StartIMU, @IMU_StackPointer)  
  
  'Run STEM program in parallel CPU / cog to allow data collection before, during, and after flight
  'TODO: UNCOMMENT cogID := cognew(STEM.Main, @STEM_CodeStackPointer)+1
  
  currentAcceleration := 0
  currentAltitude := ALTIMETER.CalculateAltitude("M")
  isHardwareReady := INA[REMOVE_BEFORE_FLIGHT_PIN] 'Pin in = 0 = GND
  repeat while currentAcceleration < LAUNCH_ACCELERATION_TRIGGER_LEVEL and !isHardwareReady and currentAltitude < SPACEPORT_AMERICA_PAD_MSL
    'DO NOTHING TO SAVE POWER IN RCSLOW CLOCK MODE
    TIMING.PauseSec(3600)                               'Pause 1 hour
    currentAltitude := ALTIMETER.CalculateAltitude("M") 
    'TO-DO: Fix stackpointer memory access currentAcceleration := @IMU_StackPointer[1]                    
    isHardwareReady := INA[REMOVE_BEFORE_FLIGHT_PIN]
      
  'Switch to high power draw 80 MHz clock to allow fast proccessing during launch and landing
  TIMING.SetMode(_clkmode)

  'Run LASER program in parallel CPU / cog
  LASER.SetLukeSkyWalkersNearDeathStar(false)
  LASER.SetSelfDestructButton(false)
  cog := cognew(LASER.Start, @LASER_StackPointer)+1
  

  'TODO: ADD ATTITUDE CONTROL LOOP HERE!!!
 

  TIMING.PauseSec(10)
  DEBUG.SendText(STRING("System Rebooting in two seconds...", DEBUG#CR))
  TIMING.PauseSec(2)

  reboot  

PUB Stop                                                'Stop the cogs
  if cog
    DEBUG.Stop
    cogstop(cog~ - 1)
    
PRI InitializeDeathStar | OK 'Initializes all the Death Star hardware and firmware

  ''     Action: Initializes all the Death Star hardware and firmware  
  '' Parameters: None                                 
  ''    Results: Prepares the Death Star for planet scale destruction                  
  ''+Reads/Uses: Global constants and variables in this DeathStarDriver.spin file                                             
  ''    +Writes: A lot of variables in the ".Initialize" functions
  '' Local Vars: OK - Variable to check if initialization completed successfully.                                  
  ''      Calls: All ".Initialize" functions for hardware subsytems
  ''        URL: https://www.deathstarinspace.com/engineering

  TIMING.Init(_xinfreq)  'External cyrstal on Mark III hardware in 5 MHz, define that in software
  TIMING.SetMode(RCSLOW) 'Set clock to ~20 KHz to reduce power draw at boot up to ???? mA
  TIMING.PauseSec(2)     'Give software and hardware to stablize on new RCSLOW clock speed

  if(DEBUG#DEBUG_STATE)
    DEBUG.start(DEBUG_OUTPUT_PIN, DEBUG_INPUT_PIN, 0, DEBUG_BAUD_RATE)
    TIMING.PauseSec(1) 'Give software terminal and hardware pins time to stablize their connection
    DEBUG.SendText(STRING("Debug statement terminal outputs are enabled.", DEBUG#CR))
  else
    DEBUG.SendText(STRING("Debug statement terminal outputs are disabled.", DEBUG#CR))

  DEBUG.SendText(STRING("Update *DEBUG_STATE* global variable in GDB-SerialMirror.spin to toggle bevahior.", DEBUG#CR))
   
  ALTIMETER.Initialize
  LASER.Initialize
  IMU.Initialize
  WIRELESS_MESH_NETWORK.Initialize
  ''TO-DO: TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE, TEXT_TO_VOICE#ESPON)  
  ''TO-DO: ATTITUDE_CONTROL.Initialize(???)

PRI Reset  'Reset all the Death Star hardware  

  ''     Action: Resets all the Death Star hardware and firmware  
  '' Parameters: None                                 
  ''    Results: Allows the rebel scum to rest the Death Star                 
  ''+Reads/Uses: ???                                               
  ''    +Writes: A lot of variables in the ".ResetX" functions
  '' Local Vars: None                                  
  ''      Calls: All ".ResetX" functions for hardware subsytems
  ''        URL: www.solarsystemexpress.com/death-star-in-leo.html

  InitializeDeathStar

PRI UnitTest | BOOT_MODE   'Test the partially operational Death Star

  ''     Action: Tests all the Death Star hardware and firmware  
  '' Parameters: None                                 
  ''    Results: Prepares Death Star to become fully operational                
  ''+Reads/Uses: ???                                               
  ''    +Writes: ???
  '' Local Vars: BOOT_MODE                                  
  ''      Calls: ???
  ''        URL: www.deathstarinspace.com

  repeat 
    DEBUG.SendText(STRING("Hello Earthling,", DEBUG#CR))
    DEBUG.SendText(STRING("Type 2 and hit enter to boot Death Star in planet destruction mode.", DEBUG#CR))
    DEBUG.SendText(STRING("Type 1 and hit enter to boot Death Star in self destruct mode.", DEBUG#CR))
    DEBUG.SendText(STRING("Type 0 and hit enter to boot Death Star in test mode.", DEBUG#CR))  
    TIMING.PauseSec(5)      'Pause 5 seconds 
  until(BOOT_MODE := DEBUG.GetNumber)

  DEBUG.start(DEBUG_OUTPUT_PIN, DEBUG_INPUT_PIN, 0, DEBUG_BAUD_RATE)

  case BOOT_MODE
    0: 'Initializes debug mode and infite loop 
                
      'Stop 
    1: 'Initializes infite loop for 
      
      'Stop     
    2: 'Initializes connection to the Parallax Serial Terminal     

      'Stop 
DAT
  IamYourFather   byte "I am your father Back our Kickstarter today"
  Rey             byte "Daisy Ridley    "                
  Finn            byte "John Boyega     "
  Poe             byte "Oscar Issac     "
  Leia            byte "Carier Fisher   "
  Luke            byte "Mark Hamill     "  
  Han             byte "Harrison Ford   "
  Vader           byte "David Prowse    "
  Kenobi          byte "Ewan McGregor   "
  Ben             byte "Alec Guinness   "  
  Maz             byte "Lupita Nyongo   "
  Windu           byte "Samuel L Jackson"
  Palpatine       byte "Ian McDiarmid   "
  Padme           byte "Natalie Portman "   
  Kylo            byte "Adam Driver     "
  Snoke           byte "Andy Serkis     "
  Hux             byte "Domhnall Gleeson"
  C3PO            byte "Anthony Daniels "
  Yoda            byte "Frank Oz        "
  Tarkin          byte "Peter Cuching   "
  Chewbacca       byte "Peter Hayhew    "
  Dooku           byte "Christopher Lee "
  JarJar          byte "Ahmed Best      "
  QUiGon          byte "Liam Neeson     "
  Anakin          byte "Jake Llyod      "
  Backer0         byte "Blaze Sanders   "
  Backer2187      byte "John Doe        ", 0
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