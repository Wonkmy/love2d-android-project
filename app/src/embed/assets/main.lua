require("player")
require("enemy")
require("camera")
require("config")
require("bullet")
require("exp")
require("joystick")

local player
camera = nil
enemies = {}
local bullets = {}
local muzzleFlashes = {}

local exps = {}
local damageTexts = {}-- 飘字列表

local playerLevel = 1
local playerExp = 0
local needExp = 100

enemyBullets = {}
joystick = nil

local attackTimer = 0

local spawnTimer = 0

-- 游戏时间
local gameTime = 0

-- 当前刷怪间隔
local spawnInterval = Config.wave.spawnInterval

-- 尸潮相关
local waveTimer = 0
local waveDuration = Config.wave.waveDuration
local waveCooldown = Config.wave.waveCooldown
local inWave = false

function love.load()
    love.window.setMode(800, 600)
    love.graphics.setBackgroundColor(0.08, 0.09, 0.11)
    player = Player:new(0, 0)
    camera = Camera:new()
    joystick = Joystick:new()
end

function love.update(dt)
    player:update(dt)
    camera:follow(player, dt)

    -- 自动攻击计时
    attackTimer = attackTimer + dt

    if attackTimer >= Config.player.attackInterval then
        attackTimer = 0
        autoAttack()
    end

    gameTime = gameTime + dt

    -- 时间越久刷怪越快
    spawnInterval = math.max(0.15, 1.2 - gameTime * 0.01)

    waveTimer = waveTimer + dt

    -- 进入尸潮
    if not inWave and waveTimer >= waveCooldown then
        inWave = true
        waveTimer = 0
    end

    -- 尸潮结束
    if inWave and waveTimer >= waveDuration then
        inWave = false
        waveTimer = 0
    end

    spawnTimer = spawnTimer + dt

    if spawnTimer >= spawnInterval then
        spawnTimer = 0

        local spawnCount = 1

        -- 尸潮期间大量刷怪
        if inWave then
            spawnCount = 5
        end

        for i = 1, spawnCount do
            spawnEnemy()
        end
    end

    for i = #damageTexts, 1, -1 do

        damageTexts[i].life = damageTexts[i].life - dt

        -- 向上漂浮
        damageTexts[i].y = damageTexts[i].y - 80 * dt

        if damageTexts[i].life <= 0 then
            table.remove(damageTexts, i)
        end
    end


    for i = #muzzleFlashes, 1, -1 do

        muzzleFlashes[i].life = muzzleFlashes[i].life - dt

        if muzzleFlashes[i].life <= 0 then
            table.remove(muzzleFlashes, i)
        end
    end


    for i = #exps, 1, -1 do

        exps[i]:update(dt, player)

        local dx = exps[i].x - player.x
        local dy = exps[i].y - player.y

        local dist = math.sqrt(dx * dx + dy * dy)

        -- 吃经验
        if dist < exps[i].radius + player.radius then

            playerExp = playerExp + exps[i].value

            table.remove(exps, i)

            -- 升级
            if playerExp >= needExp then

                playerLevel = playerLevel + 1

                playerExp = playerExp - needExp

                needExp = math.floor(needExp * 1.25)
            end
        end
    end


    for i = #enemyBullets, 1, -1 do
        enemyBullets[i]:update(dt)

        local dx = enemyBullets[i].x - player.x
        local dy = enemyBullets[i].y - player.y

        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < enemyBullets[i].radius + player.radius then
            player.hp = player.hp - enemyBullets[i].damage
            enemyBullets[i].dead = true
        end

        if enemyBullets[i] and enemyBullets[i].dead then
            table.remove(enemyBullets, i)
        end
    end


    for i = #bullets, 1, -1 do
        bullets[i]:update(dt)

        -- 子弹命中敌人
        for j = #enemies, 1, -1 do

        if not enemies[j].dead then

                local dx = bullets[i].x - enemies[j].x
                local dy = bullets[i].y - enemies[j].y

                local dist = math.sqrt(dx * dx + dy * dy)

                if dist < bullets[i].radius + enemies[j].radius and bullets[i].hitEnemies[enemies[j]] == nil then

                    enemies[j].hp = enemies[j].hp - bullets[i].damage
                    -- 小范围溅射
                    for k = 1, #enemies do

                        local otherEnemy = enemies[k]

                        -- 跳过自己和死亡敌人
                        if
                            otherEnemy ~= enemies[j]
                            and not otherEnemy.dead
                        then

                            local sdx =
                                otherEnemy.x - enemies[j].x

                            local sdy =
                                otherEnemy.y - enemies[j].y

                            local sdist =
                                math.sqrt(sdx * sdx + sdy * sdy)

                            if sdist <= Config.bullet.splashRadius then

                                otherEnemy.hp =
                                    otherEnemy.hp -
                                    bullets[i].damage *
                                    Config.bullet.splashDamageRate

                                otherEnemy.hitFlash = 0.08
                            end
                        end
                    end

                    table.insert(damageTexts, {
                        x = enemies[j].x,
                        y = enemies[j].y,

                        value = bullets[i].damage,

                        life = 0.5
                    })


                    -- 击中闪烁
                    enemies[j].hitFlash = 0.12

                    -- 摄像机震动
                    camera:addShake(2)

                    -- 子弹击退
                    if bullets[i].canKnockback then
                        enemies[j].knockbackX = enemies[j].knockbackX + bullets[i].dirX * Config.bullet.knockback
                        enemies[j].knockbackY = enemies[j].knockbackY + bullets[i].dirY * Config.bullet.knockback
                    end

                    -- 记录已经被这颗子弹击中的敌人
                    bullets[i].hitEnemies[enemies[j]] = true

                    bullets[i].pierceLeft = bullets[i].pierceLeft - 1

                    if bullets[i].pierceLeft < 0 then
                        bullets[i].dead = true
                    end


                    if enemies[j].hp <= 0 then

                        enemies[j].dead = true

                        table.insert(
                            exps,
                            Exp:new(
                                enemies[j].x,
                                enemies[j].y
                            )
                        )
                    end

                    break
                end
            end
        end

        if bullets[i] and bullets[i].dead then
            table.remove(bullets, i)
        end
    end

    for i = #enemies, 1, -1 do
        enemies[i]:update(dt, player)
        -- 死亡动画结束后真正删除
        if enemies[i].dead and enemies[i].scale <= 0 then
            table.remove(enemies, i)
        end
    end
