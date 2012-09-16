
Nato_556 = {}

-- Bullet shit
Nato_556.Velocity = Feet(2970) -- 2350 feet per second
Nato_556.Damage = 20
Nato_556.GravityModifier = 1
Nato_556.Name = "Nato_556"
Nato_556.TracerChance = 0

Nato_556.Mass = 0.004
Nato_556.DragCoefficient = 0.25 / (Nato_556.Mass * 1000)

RegisterBullet(Nato_556)





Nato_556_SD = {}

-- Bullet shit
Nato_556_SD.Velocity = Feet(1100) -- No crack is heard at this velocity
Nato_556_SD.Name = "Nato_556_SD"

RegisterBullet(Nato_556_SD, Nato_556)





Nato_556_Para = {}
Nato_556_Para.Name = "Nato_556_Para"
Nato_556_Para.TracerChance = 5

RegisterBullet(Nato_556_Para, Nato_556)





Nato_9mm = {}

Nato_9mm.Velocity = Feet(940) -- 940 feet per second
Nato_9mm.Damage = 20
Nato_9mm.GravityModifier = 1
Nato_9mm.Name = "Nato_9mm"
Nato_9mm.TracerChance = 0

Nato_9mm.Mass = 0.004
Nato_9mm.DragCoefficient = 0.29 / (Nato_556.Mass * 1000)

RegisterBullet(Nato_9mm)