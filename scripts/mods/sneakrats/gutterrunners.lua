local mod = get_mod("sneakrats")
mod:dofile("scripts/mods/sneakrats/misc/bt_selector_gutter_runner_decoy")

-- Spawn Decoys when Gutter Runner Vanishes
--mod:dofile("scripts/mods/sneakrats/misc/ai_heroic_enemy_extension")
--[[mod:dofile("scripts/mods/sneakrats/misc/ai_heroic_enemy_extension_quickfix")
mod:decoy()]]

--[[EntitySystem:_add_system("ai_heroic_enemy_system", ExtensionSystemBase, entity_system_creation_context, {
	"AiHeroicEnemyExtension"
})]]
--[[mod:hook_origin(BTNinjaVanishAction, "vanish", function (unit, blackboard)
	--local heroic_extension = ScriptUnit.extension(unit, "ai_heroic_enemy_system")
	--heroic_extension:respawn_decoys()
	mod:respawn_decoys(unit)

	local vanish_pos = blackboard.vanish_pos:unbox()

	if script_data.debug_ai_movement then
		QuickDrawerStay:cylinder(vanish_pos, vanish_pos + Vector3(0, 0, 17), 0.4, Color(200, 0, 131), 20)
		QuickDrawerStay:line(POSITION_LOOKUP[unit] + Vector3(0, 0, 4), vanish_pos + Vector3(0, 0, 17), Color(200, 0, 131))
	end

	local network_manager = Managers.state.network

	BTNinjaVanishAction.play_foff(unit, blackboard, network_manager, POSITION_LOOKUP[unit], vanish_pos)
	network_manager:anim_event(unit, "idle")
	blackboard.locomotion_extension:teleport_to(vanish_pos)

	local ai_navigation = blackboard.navigation_extension

	ai_navigation:move_to(vanish_pos)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3.zero())
	Managers.state.entity:system("ai_bot_group_system"):enemy_teleported(unit, vanish_pos)

	local ping_system = Managers.state.entity:system("ping_system")

	ping_system:remove_ping_from_unit(unit)
end)]]

-- Gutter Runner Actions
BreedActions.skaven_gutter_runner.circle_prey_decoy = {
	despawn_on_outside_navmesh = true
}

for breed_name, breed_actions in pairs(BreedActions) do
	for action_name, action_data in pairs(breed_actions) do
		action_data.name = action_name
	end
end

-- Decoy Death Reaction

DeathReactions.templates.gutter_runner_decoy = {
	unit = {
		start = function (unit, context, t, killing_blow, is_server)
			local data, result = ai_default_unit_start(unit, context, t, killing_blow, is_server)
			data.despawn_after_time = t + 2

			StatisticsUtil.register_kill(unit, killing_blow, context.statistics_db, true)
			trigger_unit_dialogue_death_event(unit, killing_blow[DamageDataIndex.ATTACKER], killing_blow[DamageDataIndex.HIT_ZONE], killing_blow[DamageDataIndex.DAMAGE_TYPE])
			trigger_player_killing_blow_ai_buffs(unit, killing_blow, true)

			return data, result
		end,
		update = function (unit, dt, context, t, data)
			if data.despawn_after_time and data.despawn_after_time < t then
				Managers.state.unit_spawner:mark_for_deletion(unit)

				return DeathReactions.IS_DONE
			end

			return DeathReactions.IS_NOT_DONE
		end
	},
	husk = {
		start = function (unit, context, t, killing_blow, is_server)
			local data, result = ai_default_husk_start(unit, context, t, killing_blow, is_server)

			if not is_hot_join_sync(killing_blow) then
				StatisticsUtil.register_kill(unit, killing_blow, context.statistics_db)
				trigger_player_killing_blow_ai_buffs(unit, killing_blow, false)
			end

			return nil, DeathReactions.IS_DONE
		end,
		update = function (unit, dt, context, t, data)
			return DeathReactions.IS_DONE
		end
	}
}

-- Decoy Behaviors

local ACTIONS = BreedActions.skaven_gutter_runner
BreedBehaviors.gutter_runner_decoy = {
	"BTSelector",
	{
		"BTFallAction",
		condition = "is_gutter_runner_falling",
		name = "falling"
	},
	{
		"BTStaggerAction",
		name = "stagger",
		condition = "stagger",
		action_data = ACTIONS.stagger
	},
	{
		"BTSpawningAction",
		condition = "spawn",
		name = "spawn"
	},
	{
		"BTInVortexAction",
		condition = "in_vortex",
		name = "in_vortex"
	},
	{
		"BTSelector",
		{
			"BTTeleportAction",
			condition = "at_teleport_smartobject",
			name = "teleport"
		},
		{
			"BTJumpAcrossAction",
			condition = "at_jump_smartobject",
			name = "jump_across"
		},
		{
			"BTSmashDoorAction",
			name = "smash_door",
			condition = "at_door_smartobject",
			action_data = ACTIONS.smash_door
		},
		{
			"BTNinjaHighGroundAction",
			condition = "at_climb_smartobject",
			name = "climb"
		},
		condition = "gutter_runner_at_smartobject",
		name = "smartobject"
	},
	{
		"BTCirclePreyAction",
		name = "abide",
		condition = "secondary_target",
		action_data = ACTIONS.circle_prey_decoy
	},
	{
		"BTIdleAction",
		name = "idle"
	},
	name = "gutter_runner_decoy"
}

