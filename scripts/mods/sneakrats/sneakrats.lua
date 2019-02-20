local mod = get_mod("sneakrats")

local mod_debugmenu = get_mod("DebugMenu")
local list = require("scripts/network/unit_extension_templates")
mod_debugmenu.app.list:setList(list)

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

mod:hook_origin(ConflictDirector, "set_threat_value", function (self, breed_name, value)
	threat_values[breed_name] = value
end)

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


-- DEBUG

local function readonlytable(table)
	return setmetatable({}, {
		__metatable = false,
		__index = table,
		__newindex = function (table, key, value)
			error("Coder trying to modify EntityManager's read-only empty table. Don't do it!")
		end
	})
end
local EMPTY_TABLE = readonlytable({})
mod:hook_origin(EntityManager2, "add_unit_extensions", function (self, world, unit, unit_template_name, all_extension_init_data)
	all_extension_init_data = all_extension_init_data or EMPTY_TABLE
	local ignore_extensions_list = self._ignore_extensions_list
	local extension_to_system_map = self._extension_to_system_map
	local self_units = self._units
	local self_extensions = self._extensions
	local self_systems = self._systems
	local extensions_list, num_extensions = self.extension_extractor_function(unit, unit_template_name)

	if unit_template_name and self.system_to_extension_per_unit_type_map[extensions_list] == nil then
		local reverse_lookup = {}

		for i = 1, num_extensions, 1 do
			repeat
				local extension_name = extensions_list[i]

				if ignore_extensions_list[extension_name] then
					break
				end

				local system_name = self._extension_to_system_map[extension_name]
				reverse_lookup[system_name] = extension_name
			until true
		end

		self.system_to_extension_per_unit_type_map[extensions_list] = reverse_lookup
	end

	local unit_extensions_list = self._unit_extensions_list

	assert(not unit_extensions_list[unit], "Adding extensions to a unit that already has extensions added!")

	unit_extensions_list[unit] = extensions_list

	if num_extensions == 0 then
		if unit_template_name ~= nil then
			Unit.flow_event(unit, "unit_registered")
		end

		return false
	end

	for i = 1, num_extensions, 1 do
		repeat
			local extension_name = extensions_list[i]

			if ignore_extensions_list[extension_name] then
				break
			end

			local extension_system_name = extension_to_system_map[extension_name]

			assert(extension_system_name, string.format("No such registered extension %q", extension_name))

			local extension_init_data = all_extension_init_data[extension_system_name] or EMPTY_TABLE

			assert(extension_to_system_map[extension_name])

			local system = self_systems[extension_system_name]

			assert(system ~= nil, string.format("Adding extension %q with no system is registered.", extension_name))

			local extension = system:on_add_extension(world, unit, extension_name, extension_init_data)

			assert(extension, string.format("System (%s) must return the created extension (%s)", extension_system_name, extension_name))

			self_extensions[extension_name] = self_extensions[extension_name] or {}
			self_units[unit] = self_units[unit] or {}
			self_units[unit][extension_name] = extension

			assert(extension ~= EMPTY_TABLE)
		until true
	end

	local extensions = self_units[unit]

	for i = 1, num_extensions, 1 do
		repeat
			local extension_name = extensions_list[i]

			if ignore_extensions_list[extension_name] then
				break
			end

			local extension = extensions[extension_name]

			if extension.extensions_ready ~= nil then
				extension:extensions_ready(world, unit)
			end

			local extension_system_name = extension_to_system_map[extension_name]
			local system = self_systems[extension_system_name]

			if system.extensions_ready ~= nil then
				system:extensions_ready(world, unit, extension_name)
			end
		until true
	end

	Unit.flow_event(unit, "unit_registered")

	return true
end)

mod:hook_safe(ExtensionSystemBase, "init", function (self, entity_system_creation_context, system_name, extension_list)
	mod:echo(system_name)
end)

mod:hook_safe(EntityManager2, "register_system", function (self, system, system_name, extension_list)
	mod:echo(system_name)
	for i, extension in ipairs(extension_list) do
		mod:echo(self._extension_to_system_map[extension])
	end
end)