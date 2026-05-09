Joystick = {}

function Joystick:new()
    local obj = {
        baseX = 0,
        baseY = 0,

        knobX = 0,
        knobY = 0,

        radius = 70,
        knobRadius = 35,

        dirX = 0,
        dirY = 0,

        active = false,
        touchId = nil
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Joystick:update(dt)

end

function Joystick:draw()
    -- 没触摸时不显示摇杆
    if not self.active then
        return
    end

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.circle("fill", self.baseX, self.baseY, self.radius)

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.circle("fill", self.knobX, self.knobY, self.knobRadius)
end

function Joystick:touchpressed(id, x, y)
    -- 已有手指控制时忽略
    if self.active then
        return
    end

    self.active = true
    self.touchId = id

    -- 第一次触摸位置作为摇杆中心
    self.baseX = x
    self.baseY = y

    self.knobX = x
    self.knobY = y
end

function Joystick:touchmoved(id, x, y)
    if not self.active then
        return
    end

    if id ~= self.touchId then
        return
    end

    local dx = x - self.baseX
    local dy = y - self.baseY

    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > self.radius then
        dx = dx / dist * self.radius
        dy = dy / dist * self.radius
    end

    self.knobX = self.baseX + dx
    self.knobY = self.baseY + dy

    self.dirX = dx / self.radius
    self.dirY = dy / self.radius
end

function Joystick:touchreleased(id, x, y)
    if id ~= self.touchId then
        return
    end

    self.active = false
    self.touchId = nil

    self.knobX = self.baseX
    self.knobY = self.baseY

    self.dirX = 0
    self.dirY = 0

    self.baseX = 0
    self.baseY = 0
end