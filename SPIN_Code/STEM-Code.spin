{{
''***********************************************************************************
''*  Title:                                                                         *
''*  STEM-Code.spin                                                                 *
''*  This object allows students to submit code to the Death Star in Space project. * 
''*  Author: Blaze Sanders [deathstarinspace@gmail.com]                             *
''*  Copyright (c) 2018                                                             *
''*  See end of file for terms of use.                                              *
''***********************************************************************************
''*  Brief Description:                                                             *
''*  Number of cogs/CPU's used: 1 out of 8                                          *
''*                                                                                 *
''*                                                                                 *                                                                           
''*                                                                                 *
''*  Revisions:                                                                     *
''*  - Mark I   (Dec 24, 2018): Initial release                                     * 
''*  - Mark II  (Mar 13, 2019): Updated comments & example code for podcast         * 
''*  - Mark III (Apr 08, 2019): Refactored TurnOnRed(?, ?) to TurnOnLED(RED, ?, ?)  * 
''***********************************************************************************                                                    
}}
VAR 'Global variables  
 
  'Boolean variable that determines wheter debug text is displayed on the Parallax Serial Terminal 
  byte DEBUG_MODE
  
  'Boolean variable that determines if data is stored in memory or just printed to Parallax Serial Terminal 
  byte isDataSaving
  
  'Array to store 3 variables (temperature, pressure, and altitude) for upto 60 seconds (ALTIMETER#MAX_DATA_COLLECTION_DURATION)
  word experimentData[180]
  
CON 'Global Constants
 
  '----General useful constants---- 
  HIGH = 1 
  LOW = 0  
  
  'Standard clock mode = PLL multiplier * crystal frequency = 16 * 5 MHz = 80 MHz
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
    
OBJ 'Additional files you would like imported / included 

  'Used to control CPU clock timing functions
  'Source URL - http://obex.parallax.com/object/173
  TIMING        : "Clock"

  'Used to output debugging statments to the Serial Terminal
  'Custom PSP file updating http://obex.parallax.com/object/521 
  DEBUG         : "GDB-SerialMirror"

  'Used to control the RGB LED color, frequency and ON duration
  LED           : "TriColorLED"

  'Used to collect temperature & pressure data and calculate altitude above Mean Sea Level  
  ALTIMETER     : "MPL3115A2"

  'Used to control the current and thus power flowing through a WSLD-650-180m-1 laser diodes
  LASER         : "WSLD-650-180m-1"
  
  'Used to read and write data from the onboard 256KB EEPROM.
  EEPROM        : "Basic_I2C_Driver"

