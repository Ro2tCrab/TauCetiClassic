/obj/item/weapon/inflatable_dispenser
    name = "inflatables dispenser"
    desc = "Hand-held device which allows rapid deployment and removal of inflatables."
    icon = 'icons/obj/storage.dmi'
    icon_state = "inf_deployer"
    w_class = SIZE_SMALL

	var/stored_walls = 6
	var/stored_doors = 3
	var/max_walls = 6
	var/max_doors = 3
	var/mode = 0 // 0 - Walls   1 - Doors

/obj/item/weapon/inflatable_dispenser/robot
	w_class = ITEM_SIZE_HUGE
	stored_walls = 20
	stored_doors = 5
	max_walls = 20
	max_doors = 5

/obj/item/weapon/inflatable_dispenser/examine(mob/user)
	. = ..()
	if(!.)
		return
	. += "\nIt has [stored_walls] wall segment\s and [stored_doors] door segment\s stored."
	. += "\nIt is set to deploy [mode ? "doors" : "walls"]"


/obj/item/weapon/inflatable_dispenser/attack_self()
	mode = !mode
	to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/afterattack(atom/A, mob/user)
	..(A, user)
	if(!user)
		return
	if(!user.(user.Adjacent(A))
		to_chat(user, "You can't reach!")
		return
	if(istype(A, /turf))
		try_deploy_inflatable(A, user)
	if(istype(A, /obj/item/inflatable) || istype(A, /obj/structure/inflatable))
		pick_up(A, user)

/obj/item/weapon/inflatable_dispenser/proc/try_deploy_inflatable(turf/T, mob/living/user)
	if(mode) // Door deployment
		if(!stored_doors)
			to_chat(user, "\The [src] is out of doors!")
			return

		if(T && istype(T))
			new /obj/structure/inflatable/door(T)
			stored_doors--

	else // Wall deployment
		if(!stored_walls)
			to_chat(user, "\The [src] is out of walls!")
			return

		if(T && istype(T))
			new /obj/structure/inflatable(T)
			stored_walls--

	playsound(T, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "You deploy the inflatable [mode ? "door" : "wall"]!")


/obj/item/weapon/inflatable_dispenser/proc/pick_up(obj/A, mob/living/user)
	if(istype(A, /obj/structure/inflatable/door))
		if(istype(A, /obj/structure/inflatable))
			if(stored_walls >= max_walls)
				to_chat(user, "\The [src] is full.")
				return
			stored_walls++
			qdel(A)
		else
			if(stored_doors >= max_doors)
				to_chat(user, "\The [src] is full.")
				return
			stored_doors++
			qdel(A)
		playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
		visible_message("\The [user] deflates \the [A] with \the [src]!")
		return
	if(istype(A, /obj/item/inflatable))
		if(istype(A, /obj/item/inflatable/wall))
			if(stored_walls >= max_walls)
				to_chat(user, "\The [src] is full.")
				return
			stored_walls++
			qdel(A)
		else
			if(stored_doors >= max_doors)
				to_chat(usr, "\The [src] is full!")
				return
			stored_doors++
			qdel(A)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		return

	to_chat(user, "You fail to pick up \the [A] with \the [src]")
	return


