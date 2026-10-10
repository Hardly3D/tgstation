/// SHOTGUNS

/obj/item/gun/ballistic/shotgun
	recoil = 0.5
	recoil_unwielded = 6 // Should only happen with sawoff or unique shotguns (Warden, Bulldog, etc)
	wield_delay = 0.8 SECONDS
	wield_slowdown = SHOTGUN_SLOWDOWN
	aimed_wield_slowdown = SHOTGUN_AIM_SLOWDOWN

/obj/item/gun/ballistic/shotgun/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.1, scope_icon = FALSE)

/obj/item/gun/ballistic/shotgun/bulldog
	recoil = 0.2
	wield_slowdown = HEAVY_SHOTGUN_SLOWDOWN
	wield_delay = 0.65 SECONDS // More compact or something

/obj/item/gun/ballistic/shotgun/automatic
	recoil = 0.3

/// MISC

/obj/item/gun/ballistic/shotgun/musket
	recoil = 0.7
	recoil_unwielded = 3
	spread_unwielded = 12
	wield_slowdown = RIFLE_SLOWDOWN
	aimed_wield_slowdown = RIFLE_AIM_SLOWDOWN

/obj/item/gun/ballistic/shotgun/musket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.4, scope_icon = FALSE)
