# convobro
A library for managing dialogue.

### Setup
Download the .zip of convobro. Then, extract the .zip, and copy the convobro.lua file into your project directory. Afterwards, write `convobro = require "convobro"`. All done!


## Tutorial
> [!IMPORTANT]
> This tutorial assumes you are using Löve2D.

### Make a dialogue list
A dialogue list can be made using `convobro.buildDialogueListFromText(text)`, where each line of `text` is a different dialogue object. For example:

```
local talk = convobro.buildDialogueListFromText(
[[Hello, there.
Hello, back!
Thank you.]])
```

The object this creates, a dialogue list object, can be passed into other convobro functions seemlessly. No tweaking or fussing required, convobro will handle it.

### Use the dialogue list
Below is an example of how to use dialogue lists.

```
local convobro = require "convobro" -- Initializes the convobro library.

function love.load()
    Things = convobro.buildDialogueListFromText(
[[Hello! I'm a big fat stinky fart.
That's you, hahaha!]]) -- Create the dialogue list.

    convobro.startDialogue(Things) -- Play the dialogue list.
end

function love.update()
    convobro.updateDialogueList(Things) -- Update the dialogue list (rendering characters one after the other).
end

function love.draw()
    convobro.drawDialogue(Things, 10, 10, 1000, "left") -- Draw the dialogue to the screen (uses love.graphics.printf).
end

function love.mousepressed()
    convobro.advanceDialogueList(Things, true) -- Advances to the next bit of dialogue every time you click.
end
```

Dialogue can also include tags, being in-text commands to alter the dialogue in some way. Below is a list of all the tags convobro supports.

- `/wait:XXX` waits XXX frames.
- `/ci:XXX` sets the character interval to XXX frames (the amount of frames between when each character is shown on the screen).
- `/person:XXX` sets the person speaking to XXX.
- `/color:RRR,GGG,BBB` sets the R, G, and B color channels of the text to RRR, GGG, and BBB respectively (RGB channels in 0..1).
- `/n` adds a new line character.
- `/shaky:XXX` sets how shaky the text is.

Now, we're able to add these tags into the dialogue text to add more life. For example, instead of writing...

```
Things = convobro.buildDialogueListFromText(
[[Hello! I'm a big fat stinky fart.
That's you, hahaha!]])
```

We could instead write...

```
Things = convobro.buildDialogueListFromText(
[[/person:Jared /ci:5 Hello! I'm a big /wait:10 fat /wait:10 stinky /wait:10 /ci:10 /color:1,0,0 fart.
/person:Mared /ci:5 That's you, /wait:10 /shaky:3 hahaha!]])
```

All done! That's all the knowledge needed to use convobro.
