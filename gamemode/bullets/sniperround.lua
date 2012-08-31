
SniperBullet = {}

-- Bullet shit
SniperBullet.Velocity = 24000 -- 2000 feet per second
SniperBullet.Damage = 95
SniperBullet.GravityModifier = 1
SniperBullet.Name = "Sniper"

SniperBullet.Mass = 0.004
SniperBullet.DragCoefficient = 0.295 / (SniperBullet.Mass * 1000)

RegisterBullet(SniperBullet)
