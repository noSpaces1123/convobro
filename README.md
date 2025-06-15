# convobro
A library for managing dialogue.

### Setup
Download the .zip of convobro. Then, extract the .zip, and copy the convobro.lua file into your project directory. Afterwards, write `convobro = require "convobro"`. All done!


## Tutorial
This tutorial assumes you are using Löve2D.

### Make a dialogue list
A dialogue list can be made using `convobro.buildDialogueList(text)`, where each line of `text` is a different dialogue object. For example