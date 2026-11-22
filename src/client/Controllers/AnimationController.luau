--!strict
--[[
    AnimationController.luau
    Client-side animation manager for MAGIA ETERNA.
    Handles staff casting/equipping animations and procedural fallback tweens.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local AnimationController = {}
local localPlayer = Players.LocalPlayer
local loadedTracks: { [string]: AnimationTrack } = {}

-- Optional Roblox Animation IDs (replace with custom uploaded rigs when ready)
local ANIMATION_IDS: { [string]: string } = {
	StaffCast = "rbxassetid://0",
	StaffEquip = "rbxassetid://0",
	ForgeHammer = "rbxassetid://0",
	Celebrate = "rbxassetid://0",
}

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

function AnimationController.Play(animName: string, speed: number?)
	local assetId = ANIMATION_IDS[animName]
	if not assetId or assetId == "rbxassetid://0" then
		-- Procedural micro-pulse on character RootPart when no AnimationId is assigned
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root and animName == "StaffCast" then
			local orig = root.CFrame
			TweenService:Create(root, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {
				CFrame = orig * CFrame.new(0, 0.25, 0),
			}):Play()
		end
		return
	end

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
		track:Play(0.1, 1, speed or 1)
	end
end

function AnimationController.Init()
	localPlayer.CharacterAdded:Connect(function()
		table.clear(loadedTracks)
	end)
	print("[AnimationController] Initialized successfully.")
end

return table.freeze(AnimationController)
