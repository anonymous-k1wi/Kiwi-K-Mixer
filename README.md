# Kiwi-K Mixer
Kiwi-K (Quick) Mixer is a Lua script for [EdgeTX](https://edgetx.org/) transmitters designed to make setting up and editting model mixes quick and easy, tailored to combat robotics users.

## Introduction
Setting a model mix on an EdgeTX transmitter can be a less-than-intuitive process for beginners, and can still be time consuming for experienced users.  Kiwi-K (Quick) Mixer is an attempt to solve this problem utilizing the [Lua](https://www.lua.org/about.html) scripting language built into EdgeTX Transmitters

The Kiwi-K Mixer creates a user interface that prompts the user to provide the channel inputs desired for their mix.  Upon completion, the mix is automatically written to the active EdgeTX model.  After creating the mix, the Kiwi-K mixer has addition editting menu to allow the user to further edit or tune the robot.  The editting menu includes controls to invert the direction of drive motors, reverse the steering, and adjust the rates of robot turning and straightline movement.  These editting features are aimed at reducing repair times and improving driving ability.

## Installing Kiwi-K Mixer

*Kiwi-K Mixer is currently designed to with Black/White EdgeTX controllers only (no color screens).* 

## Using Kiwi-K Mixer
The Kiwi-K Mixer can be accessed through the "Tools" menu of your transmitter.  The "Tools" menu can be accessed by a long press on the "Model" (MDL) key.  On transmitters with a "System" key, the "System" (SYS) key can be pressed instead to access the tools menu.


Use the scroll wheel to navigate the list of tools, and select the "Kiwi-K Mixer" using the enter key.

## Creating a New Model
To create a new model, select the `Setup New Robot` menu option on the home page.

<img width="384" height="192" alt="kiwik_menu" src="https://github.com/user-attachments/assets/0969a41e-6d35-416b-ba20-c0073a2be8db" />

<sup> *Main menu page of the Kiwi-K Mixer Lua script* </sup>

&nbsp;

Kiwi-K Mixer will first warn the user about the potential risks of overwriting radio models.  Kiwi-K Mixer edits the model currently active/selected in the EdgeTX environment.  Kiwi-K Mixer will overwrite the active model when creating a new mix, so it is recommended to create a new model.  The name and first-page settings of the model are not touched by Kiwi-K Mixer, so the process of naming the radio model and binding recievers is not changed.

<img width="384" height="192" alt="setup_warning" src="https://github.com/user-attachments/assets/7c352afa-c71c-4202-9229-8dc6ba7d3fa3" />

<sup> *User warning for creating new model mix* </sup>

&nbsp;

The following page prompts the user to provide information about their robot configuration with the following options:

`Has motor`

`Has servo`

<img width="384" height="192" alt="define_empty" src="https://github.com/user-attachments/assets/792449fc-25f4-447a-85e0-8ea135f34cb6" />

<sup> *Robot defintion page* </sup>

The `Has motor` option is intended for robots that have a spinning KE weapon (usually a brushless motor).  If selected, setup pages asking the user to define inputs for a throttle control and arming switch.  The `Has servo` option is intended for flipper/lifter robots that use a servo as their main actuator.  If required for the robot configuration, both options can be selected (i.e. for a hammersaw-style robot).

<img width="384" height="192" alt="define_filled" src="https://github.com/user-attachments/assets/ea5304b1-d384-4297-8859-f843372d666f" />

<sup> *Robot definition page with both inputs selected* </sup>

&nbsp;

Based on the selected options on the model definition page, the following page will provide a wiring template for the user.  The robot outputs listed should be plugged into the various reciever channels as directed.  If the motor or servo is not selected on the robot definition page, instructions for wiring the motor and server will be omitted to limit confusion.

Due to limitations of the script implementation, custom output definitions are not supported at this time.  As the script does not store additional information about the model to an external file, it is not be possible for the script to remember a custom reciever wiring for each model.

<img width="384" height="192" alt="wiring" src="https://github.com/user-attachments/assets/3ea5aca0-0d79-40f6-929a-e4a01157285c" />

<sup> *Reciever wiring setup page (with both motor and servo showing)* </sup>

&nbsp;

If `Has motor` was selected, the next page will include a prompt to set a transmitter input for the weapon motor.  To begin editing, the "Enter" button on the radio can be pressed.  To select an input, the desired input on the transmitter can be moved, which will automatically load the input into the selection box.  Alternatively, the scroll wheel can be used to manually select an input.  Once an input is selected, a small check mark will appear next to the input.  To save the selection, the "Enter" button should be pressed again.

<img width="384" height="192" alt="weapon" src="https://github.com/user-attachments/assets/06c5fac8-1ed4-49c6-8c26-73170ded98b6" />
<img width="384" height="192" alt="weapon_filled" src="https://github.com/user-attachments/assets/26a7e5d6-ebb7-4961-935a-d82d39a4d8e9" />

<sup> *Weapon input setup page (left: no input selected, right: input selected and acknowledged)* </sup>

&nbsp;

If `Has servo` was selected, the following page will include a prompt for the servo transmitter input and the center position of the servo (used for safety switch).  The disarm position of the servo is not able to be edited until the transmitter input channel has been set. The servo center position defaults to a value of `0`, corresponding to the mid point on the servo.  The values of the center position are limited between `-100` and `100`, corresponding to the standard mix output.  For the setup menu, values are limited to steps of 5 to reduce scrolling time.  If additional precision is needed, the servo disarm position can be later changed in steps of 1 in the Kiwi-K Mixer editing menu.

<img width="384" height="192" alt="servo_filled" src="https://github.com/user-attachments/assets/e329b5b2-3b65-4e61-a165-627649367fe9" />

<sup> *Servo setup page with example input (input selected and acknowledged, disarm pos. active)* </sup>

&nbsp;

If either `Has motor` or `Has servo` was selected, the user is required to provide a safety switch input (arming).  The purpose of the switch is to add an additional safety system to protect the user from potential unintentional movement of the robot.  This safety switch immediately overides the weapon motor and servo channels to -100 and the "servo disarm" value, respectively.  The input on this page is limited to switches on the transmitter, and saves the "disarmed" position of the switch (no movement).

<img width="384" height="192" alt="safety_filled" src="https://github.com/user-attachments/assets/adef8e9d-ba8b-41ba-bb78-00cb33c5f456" />

<sup> *Safety switch setup page with example input* </sup>

**A SAFETY SWITCH IS NOT A SUBSTITUTE FOR A PHYSICAL WEAPON LOCK THAT PREVENTS THE MOVEMENT OF THE ROBOT.  A PROPER WEAPON LOCK AND TEST BOX SHOULD *ALWAYS* BE USED WHEN WORKING WITH KINETIC ENERGY WEAPONS.  YOU ARE RESPONSIBLE FOR YOUR OWN SAFETY AND THE SAFETY OF THOSE AROUND YOU.**

&nbsp;

The next page prompts the user for the forward/backward (straightline) and left/right (turning) transmitter inputs.  If neither `Has motor` or `Has servo` was selected, those pages will be skipped.

<img width="384" height="192" alt="drive_filled" src="https://github.com/user-attachments/assets/ecdaa352-0972-44b8-9a6e-60c9df2844a8" />

<sup> *Drive setup page with example inputs* </sup>

&nbsp;

The final page provides an "Exit" button for the setup, which will display a prompt to either save and exit or exit without saving by pressing the "enter" button.  If all inputs in the previous pages are not defined, the user will see the option to exit without saving.  To save and exit, ***all*** inputs must be properly defined in the proceeding pages.

<img width="384" height="192" alt="exit_no_save" src="https://github.com/user-attachments/assets/ea740a9b-ac03-4ae1-9b82-41847c79fe7a" />
<img width="384" height="192" alt="save_and_exit" src="https://github.com/user-attachments/assets/aefeafa7-34d8-4f4e-99de-d224606e242f" />

<sup> *Exit page (left: fields empty, user can exit without saving, right: all fields filled, user can save and exit)* </sup>

## Editting an Existing Model
To edit an existing model, select the `Update Settings` menu option on the home page.

&nbsp;

Kiwi-K Mixer will first warn the user that robots must be set up by the Kiwi-K Mixer prior to being edited.  If a robot is not set up with the Kiwi-K Mixer first, it is not gauranteed to work with the editor (due to channel definitions).

&nbsp;

The editing page contains the following set of options based on some of the most common issues users run into when mixing a robot.  The following options are given:

* **Invert Left Motor:** This will invert the left motor response.  If speed controller is flipped or the motor is wire soldering is reversed, this option allows the user to reverse the motor without resoldering or reflashing.
* **Invert Right Motor:** This will invert the right motor response.  If speed controller is flipped or the motor is wire soldering is reversed, this option allows the user to reverse the motor without resoldering or reflashing.
* **Invert Steering:**  This inverts the turning direction of the mix.  This does not flip individual motors, but flips just the steering of portion of both motors.  This only occurs if the left and right motor wiring does not match the suggested wiring.
* **Straight Speed:**  Numerical variable for the weight of the forward/backward portion of the mix.  The default value is `100` (maximum).  If this is too fast for your robot, it can be turned down to a desired value.
* **Steering Speed:**  Numerical variable for the weight of the left/right portion of the mix.  The default value is `30`, as many beginners tend to not weight this variable at all and have a hard time accurately turning (severe oversteer).  If desired, this can be turned up or down.  (If sufficient user feedback determines a better defualt value, this value is subject to change in the future).
* **Servo Disarm Position:**  If `Has servo` was selected for the model, the disarm position of the servo can be changed here.  If it was not selected for the model, then this line will not appear.

<img width="384" height="192" alt="edit_menu" src="https://github.com/user-attachments/assets/64002fa0-b77e-41a4-af6e-93a0ec4d8980" />

