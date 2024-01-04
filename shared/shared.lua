Shared = {
    LockNPCVehicle = true, -- lock all npc vehicles
    playerDraggable = true, -- allow players to drag other players
    toggleLightsOnlyRemote = true, -- true if you want the vehicle lights to toggle only when not in the vehicle
    steal = {
        available = true, -- allow players to carjack vehicles
        getKey = true, -- if true you get a permanent instead of a temporary key
        label = 'Stealing Vehicle...',
        minTime = 5000,
        maxTime = 7000,
        stressIncrease = math.random(1, 3),
        chance = {
            ['2685387236'] = 0.0, -- melee
            ['416676503'] = 0.5, -- handguns
            ['-957766203'] = 0.75, -- SMG
            ['860033945'] = 0.90, -- shotgun
            ['970310034'] = 0.90, -- assault
            ['1159398588'] = 0.99, -- LMG
            ['3082541095'] = 0.99, -- sniper
            ['2725924767'] = 0.99, -- heavy
            ['1548507267'] = 0.0, -- throwable
            ['4257178988'] = 0.0, -- misc
        }
    },
    lockpick = {
        stressIncrease = math.random(1, 3),
        breakChance = 0.5,
        advancedBreakChance = 0.1
    },
    grab = { -- grab a dead npc out of a vehicle
        label = 'Robbing Vehicle...',
        minTime = 5000,
        maxTime = 7000,
    },
    hotwire = { -- hotwire a vehicle
        label = 'Hotwiring Vehicle...',
        chance = 1.0,
        minTime = 2000,
        maxTime = 3000,
        stressIncrease = math.random(1, 3)
    },
    BlackListedWeapon = {
        "WEAPON_UNARMED",
        "WEAPON_Knife",
        "WEAPON_Nightstick",
        "WEAPON_HAMMER",
        "WEAPON_Bat",
        "WEAPON_Crowbar",
        "WEAPON_Golfclub",
        "WEAPON_Bottle",
        "WEAPON_Dagger",
        "WEAPON_Hatchet",
        "WEAPON_KnuckleDuster",
        "WEAPON_Machete",
        "WEAPON_Flashlight",
        "WEAPON_SwitchBlade",
        "WEAPON_Poolcue",
        "WEAPON_Wrench",
        "WEAPON_Battleaxe",
        "WEAPON_Grenade",
        "WEAPON_StickyBomb",
        "WEAPON_ProximityMine",
        "WEAPON_BZGas",
        "WEAPON_Molotov",
        "WEAPON_FireExtinguisher",
        "WEAPON_PetrolCan",
        "WEAPON_Flare",
        "WEAPON_Ball",
        "WEAPON_Snowball",
        "WEAPON_SmokeGrenade",
    }
}