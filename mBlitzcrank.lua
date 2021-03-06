local version = "1.2"
local ts

if myHero.charName ~= "Blitzcrank" then return end

require 'SOW'
require 'VPrediction'
require 'SourceLib'


	
function OnLoad()
	VPrediction = VPrediction()
	DManager = DrawManager()
	local SOW = SOW(VPrediction)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	DLib = DamageLib()
	
	local Combo = {_Q, _E, _R, _R, _IGNITE}
	local Ranges = {[_Q] = 925,      	 [_W] = 0,  	[_E] = 125,       [_R] = 450}
	local Widths = {[_Q] = 60,      	 [_W] = 0,  	[_E] = 0,				  [_R] = 450}
	local Delays = {[_Q] = 0.25,       [_W] = 0,    [_E] = 0,    	 	  [_R] = 0.25} 
	local Speeds = {[_Q] = 1800,	  	 [_W] = 0, 		[_E] = 0,    	 	  [_R] = 1100}
	
	PrintChat ("mBlitzCronk V1.2 By Mezoniz")
	
	--Menu
	Menu = scriptConfig("Blitzcrank", "Menu")
	Menu:addSubMenu("Target selector", "STS")		
	Menu:addSubMenu("Orbwalker", "Orbwalker")
	
	Menu:addSubMenu("Combo", "Combo")
	 Menu.Combo:addParam("Enabled", "Use Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	 Menu.Combo:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
   Menu.Combo:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
		
	Menu:addSubMenu("Ultimate", "R")
		Menu.R:addSubMenu("Don't use R on", "Targets")
		for i, enemy in ipairs(GetEnemyHeroes()) do
			Menu.R.Targets:addParam(enemy.hash,  enemy.charName, SCRIPT_PARAM_ONOFF, false)
		end
		
	Menu:addSubMenu("Drawings", "Drawings")
		DManager:CreateCircle((myHero), SOW:MyRange() + 50, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, "AA Range", true, true, true)	
		DManager:CreateCircle((myHero), 925 + 50, 1, {243, 100, 55, 255}):AddToMenu(Menu.Drawings, "Hook Range", true, true, true)	
				
	Menu:addSubMenu("Misc", "Misc")
	Menu.Misc:addParam("Qhitchance", "Q min hitchance(1 - insta cast)", SCRIPT_PARAM_SLICE, 1, 1, 2)
	SOW:LoadToMenu(Menu.Orbwalker)
	STS:AddToMenu(Menu.STS)
	Menu.Misc:addParam("SilenceR", "Use R to Silence Enemies", SCRIPT_PARAM_ONOFF, true)
	

	if string.find(player:GetSpellData(SUMMONER_1).name..player:GetSpellData(SUMMONER_2).name, "SummonerDot") ~= nil then
 local key = 114
 if player:GetSpellData(SUMMONER_1).name == "SummonerDot" then
 slot = SUMMONER_1
 elseif player:GetSpellData(SUMMONER_2).name == "SummonerDot" then
 slot = SUMMONER_2
 key = 115
 end
 
 	Menu.Misc:addParam("ADot", "Auto Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, key)
 castDelay = 0
 damagePerLevel = 20
 baseDamage = 50
 range = 600
 forced = false
 forcedTick = 0
	

	
Q = Spell(_Q, Ranges[_Q], false)
	E = Spell(_E, Ranges[_E], false)
	R = Spell(_R, Ranges[_R], false)
	
	Q:SetSkillshot (VPrediction, SKILLSHOT_LINEAR, Widths[_Q], Delays[_Q], Speeds[_Q], false)
	E:SetSkillshot (VPrediction, SKILLSHOT_CIRCULAR, Widths[_E], Delays[_E], Speeds[_E], false)
	R:SetSkillshot(VPrediction, SKILLSHOT_CIRCULAR, Widths[_R], Delays[_R], Speeds[_R], false)
	
		
	end
	end
	

	
function autoIgniteIfKill()
 if slot ~= nil and castDelay < GetTickCount() and player:CanUseSpell(slot) == READY then
 local damage = baseDamage + damagePerLevel * player.level
 for i = 1, heroManager.iCount, 1 do
 local hero = heroManager:getHero(i)
 if ValidTarget(hero, range) and hero.health <= damage then
 return igniteTarget( hero )
			end
		end
	end
 end
 
function autoIgniteLowestHealth()
 if slot ~= nil and castDelay < GetTickCount() and player:CanUseSpell(slot) == READY then
 local minLifeHero = nil
 for i = 1, heroManager.iCount, 1 do
 local hero = heroManager:getHero(i)
 if ValidTarget(hero, range) then
 if minLifeHero == nil or hero.health < minLifeHero.health then
 minLifeHero = hero
		end
	end
 end
 
 if minLifeHero ~= nil then
 return igniteTarget( minLifeHero )
		end
	end
 end
 
function igniteTarget(target)
 if slot ~= nil and castDelay < GetTickCount() and player:CanUseSpell(slot) == READY then
 CastSpell(slot, target)
 castDelay = GetTickCount() + 500
 return target
 end
 end
 
function Combo()
	if Menu.Combo then UseQ() end
	if Menu.Combo.useE then UseE() end
	if Menu.Combo.useR then UseR() end
end


function UseQ()
	for i, target in pairs(GetEnemyHeroes()) do
		local CastPosition, HitChance, Position = VPrediction:GetLineCastPosition(target, 0.6, 75, 650, 1800, myHero, true)
	if HitChance >= 1 and GetDistance(CastPosition) < 900 then
		CastSpell(_Q, CastPosition.x, CastPosition.z)
	end
	end
	end
	
	
function UseE()
 for i, target in pairs(GetEnemyHeroes()) do
	local CastPosition, HitChance = VPrediction:GetPredictedPos(myHero, 0.25, 0.25, myHero, false)
	if HitChance >= 2 and GetDistance(target) < 50 then
		CastSpell(_E, CastPosition.x, CastPosition.z)
		end
		end
		end
		
function UseR()
for i, target in pairs(GetEnemyHeroes()) do
	local CastPosition, HitChance = VPrediction:GetCircularCastPosition(myHero, 0.5, 350, 350, 0.5, myHero, false)
	if HitChance >= 2 and GetDistance(target) < 50 then
		CastSpell(_R, CastPosition.x, CastPosition.z)
	end
	end
	end




function OnProcessSpell(unit, spell)
        if Menu.Misc.SilenceR and unit ~= nil and unit.valid and unit.team == TEAM_ENEMY and CanUseSpell(_R) == READY and GetDistance(unit) <= 450 then
                if spell.name=="KatarinaR" or spell.name=="GalioIdolOfDurand" or spell.name=="Crowstorm" or spell.name=="DrainChannel"
                or spell.name=="AbsoluteZero" or spell.name=="ShenStandUnited" or spell.name=="UrgotSwap2" or spell.name=="AlZaharNetherGrasp"
                or spell.name=="FallenOne" or spell.name=="Pantheon_GrandSkyfall_Jump" or spell.name=="CaitlynAceintheHole"
                or spell.name=="MissFortuneBulletTime" or spell.name=="InfiniteDuress" or spell.name=="Teleport" or spell.name=="Meditate" then
                        CastSpell(_R, unit)
end
end
end


function OnTick(target)
			if Menu.Combo.Enabled then
		Combo()
	end
	
		local tick = GetTickCount()
 if Menu.forcedDot and (slot ~= nil and player:CanUseSpell(slot) == READY) then
 forced = true
 forcedTick = GetTickCount() + 2000
 end
 if forced then
 PrintFloatText(player,0,"Auto ignite forced")
 if autoIgniteLowestHealth() ~= nil or forcedTick < tick then
 forced = false
 
 elseif Menu.ADot or Menu.ADotOnKey then
autoIgniteIfKill()
	end
	end
	end	
	
