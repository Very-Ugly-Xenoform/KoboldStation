//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "A SalonPro Nano-Mirror(TM) brand mirror! The leading technology in hair salon products, utilizing nano-machinery to style your hair just right."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0
	var/list/ui_users = list()

/obj/structure/mirror/attack_hand(mob/user as mob)

	if(shattered)	return

	if(user.mind && user.mind.vampire && (!(user.mind.vampire.status & VAMP_ISTHRALL)))
		to_chat(user, "<span class='notice'>Your reflection appears distorted on the surface of \the [src].</span>")

	if(ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/proc/shatter()
	if(shattered)	return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)

	if(prob(Proj.get_structure_damage() * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()

/obj/structure/mirror/attackby(obj/item/I as obj, mob/user as mob)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 70, 1)

/obj/structure/mirror/attack_generic(var/mob/user, var/damage)

	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return 0

	if(damage)
		user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
		shatter()
	else
		user.visible_message("<span class='danger'>[user] hits [src] and bounces off!</span>")
	return 1

/obj/structure/mirror/Destroy()
	for(var/user in ui_users)
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		qdel(AC)
	ui_users.Cut()
	return ..()

/obj/item/weapon/mirror
	name = "mirror"
	desc = "A SalonPro Nano-Mirror(TM) brand mirror! Now a portable version."
	icon = 'icons/obj/cosmetics.dmi'
	icon_state = "mirror"
	var/list/ui_users = list()

/obj/item/weapon/mirror/attack_self(mob/user as mob)

	if(user.mind && user.mind.vampire && (!(user.mind.vampire.status & VAMP_ISTHRALL)))
		to_chat(user, "<span class='notice'>Your reflection appears distorted on the surface of \the [src].</span>")

	if(ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if(!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			AC.flags = APPEARANCE_HAIR
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/item/weapon/mirror/Destroy()
	for(var/user in ui_users)
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		qdel(AC)
	ui_users.Cut()
	return ..()


//merchant mirror, turns you into a vox
/obj/structure/mirror/merchant
	name = "cracked mirror"
	desc = "Something seems strange about this old, dirty mirror. Your reflection doesn't look like you remember it."
	icon_state = "mirror_broke"
	shattered = 1

/obj/structure/mirror/merchant/attack_hand(var/mob/living/carbon/human/user)
	if(istype(get_area(src),/area/merchant_station))
		if(istype(user) && user.mind && user.mind.assigned_role == "Merchant" && user.species.name != "Vox")
			var/choice = input("Do you wish to become a Vox? This is not reversible.") as null|anything in list("No","Yes")
			if(choice == "Yes")
				user.set_species("Vox")
				user.species.before_equip(user)

				var/newname = sanitizeSafe(input(user,"Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
				if(!newname || newname == "")
					newname = user.species.get_random_name()
				user.fully_replace_character_name(user.real_name,newname)
	..()