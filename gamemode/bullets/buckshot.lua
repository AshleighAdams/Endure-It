
BuckShot = BuckShot or {}

-- Bullet shit
BuckShot.Velocity = 1325 * 12 -- 2000 feet per second
BuckShot.Damage = 4
BuckShot.GravityModifier = 1
BuckShot.Name = "BuckShot"

BuckShot.Mass = 0.003
BuckShot.DragCoefficient = 0.35 / (BuckShot.Mass * 1000)

RegisterBullet(BuckShot)
