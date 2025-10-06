# Kiwi-K Mixer
Kiwi-K Mixer is a Lua script for [EdgeTX](https://edgetx.org/) transmitters designed to make setting up and editting model mixes quick and easy, tailored to combat robotics users.

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

<sup> *Model defintion page* </sup>

The `Has motor` option is intended for robots that have a spinning KE weapon (usually a brushless motor).  If selected, setup pages asking the user to define inputs for a throttle control and arming switch.  The `Has servo` option is intended for flipper/lifter robots that use a servo as their main actuator.  If required for the robot configuration, both options can be selected (i.e. for a hammersaw-style robot).

<img width="384" height="192" alt="define_filled" src="https://github.com/user-attachments/assets/ea5304b1-d384-4297-8859-f843372d666f" />

<sup> *Model definition page with both inputs selected* </sup>

&nbsp;

Based on the selected options on the model definition page, the following page will provide a wiring template for the user.  The robot outputs listed should be plugged into the various reciever channels as directed.  If the motor or servo is not selected on the robot definition page, instructions for wiring the motor and server will be omitted to limit confusion.

Due to limitations of the Kiwi-K Mixer implementation, custom output definitions are not supported at this time.  As the script does not store additional information about the model to an external file, it would not be possible for the script to remember a custom reciever wiring for each model.

<img width="384" height="192" alt="wiring" src="https://github.com/user-attachments/assets/3ea5aca0-0d79-40f6-929a-e4a01157285c" />

<sup> *Reciever wiring setup page (with both mootor and servo showing)* </sup>

&nbsp;

If `Has motor` was selected, the next page will include a prompt to set a transmitter input for the weapon motor.  To begin editing, the "Enter" button on the radio can be pressed.  To select an input, the desired input on the transmitter can be moved, which will automatically load the input into the selection box.  Alternatively, the scroll wheel can be used to manually select an input.  To save the selection, the "Enter" button should be pressed again.

&nbsp;

If `Has servo` was selected, the following page will include a prompt for the servo transmitter input and the center position of the servo (used for safety switch).  The servo center position defaults to a value of `0`, corresponding to the mid point on the servo.  The values of the center position are limited between `-100` and `100`, corresponding to the mix output.  For the setup menu, values are limited to steps of 5 to reduce scrolling time.  If additional precision is needed, the servo disarm position can be later changed in steps of 1 in the Kiwi-K Mixer editing menu.

&nbsp;

If either `Has motor` or `Has servo` was selected, the user is required to provide a safety switch input (arming).  The purpose of the switch is to add an additional safety system to protect the user from potential unintentional movement of the robot.  This safety switch immediately overides the weapon motor and servo channels to -100 and the "servo disarm" value, respectively.  The input on this page is limited to switches on the transmitter, and saves the "disarmed" position of the switch (no movement).

**The safety switch is not a substitue for a physical weapon lock that prevents movement of spinning parts.  A proper weapon lock and test box should always be used with working with kinetic energy weapons.  You are responsible for your own safety and the safety of those around you.**

&nbsp;

The next page prompts the user to input the forward/backward (straightline) and left/right (turning) transmitter inputs.  If neither `Has motor` or `Has servo` was selected, those pages will be skipped.

&nbsp;

The final page provides an "Exit" button for the setup, which will display a prompt to either save and exit or exit without saving.  If all inputs in the previous pages are not defined, the user will see the option to exit without saving.  To save and exit, *all* inputs must be properly defined in the proceeding pages.

## Editting an Existing Model
To create a new model, select the `Update Settings` menu option on the home page.
