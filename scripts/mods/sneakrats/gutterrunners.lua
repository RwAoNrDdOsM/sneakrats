local mod = get_mod("sneakrats")
mod:dofile("scripts/mods/sneakrats/misc/bt_selector_gutter_runner_decoy")
mod:dofile("scripts/mods/sneakrats/misc/ai_heroic_enemy_extension")

-- Gutter Runner Actions
BreedActions.skaven_gutter_runner.circle_prey_decoy = {
	despawn_on_outside_navmesh = true
}

for breed_name, breed_actions in pairs(BreedActions) do
	for action_name, action_data in pairs(breed_actions) do
		action_data.name = action_name
	end
end

mod:hook_origin(BTNinjaVanishAction, "vanish", function (unit, blackboard)
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

	local heroic_extension = ScriptUnit.extension(unit, "ai_heroic_enemy_system")
	
	heroic_extension:respawn_decoys()
end)

-- Decoy Death Reaction

DeathReactions.templates.gutter_runner_decoy = {
	unit = {
		start = function (unit, dt, context, t, killing_blow, is_server, cached_wall_nail_data)
			local killer_unit = killing_blow[DamageDataIndex.ATTACKER]
			local damaged_by_other = unit ~= killer_unit

			if damaged_by_other then
				local ai_extension = ScriptUnit.extension(unit, "ai_system")

				AiUtils.alert_nearby_friends_of_enemy(unit, ai_extension:blackboard().group_blackboard.broadphase, killer_unit)
			end

			local locomotion = ScriptUnit.extension(unit, "locomotion_system")
			Unit.flow_event(unit, "disable_despawn_fx")
			World.create_particles(context.world, "fx/chr_gutter_foff", POSITION_LOOKUP[unit], Unit.local_rotation(unit, 0))
			local data, result = ai_default_unit_start(unit, context, t, killing_blow, is_server)

			StatisticsUtil.register_kill(unit, killing_blow, context.statistics_db, true)

			return {
				despawn_after_time = t + 2
			}, DeathReactions.IS_NOT_DONE
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
		start = function (unit, dt, context, t, killing_blow, is_server, cached_wall_nail_data)
			--[[if ScriptUnit.has_extension(unit, "locomotion_system") then
				local locomotion = ScriptUnit.extension(unit, "locomotion_system")

				locomotion:set_mover_disable_reason("husk_death_reaction", true)
				locomotion:set_collision_disabled("husk_death_reaction", true)
				locomotion:destroy()
			end]]

			Unit.flow_event(unit, "disable_despawn_fx")
			World.create_particles(context.world, "fx/chr_gutter_foff", POSITION_LOOKUP[unit], Unit.local_rotation(unit, 0))
			if not is_hot_join_sync(killing_blow) then
				StatisticsUtil.register_kill(unit, killing_blow, context.statistics_db)
			end

			return {}, DeathReactions.IS_DONE
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

Breeds.skaven_gutter_runner_decoy = {
	behavior = "gutter_runner_decoy",
	walk_speed = 3,
	run_speed = 9,
	stagger_in_air_mover_check_radius = 0.2,
	vortexable = true,
	ignore_death_watch_timer = true,
	target_selection = "pick_ninja_approach_target",
	exchange_order = 2,
	animation_sync_rpc = "rpc_sync_anim_state_3",
	pounce_bonus_dmg_per_meter = 1,
	has_inventory = true,
	default_inventory_template = "gutter_runner",
	allow_fence_jumping = true,
	armor_category = 1,
	approaching_switch_radius = 10,
	flingable = true,
	hit_reaction = "ai_default",
	jump_speed = 25,
	time_to_unspawn_after_death = 1,
	no_stagger_duration = true,
	special = true,
	headshot_coop_stamina_fatigue_type = "headshot_special",
	smart_targeting_outer_width = 0.6,
	awards_positive_reinforcement_message = true,
	hit_effect_template = "HitEffectsGutterRunner",
	smart_targeting_height_multiplier = 1.6,
	radius = 1,
	poison_resistance = 100,
	unit_template = "ai_unit_gutter_runner",
	debug_flag = "ai_gutter_runner_behavior",
	special_spawn_stinger = "enemy_gutterrunner_stinger",
	race = "skaven",
	bone_lod_level = 1,
	proximity_system_check = true,
	death_reaction = "gutter_runner_decoy",
	perception = "perception_all_seeing_re_evaluate",
	player_locomotion_constrain_radius = 0.7,
	jump_gravity = 9.82,
	smart_object_template = "special",
	jump_range = 20,
	smart_targeting_width = 0.3,
	special_spawn_stinger_time = 6,
	is_bot_aid_threat = true,
	initial_is_passive = false,
	base_unit = "units/beings/enemies/skaven_gutter_runner/chr_skaven_gutter_runner",
	threat_value = 8,
	pounce_impact_damage = {
		5,
		7
	},
	detection_radius = math.huge,
	perception_weights = {
		sticky_bonus = 5,
		dog_pile_penalty = -5,
		distance_weight = 10,
		max_distance = 40
	},
	max_health = {
		1,
		1,
		1,
		1,
		1
	},
	bloodlust_health = BreedTweaks.bloodlust_health.skaven_special,
	stagger_duration = {
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1
	},
	debug_class = DebugGutterRunner,
	debug_color = {
		255,
		200,
		200,
		0
	},
	disabled = Development.setting("disable_gutter_runner") or false,
	run_on_spawn = AiBreedSnippets.on_gutter_runner_spawn,
	hitzone_multiplier_types = {
		head = "headshot"
	},
	hit_zones = {
		full = {
			prio = 1,
			actors = {}
		},
		head = {
			prio = 1,
			actors = {
				"c_head"
			},
			push_actors = {
				"j_head",
				"j_spine1"
			}
		},
		neck = {
			prio = 1,
			actors = {
				"c_neck"
			},
			push_actors = {
				"j_head",
				"j_spine1"
			}
		},
		torso = {
			prio = 3,
			actors = {
				"c_hips",
				"c_spine",
				"c_spine2",
				"c_leftshoulder",
				"c_rightshoulder"
			},
			push_actors = {
				"j_spine1"
			}
		},
		left_arm = {
			prio = 4,
			actors = {
				"c_leftarm",
				"c_leftforearm",
				"c_lefthand"
			},
			push_actors = {
				"j_spine1"
			}
		},
		right_arm = {
			prio = 4,
			actors = {
				"c_rightarm",
				"c_rightforearm",
				"c_righthand"
			},
			push_actors = {
				"j_spine1"
			}
		},
		left_leg = {
			prio = 4,
			actors = {
				"c_leftleg",
				"c_leftupleg",
				"c_leftfoot",
				"c_lefttoebase"
			},
			push_actors = {
				"j_leftfoot",
				"j_rightfoot",
				"j_hips"
			}
		},
		right_leg = {
			prio = 4,
			actors = {
				"c_rightleg",
				"c_rightupleg",
				"c_rightfoot",
				"c_righttoebase"
			},
			push_actors = {
				"j_leftfoot",
				"j_rightfoot",
				"j_hips"
			}
		},
		tail = {
			prio = 4,
			actors = {
				"c_tail1",
				"c_tail2",
				"c_tail3",
				"c_tail4",
				"c_tail5",
				"c_tail6"
			},
			push_actors = {
				"j_hips"
			}
		},
		afro = {
			prio = 5,
			actors = {
				"c_afro"
			}
		}
	},
	custom_death_enter_function = function (unit, killer_unit, damage_type, death_hit_zone, t, damage_source)
		local blackboard = BLACKBOARDS[unit]

		if not Unit.alive(killer_unit) then
			return
		end

		QuestSettings.check_gutter_killed_while_pouncing(blackboard, killer_unit, damage_source)
	end,
	run_on_spawn = AiBreedSnippets.on_gutter_runner_spawn,
	before_stagger_enter_function = function (unit, blackboard, attacker_unit, is_push)
		if is_push then
			QuestSettings.check_gutter_runner_push_on_pounce(blackboard, attacker_unit)
			QuestSettings.check_gutter_runner_push_on_target_pounced(blackboard, attacker_unit)
		end
	end
}

local available_nav_tag_layers = {
	end_zone = 0,
	ledges = 1.5,
	barrel_explosion = 10,
	jumps = 1.5,
	bot_ratling_gun_fire = 3,
	big_boy_destructible = 0,
	planks = 1.5,
	ledges_with_fence = 1.5,
	doors = 1.5,
	teleporters = 5,
	bot_poison_wind = 1.5,
	fire_grenade = 10
}
local available_nav_cost_map_layers = {
	plague_wave = 20,
	troll_bile = 20,
	lamp_oil_fire = 10,
	warpfire_thrower_warpfire = 20,
	vortex_near = 1,
	stormfiend_warpfire = 30,
	vortex_danger_zone = 1
}

for breed_name, breed_data in pairs(Breeds) do
	local lookup = BreedHitZonesLookup[breed_name]

	if lookup then
		breed_data.hit_zones_lookup = lookup

		fassert(breed_data.debug_color, "breed needs a debug color")
	end

	local allowed_layers = breed_data.allowed_layers

	if allowed_layers then
		table.merge(available_nav_tag_layers, allowed_layers)
	end

	local nav_cost_map_allowed_layers = breed_data.nav_cost_map_allowed_layers

	if nav_cost_map_allowed_layers then
		table.merge(available_nav_cost_map_layers, nav_cost_map_allowed_layers)
	end

	if breed_data.special then
		breed_data.immediate_threat = true
	end
end
