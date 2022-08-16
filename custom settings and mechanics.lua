local csettings = {
    --edit it whatever you want
    allowBonusHp = true, --tabi style, too lazy to do with custom health bars
    showHpValue = true,
    showBonusHp = true, --must have showHpValue and allowBonusHp activated at the same time
    maximumHpBonus = 2.0, --default : 2.0
    negativeHealthReduce = 1.0, --default : 1.0
    customStartingHealth = nil,
    --this makes you start at 100% HP but you still have 50% if you take a look
    --however you also have 50% negative hp, and if you lose them all, you blue ball.
    negaHealthRegen = true, --if false, you must rap to reach the normal and no one will help ya
    nhRegenPerSec = .07, --must have negaHealthRegen active!

    tiltScreenWhenRap = false, --i dont need to say about this am I right?

    kadeStyleInput = false --if false, you get psych engine style; if true, hehehehe
    --may not be capable with low-end pcs
}

local defaultHealthBarX
local hpshowmode=0
local maxBonusHealth=csettings.maximumHpBonus
local kade=csettings.kadeStyleInput --also overwrites accuracy
local bonusHealth=0.0
local health=1.0
local regen=csettings.negaHealthRegen
local regenValue=csettings.nhRegenPerSec
local ingameHpBarPosit=0.0

function onCreatePost()
    if csettings.showHpValue then
        if csettings.showBonusHp then
            hpshowmode = 2 -- bonus hp
        else
            hpshowmode = 1 -- only property 'health'
        end
        if downscroll then
            makeLuaText('healthTxt','50%',screenWidth*0.3,screenWidth*0.8,screenWidth*0.15)
        else
            makeLuaText('healthTxt','50%',screenWidth*0.3,screenWidth*0.8,screenWidth*0.85)
        end
        setTextSize('healthTxt',20)
        addLuaText('healthTxt')
    end
    bonusHealth=csettings.negativeHealthReduce
    defaultHealthBarX = getProperty('healthBar.x')
    if csettings.customStartingHealth ~= nil then
        local customHealth = csettings.customStartingHealth
        if customHealth <= csettings.negativeHealthReduce then
            health=0.000002
            bonusHealth = customHealth
        end
    end
end

function onUpdate(elapsed)
    --happy birthday @megapixel! please remember his bday - Aug 16th
    health = getHealth()
    if csettings.allowBonusHp then --yep
        if bonusHealth > maxBonusHealth then --capped at maximum
            bonusHealth = maxBonusHealth
        end
        if (health+bonusHealth>=csettings.negativeHealthReduce) and (health+bonusHealth<=csettings.negativeHealthReduce+2) and (bonusHealth ~= csettings.negativeHealthReduce) then
            health = health+bonusHealth-csettings.negativeHealthReduce
            setHealth(health)
            bonusHealth = 2
        end
        if health + bonusHealth <= 0 then --you blue ball when you have no health left
            setHealth(0)
            health=0
        end
        if ingameHpBarPosit < 0 then --keeping nega health
            bonusHealth = bonusHealth - health + 0.000002
            setHealth(0.000002)
            health=0.000002
        end
        if ingameHpBarPosit > 0 then --extra health
            bonusHealth = bonusHealth + health - 2
            setHealth(2)
            health=2
        end
        if health > 2 then -- when the ordinal hp is over 100%
            bonusHealth = bonusHealth + health - 2
            setHealth(2)
            health=2
        end
        if health < 0.000002 then
            bonusHealth = bonusHealth - health + 0.000002
            setHealth(0.000002)
            health=0.000002
        end
        ingameHpBarPosit = bonusHealth - csettings.negativeHealthReduce
        if ingameHpBarPosit < 0 then
            if regen then --nega neutral regen
                bonusHealth = bonusHealth + regenValue * elapsed
            end
        end
    end
    if hpshowmode > 0 then
        if hpshowmode == 1 then
            setTextString('healthTxt',(math.floor(health*5000)/100)..'%')
        else
            setTextString('healthTxt',(math.floor((health+bonusHealth-csettings.negativeHealthReduce)*5000)/100)..'%') --ahh yes I absolutely love this
        end
    end
    setProperty('healthBar.x',defaultHealthBarX-320*ingameHpBarPosit) --being a tabi health bar B)
end
--wahooooooo