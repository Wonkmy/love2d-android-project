Camera = {}

function Camera:new()
    local obj = {
        x = 0,
        y = 0,
        shake = 0,
        scale = 1
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Camera:follow(target, dt)

    local screenW = love.graphics.getWidth() / self.scale

    local screenH = love.graphics.getHeight() / self.scale

    local centerX = self.x + screenW / 2
    local centerY = self.y + screenH / 2

    local dx = target.x - centerX
    local dy = target.y - centerY

    -- 摄像机死区范围
    local deadZone = 80

    local moveX = 0
    local moveY = 0

    if math.abs(dx) > deadZone then
        moveX = dx - deadZone * (dx / math.abs(dx))
    end

    if math.abs(dy) > deadZone then
        moveY = dy - deadZone * (dy / math.abs(dy))
    end

    -- 根据敌人数量动态缩放镜头
    local targetScale = 1
    if enemies then
        local enemyCount = #enemies
        -- 敌人越多镜头越远
        targetScale =
            math.max(
                0.72,
                1 - enemyCount * 0.003
            )
    end

    self.scale =
        self.scale +
        (targetScale - self.scale) *
        dt * 2
    -- 缓动跟随
    self.x = self.x + moveX * dt * 5
    self.y = self.y + moveY * dt * 5

    -- 震屏
    if self.shake > 0 then

        self.x =
            self.x + love.math.random(-self.shake, self.shake)

        self.y =
            self.y + love.math.random(-self.shake, self.shake)

        self.shake = self.shake * 0.9
    end
end

function Camera:apply()

    love.graphics.push()

    -- 缩放
    love.graphics.scale(self.scale, self.scale)

    love.graphics.translate(
        -self.x,
        -self.y
    )
end

function Camera:clear()
    love.graphics.pop()
end

function Camera:addShake(power)
    if power > self.shake then
        self.shake = power
    end
end
