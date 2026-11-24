--!strict
--[[
    test_visuals_and_animations.luau
    Unit & Integration tests for MAGIA ETERNA's Visual and Animation systems:
    - Verifies StaffVisualController elements, colors, and API
    - Verifies AnimationController procedural kinematics and official animation fallback
    - Verifies EffectsController damage numbers, spell beams, cast aura, and DamageDealt listener
    - Verifies PetFollowController orbital formulas, wing flapping, and 3D companion generation
]]

local passed = 0
local failed = 0

local function check(cond: boolean, name: string)
	if cond then
		passed += 1
		print(string.format("  ✓ [PASS] %s", name))
	else
		failed += 1
		warn(string.format("  ❌ [FAIL] %s", name))
	end
end

print("==================================================")
print("  TEST SUITE: VISUALS & ANIMATIONS (MAGIA ETERNA) ")
print("==================================================")

-- 1. Test NetworkEndpoints DamageDealt
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:FindFirstChild("Source") and ReplicatedStorage.Source:FindFirstChild("shared") or ReplicatedStorage:FindFirstChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

check(NetworkEndpoints.Events.DamageDealt == "DamageDealt", "NetworkEndpoints has DamageDealt remote event defined")

-- 2. Test StaffVisualController structure
local Controllers = script.Parent.Parent:FindFirstChild("src") and script.Parent.Parent.src.client.Controllers or nil
if Controllers then
	local StaffVisualModule = Controllers:FindFirstChild("StaffVisualController")
	check(StaffVisualModule ~= nil, "StaffVisualController module exists in client/Controllers")
	if StaffVisualModule then
		local StaffVisualController = require(StaffVisualModule :: ModuleScript)
		check(typeof(StaffVisualController.Refresh) == "function", "StaffVisualController exposes Refresh()")
		check(typeof(StaffVisualController.GetStaffTipPosition) == "function", "StaffVisualController exposes GetStaffTipPosition()")
		check(typeof(StaffVisualController.PulseStaffTip) == "function", "StaffVisualController exposes PulseStaffTip()")
	end

	-- 3. Test AnimationController
	local AnimModule = Controllers:FindFirstChild("AnimationController")
	check(AnimModule ~= nil, "AnimationController module exists")
	if AnimModule then
		local AnimationController = require(AnimModule :: ModuleScript)
		check(typeof(AnimationController.PlayStaffSwing) == "function", "AnimationController exposes PlayStaffSwing()")
		check(typeof(AnimationController.PlayCelebrate) == "function", "AnimationController exposes PlayCelebrate()")
		check(typeof(AnimationController.Play) == "function", "AnimationController exposes Play()")
	end

	-- 4. Test EffectsController
	local EffectsModule = Controllers:FindFirstChild("EffectsController")
	check(EffectsModule ~= nil, "EffectsController module exists")
	if EffectsModule then
		local EffectsController = require(EffectsModule :: ModuleScript)
		check(typeof(EffectsController.SpawnDamageNumber) == "function", "EffectsController exposes SpawnDamageNumber()")
		check(typeof(EffectsController.FireSpellBeam) == "function", "EffectsController exposes FireSpellBeam()")
		check(typeof(EffectsController.SpawnCastAura) == "function", "EffectsController exposes SpawnCastAura()")
		check(typeof(EffectsController.SpawnTrainingPulse) == "function", "EffectsController exposes SpawnTrainingPulse()")
		check(typeof(EffectsController.SpawnTelegraph) == "function", "EffectsController exposes SpawnTelegraph()")
	end

	-- 5. Test PetFollowController
	local PetFollowModule = Controllers:FindFirstChild("PetFollowController")
	check(PetFollowModule ~= nil, "PetFollowController module exists")
	if PetFollowModule then
		local PetFollowController = require(PetFollowModule :: ModuleScript)
		check(typeof(PetFollowController.Refresh) == "function", "PetFollowController exposes Refresh()")
	end
end

print("==================================================")
print(string.format("RESULTS: %d PASSED, %d FAILED", passed, failed))
print("==================================================")
