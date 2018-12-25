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
''*  2) One WSLD-650-180m-1 laser diodes - 650 nm, 180 mW and upto 2.5 Gbps          *
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
''*  - Mark I  (March 15, 2015): Initial release                                     *
''*  - Mark II (August 1, 2016): Documentation update and questions marks added      *
''*  - Mark III (November 12, 2018): Implemented all 2018 MDR code requirements      * 
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
  
'----General useful constants---- 
HIGH = 1
LOW = 0

OUTPUT = 1
INPUT = 0

MECO_ALTITUDE := 100_000 'Main Engine Cut Off in meters

'----Propeller pin configuration for Death Star Mark III----

'--I2C bus pins--
I2C_SCL = 28
I2C_SDA = 29


'--Laser hardware pins and constants--
FULL_POWER = 100
HALF_POWER = 50


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


'--EMIC 2 hardware pins and constants--
EMIC_TX        = 0             ' Serial output (connects to Emic 2 SIN)
EMIC_RX        = 1             ' Serial input (connects to Emic 2 SOUT)
VOICE_BAUD_RATE = 9600         ' 9600 bits per second (BPS)


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
'Custom PSP file updating http://obex.parallax.com/object/521 
DEBUG                   : "GDB-SerialMirror"

'Used to control the RGB LED color, frequency and ON duration
LED                     : "TriColorLED"

'Used to control the current and thus power flowing through a WSLD-650-180m-1 laser diodes
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

PUB Main | word currentAltitude, byte currentAcceleration 

''     Action: Initialize all Death Star hardware and put system into low power mode  
'' Parameters: None                                 
''    Results: Puts CPU into low power mode until rocket launch                  
''+Reads/Uses: EVERYTHING                                               
''    +Writes: EVERYTHING
'' Local Vars: currentAltitude, currentAcceleration 
''Local Const: LAUNCH_ACCELERATION                                 
''      Calls: EVERYTHING
''        URL: https://www.deathstarinspace.com

byte LAUNCH_ACCELERATION := 3 'G's = 29.43 m/s^2

InitializeDeathStar

currentAltitude := ALTIMETER.GetAltitude

'32 bit integer in units of meters
if(currentAltitude > MECO_ALTITUDE)
if(currentAcceleration > LAUNCH_ACCELERATION)

cog := cognew(IMU.StartIMU, @IMU_StackPointer)+1
cog := cognew(LASER.Start, @LASER_StackPointer)+1
cog := cognew(STEM.Start, @STEM_CodeStackPointer)+1

'TODO: ADD CONTROL LOOP HERE!!!


TIMING.PauseSec(10)
DEBUG.SendText(STRING("System Rebooting...", DEBUG#CR))
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
''+Reads/Uses:  Global constants and variables in this DeathStarDriver.spin file                                             
''    +Writes: A lot of variables in the ".Initialize" functions
'' Local Vars: OK - Variable to check if initialization has gone good.                                  
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
IMU.Initialize
WIRELESS_MESH_NETWORK.Initialize
''TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE, TEXT_TO_VOICE#ESPON)  


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
PUB FutureWork
  ''TO-DO:ATTITUDE_CONTROL.Initialize
  
  TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE, TEXT_TO_VOICE#ESPON)
  TEXT_TO_VOICE.SpeekStoredQuote(4)
  TEXT_TO_VOICE.SpeekStoredQuote(VADER_FAITH_QUOTE)
  
  
  TEXT_TO_VOICE.SpeekStoredQuote(VADER_FATHER_QUOTE)

      
if(DEBUG#DEBUG_STATE)
  DEBUG.SendText(STRING("Laser fired! Planet Alderaan was destoryed :(", DEBUG#CR))
  TEXT_TO_VOICE.SpeekStoredQuote(VADER_DARK_SIDE_QUOTE) 

 TRACKING_CAMERA.ResetCamera 
'Initialize CMU Camera Settings
TRACKING_CAMERA.CameraPower(TRUE)
TRACKING_CAMERA.SetFrameRate(13)    ' = TRACKING_CAMERA.SetRegister(17, 13) Up to 50 FPS possible
TRACKING_CAMERA.setHiResMode(true) 
TRACKING_CAMERA.Start(CAMERA_RX_PIN, CAMERA_TX_PIN, CAMERA_BAUD_RATE)
TRACKING_CAMERA.SetBufferMode(FALSE) 'Non-Continuous Frame Reading / frame stored to memory  
TRACKING_CAMERA.SetRegister(CONTRAST, 128)     'Value between 0 and 255 inclusive
TRACKING_CAMERA.SetRegister(BRIGHTNESS, 128)   'Value between 0 and 255 inclusive
TRACKING_CAMERA.SetRegister(COLOR_MODE, 36)    'YCrCb*  Auto White Balance On
TRACKING_CAMERA.SetRegister(AUTO_EXPOSURE, 33) 'Auto Gain On
TRACKING_CAMERA.SetDelayMode(10)               'Delay Between Characters on Serial Port 0..255 
TRACKING_CAMERA.SetDownSampleFactors(2, 2)      'Down Sampling Factors
TRACKING_CAMERA.SetLED0Mode(AUTO)              'LED control
TRACKING_CAMERA.SetLED1Mode(AUTO)              'LED control
TRACKING_CAMERA.SetNoiseFilter(10)             '???    SetFrameDifferencingChannel
TRACKING_CAMERA.SetHiResFrameDifferencing(true)'HiRes Frame Differencing 
'TRACKING_CAMERA.SetFrameDifferencingChannel(RED)  '??? Set Frame Differencing Channel (0=Red, 1=Green, 2=Blue)
'TRACKING_CAMERA.SetFrameDifferencingChannel(GREEN)'??? Set Frame Differencing Channel (0=Red, 1=Green, 2=Blue)
'TRACKING_CAMERA.SetFrameDifferencingChannel(BLUE) '??? Set Frame Differencing Channel (0=Red, 1=Green, 2=Blue)
'TRACKING_CAMERA.SetLineMode                       '???
'TRACKING_CAMERA.SetOutputMask                     '???
TRACKING_CAMERA.SetPixelDifferenceMode(true)       'Set Noise Filter threshold   
TRACKING_CAMERA.SetPacketFilteringMode(true)      'Set Noise Filter threshold   
'TRACKING_CAMERA.SetPollMode(false)                '??? 
TRACKING_CAMERA.SetPacketSkipping(false)           '???
TRACKING_CAMERA.SetPollMode(true)                  '??? 
TRACKING_CAMERA.SetTrackInverted(false)           'Track Inverted Mode (0 or 1) 
                                                    
TRACKING_CAMERA.SetServoMask(%0000)     'Pan and Tilt control and report is disabled
TRACKING_CAMERA.SetServoLevel(1, LOW)  'Pan Servo LOW / OFF
TRACKING_CAMERA.SetServoLevel(2, LOW)  'Tilt Servo LOW / OFF
TRACKING_CAMERA.SetServoParameters(PAN_START, PAN_END, PAN_STEP, TILT_START, TILT_END, TILT_STEP) '???

'TRACKING_CAMERA.TrackingColors(245, 255, 237, 245, 0, 10) ' Track MSPAINT Yellow ??? 
TRACKING_CAMERA.SetTrackingColors(245, 255, 237, 245, 0, 10) ' Track MSPAINT Yellow 
'Input to the camera is NOT raw bytes, ACK\r and NCK\r confirmations are NOT suppressed, and Output from the camera is in raw bytes  
TRACKING_CAMERA.SetRawMode(%001)    
TRACKING_CAMERA.SetWindow(0, 0, 640, 480) '???
}}

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