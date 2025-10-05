# Kiwi-K Mixer
Kiwi-K Mixer is a Lua script for [EdgeTX](https://edgetx.org/) transmitters designed to make setting up and editting model mixes quick and easy, tailored to combat robotics users.

## Introduction
Setting a model mix on an EdgeTX transmitter can be a less-than-intuitive process for beginners, and can still be time consuming for experienced users.  Kiwi-K (Quick) Mixer is an attempt to solve this problem utilizing the [Lua](https://www.lua.org/about.html) scripting language built into EdgeTX Transmitters

The Kiwi-K Mixer creates a user interface

## Installing Kiwi-K Mixer

*Kiwi-K Mixer is currently designed to with Black/White EdgeTX controllers only (no color screens).* 

## Using Kiwi-K Mixer
The Kiwi-K Mixer can be accessed through the "Tools" menu of your transmitter.  The "Tools" menu can be accessed by long pressing the "Model" key.  On transmitters with a "SYS" key, the "SYS" key can be pressed instead to access the tools menu.


Use the scroll wheel to navigate the list of tools, and select the "Kiwi-K Mixer" using the enter key.

### Creating a New Model
Kiwi-K Mixer edits the model currently active/selected in the EdgeTX environment.  Kiwi-K Mixer will overwrite the active model when creating a new mix, so it is recommended to create a new model.  The name and first-page settings of the model are not touched by Kiwi-K Mixer, so the process of naming the radio model and binding recievers is not changed.

To create a new model, select the `Setup New Robot` menu option on the home page.

Kiwi-K Mixer will first warn the user about the potential risks of overwriting radio models.

<img width="384" height="192" alt="kiwik_menu" src="https://github.com/user-attachments/assets/0969a41e-6d35-416b-ba20-c0073a2be8db" />

&nbsp;

The following page prompts the user to provide information about their robot configuration with the following options:
&nbsp;
`Has motor`
&nbsp;
`Has servo`

The `Has motor` option is intended for robots that have a spinning KE weapon (usually a brushless motor).  If selected, setup pages asking the user to define inputs for a throttle control and arming switch. 


### Editting an Existing Model
