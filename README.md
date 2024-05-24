# Death Star in Space
Lets launch a miniature Death Star into space to celebrate Star Wars: Episode IX

Using a 5.5 meter Blackstar Orbital Space Drone (previously a United Frontiers Discovery rocket), we will be launching a 10 centimeter diameter spherical space station to 110 km, which is above the Kármán line - the official definition of outer space. At the core of the space station will be 50 Kickstarter backer names etched & gold plated onto a Jedi blue, Ahsoka Tano white, or Sith red colored printed circuit board. Each of these Earthling backers will receive their name as a space flown souvenir after the mission. Up to 2000 additional names will also be stored on a memory chip headed to space. After a zero-G free fall of 5 minutes and a parachute landing, one backer will receive a fully operational space station that has been to space and traveled at over 2400 m/s (5370 miles per hour)!  

1. Watch our promo video: [https://youtu.be/Dxnh5BiHv4g](https://youtu.be/Dxnh5BiHv4g) 
2. Explore a 3D model: [https://bit.ly/DSiS-3D-SketchFab-Model](https://sketchfab.com/3d-models/100-mm-death-star-assembly-2495960a236d46709407e76e277f42ad)
3. Review the Bill of Material (BOM): [https://bit.ly/DSiS-BOM](https://docs.google.com/spreadsheets/d/1RHAaBC7VSPKMwwPVoe0QWJPQoMcc5cV_x1BiOgR484k/edit#gid=332828283)
4. New technical website coming soon: [www.deathstarinspace.com/engineering](www.deathstarinspace.com/engineering) 
5. Initial planning google Doc [https://goo.gl/VPZJBm](https://docs.google.com/document/d/1QYdtl1z7N_BdPdUgFNftrE6QVGZbwIDHrKbNn_z0-mk/edit#heading=h.ja90dr6jpc34)

FUTURE WORK - Send Death Star in Low Earth Orbit (LEO) or flyby of the Moon and transmit names and photos to distance stars via lasers. <br> <br>

## Software

This Git repo is broken down into the following two folders / directories (***PYTHON_Code, SPIN_Code***). 
1. The PYTHON_Code directory holds prototype code used to test the system on the ground using a Raspberry Pi 3 B+ https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/
2. The SPIN_Code directory holds the flight code that will be running on a Parallax Propeller 1 microcontroller https://www.parallax.com/product/32810 while the Death Star rides a rocket into space

***

PYTHON_Code: 

https://www.raspberrypi.org/documentation/linux/software/python.md

After downloading our full GitHub repo you can run code in PYTHON_Code directory by completing the following steps:
1. Open a terminal and navigate to the PYTHON_Code using the "cd" command.
2. Run the command "python DeathStarDriver.py" to start Death Star software running.
3. Enter ternimal input as prompted to test individual subsystems. 

*** 

SPIN_Code: 

https://www.parallax.com/downloads/propelleride-software-windows-spin-pasm-propbasic

After downloading our full GitHub repo you can run code in SPIN_Code directory by completing the following steps:
1. Download and open the Parallax Propeller Tool / IDE (link above).
2. Select menu item: File > Open (Ctrl+O) the DeathStarDriver.SPIN file
3. Select menu item: Project > Write (F11) to programm EEPROM and start Death Star software running. 

For faster testing after inital EEPROM write you can use Project > Run (F10) to program volatile RAM.

***

Questions? Contact me on X (formely Twitter): @X_BlazeSanders <br> 

Donations accepted via Cash App: $blazesanders42 

![CashAppQR-BlazeCropped](https://github.com/OpenSourceIronman/DeathStarInSpace/assets/28512994/ffe3e3be-d0be-4a93-8adf-7dedd0d704f9)

