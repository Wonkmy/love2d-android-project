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
        owner = owner or "player",
        trail = {},
        canKnockback = true,
        pierceLeft = Config.bullet.pierceCount,
        hitEnemies = {},
        life = 2,
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Bullet:update(dt)
    self.x = self.x + self.dirX * self.speed * dt
    self.y = self.y + self.dirY * self.speed * dt

    -- 生命周期
    self.life = self.life - dt

    if self.life <= 0 then
        self.dead = true
    end


    -- 记录尾迹点
    table.insert(self.trail, 1, {
        x = self.x,
        y = self.y
    })

    -- 限制尾迹长度
    if #self.trail > 12 then -- 推荐10~14
        table.remove(self.trail)
    end
end

function Bullet:draw()
    if self.owner == "enemy" then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 0.3)
    end

    -- 绘制尾迹
    for i = 1, #self.trail do

        local t = self.trail[i]

        local alpha = 1 - (i / #self.trail)

        if self.owner == "enemy" then
            love.graphics.setColor(1, 0, 0, alpha * 0.8)
        else
            love.graphics.setColor(1, 1, 1, alpha * 0.8)
        end

        love.graphics.circle("fill", t.x, t.y, self.radius * alpha)
    end


    love.graphics.circle("fill", self.x, self.y, self.radius)
    -- 恢复颜色，避免影响后续绘制
    love.graphics.setColor(1, 1, 1)
end