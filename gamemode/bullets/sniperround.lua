
SniperBullet = SniperBullet or {}

-- Bullet shit
SniperBullet.Velocity = 2790 * 12 -- 2000 feet per second
SniperBullet.Damage = 95
SniperBullet.GravityModifier = 1
SniperBullet.Name = "Sniper"

SniperBullet.Mass = 0.008
SniperBullet.DragCoefficient = 0.1 / (SniperBullet.Mass * 1000)

RegisterBullet(SniperBullet)
