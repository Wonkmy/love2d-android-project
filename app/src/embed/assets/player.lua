Player = {}
player_text = nil
function Player:new(x, y)
    local obj = {
        x = x,
        y = y,
        radius = 18,
        speed = Config.player.moveSpeed,
        hp = Config.player.hp,
        maxHp = Config.player.hp,
        angle = 0,
        targetAngle = 0,
        weaponAngle = 0
    }
    setmetatable(obj, self)
    self.__index = self

    player_text = love.graphics.newImage("sprites/player.png")
    return obj
end

function Player:update(dt)
    local dx, dy = 0, 0

    -- WASD控制
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        dy = dy - 1
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        dy = dy + 1
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        dx = dx - 1
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        dx = dx + 1
    end

    -- 摇杆控制
    if joystick then
        dx = dx + joystick.dirX
        dy = dy + joystick.dirY
    end

    local len = math.sqrt(dx * dx + dy * dy)

    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- 更新玩家朝向为摇杆方向
    if joystick and (joystick.dirX ~= 0 or joystick.dirY ~= 0) then
        self.angle = math.atan2(joystick.dirY, joystick.dirX)
    end
    
    -- 武器自动朝向最近敌人
    if enemies and #enemies > 0 then

        local nearestEnemy = nil
        local nearestDist = math.huge

        for i = 1, #enemies do
            local ex = enemies[i].x - self.x
            local ey = enemies[i].y - self.y

            local dist = ex * ex + ey * ey

            if dist < nearestDist then
                nearestDist = dist
                nearestEnemy = enemies[i]
            end
        end

        if nearestEnemy then
            local dx = nearestEnemy.x - self.x
            local dy = nearestEnemy.y - self.y

            self.weaponAngle = math.atan2(dy, dx)
        end
    end


end

function Player:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(player_text, self.x, self.y,self.angle + 90, 0.1, 0.1, player_text:getWidth() / 2, player_text:getHeight() / 2)

    -- 武器位置
    local weaponLen = 28

    local wx = self.x + math.cos(self.weaponAngle) * weaponLen
    local wy = self.y + math.sin(self.weaponAngle) * weaponLen

    -- 武器
    love.graphics.setColor(1, 1, 0.3)
    love.graphics.setLineWidth(6)

    love.graphics.line(self.x, self.y, wx, wy)

    love.graphics.setColor(1,1,1)
end