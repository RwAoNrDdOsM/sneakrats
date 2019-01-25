local mod = get_mod("sneakrats")

--[[mod.init = function (self, context, unit, extension_init_data)
	self._unit = unit
	self._is_server = Managers.player.is_server
end]]

mod.decoy = function (self, unit)
	self._num_decoys = 3
	self._decoys = {}
end

mod._spawn_decoys = function (self, unit)
	for i = 1, self._num_decoys, 1 do
		local breed = Breeds.skaven_gutter_runner_decoy.breed_name
		local conflict_director = Managers.state.conflict
		--local spawn_pos = Unit.local_position(unit, 0)
		local player_positions = PLAYER_POSITIONS
		local center_pos = player_positions[1]
		local spawner = ConflictUtils.get_random_hidden_spawner(center_pos, 40)
		local spawn_pos = Unit.local_position(spawner, 0)
		local spawn_category = "debug_spawn"
		local rot = Quaternion(Vector3.up(), math.degrees_to_radians(math.random(1, 360)))
		local spawn = conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), spawn_category, nil)
		self._decoys[i] = spawn
		mod:echo("Spawned Gutter Runner Decoy")
	end
end

mod._kill_decoys = function (self, unit)
	for i = 1, self._num_decoys, 1 do
		local decoy_unit = self._decoys[i]

		if AiUtils.unit_alive(decoy_unit) then
			AiUtils.kill_unit(decoy_unit, unit)
		end
	end
end

mod.respawn_decoys = function (self, unit)
	mod:_kill_decoys(unit)
	mod:_spawn_decoys(unit)
end

mod.decoy_destroyed = function (self, unit)
	if Managers.player.is_server then
		mod:_kill_decoys(unit)
	end
end

