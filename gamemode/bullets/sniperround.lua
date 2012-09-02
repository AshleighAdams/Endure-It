
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


StanagBullet_556_Sniper = {}

-- Bullet shit
StanagBullet_556_Sniper.Velocity = 2800 * 12 -- 2350 feet per second
StanagBullet_556_Sniper.Damage = 25
StanagBullet_556_Sniper.GravityModifier = 1
StanagBullet_556_Sniper.Name = "StanagBullet_556_Snipper"
StanagBullet_556_Sniper.TracerChance = 0

StanagBullet_556_Sniper.Mass = 0.0035
StanagBullet_556_Sniper.DragCoefficient = 0.285 / (StanagBullet_556_Sniper.Mass * 1000)

RegisterBullet(StanagBullet_556_Sniper)