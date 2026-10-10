/// RIFLES

/obj/item/gun/ballistic/rifle
	recoil = 0.7
	recoil_unwielded = 3
	spread_unwielded = 12
	wield_delay = 0.8


/obj/item/gun/ballistic/rifle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.4, scope_icon = FALSE)

/obj/item/gun/ballistic/rifle/boltaction/prime
	recoil = 0.6

/obj/item/gun/ballistic/rifle/sks
	recoil = 0.4
	recoil_unwielded = 2

/// SNIPER

/obj/item/gun/ballistic/rifle/sniper_rifle
	recoil = 0.8
	recoil_unwielded = 5

/obj/item/gun/ballistic/automatic/lahti
	wield_delay = 1
	recoil_unwielded = 35 // Heavy ass sniper rifle

/// CROSSBOWS

/obj/item/gun/ballistic/rifle/rebarxbow
	recoil = 0.05
	recoil_unwielded = 0.1
	spread_unwielded = 12

/obj/item/gun/ballistic/rifle/rebarxbow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 0.4, scope_icon = FALSE)
