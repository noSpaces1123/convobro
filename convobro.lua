-- BSD 3-Clause License

-- Copyright (c) 2025, frazy

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.

-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.

-- 3. Neither the name of the copyright holder nor the names of its
--    contributors may be used to endorse or promote products derived from
--    this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local convobro = { version = "1.1" }




local assertMessage = function (tag, dialogueObject, message)
    return "(\"" .. dialogueObject.targetText .. "\") " .. tag .. "\n-> " .. message
end

local function updateTimer(timer, dt, completeFunction, speed)
    if timer.running ~= nil and not timer.running then return timer end
    timer.current = timer.current + (speed and speed or timer.speed) * dt
    if timer.current > timer.max then
        repeat
            timer.current = timer.current - timer.max
            if completeFunction then completeFunction()
            elseif timer.completeFunction then timer.completeFunction() end
        until timer.current < timer.max
    end
    return timer
end

local function getChar(str, index)
    return string.sub(str, index, index)
end

local function split(str, separator)
    assert(not separator or #separator <= 1, "separator must be nil or must be 0 or 1 characters long.")
    local t = ((separator and #separator > 0) and {""} or {})
    for i = 1, #str do
        local char = string.sub(str,i,i)
        if separator and #separator > 0 then
            if char == separator then
                t[#t+1] = ""
            else
                t[#t] = t[#t]..char
            end
        else
            t[#t+1] = char
        end
    end
    return t
end

local function jitter(amplitude)
    return (math.random()-math.random())*amplitude
end

local tags = {
    ["/wait"] = function (dialogueObject, following, tag)
        assert(tonumber(following) >= 0, assertMessage(tag, dialogueObject, "Cannot wait a negative number of frames."))
        dialogueObject.wait.current = 0
        dialogueObject.wait.running = true
        dialogueObject.wait.max = tonumber(following)
    end,
    ["/ci"] = function (dialogueObject, following, tag)
        if following == "d" then
            dialogueObject.charInterval.max = dialogueObject.charInterval.defaultMax
        else
            assert(tonumber(following) > 0, assertMessage(tag, dialogueObject, "Char interval cannot be set to a number ≤ 0."))
            dialogueObject.charInterval.max = tonumber(following)
        end
    end,
    ["/person"] = function (dialogueObject, following, tag)
        dialogueObject.person = following
    end,
    ["/color"] = function (dialogueObject, following, tag)
        local components = split(following, ",")
        dialogueObject.color = { components[1], components[2], components[3], (components[4] and components[4] or 1) }
    end,
    ["/n"] = function (dialogueObject, following, tag)
        dialogueObject.textThusFar = dialogueObject.textThusFar .. "\n"
    end,
    ["/shaky"] = function (dialogueObject, following, tag)
        dialogueObject.shaky = tonumber(following)
    end,
}

local function readChar(dialogueObject)
    if getChar(dialogueObject.targetText, dialogueObject.charIndex) == "/" and getChar(dialogueObject.targetText, dialogueObject.charIndex + 1) ~= "/" and getChar(dialogueObject.targetText, dialogueObject.charIndex - 1) ~= "/" then
        local fullTag = split(string.sub(dialogueObject.targetText, dialogueObject.charIndex), " ")[1]
        dialogueObject.charIndex = dialogueObject.charIndex + #fullTag

        local components = split(fullTag, ":")

        tags[components[1]](dialogueObject, components[2], fullTag)
    else
        dialogueObject.textThusFar = dialogueObject.textThusFar .. getChar(dialogueObject.targetText, dialogueObject.charIndex)
    end

    return dialogueObject
end

local function addNextChar(dialogueObject)
    dialogueObject = readChar(dialogueObject)
    dialogueObject.charIndex = dialogueObject.charIndex + 1
    if dialogueObject.charIndex > #dialogueObject.targetText then
        dialogueObject.running = false
    end
end



--Creates a dialogue object (table) that can be passed into other convobro functions. `text` is the text the dialogue reads, `color` is a table containing the RGB values for the color of the text when it is drawn, `person` is a string containing the speaker's name, and `charInterval` is an integer representing the number of frames between when each character is written.
function convobro.newDialogueObject(text, color, person, charInterval)
    return {
        targetText = text, color = color, person = person,
        textThusFar = "",
        charInterval = { current = 0, max = charInterval, defaultMax = charInterval },
        charIndex = 1,
        wait = { current = 0, max = 100, running = false },
        shaky = 0,
        running = false,
    }
end

--Creates a dialogue list (table containing dialogue objects) that can be passed into other convobro functions. 
function convobro.buildDialogueListFromText(text)
    local list = { iAmADialogueList = true, index = 1, running = false, onHold = false, dialogue = {} }
    local dialogueBits = split(text, "\n")
    for _, bit in ipairs(dialogueBits) do
        table.insert(list.dialogue, convobro.newDialogueObject(bit, {1,1,1}, nil, 3))
    end
    return list
end

--Starts a dialogue object or list. Returns `dialogueObjectOrList` after being updated.
function convobro.startDialogue(dialogueObjectOrList)
    dialogueObjectOrList.running = true
    if not dialogueObjectOrList.iAmADialogueList then
        dialogueObjectOrList.textThusFar = ""
        dialogueObjectOrList.charIndex = 1
    end
    return dialogueObjectOrList
end

--Updates a dialogue object. Must be called every frame. Returns `dialogueObject` after being updated.
function convobro.updateDialogueObject(dialogueObject)
    local dt = love.timer.getDelta() * 60

    if dialogueObject.wait.running then
        updateTimer(dialogueObject.wait, dt, function ()
            dialogueObject.wait.running = false
        end, 1)
    else
        updateTimer(dialogueObject.charInterval, dt, function ()
            addNextChar(dialogueObject)
        end, 1)
    end

    return dialogueObject
end

--Updates a dialogue list. Must be called every frame. Returns `dialogueList` after being updated.
function convobro.updateDialogueList(dialogueList)
    if not dialogueList.running or dialogueList.onHold then return end
    if not dialogueList.dialogue[dialogueList.index].running then convobro.startDialogue(dialogueList.dialogue[dialogueList.index]) end
    convobro.updateDialogueObject(dialogueList.dialogue[dialogueList.index])
    if not dialogueList.dialogue[dialogueList.index].running then
        dialogueList.onHold = true
    end
    return dialogueList
end

--Moves to the next dialogue in the list. If boolean `quickReveal` is true, if dialogue from `dialogueList` is currently playing, the rest of the dialogue will be instantly revealed. This function will need to be called again to move onto the next dialogue in the list.
function convobro.advanceDialogueList(dialogueList, quickReveal)
    local dialogueObject = dialogueList.dialogue[dialogueList.index]
    if not dialogueObject then return "fail" end
    if quickReveal and dialogueObject.running then -- quick reveal
        dialogueList.onHold = true

        repeat
            addNextChar(dialogueObject)
        until not dialogueObject.running
    else
        dialogueObject.running = false
        dialogueList.onHold = false
        dialogueList.index = dialogueList.index + 1
        if dialogueList.index > #dialogueList.dialogue then
            dialogueList.running = false
        end
    end
    return dialogueList
end

--Gets the text from a dialogue object or dialogue list.
function convobro.getText(dialogueObjectOrDialogueList)
    if not dialogueObjectOrDialogueList.running then return end
    if dialogueObjectOrDialogueList.iAmADialogueList then return dialogueObjectOrDialogueList.dialogue[dialogueObjectOrDialogueList.index].textThusFar
    else return dialogueObjectOrDialogueList.textThusFar end
end

function convobro.getPerson(dialogueObjectOrDialogueList)
    if not dialogueObjectOrDialogueList.running then return end
    if dialogueObjectOrDialogueList.iAmADialogueList then return dialogueObjectOrDialogueList.dialogue[dialogueObjectOrDialogueList.index].person
    else return dialogueObjectOrDialogueList.person end
end

--REQUIRES LÖVE2D! Draws dialogue using `love.graphics.printf`. Arguments `font` and those following are optional (can be left nil). Use `convobro.getText` to get the text to draw on the screen if you aren't using Löve2D.
function convobro.drawDialogue(dialogueObjectOrDialogueList, x, y, textBoxWidth, aligment, font, r, sx, sy, ox, oy, kx, ky)
    if not dialogueObjectOrDialogueList.running then return end
    local object
    if dialogueObjectOrDialogueList.iAmADialogueList then
        object = dialogueObjectOrDialogueList.dialogue[dialogueObjectOrDialogueList.index]
    else object = dialogueObjectOrDialogueList end

    if font then love.graphics.setFont(font) end
    love.graphics.setColor(object.color)
    love.graphics.printf(object.textThusFar, x + jitter(object.shaky), y + jitter(object.shaky), textBoxWidth, aligment, r, sx, sy, ox, oy, kx, ky)
end






return convobro