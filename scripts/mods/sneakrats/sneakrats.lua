local mod = get_mod("sneakrats")

mod:dofile("scripts/mods/sneakrats/patrols")
mod:dofile("scripts/mods/sneakrats/gutterrunners")

mod:hook_origin(ConflictDirector, "calculate_threat_value", function (self)
		local threat_value = 0
		local i = 0
		local activated_per_breed = Managers.state.performance:activated_per_breed()
	
		for breed_name, amount in pairs(activated_per_breed) do
			threat_value = threat_value + threat_values[breed_name] * amount
			i = i + amount
		end
	
		self.delay_horde = self.delay_horde_threat_value < threat_value
		self.delay_mini_patrol = self.delay_mini_patrol_threat_value < threat_value
		self.delay_specials = self.delay_specials_threat_value < threat_value
		self.threat_value = threat_value
		self.num_aggroed = i
end)