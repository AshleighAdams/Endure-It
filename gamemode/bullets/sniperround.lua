
SniperBullet = SniperBullet or {}

-- Bullet shit
SniperBullet.Velocity = 2790 * 12 -- 2000 feet per second
SniperBullet.Damage = 950000
SniperBullet.GravityModifier = 1
SniperBullet.Name = "Sniper"
SniperBullet.TracerChance = 0
SniperBullet.DrawTracer = function(self, bullet) end

SniperBullet.Mass = 0.004
SniperBullet.DragCoefficient = 0.25 / (SniperBullet.Mass * 1000)

RegisterBullet(SniperBullet)
RegisterBullet(SniperBullet)