PUB Main
  
  TIMING.Init(_xinfreq)         'External cyrstal hardware in 5 MHz, defined in "CON" section above
  TIMING.SetMode(XTAL1_PLL1X)   'Set clock to 5 MHz to reduce power draw at boot up and during operations
  
  EEPROM.Initialize(DEBUG#I2C_SCL)
  EEPROM.Start(DEBUG#I2C_SCL)
  
  DEBUG.start(DEBUG_OUTPUT_PIN, DEBUG_INPUT_PIN, 0, DEBUG_BAUD_RATE) 'Initialize the Parallax Serial Terminal                      
  TIMING.PauseSec(1) 'Give software terminal and hardware pins time to stablize their connection
  
  isDataSaving = False             'No data will be stored in memory (printing to Serial Terminal instead)
                                                                     
  LEDexampleFunction()                       'Run LEDexampleProgram code below
  AltimeterExampleFunction(isDataSaving)   'Run AltimeterExampleProgram code below
  
  'INSERT YOUR CODE BELOW: Either replace next line with name of your code OR write your code in StudentProgram1()
  StudentFunction1()                         

  'Clean up internal memory by stopping EEPROM and DEBUG code from running
  EEPROM.Stop(DEBUG#I2C_SCL)
  DEBUG.stop()
  'END OF STEM-Code.spin PROGRAM. ALL FUNCTIONS BELOW HERE MUST BE CALLED TO BE USED

PRI StudentFunction1()
  'WRITE YOUR CODE HERE

PRI StudentFunction2()
  'WRITE YOUR CODE HERE
  
PRI StudentFunctionN()
  'WRITE YOUR CODE HERE

PRI LEDexampleFunction() 

  ''     Action: Prints Star Wars quotes on the debug terminal and turns on correct color lightsaber  
  '' Parameters: None                                 
  ''    Results: Turns multicolor LED on and off                  
  ''Readds/Uses: LIGTHSABER_FREQ and INFINITE constants from the TriColorLED.spin object                                               
  ''     Writes: Nothing to memory
  '' Local Vars: None
  ''Local Const: None                                 
  ''      Calls: Functions like LED.TurnOnRed(duration, flashingFreq)
  ''        URL: https://www.deathstarinspace.com/blog/smlp36rgb2w3
    
  TIMING.PauseSec(1)      'Pause 1 second to give Parallax Serial Terminal time to stabilize
                          
  DEBUG.SendText(STRING("My name is Blaze Sanders. This is my lightsaber program for DSiS Kickstarter.", DEBUG#CR))
  TIMING.PauseSec(2)                                'Pause 2 seconds before next event
                        
  DEBUG.SendText(STRING("You are on the council, but we do not grant you the rank of master.", DEBUG#CR)) 'Mace Windu
  LED.TurnOnLED(LED#PURPLE, 5, LED#LIGTHSABER_FREQ) 'Turn on purple LED for 5 seconds flashing at 772 Hz
  TIMING.PauseSec(2)                                'Pause 2 seconds before next event 

  LED.TurnOnLED(LED#GREEN, LED#STAY_ON, LED#LIGTHSABER_FREQ)                'Turn on green LED flashing at 772 Hz
  TIMING.PauseSec(3)                                                        'Pause 3 seconds for dramatic effect
  LED.TurnOffLED()                                                          'Turn off green LED 
  DEBUG.SendText(STRING("I am a Jedi like my father before me!", DEBUG#CR)) 'Luke Skywalker
  TIMING.PauseSec(2)                                                        'Pause 2 seconds before next event

  DEBUG.SendText(STRING("No, I am your father...", DEBUG#CR)) 'Darth Vader
  LED.TurnOnLED(LED#RED, LED#STAY_ON, LED#LIGTHSABER_FREQ)    'Turn on red LED flashing at 772 Hz
  TIMING.PauseSec(2)                                          'Pause 2 seconds before next event 

  DEBUG.SendText(STRING("I dont like sand. Its coarse and rough and irritating and it gets everywhere.", DEBUG#CR)) 'Anakin Skywalker
  LED.TurnOnLED(LED#BLUE, 10, LED#LIGTHSABER_FREQ)  'Turn on blue LED flashing at 772 Hz. This line automatically makes red LED turn off                  

  DEBUG.SendText(STRING("I am sorry master, but I am not coming back", DEBUG#CR))   'Ahsoka Tano
  ontime := 42                                              'Variable to set to duration parameters of the TurnOnWhite function.
  LED.TurnOnLED(LED#WHITE, onTime, LED#LIGTHSABER_FREQ)     'Turn on blue LED flashing at 772 Hz. This line automatically makes red LED turn off                  

  DEBUG.SendText(STRING("The End", DEBUG#CR))
  TIMING.PauseSec(4)                                        'Pause 4 seconds before ending example program
                   

PRI AltimeterExampleFunction(storeDataToMemory) 

  ''     Action: Collect temperature, pressure, and altitude data from Death Star sensors  
  '' Parameters: storeDataToMemory - Boolean variable to configure how data is stored / displayed                                 
  ''    Results: Stores data to 246K EEPROM or Prints data to Parallax Serial Terminal                 
  ''Readds/Uses: MAX_DATA_COLLECTION_DURATION constant from the MPL3115A2.spin object                                               
  ''     Writes: To experimentData{} array if storeDataToMemory parameter EQUALS true
  '' Local Vars: SecEslapsed
  ''Local Const: None                                 
  ''      Calls: Functions like ALTIMETER.CalculateAltitude(unitOfMeasure)
  ''        URL: https://www.deathstarinspace.com/blog/MPL3115A2
  
  SecEslapsed := 0
  while (SecEslapsed <= duration - SecEslapsed || SecEslapsed < ALTIMETER#MAX_DATA_COLLECTION_DURATION)
    temp := ALTIMETER.GetTemperature(C)
    pres := ALTIMETER.GetPressure(B)
    alt  := ALTIMETER.GetAltitude(M)  'Program calcultes altitude use temp and pres variables
    
    '*** You will have the most fun if you only edit the code between the *** markers :)
    
    if storeDataToMemory == True
      
      DEBUG#DEBUG_STATE := False 'Don't print data to terminal window, instead save to EEPROM (memory)
      memoryLocation := 3*SecEslapsed
      experimentData[memoryLocation] :=  temp
      experimentData[memoryLocation+1] := pres 
      experimentData[memoryLocation+2] := alt                        '
  
    else
      DEBUG#DEBUG_STATE := True
      DEBUG.SendText(STRING("Debug statements in Parallax Serial Terminal are enabled.", DEBUG#CR))
      DEBUG.Dec(temp)                                       'Print decimal temperature value with units to terminal window
      DEBUG.SendText(STRING(" degrees Celsius", DEBUG#CR))
      DEBUG.Dec(pres)                                       'Print decimal pressure value with units to terminal window
      DEBUG.SendText(STRING(" bar of pressure", DEBUG#CR))
      DEBUG.Dec(alt)                                        'Print decimal altitude value with units to terminal window
      DEBUG.SendText(STRING(" meters in altitude", DEBUG#CR))
  
      TIMING.PauseMSec(900)      'Pause 900 microsecond to give to account for time sensors readings take
   
   '***
   
     SecEslapsed += 1
     
     
  'THIS IS END OF WHILE LOOP
  
  'Write data store in 180 element array to EEPROM before exiting AltimeterExampleFunction()
  i := 0
  repeat 180
    EEPROM.Write(DEBUG#I2C_SCL, experimentData[i])   