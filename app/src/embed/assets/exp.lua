Exp = {}

function Exp:new(x, y)
    local obj = {
        x = x,
        y = y,

        radius = 10,
        value = 10,

        moveSpeed = 0
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Exp:update(dt, player)

    local dx = player.x - self.x
    local dy = player.y - self.y

    local dist = math.sqrt(dx * dx + dy * dy)

    -- 自动吸附
    if dist < 180 then

        if dist > 0 then
            dx = dx / dist
            dy = dy / dist
        end

        self.moveSpeed = self.moveSpeed + 600 * dt

        self.x = self.x + dx * self.moveSpeed * dt
        self.y = self.y + dy * self.moveSpeed * dt
    end
end

function Exp:draw()
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    love.graphics.setColor(1, 1, 1)
end