Config = {
    player = {
        hp = 500,-- 玩家初始生命值
        moveSpeed = 220,-- 玩家移动速度

        attackInterval = 1.0,-- 玩家自动攻击间隔
        attackRange = 260-- 玩家自动攻击范围
    },

    enemy = {
        hp = 20,-- 敌人初始生命值
        moveSpeed = 90,-- 敌人移动速度

        attackDamage = 10,-- 敌人攻击伤害
        attackRange = 220,-- 敌人攻击范围
        attackInterval = 1.2-- 敌人攻击间隔
    },

    bullet = {
        speed = 500,-- 子弹速度
        damage = 10,-- 子弹伤害
        knockback = 220,-- 子弹击退力度
        pierceCount = 1,-- 穿透数（被击中后仍能继续前进并伤害其他目标的次数）
        splashRadius = 80,-- 溅射半径
        splashDamageRate = 0.3,-- 溅射伤害比例
    },

    wave = {
        spawnInterval = 1.2,-- 每波敌人生成间隔
        waveDuration = 8,-- 每波持续时间
        waveCooldown = 15-- 波与波之间的冷却时间
    }

}