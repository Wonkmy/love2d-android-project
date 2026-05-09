Config = {
    player = {
        hp = 100,
        moveSpeed = 220,

        attackInterval = 1.0,
        attackRange = 260
    },

    enemy = {
        hp = 20,
        moveSpeed = 90,

        attackDamage = 10,
        attackRange = 220,
        attackInterval = 1.2
    },

    bullet = {
        speed = 500,
        damage = 10,
        -- 子弹击退力度
        knockback = 220
    },

    wave = {
        spawnInterval = 1.2,

        waveDuration = 8,
        waveCooldown = 15
    }

}