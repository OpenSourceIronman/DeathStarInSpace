{{
''***********************************************************************************
''*  Title:                                                                         *
''*  EMIC2.spin                                                                     *
''*  The object creates high-quality speech synthesis for English & Spanish         * 
''*  Author: Blaze Sanders [blaze.sanders@solarsystemexpress.com]                   *
''*  Copyright (c) 2015 PongSat Parts LLC                                           *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *   
''*  This code controls the open source hardware of the EMIC2 Text to Voice         *
''*  multi-language voice synthesizer that converts a stream of digital text into   *
''*  natural sounding speech. Please refer to the Emic 2 product manual for full    *
''*  details of functionality and capabilities.                                     *   
''*                                                                                 * 
''*  EMIC 2 subsystem circuit diagram can be found at:                              *
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
''*  Based off the EMIC2_Demo file by Joe Grand of Grandidea Studio                 *
''*  http://www.grandideastudio.com/portfolio/emic-2-text-to-speech-module/         *
''*  Revisions:                                                                     *
''*  - Mark I (March 15, 2015): Initial release                                     * 
 ''**********************************************************************************                                                        
}}

CON 'Global Constants

'Voice enumerations (enums)
DARTH_VADER = 0
LUKE_SKYWALKER = 1
PRINCESS_LEIA = 2
HAN_SOLO = 3

VADER_FAITH_QUOTE   = 0        ' "I find your lack of faith disturbing", 0
VADER_FATHER_QUOTE  = 1        ' "No Luke I am your father"
VADER_FORCE_QUOTE   = 2        ' "The ability to destroy a planet is insignificant next to the power of the force"
VADER_DARK_SIDE_QUOTE  = 3     ' "You underestimate the power of the dark side"

'DECtalk is the worlds most intelligible text-to-speech (TTS) synthesizer
DEC_TALK = 0

'??? is the ??? text-to-speech (TTS) synthesizer 
ESPON = 1

'Defualt serial communication speed for the EMIC2
VOICE_BAUD_RATE = 9600
 
VAR 'Global Variables

'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
byte DEBUG_MODE

'Type of synthesizer (DEC Talk or ESPON) to use for text-to-speech (TTS) synthesis 
byte voiceSynthesizer

'Temporary memory, to hold operational data such as call stacks, parameters and intermediate expression results.
'Use an object like "Stack Length" to determine the optimal length and save memory. http://obex.parallax.com/object/574 
long EMIC2StackPointer[100] 
    
OBJ 'Additional files you would like imported / included 
PST      : "Parallax Serial Terminal"                   ' Debug Terminal
SERIAL   : "FullDuplexSerial"                           ' Full Duplex Serial

'Used to control CPU clock timing functions
'Source URL - http://obex.parallax.com/object/173
TIMING          : "Clock"
  
PUB Initialize(voice, EMIC_RX, EMIC_TX, terminalBaudrate, voiceBaudRate, synthesizer) : error

''     Action: Initializes the EMIC2 hardware and firmware  
'' Parameters: voice - Desire voice type (i.e. Darth Vader, Wedge, ...)
''             EMIC_RX - Serial output pin from host
''             EMIC_TX - Serial input input to  host
''             terminalBaudrate - Text output "Parallax Serial Terminal" baud rate
''             synthesizer - Text to voice synthesizer to use (1 = ESPON & 0 = DEC TALK)
''             voiceBaudRate - Voice data serial port baud rate                  
''    Results: Prepares the EMIC2 to start speaking                 
''+Reads/Uses: From Global Constants and Global Variables  ???                                              
''    +Writes: A lot of variables in the functions ???
'' Local Vars: None                                  
''      Calls: PST.Start(), PST.Str(), SERIAL.Start(), SERIAL.RxFlush(), SetVoice(), SendCommand()
''        URL: www.solarsystemexpress.com/death-star-in-leo.html

if (synthesizer == ESPON)
  voiceSynthesizer := ESPON
elseif (synthesizer == DEC_TALK)  
  voiceSynthesizer := DEC_TALK
