--!strict
--[[
    AnimationController.luau
    Client-side animation manager for MAGIA ETERNA.
    Features:
    - Hybrid Architecture: Official Roblox Animation Tracks + Fluid Procedural Motor6D Kinematics.
    - Zero dependencies on external asset approval: guaranteed fluid character casting in all environments.
    - Procedural Staff Cast Swing: dynamically articulates Right Shoulder and Torso with snappy recoil.
    - Procedural Celebrate / Victory Pose: lifts staff high with double-arm celebration.
    - Works identically on R15 and R6 character rigs.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local AnimationController = {}
local localPlayer = Players.LocalPlayer
local loadedTracks: { [string]: AnimationTrack } = {}

-- Standard official Roblox Core / Public Animation IDs
local ANIMATION_IDS: { [string]: string } = {
	StaffCast = "rbxassetid://507770453",    -- Official Point / Spellcast
	StaffSlash = "rbxassetid://522635514",   -- Official Sword / Staff Slash
	Celebrate = "rbxassetid://507770677",    -- Official Cheer / Rebirth
	ForgeHammer = "rbxassetid://507770268",  -- Official Wave / Strike
}

-- Finds the right arm Motor6D on R15 or R6
local function getRightArmJoint(): Motor6D?
	local char = localPlayer.Character
	if not char then return nil end

	-- R15: RightUpperArm -> RightShoulder
	local rightUpper = char:FindFirstChild("RightUpperArm")
	if rightUpper then
		local shoulder = rightUpper:FindFirstChild("RightShoulder") :: Motor6D?
		if shoulder then return shoulder end
	end

	-- R6: Torso -> Right Shoulder
	local torso = char:FindFirstChild("Torso")
	if torso then
		local shoulder = torso:FindFirstChild("Right Shoulder") :: Motor6D?
		if shoulder then return shoulder end
	end

	return nil
end

-- Finds the left arm Motor6D on R15 or R6
local function getLeftArmJoint(): Motor6D?
	local char = localPlayer.Character
	if not char then return nil end

	local leftUpper = char:FindFirstChild("LeftUpperArm")
	if leftUpper then
		local shoulder = leftUpper:FindFirstChild("LeftShoulder") :: Motor6D?
		if shoulder then return shoulder end
	end

	local torso = char:FindFirstChild("Torso")
	if torso then
		local shoulder = torso:FindFirstChild("Left Shoulder") :: Motor6D?
		if shoulder then return shoulder end
	end

	return nil
end

local function getAnimator(): Animator?
	local char = localPlayer.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return nil end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	return animator
end

-- Procedural Staff Swing: snappily thrusts arm forward and rotates staff, then recoils
local isSwinging = false
local defaultC0Right: CFrame? = nil

function AnimationController.PlayStaffSwing(customSpeed: number?)
	local joint = getRightArmJoint()
	if not joint then return end

	if not defaultC0Right then
		defaultC0Right = joint.C0
	end

	local baseC0 = defaultC0Right or joint.C0
	local duration = 0.18 / (customSpeed or 1)

	-- Cast forward target pose: arm forward and raised, angled inward
	local castPose = baseC0 * CFrame.Angles(math.rad(80), math.rad(-20), math.rad(30))

	-- Snappy forward snap (0.07s)
	local tweenForward = TweenService:Create(joint, TweenInfo.new(duration * 0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		C0 = castPose,
	})
	-- Smooth recoil return (0.11s)
	local tweenReturn = TweenService:Create(joint, TweenInfo.new(duration * 0.60, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		C0 = baseC0,
	})

	tweenForward:Play()
	tweenForward.Completed:Connect(function()
		tweenReturn:Play()
	end)
end

-- Procedural Double-Arm Victory Celebration
function AnimationController.PlayCelebrate()
	local rJoint = getRightArmJoint()
	local lJoint = getLeftArmJoint()
	if not rJoint or not lJoint then return end

	local baseR = defaultC0Right or rJoint.C0
	local baseL = lJoint.C0

	local rCelebrate = baseR * CFrame.Angles(math.rad(150), math.rad(-15), math.rad(20))
	local lCelebrate = baseL * CFrame.Angles(math.rad(150), math.rad(15), math.rad(-20))

	TweenService:Create(rJoint, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { C0 = rCelebrate }):Play()
	TweenService:Create(lJoint, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { C0 = lCelebrate }):Play()

	task.delay(1.5, function()
		if rJoint and rJoint.Parent then
			TweenService:Create(rJoint, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = baseR }):Play()
		end
		if lJoint and lJoint.Parent then
			TweenService:Create(lJoint, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = baseL }):Play()
		end
	end)
end

-- Plays an official animation track with procedural fallback
function AnimationController.Play(animName: string, speed: number?)
	-- Always fire procedural kinematics for instant feedback
	if animName == "StaffCast" or animName == "StaffSlash" then
		AnimationController.PlayStaffSwing(speed)
	elseif animName == "Celebrate" then
		AnimationController.PlayCelebrate()
	end

	local assetId = ANIMATION_IDS[animName]
	if not assetId or assetId == "rbxassetid://0" then return end

	local animator = getAnimator()
	if not animator then return end

	local track = loadedTracks[animName]
	if not track then
		local anim = Instance.new("Animation")
		anim.AnimationId = assetId
		local ok, res = pcall(function()
			return animator:LoadAnimation(anim)
		end)
		if ok and res then
			track = res
			loadedTracks[animName] = track
		end
	end

	if track then
		track:Play(0.08, 1, speed or 1)
	end
end

function AnimationController.Init()
	localPlayer.CharacterAdded:Connect(function()
		table.clear(loadedTracks)
		defaultC0Right = nil
	end)
	print("[AnimationController] Initialized successfully with Procedural Arm Kinematics & Core Animation Rigs.")
end

return table.freeze(AnimationController)
