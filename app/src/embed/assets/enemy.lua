Enemy = {}
Enemy_text = nil
function Enemy:new(x, y)
    local obj = {
        x = x,
        y = y,
        angle = 0,
        radius = 14,
        speed = Config.enemy.moveSpeed,
        hp = Config.enemy.hp,
        attackDamage = Config.enemy.attackDamage,
        attackRange = Config.enemy.attackRange,
        attackInterval = Config.enemy.attackInterval,
        attackTimer = 0,

        knockbackX = 0,
        knockbackY = 0,
    }
    setmetatable(obj, self)
    self.__index = self

    Enemy_text = love.graphics.newImage("sprites/enemy.png")

    return obj
end

function Enemy:update(dt, player)
    local dx = player.x - self.x
    local dy = player.y - self.y

    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        dx = dx / dist
        dy = dy / dist
    end

    local moveSpeed = self.speed

    if dist <= self.attackRange then
        moveSpeed = self.speed * 0.25
    end

    self.x = self.x + dx * moveSpeed * dt
    self.y = self.y + dy * moveSpeed * dt

    -- 只有没进入攻击范围时才移动
    if dist > self.attackRange then
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    else
        -- 攻击计时
        self.attackTimer = self.attackTimer + dt

        if self.attackTimer >= self.attackInterval then
            self.attackTimer = 0

            -- 敌人攻击玩家
           table.insert(enemyBullets, Bullet:new(self.x, self.y, dx, dy, "enemy"))
        end
    end
    -- 敌人朝向玩家
    self.angle = math.atan2(dy, dx) * 57.29578

    -- 击退位移衰减
    self.x = self.x + self.knockbackX * dt
    self.y = self.y + self.knockbackY * dt

    self.knockbackX = self.knockbackX * 0.85
    self.knockbackY = self.knockbackY * 0.85
end

function Enemy:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(Enemy_text, self.x, self.y, math.rad(self.angle + 90), 0.1, 0.1, Enemy_text:getWidth() / 2, Enemy_text:getHeight() / 2)
    love.graphics.setColor(1,1,1)
end