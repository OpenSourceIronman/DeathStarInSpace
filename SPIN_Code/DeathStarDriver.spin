{{
''************************************************************************************
''*  Title:                                                                          *
''*  DeathStarDriver.spin                                                            *
''*  Death Star program operation starts from the Main function in this file.        *
''*  Author: Blaze Sanders [blaze.d.a.sanders@gmail.com] 20                          *
''*  See end of file for terms of use.                                               *
''************************************************************************************
''*  Brief Description:                                                              *
''*  Number of cogs/CPU's used: ?6? out of 8                                         *
''*                                                                                  *   
''*  This code controls the open source hardware of the Death Star is Space project  *
''*  creating a high level API for the control of the following pieces of hardware:  *
''*  1) One CMU5 Camera - VGA resolution (640x480) at 13 fps (2 COGS)                *    
''*  2) One WSLD-650-180m-1 laser diodes - 650 nm, 180 mW and upto 2.5 Gbps        *
''*  3) Three NSS Magnetorquer Rods - Magnetic moment of 0.2 Am^2                    *
''*  4) One ESP-12 wireless transceiver - 2.4 GHz @ distances up to ?300? meters     *
''*  5) Thirty solar panels for recharging @ ?? V and ?? mA & laser detection sensor *
''*  6) One IMU - 9 axis, 850 Hz with quaternion-based QCOMP AHRS                    *
''*  7) One EMIC2 - Text to voice conversion with custom and 9 static voices types   *                                                             
''*                                                                                  *
''*  Deaath Star Max Power Draw: 5 V @ ?220? mA  = ?1.1 W?                           *
''*                                                                                  *                                                 
''*  The Death Star plans, datasheets, and circuit diagram can be found at:          *
''*  www.deathstarinspace.com/engneering                                             *                                        
''*                                                                                  * 
''*  Revisions:                                                                      *
''*  - Mark I  (March 15, 2015): Initial release                                     *
''*  - Mark II (August 1, 2016): Documentation update and questions marks added      *
''*  - Mark III (November ?, 2018): Implemented all 2018 MDR code requirements       * 
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

'Array variable with three axis lock status of target  
byte targetLocked[3]

'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
long EMIC2_StackPointer[100]
long IMU_StackPointer[100]
long LASER_StackPointer[100]

CON 'Global Constants

'Standard clock mode * crystal frequency = 16 * 5 MHz = 80 MHz
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000
  
'----General useful constants---- 
HIGH = 1
LOW = 0

OUTPUT = 1
INPUT = 0
 
'----Propeller pin configuration for Death Star Mark I----

'--I2C bus pins--
I2C_SCL = 28
I2C_SDA = 29

'--Laser hardware pins and constants--
FULL_POWER = 100
HALF_POWER = 50

'--Reaction Wheel hardware pins and constants--
NEGATIVE = -1
POSITIVE = 1
TARGETING_SLACK = 4 ???

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

'--Program debugging pins and constants--x`
SURFACE_SERIAL_BUS = 31   'Only usable as GPIO when Prop Plug is NOT plugged in  
DEBUG_OUTPUT_PIN = 31     'Only usable as GPIO when Prop Plug is NOT plugged in
DEBUG_INPUT_PIN = 30      'Only usable as GPIO when Prop Plug is NOT plugged in
DEBUG_BAUD_RATE = 1000000 'Make sure this matches Parallax Serial Terminal setting
LF = 10 'LINE_FEED - Move cursor down one line, but not to the beginning of line
CR = 13 'CARRIAGE_RETURN - Move cursor down one line and to the beginning of line


OBJ 'Additional files you would like imported / included   

'Used to output debugging statments to the Serial Terminal
'Custom PSP file updating http://obex.parallax.com/object/521 
DEBUG            : "GDB-SerialMirror"

'Used to perform color detection, motion detection, and color classification 
TRACKING_CAMERA  : "CMUCamera2"

'Used to generate Darth Vader like audio output from text strings
TEXT_TO_VOICE    : "EMIC2"

'Used to control CPU clock timing functions
'Source URL - http://obex.parallax.com/object/173
TIMING           : "Clock"

'Used to control the current and thus power flowing through a WSLD-650-180m-1 laser diodes
'LASER            : "WSLD-650-180m-1"

'Used to control the current and thus magnnetic field around NSS Magnetorquer Rods 
'ATTITUDE_CONTROL : "NSS-Mag-Rod"

'Used to collect 9-axis (triaxial gyroscope, accelerometer, and compass sensors) data 
'IMU              : "YEI-3Space"

'Used to stream video and images between Earth dish and LEO (distance greater then 100 km)
'WIRELESS_SBAND   : "n2420"

'Used to stream video and images between two objects in LEO (distance less than 100 meters)
'WIRELESS_MESHNET : "ESP12E"


