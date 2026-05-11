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
        hitFlash = 0,
        dead = false,
        deadTimer = 0,

        scale = 0.1,
        isFastEnemy = false,
        hasShield = false,
        shieldHp = 1,
    }
    setmetatable(obj, self)
    self.__index = self

    Enemy_text = love.graphics.newImage("sprites/enemy.png")

    return obj
end

function Enemy:update(dt, player)
    if player.hp <= 0 then
        return
    end
    -- 死亡动画：只缩小，不再移动/攻击
    if self.dead then
        self.deadTimer = self.deadTimer + dt
        self.scale = self.scale - dt * 6

        if self.scale < 0 then
            self.scale = 0
        end

        return
    end

    -- 出生缩放动画
    if self.scale < 1 then
        self.scale = self.scale + dt * 6

        if self.scale > 1 then
            self.scale = 1
        end
    end

    local dx = player.x - self.x
    local dy = player.y - self.y

    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > 0 then
        dx = dx / dist
        dy = dy / dist
    end

    -- 进入攻击范围后减速
    local moveSpeed = self.speed

    -- 高速敌人
    if self.isFastEnemy then
        moveSpeed =
            moveSpeed *
            Config.wave.enemySpeedRate
    end

    if dist <= self.attackRange then
        moveSpeed = self.speed * 0.25
    end

    self.x = self.x + dx * moveSpeed * dt
    self.y = self.y + dy * moveSpeed * dt

    if dist <= self.attackRange then
        self.attackTimer = self.attackTimer + dt

        if self.attackTimer >= self.attackInterval then
            self.attackTimer = 0
            if inWave then
                for i = -1, 1 do
                    local angle =
                        math.atan2(dy, dx) +
                        math.rad(i * 12)

                    local dirX = math.cos(angle)
                    local dirY = math.sin(angle)

                    table.insert(
                        enemyBullets,
                        Bullet:new(
                            self.x,
                            self.y,
                            dirX,
                            dirY,
                            "enemy"
                        )
                    )
                end
            else
                table.insert(
                    enemyBullets,
                    Bullet:new(
                        self.x,
                        self.y,
                        dx,
                        dy,
                        "enemy"
                    )
                )
            end
        end
    end

    -- 敌人朝向玩家
    self.angle = math.atan2(dy, dx) * 57.29578

    -- 击退位移衰减
    self.x = self.x + self.knockbackX * dt
    self.y = self.y + self.knockbackY * dt

    self.knockbackX = self.knockbackX * 0.85
    self.knockbackY = self.knockbackY * 0.85

    -- 受击闪白衰减
    if self.hitFlash > 0 then
        self.hitFlash = self.hitFlash - dt
    end
end

function Enemy:draw()
    -- 受击闪白
    if self.hitFlash > 0 then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    -- 高速敌人轻微染色
    if self.isFastEnemy then
        love.graphics.setColor(1, 0.5, 0.5)
    end
    love.graphics.draw(Enemy_text, self.x, self.y, math.rad(self.angle + 90), 0.1 * self.scale, 0.1 * self.scale, Enemy_text:getWidth() / 2, Enemy_text:getHeight() / 2)
    -- 护盾
    if inWave and self.shieldHp > 0 then
        local shieldDist = 24

        local sx =
            self.x +
            math.cos(math.rad(self.angle)) *
            shieldDist

        local sy =
            self.y +
            math.sin(math.rad(self.angle)) *
            shieldDist

        love.graphics.setColor(0.3, 0.8, 1)

        love.graphics.rectangle(
            "fill",
            sx - 10,
            sy - 6,
            20,
            12
        )

        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.setColor(1,1,1)
end
