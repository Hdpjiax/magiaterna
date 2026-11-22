--!strict
--[[
    PetFollowController.luau
    Client-side pet following algorithm for MAGIA ETERNA.
    Runs on RenderStepped (60 FPS) to orbit equipped pets smoothly around the local avatar.
    Zero server physics overhead, instant responsiveness, and mobile-optimized.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local Controllers = script.Parent
local DataController = require(Controllers:WaitForChild("DataController") :: ModuleScript)

local PetFollowController = {}
local activePetModels: { [string]: Model } = {}
local orbitRadius = 5.5
local orbitSpeed = 1.8

-- Calculates target CFrame for pet index out of total equipped
local function getPetTargetCFrame(rootCFrame: CFrame, index: number, total: number): CFrame
	local now = os.clock()
	local angleStep = (math.pi * 2) / math.max(1, total)
	local angle = (index * angleStep) + (now * 0.4)
	
	-- Circular offset behind/around player
	local offsetX = math.sin(angle) * orbitRadius
	local offsetZ = math.cos(angle) * orbitRadius
	local bobbingY = math.sin(now * 3.5 + index) * 0.35
	
	local targetPos = rootCFrame.Position + Vector3.new(offsetX, 1.2 + bobbingY, offsetZ)
	local lookTarget = rootCFrame.Position + (rootCFrame.LookVector * 10)
	return CFrame.new(targetPos, lookTarget)
end

-- Updates pet positions each frame
local function onRenderStep(deltaTime: number)
	local character = localPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then return end
	
	local data = DataController.GetData()
	if not data then return end
	
	local totalEquipped = #data.EquippedPets
	for index, petUuid in ipairs(data.EquippedPets) do
		local petModel = activePetModels[petUuid]
		if petModel and petModel.PrimaryPart then
			local targetCF = getPetTargetCFrame(rootPart.CFrame, index, totalEquipped)
			-- Smooth Lerp interpolation for buttery motion
			local alpha = math.clamp(deltaTime * 10, 0, 1)
			petModel:PivotTo(petModel:GetPivot():Lerp(targetCF, alpha))
		end
	end
end

-- Initializes PetFollowController
function PetFollowController.Init()
	DataController.OnDataChanged:Connect(function(newData)
		-- Trigger pet model refresh when equipped pets change
	end)
	
	RunService.RenderStepped:Connect(onRenderStep)
	print("[PetFollowController] Initialized successfully with 60 FPS orbital physics.")
end

return table.freeze(PetFollowController)