PUB Main | axis 'First method called, like in JAVA

''     Action: Controls the Death Star  
'' Parameters: None                                 
''    Results: Prepares the Death Star for laser firing action                   
''+Reads/Uses: EVERYTHING                                               
''    +Writes: EVERYTHING
'' Local Vars: None                                  
''      Calls: EVERYTHING
''        URL: http://www.solarsystemexpress.com/death-star-in-leo.html

TIMING.Init(_xinfreq)
TIMING.PauseSec(2)

TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE, TEXT_TO_VOICE#ESPON)
TEXT_TO_VOICE.SpeekStoredQuote(4)

{{
InitializeDeathStar

Stop
cog := cognew(IMU.StartIMU, @IMUStackPointer)+1

TEXT_TO_VOICE.SpeekStoredQuote(VADER_FATHER_QUOTE)

targetDestoryed := false

repeat until targetDestoryed
  TRACKING_CAMERA.GetInputs                           'Get Input Values from Cameras Inputs
  'targetPostion[0] :=                                'X axis
  'targetPostion[1] :=                                'Y axis
  'targetPostion[2] :=                                'Z axis

  repeat axis from 0 to 2 '3 axes
    if(targetPostion[axis] < 0 AND targetPostion[0] < (-1*TARGETING_SLACK))
      REACTION_WHEEL.Rotate(axis, NEGATIVE)
    elseif(targetPostion[0] > 0 AND targetPostion[0] > TARGETING_SLACK)
      REACTION_WHEEL.Rotate(axis, POSITIVE)
    else
      targetLocked[axis] := true
      
      if(targetLocked[0] == true AND DEBUG#DEBUG_STATE)
        DEBUG.SendText(STRING("X-axis ready to fire", DEBUG#CR))
      elseif(targetLocked[1] == true AND DEBUG#DEBUG_STATE)
        DEBUG.SendText(STRING("Y-axis ready to fire", DEBUG#CR))
      elseif(targetLocked[2] == true AND DEBUG#DEBUG_STATE)
        DEBUG.SendText(STRING("Z-axis ready to fire", DEBUG#CR))        

    if(targetLocked[0] := true AND targetLocked[1] := true AND targetLocked[2] := true)
      LASER.Fire(FULL_POWER, 2)
      targetDestoryed := true
       
if(DEBUG#DEBUG_STATE)
  DEBUG.SendText(STRING("Laser fired! Planet Alderaan was destoryed :(", DEBUG#CR))
  TEXT_TO_VOICE.SpeekStoredQuote(VADER_DARK_SIDE_QUOTE) 

TIMING.PauseSec(30)
DEBUG.SendText(STRING("System Rebooting...", DEBUG#CR))
TIMING.PauseSec(2)

reboot  

{{
TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE)
TEXT_TO_VOICE.SpeekStoredQuote(VADER_FAITH_QUOTE)
}}


PUB Stop                                                'Stop the cogs
  if cog
    DEBUG.Stop
    cogstop(cog~ - 1)
    
PRI InitializeDeathStar | OK 'Initializes all the Death Star hardware and firmware

''     Action: Initializes all the Death Star hardware and firmware  
'' Parameters: None                                 
''    Results: Prepares the Death Star for planet destruction                  
''+Reads/Uses: From Global Constants an Global Variables  ???                                              
''    +Writes: A lot of variables in the ".Initialize" functions
'' Local Vars: OK - Variable to check if initialization has gone good.                                  
''      Calls: All ".Initialize" functions for hardware subsytems
''        URL: www.solarsystemexpress.com/death-star-in-leo.html

if (DEBUG_MODE)
  DEBUG.start(DEBUG_OUTPUT_PIN, DEBUG_INPUT_PIN, 0, DEBUG_BAUD_RATE)

TEXT_TO_VOICE.Initialize(TEXT_TO_VOICE#DARTH_VADER, EMIC_RX, EMIC_TX, DEBUG_BAUD_RATE, VOICE_BAUD_RATE, TEXT_TO_VOICE#ESPON)  
''TO-DO:IMU.Initialize
''TO-DO:ATTITUDE_CONTROL.Initialize
 

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


PRI Reset  'Reset all the Death Star hardware  

''     Action: Resets all the Death Star hardware and firmware  
'' Parameters: None                                 
''    Results: Allows the rebel scum to rest the Death Star                 
''+Reads/Uses: ???                                               
''    +Writes: A lot of variables in the ".ResetX" functions
'' Local Vars: None                                  
''      Calls: All ".ResetX" functions for hardware subsytems
''        URL: www.solarsystemexpress.com/death-star-in-leo.html

TRACKING_CAMERA.ResetCamera
''TO-DO:IMU.ResetIMU

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
