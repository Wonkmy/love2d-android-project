Camera = {}

function Camera:new()
    local obj = {
        x = 0,
        y = 0
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Camera:follow(target)
    -- 摄像机始终让玩家保持在屏幕中心
    self.x = target.x - love.graphics.getWidth() / 2
    self.y = target.y - love.graphics.getHeight() / 2
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end