# Kiwi-K Mixer
Kiwi-K Mixer is a Lua script for [EdgeTX](https://edgetx.org/) transmitters designed to make setting up and editting model mixes quick and easy, tailored to combat robotics users.

## Introduction
Setting a model mix on an EdgeTX transmitter can be a less-than-intuitive process for beginners, and can still be time consuming for experienced users.  Kiwi-K (Quick) Mixer is an attempt to solve this problem utilizing the [Lua](https://www.lua.org/about.html) scripting language built into EdgeTX Transmitters

The Kiwi-K Mixer creates a user interface that prompts the user to provide the channel inputs desired for their mix.  Upon completion, the mix is automatically written to the active EdgeTX model.  After creating the mix, the Kiwi-K mixer has addition feature to allow the user to further tune or edit the robot.  These include inverting the direction of drive motors, inverting the steering, and adjusting the rates of turning and straightline movement. 

## Installing Kiwi-K Mixer

*Kiwi-K Mixer is currently designed to with Black/White EdgeTX controllers only (no color screens).* 

## Using Kiwi-K Mixer
The Kiwi-K Mixer can be accessed through the "Tools" menu of your transmitter.  The "Tools" menu can be accessed by long pressing the "Model" key.  On transmitters with a "SYS" key, the "SYS" key can be pressed instead to access the tools menu.


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

The `Has motor` option is intended for robots that have a spinning KE weapon (usually a brushless motor).  If selected, setup pages asking the user to define inputs for a throttle control and arming switch.  The `Has servo` option is intended for flipper/lifter robots that use a servo as their main actuator.  If required for the robot configuration, both options can be selected (i.e. for a hammersaw-style robot).

<img width="384" height="192" alt="define_filled" src="https://github.com/user-attachments/assets/ea5304b1-d384-4297-8859-f843372d666f" />

&nbsp;

Based on the selected options on the model definition page, the following page will provide a wiring template for the user.  The robot outputs listed should be plugged into the various reciever channels as directed.  If the motor or servo is not selected on the robot definition page, instructions for wiring the motor and server will be omitted to limit confusion.

Due to limitations of the Kiwi-K Mixer implementation, custom output definitions are not supported at this time.  As the script does not store additional information about the model to an external file, it would not be possible for the script to remember a custom reciever wiring for each model.

<img width="384" height="192" alt="wiring" src="https://github.com/user-attachments/assets/3ea5aca0-0d79-40f6-929a-e4a01157285c" />

&nbsp;



If `Has motor` was selected, the next


## Editting an Existing Model