end

function love.draw()
    camera:apply()

    drawGrid()
    player:draw()

    for i = 1, #damageTexts do

        local t = damageTexts[i]

        love.graphics.setColor(1, 1, 1, t.life * 2)

        love.graphics.print(tostring(t.value), t.x, t.y)
    end

    love.graphics.setColor(1, 1, 1)


    for i = 1, #muzzleFlashes do

        local flash = muzzleFlashes[i]

        local size = flash.life * 120

        love.graphics.setColor(1, 0.9, 0.3, flash.life * 12)

        love.graphics.circle("fill", flash.x, flash.y, size)
    end
    love.graphics.setColor(1,1,1)


    for i = 1, #bullets do
        bullets[i]:draw()
    end

    for i = 1, #exps do
        exps[i]:draw()
    end

    for i = 1, #enemyBullets do
        enemyBullets[i]:draw()
    end

    for i = 1, #enemies do
        enemies[i]:draw()
    end

    camera:clear()

    drawUI()
    joystick:draw()
end

function spawnEnemy()
    local side = love.math.random(1, 4)
    local distance = 500

    local x = player.x
    local y = player.y

    -- 在玩家周围远处随机生成敌人
    if side == 1 then
        x = player.x - distance
        y = player.y + love.math.random(-300, 300)
    elseif side == 2 then
        x = player.x + distance
        y = player.y + love.math.random(-300, 300)
    elseif side == 3 then
        x = player.x + love.math.random(-500, 500)
        y = player.y - distance
    else
        x = player.x + love.math.random(-500, 500)
        y = player.y + distance
    end

    table.insert(enemies, Enemy:new(x, y))
end

function drawGrid()
    love.graphics.setColor(0.16, 0.17, 0.2)

    local size = 64
    local startX = math.floor((camera.x - 100) / size) * size
    local endX = camera.x + love.graphics.getWidth() + 100
    local startY = math.floor((camera.y - 100) / size) * size
    local endY = camera.y + love.graphics.getHeight() + 100

    for x = startX, endX, size do
        love.graphics.line(x, startY, x, endY)
    end

    for y = startY, endY, size do
        love.graphics.line(startX, y, endX, y)
    end
end

function drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HP: " .. math.floor(player.hp), 20, 20)
    love.graphics.print("Enemy: " .. #enemies, 20, 44)

    love.graphics.print("Time: " .. math.floor(gameTime), 20, 96)

    if inWave then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.print("WAVE !!", 20, 120)
        love.graphics.setColor(1, 1, 1)
    end

    -- 血条背景
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.rectangle("fill", 20, 70, 200, 16)

    -- 血条
    local hpRate = math.max(player.hp / player.maxHp, 0)
    love.graphics.setColor(0.2, 1, 0.3)
    love.graphics.rectangle("fill", 20, 70, 200 * hpRate, 16)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 20, 70, 200, 16)

        -- 经验条背景
    love.graphics.setColor(0.2, 0.2, 0.2)

    love.graphics.rectangle("fill", 20, 150, 220, 18)

    -- 经验条
    love.graphics.setColor(0.2, 0.8, 1)

    love.graphics.rectangle("fill", 20, 150, 220 * (playerExp / needExp), 18)

    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("line", 20, 150, 220, 18)

    love.graphics.print("LV." .. playerLevel, 20, 175)

end

-- 自动攻击
function autoAttack()

    local nearestDist = math.huge

    for i = 1, #enemies do
        local dx = enemies[i].x - player.x
        local dy = enemies[i].y - player.y

        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < nearestDist then
            nearestDist = dist
        end
    end

    -- 超出攻击范围不攻击
    if nearestDist > Config.player.attackRange then
        return
    end

    local baseAngle = player.weaponAngle

    -- 三连发
    for i = -1, 1 do

        local angle = baseAngle + math.rad(i * 8)

        local dirX = math.cos(angle)
        local dirY = math.sin(angle)

        table.insert(muzzleFlashes, {
            x = player.x + dirX * 28,
            y = player.y + dirY * 28,

            dirX = dirX,
            dirY = dirY,

            life = 0.08
        })

        local bullet = Bullet:new(player.x, player.y, dirX, dirY, "player")

        -- 只有中间子弹有击退
        if i ~= 0 then
            bullet.canKnockback = false
        end

        table.insert(bullets, bullet)

        -- table.insert(
        --     bullets,
        --     Bullet:new(
        --         player.x,
        --         player.y,
        --         dirX,
        --         dirY,
        --         "player"
        --     )
        -- )
    end
end


function love.touchpressed(id, x, y)
    joystick:touchpressed(id, x, y)
end

function love.touchmoved(id, x, y)
    joystick:touchmoved(id, x, y)
end

function love.touchreleased(id, x, y)
    joystick:touchreleased(id, x, y)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        joystick:touchpressed("mouse", x, y)
    end
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) then
        joystick:touchmoved("mouse", x, y)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        joystick:touchreleased("mouse", x, y)
    end
end