/obj/item/weapon/material/sword
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = 4
	force_divisor = 0.7 // 42 when wielded with hardnes 60 (steel)
	thrown_force_divisor = 0.5 // 10 when thrown with weight 20 (steel)
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	can_embed = 0
	var/parry_chance = 40
	drop_sound = 'sound/items/drop/sword.ogg'

/obj/item/weapon/material/sword/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	var/parry_bonus = 1

	if(default_parry_check(user, attacker, damage_source) && prob(parry_chance * parry_bonus))
		user.visible_message("<span class='danger'>\The [user] parries [attack_text] with \the [src]!</span>")
		playsound(user.loc, 'sound/weapons/bladeparry.ogg', 50, 1)
		return 1
	return 0

/obj/item/weapon/material/sword/perform_technique(var/mob/living/carbon/human/target, var/mob/living/carbon/human/user, var/target_zone)
	var/armor_reduction = target.run_armor_check(target_zone,"melee")
	var/obj/item/organ/external/affecting = target.get_organ(target_zone)
	if(!affecting)
		return

	user.do_attack_animation(target)

	if(target_zone == "head" || target_zone == "eyes" || target_zone == "mouth")
		if(prob(70 - armor_reduction))
			target.eye_blurry += 5
			target.confused += 10
			return TRUE

	if(target_zone == "r_arm" || target_zone == "l_arm" || target_zone == "r_hand" || target_zone == "l_hand")
		if(prob(80 - armor_reduction))
			if(target_zone == "r_arm" || target_zone == "r_hand")
				target.drop_r_hand()
			else
				target.drop_l_hand()
			return TRUE

	if(target_zone == "r_feet" || target_zone == "l_feet" || target_zone == "r_leg" || target_zone == "l_leg")
		if(prob(60 - armor_reduction))
			target.Weaken(5)
			return TRUE

	return FALSE

/obj/item/weapon/material/sword/katana
	name = "katana"
	desc = "Woefully underpowered in D20. This one looks pretty sharp."
	icon_state = "katana"
	item_state = "katana"
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/weapon/material/sword/rapier
	name = "rapier"
	desc = "A slender, fancy and sharply pointed sword."
	icon = 'icons/obj/sword.dmi'
	icon_state = "rapier"
	item_state = "rapier"
	contained_sprite = 1
	slot_flags = SLOT_BELT
	attack_verb = list("attacked", "stabbed", "prodded", "poked", "lunged")
	sharp = 0

/obj/item/weapon/material/sword/longsword
	name = "longsword"
	desc = "A double-edged large blade."
	icon_state = "longsword"
	item_state = "claymore"
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/weapon/material/sword/longsword/pre_attack(var/mob/living/target, var/mob/living/user)
	if(istype(target))
		cleave(user, target)
	..()

/obj/item/weapon/material/sword/sabre
	name = "sabre"
	desc = "A sharp curved backsword."
	icon = 'icons/obj/sword.dmi'
	icon_state = "sabre"
	item_state = "sabre"
	contained_sprite = 1
	slot_flags = SLOT_BELT

/obj/item/weapon/material/sword/axe
	name = "battle axe"
	desc = "A one handed battle axe, still a deadly weapon."
	icon = 'icons/obj/sword.dmi'
	icon_state = "axe"
	item_state = "axe"
	contained_sprite = 1
	slot_flags = SLOT_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	applies_material_colour = 0
	parry_chance = 10
	drop_sound = 'sound/items/drop/axe.ogg'

/obj/item/weapon/material/sword/axe/pre_attack(var/mob/living/target, var/mob/living/user)
	if(istype(target))
		cleave(user, target)
	..()

/obj/item/weapon/material/sword/khopesh
	name = "khopesh"
	desc = "An ancient sword shapped like a sickle."
	icon = 'icons/obj/sword.dmi'
	icon_state = "khopesh"
	item_state = "khopesh"
	contained_sprite = 1
	slot_flags = SLOT_BELT

/obj/item/weapon/material/sword/dao
	name = "dao"
	desc = "A single-edged broadsword."
	icon = 'icons/obj/sword.dmi'
	icon_state = "dao"
	item_state = "dao"
	contained_sprite = 1
	slot_flags = SLOT_BELT

/obj/item/weapon/material/sword/gladius
	name = "gladius"
	desc = "An ancient short sword, designed to stab and cut."
	icon = 'icons/obj/sword.dmi'
	icon_state = "gladius"
	item_state = "gladius"
	contained_sprite = 1
	slot_flags = SLOT_BELT

/obj/item/weapon/material/sword/amohdan_sword
	name = "amohdan blade"
	desc = "A tajaran sword, commonly used by the swordsmen of the island of Amohda."
	icon = 'icons/obj/sword.dmi'
	icon_state = "amohdan_sword"
	item_state = "amohdan_sword"
	contained_sprite = 1
	slot_flags = SLOT_BELT

// improvised sword
/obj/item/weapon/material/sword/improvised_sword
	name = "selfmade sword"
	desc = "A crudely made, rough looking sword. Still appears to be quite deadly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "improvsword"
	item_state = "improvsword"
	var/obj/item/weapon/material/hilt //what is the handle made of?
	force_divisor = 0.3
	slot_flags = SLOT_BELT

/obj/item/weapon/material/sword/improvised_sword/apply_hit_effect()
	. = ..()
	if(!unbreakable)
		if(hilt.material.is_brittle())
			health = 0
		else if(!prob(hilt.material.hardness))
			health--
		check_health()

/obj/item/weapon/material/sword/improvised_sword/proc/assignDescription()
	if(hilt)
		desc = "A crudely made, rough looking sword. Still appears to be quite deadly. It has a blade of [src.material], and a hilt of [hilt.material]."
	else
		desc = "A crudely made, rough looking sword. Still appears to be quite deadly. It has a blade of [src.material]."

// the things needed to create the above
/obj/item/weapon/material/sword_hilt
	name = "hilt"
	desc = "A hilt without a blade, quite useless."
	icon = 'icons/obj/weapons_build.dmi'
	icon_state = "swordhilt"
	unbreakable = TRUE
	force_divisor = 0.05
	thrown_force_divisor = 0.2

/obj/item/weapon/material/sword_hilt/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/weapon/material/sword_blade))
		var/obj/item/weapon/material/sword_blade/blade = O
		var/obj/item/weapon/material/sword/improvised_sword/new_sword = new(src.loc, blade.material.name)
		new_sword.hilt = src
		user.drop_from_inventory(src,new_sword)
		user.drop_from_inventory(blade,new_sword)
		user.put_in_hands(new_sword)
		qdel(blade)
		qdel(src)
		new_sword.assignDescription()
	else
		..()

/obj/item/weapon/material/sword_blade
	name = "blade"
	desc = "A blade without a hilt, don't cut yourself!"
	icon = 'icons/obj/weapons_build.dmi'
	icon_state = "swordblade"
	unbreakable = TRUE
	force_divisor = 0.20
	thrown_force_divisor = 0.3

/obj/item/weapon/material/sword_blade/attackby(var/obj/O, mob/user)
	if(istype(O, /obj/item/weapon/material/sword_hilt))
		var/obj/item/weapon/material/sword_hilt/hilt = O
		var/obj/item/weapon/material/sword/improvised_sword/new_sword = new(src.loc, src.material.name)
		new_sword.hilt = hilt.material
		new_sword.assignDescription()
		user.drop_from_inventory(src,new_sword)
		user.drop_from_inventory(hilt,new_sword)
		user.put_in_hands(new_sword)
		qdel(hilt)
		qdel(src)
		new_sword.assignDescription()
	else
		..()