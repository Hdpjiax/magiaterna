--!strict
--[[
    RateLimiter.luau
    Token-bucket / timestamp sliding window rate limiter per player and action.
    Prevents remote event flooding, auto-clickers, and DoS attacks.
]]

export type RateLimiterInstance = {
	Check: (userId: number, action: string, maxPerSecond: number) -> boolean,
	Reset: (userId: number) -> (),
}

local RateLimiter = {}
local userWindows: { [number]: { [string]: { count: number, windowStart: number } } } = {}

-- Checks if an action is within allowed rate limits. Returns true if allowed, false if rejected.
function RateLimiter.Check(userId: number, action: string, maxPerSecond: number): boolean
	local now = os.clock()
	local userMap = userWindows[userId]
	if not userMap then
		userMap = {}
		userWindows[userId] = userMap
	end
	
	local record = userMap[action]
	if not record or (now - record.windowStart) >= 1.0 then
		userMap[action] = {
			count = 1,
			windowStart = now,
		}
		return true
	end
	
	if record.count < maxPerSecond then
		record.count += 1
		return true
	end
	
	return false -- Rate limit exceeded!
end

-- Cleans up memory when a player leaves the server
function RateLimiter.Reset(userId: number)
	userWindows[userId] = nil
end

return table.freeze(RateLimiter)
