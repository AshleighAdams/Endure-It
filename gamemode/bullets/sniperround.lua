
SniperBullet = SniperBullet or {}

-- Bullet shit
SniperBullet.Velocity = 2790 * 12 * 0.75 -- 2000 feet per second
SniperBullet.Damage = 70
SniperBullet.GravityModifier = 1
SniperBullet.Name = "SniperBullet"
SniperBullet.TracerChance = 0
SniperBullet.DrawTracer = function(self, bullet) end

SniperBullet.Mass = 0.004
SniperBullet.DragCoefficient = 0.25 / (SniperBullet.Mass * 1000)

RegisterBullet(SniperBullet)

Nato_556_Sniper = {}

-- Bullet shit
Nato_556_Sniper.Velocity = 2800 * 12 * 0.75 -- 2350 feet per second
Nato_556_Sniper.Damage = 35
Nato_556_Sniper.GravityModifier = 1
Nato_556_Sniper.Name = "Nato_556_Sniper"
Nato_556_Sniper.TracerChance = 0
Nato_556_Sniper.DrawTracer = function(self, bullet) end

Nato_556_Sniper.Mass = 0.0035
Nato_556_Sniper.DragCoefficient = 0.285 / (Nato_556_Sniper.Mass * 1000)

RegisterBullet(Nato_556_Sniper)


