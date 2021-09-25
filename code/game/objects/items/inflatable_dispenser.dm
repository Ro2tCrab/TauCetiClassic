/obj/item/weapon/inflatable_dispenser
    name = "inflatable dispenser"
    icon = 'icons/obj/storage.dmi'
    icon_state = "inf_deployer"
    w_class = SIZE_SMALL

    var/stored_walls = 12
    var/stored_doors = 4
    var/max_walls = 12
    var/max_doors = 4
    var/mode = 0

/obj/item/weapon/inflatable_dispenser/atom_init()
	. = ..()
	desc = "A inflatable dispenser. It currently holds [stored_walls]/[max_walls] walls and [stored_doors]/[max_doors] doors."

/obj/item/weapon/inflatable_dispenser/attack_self()
    . = ..()
    mode = !mode
    to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/afterattack(atom/A, mob/user)
	..(A, user)
	if(!user)
		return
	if(!user.Adjacent(A))
		to_chat(user, "You can't reach!")
		return
	if(istype(A, /turf))
		try_deploy_inflatable(A, user)
	if(istype(A, /obj/item/inflatable) || istype(A, /obj/structure/inflatable))
		pick_up(A, user)

/obj/item/weapon/inflatable_dispenser/proc/try_deploy_inflatable(turf/T, mob/living/user)
    if(mode)
        if(!stored_doors)
            to_chat(user, "\The [src] out of doors")
            return
        if(T && istype(T))
            new /obj/structure/inflatable/door(T)
            --stored_doors

    else
        if(!stored_walls)
            to_chat(user, "\The [src] out of walls")
            return
        if(T && istype(T))
            new /obj/structure/inflatable(T)
            --stored_walls
    
    playsound(T,'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
    to_chat(user, "You deploy the inflatable [mode ? "door" : "wall"]!")

/obj/item/weapon/inflatable_dispenser/proc/pick_up(obj/A, mob/living/user)
	if(istype(A, /obj/structure/inflatable))
		if(istype(A, /obj/structure/inflatable/door))
			if(stored_doors >= max_doors)
				to_chat(user, "\The [src] is full.")
				return
			stored_doors++
			qdel(A)
		else
			if(stored_walls >= max_walls)
				to_chat(user, "\The [src] is full.")
				return
			stored_walls++
			qdel(A)
		playsound(loc, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER)
		visible_message("\The [user] deflates \the [A] with \the [src]!")
		return
	if(istype(A, /obj/item/inflatable))
		if(istype(A, /obj/item/inflatable/door))
			if(stored_doors >= max_doors)
				to_chat(user, "\The [src] is full.")
				return
			stored_doors++
			qdel(A)
		else
			if(stored_walls >= max_walls)
				to_chat(usr, "\The [src] is full!")
				return
			stored_walls++
			qdel(A)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		return

	to_chat(user, "You fail to pick up \the [A] with \the [src]")
	return