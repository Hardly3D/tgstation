/datum/keybinding/mob/unique_action
	hotkey_keys = list("Space")
	name = "unique_action"
	full_name = "Perform unique action"
	description = "Activates unique action, mostly for racking or setting energy mode on held weapon."
	keybind_signal = COMSIG_KB_MOB_UNIQUEACTION_DOWN

/datum/keybinding/mob/unique_action/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/current_mob = user.mob
	current_mob.do_unique_action()
	return TRUE

/mob/verb/do_unique_action()
	set name = "unique-action"
	set hidden = TRUE

	if(incapacitated)
		return

	var/obj/item/item_target = get_active_held_item()
	if(item_target)
		item_target.unique_action(src)
		update_held_items()
