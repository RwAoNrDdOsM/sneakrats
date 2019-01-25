local mod = get_mod("sneakrats")

-- Patrol Changes
mod:dofile("scripts/mods/sneakrats/patrols")

-- Decoy Gutter Runners
mod:dofile("scripts/mods/sneakrats/gutterrunners")



-- Quick fix for Decoys
local threat_values = {}

for breed_name, data in pairs(Breeds) do
	threat_values[breed_name] = override_threat_value or data.threat_value or 0

	if not data.threat_value then
		fassert(false, "missing threat in breed %s", breed_name)
	end
end

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

local DEFAULT_AGGRO_MULTIPLIERS = {
	ranged = 1,
	melee = 1,
	grenade = 1
}


mod:hook_origin(DoorSystem, "rpc_sync_boss_door_state", function (self, sender, level_object_id, door_state_id, breed_id)
	local level = LevelHelper:current_level(self.world)
	local door_unit = Level.unit_by_index(level, level_object_id)
	local door_extension = ScriptUnit.has_extension(door_unit, "door_system")
	mod:echo(breed_id)

	if door_extension then
		local new_state = NetworkLookup.door_states[door_state_id]
		local breed_name = NetworkLookup.breeds[breed_id]
		mod:echo(breed_name)

		door_extension:set_door_state(new_state, breed_name)
	else
		Application.warning(string.format("[DoorSystem:rpc_sync_boss_door_state] The synced level_object_id (%s) doesn't correspond to a unit with a 'door_system' extension. Unit: %s", level_object_id, tostring(door_unit)))
	end
end)

mod:hook_origin(DoorSystem, "close_boss_doors", function (self, map_section, group_id, breed_name)
	local boss_doors = self._boss_doors[map_section]
	local network_manager = Managers.state.network
	local network_transmit = network_manager.network_transmit

	mod:echo(breed_name)

	if boss_doors then
		for i = 1, #boss_doors, 1 do
			local boss_door_unit = boss_doors[i]
			local extension = ScriptUnit.extension(boss_door_unit, "door_system")

			extension:set_door_state("closed", breed_name)

			local level = LevelHelper:current_level(self.world)
			local level_index = Level.unit_index(level, boss_door_unit)
			local door_state_id = NetworkLookup.door_states.closed
			local breed_id = (breed_name and NetworkLookup.breeds[breed_name]) or NetworkLookup.breeds["n/a"]

			network_transmit:send_rpc_clients("rpc_sync_boss_door_state", level_index, door_state_id, breed_id)
		end

		if not self._active_groups[map_section] then
			self._active_groups[map_section] = {}
		end

		local active_groups_in_section = self._active_groups[map_section]
		active_groups_in_section[#active_groups_in_section + 1] = {
			active = false,
			group_id = group_id
		}
	end
end)

mod:hook_origin(DoorSystem, "rpc_sync_boss_door_state", function (self, sender, level_object_id, door_state_id, breed_id)
	local level = LevelHelper:current_level(self.world)
	local door_unit = Level.unit_by_index(level, level_object_id)
	local door_extension = ScriptUnit.has_extension(door_unit, "door_system")

	mod:echo(breed_name)

	if door_extension then
		local new_state = NetworkLookup.door_states[door_state_id]
		local breed_name = NetworkLookup.breeds[breed_id]

		door_extension:set_door_state(new_state, breed_name)
	else
		Application.warning(string.format("[DoorSystem:rpc_sync_boss_door_state] The synced level_object_id (%s) doesn't correspond to a unit with a 'door_system' extension. Unit: %s", level_object_id, tostring(door_unit)))
	end
end)

mod:hook_origin(BossDoorExtension, "set_door_state", function (self, new_state, breed_name)
	local current_state = self.current_state

	mod:echo(breed_name)

	if current_state == new_state then
		return
	end

	local unit = self.unit
	local state_flow_event = (new_state == "closed" and "lua_close") or "lua_open"

	Unit.flow_event(unit, state_flow_event)

	local effect_flow_event = flow_event_by_breed[breed_name]

	if effect_flow_event then
		Unit.flow_event(unit, effect_flow_event)
	end

	local closed = new_state == "closed"
	self.current_state = new_state
	self.breed_name = breed_name
	
end)

mod:hook_origin(BossDoorExtension, "hot_join_sync", function (self, sender)
	local level = LevelHelper:current_level(self.world)
	local level_index = Level.unit_index(level, self.unit)
	local door_state = self.current_state
	local door_state_id = NetworkLookup.door_states[door_state]
	local breed_name = ((self.breed_name ~= nil) and self.breed_name) or "n/a"
	local breed_id = NetworkLookup.breeds[breed_name]
	mod:echo(self.breed_name)

	RPC.rpc_sync_boss_door_state(sender, level_index, door_state_id, breed_id)
end)

mod:hook_origin(AiUtils, "update_aggro", function (unit, blackboard, breed, t, dt)
	local aggro_list = blackboard.aggro_list
	local health_extension = ScriptUnit.extension(unit, "health_system")
	local strided_array, array_length = health_extension:recent_damages()
	local aggro_decay = dt * breed.perception_weights.aggro_decay_per_sec

	for enemy_unit, aggro in pairs(aggro_list) do
		aggro_list[enemy_unit] = math.clamp(aggro - aggro_decay, 0, 100)
	end

	local aggro_multipliers = breed.perception_weights.aggro_multipliers or DEFAULT_AGGRO_MULTIPLIERS

	if array_length > 0 then
		local stride = DamageDataIndex.STRIDE
		local index = 0

		for i = 1, array_length / stride, 1 do
			local attacker_unit = strided_array[index + DamageDataIndex.ATTACKER]
			local damage_amount = strided_array[index + DamageDataIndex.DAMAGE_AMOUNT]
			local damage_source = strided_array[index + DamageDataIndex.DAMAGE_SOURCE_NAME]
			local master_list_item = rawget(ItemMasterList, damage_source)

			if master_list_item then
				local slot_type = master_list_item.slot_type
				local multiplier = aggro_multipliers[slot_type] or 1
				damage_amount = damage_amount * multiplier
			end

			local aggro = aggro_list[attacker_unit]

			if aggro then
				aggro = aggro + damage_amount
				aggro_list[attacker_unit] = aggro
			else
				aggro_list[attacker_unit] = damage_amount
			end

			index = index + stride
		end
	end
end)

local CLASS_NAME = 1

local function create_btnode_from_lua_node(lua_node, parent_btnode)
	local class_name = lua_node[CLASS_NAME]
	local identifier = lua_node.name
	local condition_name = lua_node.condition or "always_true"
	local enter_hook_name = lua_node.enter_hook
	local leave_hook_name = lua_node.leave_hook
	local action_data = lua_node.action_data
	local class_type = rawget(_G, class_name)

	if not class_type then
		fassert(false, "BehaviorTree: no class registered named( %q )", tostring(class_name))
	else
		return class_type:new(identifier, parent_btnode, condition_name, enter_hook_name, leave_hook_name, lua_node), action_data
	end
end

mod:hook_origin(BehaviorTree, "parse_lua_tree", function (self, lua_root_node)
	self._root = create_btnode_from_lua_node(lua_root_node)

	self:parse_lua_node(lua_root_node, self._root)
end)