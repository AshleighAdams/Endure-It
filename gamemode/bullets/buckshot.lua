
BuckShot = BuckShot or {}

-- Bullet shit
BuckShot.Velocity = 1525 * 12 * 0.75 -- 2000 feet per second
BuckShot.Damage = 4
BuckShot.GravityModifier = 1
BuckShot.Name = "BuckShot"
BuckShot.TracerChance = 0

BuckShot.Mass = 0.005
BuckShot.DragCoefficient = 0.25 / (BuckShot.Mass * 1000)

RegisterBullet(BuckShot)
