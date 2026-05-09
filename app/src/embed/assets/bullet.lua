Bullet = {}

function Bullet:new(x, y, dirX, dirY, owner)
    local obj = {
        x = x,
        y = y,

        dirX = dirX,
        dirY = dirY,

        radius = 6,
        speed = Config.bullet.speed,
        damage = Config.bullet.damage,
        dead = false,
        owner = owner or "player"
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Bullet:update(dt)
    self.x = self.x + self.dirX * self.speed * dt
    self.y = self.y + self.dirY * self.speed * dt
end

function Bullet:draw()
    if self.owner == "enemy" then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 1, 0.3)
    end

    love.graphics.circle("fill", self.x, self.y, self.radius)
    -- 恢复颜色，避免影响后续绘制
    love.graphics.setColor(1, 1, 1)
end