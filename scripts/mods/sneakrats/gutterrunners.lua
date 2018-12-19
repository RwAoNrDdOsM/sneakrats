local mod = get_mod("sneakrats")
mod:dofile("scripts/mods/sneakrats/misc/bt_selector_gutter_runner_decoy")
mod:dofile("scripts/mods/sneakrats/misc/ai_heroic_enemy_extension")


-- Gutter Runner Actions

local action_data = {
	target_pounced = {
		final_damage_multiplier = 5,
		foff_after_pounce_kill = true,
		fatigue_type = "blocked_attack",
		far_impact_radius = 6,
		close_impact_radius = 2,
		impact_speed_given = 10,
		damage_type = "cutting",
		stab_until_target_is_killed = true,
		time_before_ramping_damage = {
			10,
			10,
			5,
			5,
			5
		},
		time_to_reach_final_damage_multiplier = {
			15,
			15,
			10,
			10,
			10
		},
		damage = {
			1.5,
			1.5,
			1.5,
			1.5
		},
		difficulty_damage = {
			easy = {
				1,
				0.5,
				0.25
			},
			normal = {
				1,
				0.5,
				0.25
			},
			hard = {
				2,
				1,
				0.5
			},
			survival_hard = {
				2,
				1,
				0.5
			},
			harder = {
				2.5,
				1.5,
				0.5
			},
			survival_harder = {
				2.5,
				1.5,
				0.5
			},
			hardest = {
				5,
				2,
				0.5
			},
			survival_hardest = {
				7.5,
				3,
				0.75
			}
		},
		ignore_staggers = {
			true,
			false,
			false,
			true,
			false,
			false,
			allow_push = true
		}
	},
	jump = {
		difficulty_jump_delay_time = {
			0.3,
			0.3,
			0.3,
			0.3,
			0.3
		}
	},
	prepare_crazy_jump = {
		difficulty_prepare_jump_time = {
			0.4,
			0.4,
			0.4,
			0.4,
			0.4
		}
	},
	ninja_vanish = {
		stalk_lonliest_player = true,
		foff_anim_length = 0.32,
		effect_name = "fx/chr_gutter_foff"
	},
	smash_door = {
		unblockable = true,
		damage_type = "cutting",
		move_anim = "move_fwd",
		attack_anim = "smash_door",
		damage = {
			5,
			5,
			5
		}
	},
	stagger = {
		stagger_anims = {
			{
				fwd = {
					"stun_fwd_sword"
				},
				bwd = {
					"stun_bwd_sword"
				},
				left = {
					"stun_left_sword"
				},
				right = {
					"stun_right_sword"
				}
			},
			{
				fwd = {
					"stagger_fwd"
				},
				bwd = {
					"stagger_bwd"
				},
				left = {
					"stagger_left"
				},
				right = {
					"stagger_right"
				}
			},
			{
				fwd = {
					"stagger_fwd_heavy"
				},
				bwd = {
					"stagger_bwd_heavy"
				},
				left = {
					"stagger_left_heavy"
				},
				right = {
					"stagger_right_heavy"
				}
			},
			{
				fwd = {
					"stun_fwd_sword"
				},
				bwd = {
					"stun_bwd_sword"
				},
				left = {
					"stun_left_sword"
				},
				right = {
					"stun_right_sword"
				}
			},
			{
				fwd = {
					"stagger_fwd"
				},
				bwd = {
					"stagger_bwd"
				},
				left = {
					"stagger_left"
				},
				right = {
					"stagger_right"
				}
			},
			{
				fwd = {
					"stagger_fwd_exp"
				},
				bwd = {
					"stagger_bwd_exp"
				},
				left = {
					"stagger_left_exp"
				},
				right = {
					"stagger_right_exp"
				}
			},
			{
				fwd = {
					"stagger_fwd"
				},
				bwd = {
					"stagger_bwd"
				},
				left = {
					"stagger_left"
				},
				right = {
					"stagger_right"
				}
			}
		}
	},
	circle_prey_decoy = {
		despawn_on_outside_navmesh = true
	},
}
BreedActions.skaven_gutter_runner = table.create_copy(BreedActions.skaven_gutter_runner, action_data)

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

-- Decoy Behaviors

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
		action_data = BreedActions.skaven_gutter_runner.circle_prey_decoy
	},
	{
		"BTIdleAction",
		name = "idle"
	},
	name = "gutter_runner_decoy"
}

-- Decoy Breeds data

local breed_data = {
	behavior = "gutter_runner",
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
	death_reaction = "gutter_runner",
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
		12,
		12,
		18,
		24,
		36
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
	end,
}

Breeds.skaven_gutter_runner_decoy = table.create_copy(Breeds.skaven_gutter_runner_decoy, breed_data)
Breeds.skaven_gutter_runner_decoy.max_health = {
	1,
	1,
	1,
	1,
	1
}
Breeds.skaven_gutter_runner_decoy.behavior = "gutter_runner_decoy"
Breeds.skaven_gutter_runner_decoy.death_reaction = "gutter_runner_decoy"

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

unit_templates.ai_unit_gutter_runner = {
	base_template = "ai_unit_base",
	go_type = "ai_unit_gutter_runner",
	self_owned_extensions = {
		"AiHeroicEnemyExtension",
		"AIInventoryExtension",
		"PingTargetExtension",
		"EnemyOutlineExtension"
	},
	husk_extensions = {
		"AiHeroicEnemyExtension",
		"AIInventoryExtension",
		"PingTargetExtension",
		"EnemyOutlineExtension"
	}
}

for unit_template_name, template_data in pairs(unit_templates) do
	template_data.NAME = unit_template_name

	for i = 1, extension_table_names_n, 1 do
		local extension_table_name = extension_table_names[i]
		local extension_list = template_data[extension_table_name] or {}
		local extension_list_n = #extension_list

		if template_data.base_template ~= nil then
			local inherited_template_name = template_data.base_template
			local inherited_template_data = unit_templates[inherited_template_name]

			assert(inherited_template_data.base_template == nil, "%s tried to inherit from template that had a base_template", unit_template_name)

			local inherited_extension_list = inherited_template_data[extension_table_name]

			if inherited_extension_list then
				inherited_extension_list_n = #inherited_extension_list

				for j = 1, inherited_extension_list_n, 1 do
					extension_list_n = extension_list_n + 1
					extension_list[extension_list_n] = inherited_extension_list[j]
				end
			end

			local inherited_remove_when_killed = inherited_template_data.remove_when_killed and inherited_template_data.remove_when_killed[extension_table_name]

			if inherited_remove_when_killed then
				if template_data.remove_when_killed == nil then
					template_data.remove_when_killed = {}
				end

				if template_data.remove_when_killed[extension_table_name] == nil then
					template_data.remove_when_killed[extension_table_name] = {}
				end

				for j = 1, #inherited_remove_when_killed, 1 do
					local remove_when_killed = template_data.remove_when_killed[extension_table_name]
					remove_when_killed[#remove_when_killed + 1] = inherited_remove_when_killed[j]
				end
			end
		end

		template_data["num_" .. extension_table_name] = extension_list_n
		local remove_when_killed = template_data.remove_when_killed

		if remove_when_killed then
			for i = 1, extension_table_names_n, 1 do
				local extension_table_name = extension_table_names[i]
				local extension_list = remove_when_killed[extension_table_name]

				if extension_list then
					remove_when_killed["num_" .. extension_table_name] = #extension_list
				end
			end
		end
	end
end