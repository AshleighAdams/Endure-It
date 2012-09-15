
AKBullet = {}

-- Bullet shit
AKBullet.Velocity = 2350 * 12 -- 2350 feet per second
AKBullet.Damage = 35
AKBullet.GravityModifier = 1
AKBullet.Name = "AKBullet"
AKBullet.TracerChance = 0

AKBullet.Mass = 0.008
AKBullet.DragCoefficient = 0.265 / (AKBullet.Mass * 1000)

RegisterBullet(AKBullet)
