# Death Star in Space
Lets launch a miniature Death Star into space to celebrate Star Wars: Episode IX

Author: Blaze Sanders 
Email: deathstarinspace@gmail.com
Twitter: @BlazeDSanders

This Git repo is broken down into the following two folders / directories (***PYTHON_Code, SPIN_Code***). The PYTHON_Code directory holds prototype code used to test the system on the ground using a Raspberry Pi 3 B+ (https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/). The SPIN_Code directory holds the flight code that will be running on a Parallax Propeller 1 microcontroller (https://www.parallax.com/product/32810) while the Death Star rides a rocket into space!

***

SPIN_Code: 

https://www.parallax.com/downloads/propelleride-software-windows-spin-pasm-propbasic

After downloading our full GitHub repo you can run code in SPIN_Code directory by completing the following steps:
1. Download and open the Parallax Propeller Tool / IDE (link above).
2. Select menu item: File > Open (Ctrl+O) the DeathStarDriver.SPIN file
3. Select menu item: Project > Write (F11) to programm EEPROM and start Death Star software running. 

For faster testing after inital EEPROM write you can use Project > Run (F10) to program volatile RAM.

***

PYTHON_Code: 

https://www.raspberrypi.org/documentation/linux/software/python.md

After downloading our full GitHub repo you can run code in PYTHON_Code directory by completing the following steps:
1. Open a terminal and navigate to the PYTHON_Code using the "cd" command.
2. Run the command "python DeathStarDriver.py" to start Death Star software running.
3. Enter ternimal input as prompted to test individual subsystems. 

*** 

We will be launching a $18,420 Kickstarter campaign April 11, 2019 at 9:32 am PT to raise funding for the flight hardware.

1. Technical Website - www.deathstarinspace.com/engineering
2. Planning Google Doc - https://goo.gl/VPZJBm
3. Kickstarter - https://www.kickstarter.com/projects/solx/1015904087?ref=781870&token=65794c12

FUTURE WORK - Send Death Star in Low Earth Orbit (LEO) or flyby of the Moon and transmit names and photos to distance stars via lasers.