else
  PST.Str(String("ERROR! Invalid voice synthesizer selected", PST#NL))
  error := true
  return error
    
PST.Start(terminalBaudrate)   ' Set Parallax Serial Terminal to 115.2 kBPS        
PST.Str(@InitHeader)         ' Print header; uses string in DAT section.

'The serial interface is configured for 9600 bps, 8 data bits, no parity, 1 stop bit (8N1)
SERIAL.Start(EMIC_RX, EMIC_TX, %0000, voiceBaudRate)

{{
   When the Emic 2 powers on, it takes about 3 seconds for it to successfully
   intialize. It then sends a ":" character to indicate it's ready to accept
   commands. If the Emic 2 is already initialized, a CR will also cause it
   to send a ":"
}}

PST.Str(String("Waiting for Emic 2...", PST#NL))
SendCommand
PST.Str(String("The space station is fully operational!", PST#NL))

TIMING.PausemSec(10) 
SERIAL.RxFlush                                        ' Flush the receive buffer

SetVoice(voice)

{{
TO-DO: Should the EMIC run in its own COG / CPU?
Stop

return (cog := cognew(Speek, @EMIC2StackPointer)+1)


PUB Stop                                                '' Stop the cogs
  if cog
    ser.Stop
    cogstop(cog~ - 1)
}} 

PUB SpeekStoredQuote(quoteNumber) 'Uses the DEC Talk or ESPON synthesizers to generate a voice

''     Action: Uses the DEC Talk or ESPON synthesizers to generate a voice 
'' Parameters: quoteNumber - enum value of quote                  
''    Results: Speaks a quote stored in RAM                
''+Reads/Uses: Strings stored in the DAT section below                                            
''    +Writes: None
'' Local Vars: None                                  
''      Calls: PST.Str(), SERIAL.Str(), SERIAL.Tx(), SendCommand()
''        URL: http://www.parallax.com/product/30016 

SERIAL.TX("S")  'Convert the following text string into synthesized speech.
  
' Send string to convert to speech (stored in the DAT section below) 
case quoteNumber
  0: 'Darth Vader "I find your lack of faith disturbing"  
     PST.Str(String("\/ I find your lack of faith disturbing.", PST#NL))
     if(voiceSynthesizer == DEC_TALK)
       
     else
       SERIAL.Str(@Vader0)     
  1: 'Darth Vader "No Luke, I am your father"
     PST.Str(String("\/ No Luke, I am your father.", PST#NL))
     if(voiceSynthesizer == DEC_TALK)
       {{
         [:name Paul]
         [:say line]                            'Speak on end of line.
         [:dv ap 100 pr DD sx 01 sm ??]  "No "  'Apparent pitch 100, ??? , sex male
         [:mode name on] "Luke" 
         [:comma 250] ", "

         [:pronounce ??]
         [:rate 100]   ' words per minute
         [:n0]

        https://news.toggle.com/en/362/how-to-create-a-darth-vader-voice-effect-in-premiere-pro.htm
        Pitch option, change it to -4semitone.
         echo??
       }}  
     else
       SERIAL.Str(@Vader1)     
  2: 'Darth Vader "The ability to destroy a planet is insignificant next to the power of the force"           
     PST.Str(String("\/The ability to destroy a planet is insignificant next to the power of the force.", PST#NL))
     if(voiceSynthesizer == DEC_TALK)
       
     else
       SERIAL.Str(@Vader2)   
  3: 'Darth Vader "You underestimate the power of the dark side"
     PST.Str(String("\/ You underestimate the power of the dark side.", PST#NL))
     if(voiceSynthesizer == DEC_TALK)
       
     else
       SERIAL.Str(@Vader3)

  4: 'InitHeader "I am the EMIC 2. I will be saying your names in space in Darth Vaders voice. For example Jane ... I am your father!"
    PST.Str(String("I am the EMIC 2. I will be saying your name in space in Darth Vaders voice. For example, I can say John Doe, I am your father! Support our KickStarter today", PST#NL))
    if(voiceSynthesizer == DEC_TALK)
       
    else
       SERIAL.Str(@InitHeader)
{{
TO-DO: DEC TALK paramters
  [:rate 200][:n0][:dv ap 90 pr 0] All your base are belong to us.
}} 

' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command 
SendCommand

PUB SpeekStoredSoundFile(fileNumber) 'Uses the DEC Talk or ESPON synthesizers to generate a voice

''     Action: Uses the DEC Talk or ESPON synthesizers to generate a voice 
'' Parameters: fileNumber - enum value of wav file                  
''    Results: Speaks a sound file stored in RAM                
''+Reads/Uses: File address in the DAT section below                                            
''    +Writes: None
'' Local Vars: None                                  
''      Calls: ??? PST.Str(), SERIAL.Str(), SERIAL.Tx(), SendCommand()
''        URL: http://www.parallax.com/product/30016 
    
PUB SetVoice(voice) 'Configures the DEC Talk or ESPON synthesizers  

''     Action: Configures the DEC Talk or ESPON synthesizers  
'' Parameters: voice - enum value of voice to synthesize         
''    Results: ??? Changes the N, V, W, L, and P paramaters of the ESPON and ??? of the DEC Talk synthesizers                 
''+Reads/Uses: ???                                           
''    +Writes: None
'' Local Vars: None                                  
''      Calls: ??? PST.Str(), SERIAL.Str(), SERIAL.Tx(), SendCommand()
''        URL: http://www.parallax.com/product/30016 

case voice
  0: 'Darth Vader
    if(DEC_TALK)
       
    else
       PST.Str(String("Configuring Darth Vader's voice.", PST#NL)) 
       SERIAL.TX("N")   'Select Voice Huge Harry (Francisco) 
       SERIAL.TX("1")
       SendCommand
   
       SERIAL.TX("V")    'Set volume to 18 dB
       SERIAL.TX(18)
       SendCommand 
      
       SERIAL.TX("W")    'Set speaking rate to 75 word per minute
       SERIAL.TX(75)
       SendCommand
   
       SERIAL.TX("L")    'Set language to English 
       SERIAL.TX(0)
       SendCommand
      
       SERIAL.TX("P")    'Set parser to ESPON 
       SERIAL.TX(1)
       SendCommand                                      

  1: 'Luke SkyWalker 
    PST.Str(String("Configuring Luke SkyWalkers's voice.", PST#NL))   
    
  2: 'Princess Leia
    PST.Str(String("Configuring Princess Leia's voice.", PST#NL))
     
  3: 'Han Solo
    PST.Str(String("Configuring Han Solo's voice.", PST#NL)) 

{{
TO-DO: DEC TALK paramters 
Singing Happy Birthday
[:phone arpa speak on][:rate 200][:n0][hxae<300,10>piy<300,10>
brrrx<600,12>th<100>dey<600,10>tuw<600,15> yu<1200,14>_<300> hxae<300,10>piy<300,10>
brrrx<600,12>th<100>dey<600,10> tuw<600,17>yu<1200,15>_<300> hxae<300,10>piy<300,10>
brrrx<600,22>th<100>dey<600,19> dih<600,15>r
eh<600,14>m<100,12>ih<350,12>k_<120>_<300> hxae<300,20>piy<300,20>
brrrx<600,19>th<100>dey<600,15> tuw<600,17> yu<1200,15>][:n0]
}} 

PUB SendCommand 'Causes EMIC2 to start speaking last instruction sent using SpeekStoredQuote or SpeekStoredSoundFile

''     Action: Causes EMIC2 to start speaking last instruction sent using SpeekStoredQuote or SpeekStoredSoundFile
'' Parameters: None         
''    Results: Send Newline and pause intructions to the EMIC2                
''+Reads/Uses: None                                          
''    +Writes: Newline to the serial terminal
'' Local Vars: None                                  
''      Calls: PST.Str(), TIMING.PausemSec(), SERIAL.Tx(), and SERIAL.RxCheck()
''        URL: http://www.parallax.com/product/30016 

SERIAL.TX(PST#NL)                                     ' Send a CR in case the system is already up
repeat until SERIAL.RxCheck == ":"                   ' When the Emic 2 has initialized and is ready, it will send a single ':' character, so wait here until we receive it
pst.Str(String("Command complete sir!", pst#NL))
TIMING.PausemSec(500) 
 
PUB DisplaySettings 'Prints current EMIC2 setting to the serial terminal 

''     Action: Prints current EMIC2 setting to the serial terminal
'' Parameters: None         
''    Results: Prints text to serial terminal                 
''+Reads/Uses: C, I, and H registers in the EMIC2                                          
''    +Writes: None
'' Local Vars: None                                  
''      Calls: SERIAL.Tx()
''        URL: http://www.parallax.com/product/30016 

SERIAL.TX("C") ' Print current text-to-speech settings  
SERIAL.TX("I") ' Print version information
SERIAL.TX("H") ' Print list of available commands

PUB ResetSettings 'Resets the EMIC2 to factory settings

''     Action: Resets the EMIC2 to factory settings
'' Parameters: None         
''    Results: Revert to default text-to-speech settings                  
''+Reads/Uses: R register in the EMIC2                                          
''    +Writes: None
'' Local Vars: None                                  
''      Calls: SERIAL.Tx()
''        URL: http://www.parallax.com/product/30016 

SERIAL.TX("R") ' Revert to default text-to-speech settings

PRI UnitTest 'Tests all EMICs hardware and firmware 

''     Action: Tests all EMICs hardware and firmware  
'' Parameters: None                                 
''    Results: Determines if the EMIC is functional                
''+Reads/Uses: ???                                               
''    +Writes: ???
'' Local Vars: ???                                  
''      Calls: ???
''        URL: www.solarsystemexpress.com/death-star-in-leo.html

PST.Str(String("Waiting for Emic 2..."))
SERIAL.TX(PST#NL)                                     ' Send a CR in case the system is already up
repeat until SERIAL.RxCheck == ":"                   ' When the Emic 2 has initialized and is ready, it will send a single ':' character, so wait here until we receive it
PST.Str(String("Ready!", PST#NL))   

TIMING.PausemSec(10) 
SERIAL.RxFlush                                        ' Flush the receive buffer

PST.Str(String("Speaking some text..."))
SERIAL.TX("S")
SERIAL.Str(@InitHeader)                               ' Send the desired string to convert to speech (stored in the DAT section below)
SERIAL.TX(PST#NL)
repeat until SERIAL.RxCheck == ":"                    ' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command
PST.Str(String("Done!", PST#NL))  

waitcnt(clkfreq >> 1 + cnt)                           ' Delay 1/2 second

PST.Str(String("Singing a song..."))
SERIAL.Str(String("D1", PST#NL))                      ' Play the built-in demonstration song. See the product manual for exact settings used to create this song.
repeat until SERIAL.RxCheck == ":"                    ' Wait here until the Emic 2 responds with a ":" indicating it's ready to accept the next command
PST.Str(String("Done!", PST#NL))
 
DAT
InitHeader    byte "\/\/I am the EMIC 2. I will be saying your name in space in Darth Vaders voice. For example, I can say \/\/\/Luke, I am your father. /\/\/\Support our KickStarter today", 0
Vader0        byte "I find your lack of faith disturbing.", 0
Vader1        byte "No Luke, I am your father.", 0
Vader2        byte "The ability to destroy a planet is insignificant next to the power of the force.", 0
Vader3        byte "You underestimate the power of the dark side.", 0
Luke0         byte "Nooooooo!",0
Luke1         byte "I am Luke SkyWalker, I am here to rescue you", 0
Leia0         byte "I love you.", 0
Han0          byte "I know.", 0
Kenobi0       byte "That is no moon.", 0
Emperor0      byte "Now witness the firepower of this fully armed and operational battle station!", 0
Wedge0        byte "Good shot Red two!", 0 
ZeroWing      byte "All your base are belong to us.", 0


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