composer = ""
charter = ""
art = ""

function onCreate()
    makeLuaSprite("creditsButton", "creditsButton", 0, 0)
    setProperty("creditsButton.visible", false)
    screenCenter("creditsButton", 'xy')
    setObjectCamera("creditsButton", 'hud')
    addLuaSprite("creditsButton")

    makeLuaText("Credits", "SONG BY: "..composer.."\nCHART BY: "..charter.."\nART BY: "..art, 0, 420, 290)
    setObjectCamera("Credits", 'hud')
    setTextSize("Credits", 45)
    setTextFont("Credits", "arial.ttf")
    setTextBorder("Credits", 0)
    setTextAlignment("Credits", 'left')
    setProperty("Credits.visible", false)
    addLuaText("Credits")

end

function onCredits(creditsVisible)
    setTextString("Credits", "SONG BY: "..composer.."\nCHART BY: "..charter.."\nART BY: "..art)
    setProperty("creditsButton.visible", creditsVisible)
    setProperty("Credits.visible", creditsVisible)
end

function onUpdate()
    if songName == "anti_drop" then
        
        composer = "HeyMega"
        charter = "cronbi"
        art = "JP13, ALEXX"

        if curStep == 65 then
            onCredits(true)
        end
        if curStep == 128 then
            onCredits(false)
        end  
    end
end