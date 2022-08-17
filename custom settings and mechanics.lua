local csettings = {
    --edit it whatever you want
    version = '0.9.2 / 1w25a', --just here for shit
    showAnnoyingScriptVersion = true, --toggle it off please
    allowBonusHp = true, --tabi style, too lazy to do with custom health bars
    showHpValue = true,
    showBonusHp = true, --must have showHpValue and allowBonusHp activated at the same time
    maximumHpBonus = 2.0, --default : 2.0
    negativeHealthReduce = 1.0, --default : 1.0
    customStartingHealth = nil, --still not completely work yet
    --this makes you start at 100% HP but you still have 50% if you take a look
    --however you also have 50% negative hp, and if you lose them all, you blue ball.
    negaHealthRegen = true, --if false, you must rap to reach the normal and no one will help ya
    nhRegenPerSec = .07, --must have negaHealthRegen active!

    tiltScreenWhenRap = false, --i dont need to say about this am I right?

    kadeStyleInput = false --if false, you get psych engine style; if true, hehehehe
    --may not be capable with low-end pcs

    --you can add a wishOfLiving parameters in it so when bf get nega health he become op until he no longer has nega hp -Technoblade
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
    if csettings.showAnnoyingScriptVersion then
        makeLuaText('version','Current CreamyModify version: '..csettings.version,800,0,0)
        addLuaText('version')
    end
    if csettings.showHpValue then
        if csettings.showBonusHp then
            hpshowmode = 2 -- bonus hp
        else
            hpshowmode = 1 -- only property 'health'
        end
        if downscroll then
            makeLuaText('healthTxt','50%',screenWidth*0.3,screenWidth*0.65,screenHeight*0.1)
        else
            makeLuaText('healthTxt','50%',screenWidth*0.3,screenWidth*0.65,screenHeight*0.9)
        end
        setTextSize('healthTxt',30)
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
        if bonusHealth+health > csettings.negativeHealthReduce and bonusHealth+health < csettings.negativeHealthReduce-2 then
            setHealth(bonusHealth+health-csettings.negativeHealthReduce)
            health=getHealth()
            bonusHealth=csettings.negativeHealthReduce
        end
        if bonusHealth+health < csettings.negativeHealthReduce then --keeping nega health
            bonusHealth = bonusHealth + health - 0.000002
            setHealth(0.000002)
            health=0.000002
            if bonusHealth+health > csettings.negativeHealthReduce and bonusHealth+health < csettings.negativeHealthReduce-2 then
                setHealth(bonusHealth+health-csettings.negativeHealthReduce)
                health=getHealth()
                bonusHealth=csettings.negativeHealthReduce
            end
        end
        if health > 2 then -- when the ordinal hp is over 100%
            bonusHealth = bonusHealth + health - 2
            setHealth(2)
            health=2
        end
        if bonusHealth+health > csettings.negativeHealthReduce+2 then --extra health
            bonusHealth = bonusHealth + health - 2
            setHealth(2)
            health=2
            if bonusHealth+health > csettings.negativeHealthReduce and bonusHealth+health < csettings.negativeHealthReduce-2 then
                setHealth(bonusHealth+health-csettings.negativeHealthReduce)
                health=getHealth()
                bonusHealth=csettings.negativeHealthReduce
            end
        end
        if health < 0.000002 then
            bonusHealth = bonusHealth + health - 0.000002
            setHealth(0.000002)
            health=0.000002
        end
        if health + bonusHealth <= 0 then --you blue ball when you have no health left
            setHealth(0)
            health=0
        end
        ingameHpBarPosit = bonusHealth - csettings.negativeHealthReduce
        if bonusHealth < csettings.negativeHealthReduce then
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