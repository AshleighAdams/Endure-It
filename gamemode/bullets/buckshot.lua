
BuckShot = {}

-- Bullet shit
BuckShot.Velocity = 23200 -- 2000 feet per second
BuckShot.Damage = 4
BuckShot.GravityModifier = 1
BuckShot.Name = "BuckShot"

BuckShot:ExtraSimulate = function(self, bul, t) -- So we can do some more stuff without reimplimenting the main simulate
	local falloff = self.Velocity:Length() / 10000
	bul.Velocity = bul.Velocity * 1 - (falloff * t) -- Fall the velocity off over time
end

RegisterBullet(BuckShot)
