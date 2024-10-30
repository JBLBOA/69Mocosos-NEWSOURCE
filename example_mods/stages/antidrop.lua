function onCreate()
    makeLuaSprite("BG", "", -400, -300)
    makeGraphic("BG", 3000, 3000, 'ffffff')
    addLuaSprite("BG", false)

    makeLuaSprite("BGTEXT", "", 196, 500)
    makeGraphic("BGTEXT", 300, 25, '000000')
    setProperty("BGTEXT.alpha", 0.5)
    setProperty("BGTEXT.visible", false)

    makeAnimatedLuaSprite("gang", "BG/ANTIDROP/thegang", 0, 0, "sparrow")
    scaleObject("gang", 1.2, 1.2)
    addLuaSprite("gang")

    makeAnimatedLuaSprite("gang2", "BG/ANTIDROP/thegang2", 400, 560, "sparrow")
    scaleObject("gang2", 1.5, 1.5)
    setScrollFactor("gang2", 2.5, 1.0)
    addLuaSprite("gang2", true)   

    makeLuaText("sonijoin", "soni joined the game", 0, getProperty("BGTEXT.x"), getProperty("BGTEXT.y"))
    setTextFont("sonijoin", "Minecraft.ttf")
    setTextSize("sonijoin", 20)
    setTextBorder("sonijoin", 2, "000000")
    setTextColor("sonijoin", "FBFF00")
    setProperty("sonijoin.visible", false)

    makeAnimatedLuaSprite("entrada", "BG/ANTIDROP/SONIENTRANCE", 170, -200, "sparrow")
    scaleObject("entrada", 0.8, 0.8)
    addLuaSprite("entrada")   

    makeLuaSprite("screen", "BG/ANTIDROP/screen", 0, 0)
    scaleObject("screen", 0.6, 0.6)

    --HUD
    addLuaSprite("BGTEXT")   
    setObjectCamera("BGTEXT", 'hud')
    addLuaText("sonijoin")
    setObjectCamera("sonijoin", 'hud')

    --OTHER
    addLuaSprite("screen")
    setObjectCamera("screen", 'other')
end
function onCreatePost()
    setProperty("dad.visible", false)
    setProperty("entrada.alpha", 0)

    setProperty("healthBar.y", getProperty("healthBar.y") - 20)
    setProperty("iconP1.y", getProperty("iconP1.y") - 40)
    setProperty("iconP2.y", getProperty("iconP2.y") - 35)
    setProperty("scoreTxt.y", getProperty("scoreTxt.y") - 30)
    setProperty("songNameTXT.y", 650)
    setProperty("songNameTXT.x", 200)

    noteTweenX("NOTE0X", 0, -1000, 0.1, "linear")
    noteTweenX("NOTE1X", 1, -1000, 0.1, "linear")
    noteTweenX("NOTE2X", 2, -1000, 0.1, "linear")
    noteTweenX("NOTE3X", 3, -1000, 0.1, "linear")

    noteTweenX("NOTE4X", 4, defaultOpponentStrumX3, 0.1, "linear")
    noteTweenX("NOTE5X", 5, defaultOpponentStrumX3 + 100, 0.1, "linear")
    noteTweenX("NOTE6X", 6, defaultOpponentStrumX3 + 200, 0.1, "linear")
    noteTweenX("NOTE7X", 7, defaultOpponentStrumX3 + 300, 0.1, "linear")

    noteTweenY("NOTE4Y", 4, defaultOpponentStrumY0 + 50, 0.1, "linear")
    noteTweenY("NOTE5Y", 5, defaultOpponentStrumY0 + 50, 0.1, "linear")
    noteTweenY("NOTE6Y", 6, defaultOpponentStrumY0 + 50, 0.1, "linear")
    noteTweenY("NOTE7Y", 7, defaultOpponentStrumY0 + 50, 0.1, "linear")

end

function onSectionHit()
    addAnimationByPrefix("gang", "gangIDLE", "backgroundguys", 24, false)
    addAnimationByPrefix("gang2", "gangIDLE2", "THEGANG", 24, false)
end

function onUpdate()
    if curStep == 164 then
        addAnimationByPrefix("entrada", "entradaIDLE", "ENTRANCE", 24, false)

        setProperty("sonijoin.visible", true)
        setProperty("BGTEXT.visible", true)
        runTimer("tweenTimeSONIENTRO", 1)

        doTweenAlpha("entradaALPHA", "entrada", 1, 0.5, "linear")
    end
end

function opponentNoteHit()
    setProperty("dad.visible", true)
    setProperty("entrada.visible", false)
end

function onTimerCompleted(t)
    if t == "tweenTimeSONIENTRO" then
        doTweenAlpha("BGTEXTALPHA", "BGTEXT", 0, 1.5, "linear")
        doTweenAlpha("sonijoinALPHA", "sonijoin", 0, 1.5, "linear")

    end
end