-- Decoy Breeds data
Breeds.skaven_gutter_runner_decoy = table.create_copy(Breeds.skaven_gutter_runner_decoy, Breeds.skaven_gutter_runner)
Breeds.skaven_gutter_runner_decoy.behavior = "gutter_runner_decoy"
--Breeds.skaven_gutter_runner_decoy.death_reaction = "gutter_runner_decoy"
Breeds.skaven_gutter_runner_decoy.max_health = {
	1,
	1,
	1,
	1,
	1
}
Breeds.skaven_gutter_runner_decoy.patrol_passive_perception = "perception_regular"
Breeds.skaven_gutter_runner_decoy.patrol_active_target_selection = "pick_ninja_approach_target"
Breeds.skaven_gutter_runner_decoy.patrol_detection_radius = 10
Breeds.skaven_gutter_runner_decoy.patrol_active_perception = "perception_regular"
Breeds.skaven_gutter_runner_decoy.patrol_passive_target_selection = "pick_ninja_approach_target"

Breeds.skaven_gutter_runner.patrol_passive_perception = "perception_regular"
Breeds.skaven_gutter_runner.patrol_active_target_selection = "pick_ninja_approach_target"
Breeds.skaven_gutter_runner.patrol_detection_radius = 10
Breeds.skaven_gutter_runner.patrol_active_perception = "perception_regular"
Breeds.skaven_gutter_runner.patrol_passive_target_selection = "pick_ninja_approach_target"

-- Decoy Package Loader

--[[EnemyPackageLoaderSettings.categories = {
	{
		id = "bosses",
		dynamic_loading = false,
		limit = math.huge,
		breeds = {
			"chaos_spawn",
			"chaos_troll",
			"skaven_rat_ogre",
			"skaven_stormfiend"
		}
	},
	{
		id = "specials",
		dynamic_loading = false,
		limit = math.huge,
		breeds = {
			"chaos_plague_sorcerer",
			"chaos_corruptor_sorcerer",
			"skaven_gutter_runner",
			"skaven_gutter_runner_decoy",
			"skaven_pack_master",
			"skaven_poison_wind_globadier",
			"skaven_ratling_gunner",
			"skaven_warpfire_thrower",
			"chaos_vortex_sorcerer"
		}
	},
	{
		id = "level_specific",
		dynamic_loading = true,
		limit = math.huge,
		breeds = {
			"chaos_dummy_sorcerer",
			"chaos_exalted_champion_warcamp",
			"chaos_exalted_sorcerer",
			"skaven_storm_vermin_warlord",
			"skaven_storm_vermin_champion",
			"chaos_plague_wave_spawner",
			"skaven_stormfiend_boss",
			"skaven_grey_seer"
		}
	},
	{
		id = "debug",
		dynamic_loading = true,
		forbidden_in_build = "release",
		limit = math.huge,
		breeds = {
			"chaos_zombie",
			"chaos_tentacle",
			"chaos_tentacle_sorcerer",
			"chaos_mutator_sorcerer",
			"pet_rat",
			"pet_pig",
			"skaven_stormfiend_demo"
		}
	},
	{
		id = "always_loaded",
		dynamic_loading = false,
		breeds = {
			"chaos_berzerker",
			"chaos_fanatic",
			"chaos_marauder",
			"chaos_raider",
			"chaos_warrior",
			"skaven_clan_rat",
			"skaven_storm_vermin",
			"skaven_storm_vermin_with_shield",
			"skaven_slave",
			"skaven_loot_rat",
			"chaos_marauder_with_shield",
			"skaven_clan_rat_with_shield",
			"skaven_plague_monk",
			"chaos_vortex",
			"critter_rat",
			"critter_pig"
		}
	}
}]]

-- Decoy Network Lookup

NetworkLookup.breeds.skaven_gutter_runner_decoy = [#NetworkLookup.breeds + 1]
NetworkLookup.breeds[#NetworkLookup.breeds + 1] = "skaven_gutter_runner_decoy"