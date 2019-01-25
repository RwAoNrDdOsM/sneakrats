AiHeroicEnemyExtension = class(AiHeroicEnemyExtension)

AiHeroicEnemyExtension.init = function (self, context, unit, extension_init_data)
	self._unit = unit
	self._is_server = Managers.player.is_server
end

AiHeroicEnemyExtension.decoy = function (self, unit)
	if Managers.player.is_server then
		self._num_decoys = 3
		self._decoys = {}

		self:_spawn_decoys(unit)
	end
end

AiHeroicEnemyExtension._spawn_decoys = function (self, unit)
	local breed = Breeds.skaven_gutter_runner_decoy.breed_name

	for i = 1, self._num_decoys, 1 do
		local unit = Managers.state.conflict:spawn_unit(breed, Unit.local_position(unit, 0), Quaternion(Vector3.up(), 0), "specials_pacing", nil, nil, nil, nil, nil)
		self._decoys[i] = unit
	end
end

AiHeroicEnemyExtension._kill_decoys = function (self, unit)
	for i = 1, self._num_decoys, 1 do
		local decoy_unit = self._decoys[i]

		if AiUtils.unit_alive(decoy_unit) then
			AiUtils.kill_unit(decoy_unit, unit)
		end
	end
end

AiHeroicEnemyExtension.respawn_decoys = function (self)
	local unit = self._unit

	self:_kill_decoys(unit)
	self:_spawn_decoys(unit)
end

AiHeroicEnemyExtension.decoy_destroyed = function (self, unit)
	if Managers.player.is_server then
		self:_kill_decoys(unit)
	end
end

AiHeroicEnemyExtension.smoke = function (self, unit)
	return
end

AiHeroicEnemyExtension.smoke_destroyed = function (self, unit)
	return
end

AiHeroicEnemyExtension.poison = function (self, unit)
	return
end

AiHeroicEnemyExtension.poison_destroyed = function (self, unit)
	return
end

AiHeroicEnemyExtension.bomb = function (self, unit)
	return
end

AiHeroicEnemyExtension.bomb_destroyed = function (self, unit)
	return
end

return
