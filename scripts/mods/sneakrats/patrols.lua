local mod = get_mod("sneakrats")

PatrolFormationSettings.default_sneaking_settings = {
	sounds = {
		PLAYER_SPOTTED = "enemy_gutterrunner_stinger",
		FORMING = "",
		FOLEY = "",
		FORMATED = "",
		FORMATE = "",
		CHARGE = "horde_stinger_skaven_gutter_runner",
		VOICE = "enemy_gutterrunner_stinger"
	},
	offsets = PatrolFormationSettings.default_settings.offsets,
	speeds = {
		FAST_WALK_SPEED = 2.6,
		MEDIUM_WALK_SPEED = 2.35,
		WALK_SPEED = 2.12,
		SPLINE_SPEED = 2.22,
		SLOW_SPLINE_SPEED = 0.1
	}
}
PatrolFormationSettings.chaos_warrior_default = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat"
		},
		{
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		}
	},
	hard = {
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_slave",
			"skaven_slave"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		}
	},
	harder = {
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"chaos_raider",
			"chaos_raider"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		}
	},
	hardest = {
		{
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		}
	}
}
PatrolFormationSettings.chaos_warrior = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"skaven_gutter_runner"
		}
	},
	hard = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	harder = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	hardest = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner",
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	}
}
PatrolFormationSettings.chaos_warrior_small = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		}
	},
	hard = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_clan_rat_with_shield"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat"
		}
	},
	harder = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	hardest = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"chaos_warrior"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	}
}
PatrolFormationSettings.chaos_warrior_long = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_rat",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_rat"
		},
		{
			"critter_rat",
			"critter_rat"
		}
	},
	hard = {
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat"
		}
	},
	harder = {
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat"
		}
	},
	hardest = {
		{
			"critter_rat",
			"critter_rat"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_pig"
		}
	}
}
PatrolFormationSettings.chaos_warrior_wide = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig",
			"critter_pig",
			"critter_pig"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig",
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		}
	},
	hard = {
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig",
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"critter_pig",
			"critter_pig",
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		}
	},
	harder = {
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig",
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner",
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_pig",
			"critter_pig",
			"critter_pig"
		}
	},
	hardest = {
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		},
		{
			"critter_pig",
			"critter_pig",
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner",
			"critter_pig",
			"critter_pig"
		},
		{
			"critter_rat",
			"critter_rat",
			"critter_rat"
		}
	}
}
PatrolFormationSettings.one_chaos_warrior = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"skaven_gutter_runner"
		}
	},
	hard = {
		{
			"skaven_gutter_runner"
		}
	},
	harder = {
		{
			"skaven_gutter_runner"
		}
	},
	hardest = {
		{
			"skaven_gutter_runner"
		}
	}
}
PatrolFormationSettings.double_dragon = {
	settings = PatrolFormationSettings.default_sneaking_settings,
	normal = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	hard = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	harder = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	},
	hardest = {
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		},
		{
			"skaven_gutter_runner",
			"skaven_gutter_runner"
		}
	}
}