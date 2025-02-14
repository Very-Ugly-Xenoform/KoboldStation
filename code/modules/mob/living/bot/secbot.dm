#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_ARREST		2		// arresting target
#define SECBOT_START_PATROL	3		// start patrol
#define SECBOT_WAIT_PATROL	4		// waiting for signals
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

/mob/living/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon_state = "secbot0"
	maxHealth = 50
	health = 50
	req_one_access = list(access_security, access_forensics_lockers, access_weapons)
	botcard_access = list(access_security, access_sec_doors, access_forensics_lockers, access_morgue, access_maint_tunnels)

	var/mob/target

	var/idcheck = 0 // If true, arrests for having weapons without authorization.
	var/check_records = 0 // If true, arrests people without a record.
	var/check_arrest = 1 // If true, arrests people who are set to arrest.
	var/arrest_type = 0 // If true, doesn't handcuff. You monster.
	var/declare_arrests = 0 // If true, announces arrests over sechuds.
	var/auto_patrol = 0 // If true, patrols on its own

	var/mode = 0

	var/is_attacking = 0
	var/is_ranged = 0
	var/awaiting_surrender = 0

	var/obj/secbot_listener/listener = null
	var/beacon_freq = 1445			// Navigation beacon frequency
	var/control_freq = BOT_FREQ		// Bot control frequency
	var/list/path = list()
	var/frustration = 0
	var/turf/patrol_target = null	// This is where we are headed
	var/closest_dist				// Used to find the closest beakon
	var/destination = "__nearest__"	// This is the current beacon's ID
	var/next_destination = "__nearest__"	// This is the next beacon's ID
	var/nearest_beacon				// Tag of the beakon that we assume to be the closest one

	var/bot_version = 1.4
	var/list/threat_found_sounds = list(
		'sound/voice/bcriminal.ogg',
		'sound/voice/bjustice.ogg',
		'sound/voice/bfreeze.ogg'
	)
	var/list/preparing_arrest_sounds = list(
		'sound/voice/bgod.ogg',
		'sound/voice/biamthelaw.ogg',
		'sound/voice/bsecureday.ogg',
		'sound/voice/bradio.ogg',
		'sound/voice/binsult.ogg',
		'sound/voice/bcreep.ogg'
	)

	var/datum/callback/patrol_callback	// this is here so we don't constantly recreate this datum, it being identical each time.
	var/move_to_delay = 4 //delay for the automated movement.

/mob/living/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	auto_patrol = 1

/mob/living/bot/secbot/Initialize()
	. = ..()
	listener = new /obj/secbot_listener(src)
	listener.secbot = src

	if(SSradio)
		SSradio.add_object(listener, control_freq, filter = RADIO_SECBOT)
		SSradio.add_object(listener, beacon_freq, filter = RADIO_NAVBEACONS)

/mob/living/bot/secbot/Destroy()
	QDEL_NULL(listener)
	target = null
	return ..()

/mob/living/bot/secbot/turn_off()
	..()
	walk_to(src, src, 0, move_to_delay)
	target = null
	frustration = 0
	mode = SECBOT_IDLE

/mob/living/bot/secbot/update_icons()
	if(on && is_attacking)
		icon_state = "secbot-c"
	else
		icon_state = "secbot[on]"

	if(on)
		set_light(1.4, 1, "#FF6A00")
	else
		set_light(0)

/mob/living/bot/secbot/attack_hand(var/mob/user)
	if (!has_ui_access(user))
		to_chat(user, "<span class='warning'>The unit's interface refuses to unlock!</span>")
		return
	user.set_machine(src)
	var/dat
	dat += "<TT><B>Automatic Security Unit v[bot_version]</B></TT><BR><BR>"
	dat += "Status: <A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<BR>"
	dat += "Maintenance panel is [open ? "opened" : "closed"]"
	if(!locked || issilicon(user))
		dat += "<BR>Check for Weapon Authorization: <A href='?src=\ref[src];operation=idcheck'>[idcheck ? "Yes" : "No"]</A><BR>"
		dat += "Check Security Records: <A href='?src=\ref[src];operation=ignorerec'>[check_records ? "Yes" : "No"]</A><BR>"
		dat += "Check Arrest Status: <A href='?src=\ref[src];operation=ignorearr'>[check_arrest ? "Yes" : "No"]</A><BR>"
		dat += "Operating Mode: <A href='?src=\ref[src];operation=switchmode'>[arrest_type ? "Detain" : "Arrest"]</A><BR>"
		dat += "Report Arrests: <A href='?src=\ref[src];operation=declarearrests'>[declare_arrests ? "Yes" : "No"]</A><BR>"
		dat += "Auto Patrol: <A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>"
	user << browse("<HEAD><TITLE>Securitron v[bot_version] controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/mob/living/bot/secbot/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if (!has_ui_access(usr))
		to_chat(usr, "<span class='warning'>Insufficient permissions.</span>")
		return

	if(href_list["power"])
		if(on)
			turn_off()
		else
			turn_on()
		attack_hand(usr)

	if (locked && !issilicon(usr))
		return

	switch(href_list["operation"])
		if("idcheck")
			idcheck = !idcheck
		if("ignorerec")
			check_records = !check_records
		if("ignorearr")
			check_arrest = !check_arrest
		if("switchmode")
			arrest_type = !arrest_type
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
		if("declarearrests")
			declare_arrests = !declare_arrests
	attack_hand(usr)

/mob/living/bot/secbot/attackby(var/obj/item/O, var/mob/user)
	var/curhealth = health
	..()
	if(health < curhealth)
		target = user
		awaiting_surrender = 5
		mode = SECBOT_HUNT

/mob/living/bot/secbot/think()
	..()
	if(!on)
		return

	if(QDELETED(target))
		scan_view()

	if(!locked && (mode == SECBOT_START_PATROL || mode == SECBOT_PATROL)) // Stop running away when we set you up
		mode = SECBOT_IDLE

	switch(mode)
		if(SECBOT_IDLE)
			if(auto_patrol && locked)
				mode = SECBOT_START_PATROL
			return

		if(SECBOT_HUNT) // Target is in the view or has been recently - chase it
			if(frustration > 7)
				target = null
				frustration = 0
				awaiting_surrender = 0
				mode = SECBOT_IDLE
				return
			if(target)
				var/threat = check_threat(target)
				if(threat < 4) // Re-evaluate in case they dropped the weapon or something
					target = null
					frustration = 0
					awaiting_surrender = 0
					mode = SECBOT_IDLE
					return
				if(!(target in view(7, src)))
					++frustration
				if(Adjacent(target))
					mode = SECBOT_ARREST
					return
				else
					if(is_ranged)
						RangedAttack(target)
					else
						walk_to(src, target, 1, move_to_delay) // Melee bots chase a bit faster

		if(SECBOT_ARREST) // Target is next to us - attack it
			if(!target)
				mode = SECBOT_IDLE
			if(!Adjacent(target))
				awaiting_surrender = 5 // I'm done playing nice
				mode = SECBOT_HUNT
				return
			var/threat = check_threat(target)
			walk_to(src, src, 0, move_to_delay)
			if(threat < 4)
				target = null
				awaiting_surrender = 0
				frustration = 0
				mode = SECBOT_IDLE
				return
			if(awaiting_surrender < 5 && ishuman(target) && !target.lying)
				if(awaiting_surrender == 0)
					say("Down on the floor, [target]! You have five seconds to comply.")
				++awaiting_surrender
			else
				UnarmedAttack(target)
			if(ishuman(target) && declare_arrests)
				var/area/location = get_area(src)
				broadcast_security_hud_message("[src] is [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect <b>[target]</b> in <b>[location]</b>.", src)
			return

		if(SECBOT_START_PATROL)
			if(path.len && patrol_target)
				mode = SECBOT_PATROL
				return
			else if(patrol_target)
				spawn(0)
					calc_path()
					if(!path.len)
						patrol_target = null
						mode = SECBOT_IDLE
					else
						mode = SECBOT_PATROL
			if(!patrol_target)
				if(next_destination)
					find_next_target()
				else
					find_patrol_target()
					say("Engaging patrol mode.")
				mode = SECBOT_WAIT_PATROL
			return

		if(SECBOT_WAIT_PATROL)
			if(patrol_target)
				mode = SECBOT_START_PATROL
			else
				++frustration
				if(frustration > 120)
					frustration = 0
					mode = SECBOT_IDLE

		if(SECBOT_PATROL)
			patrol_step()
			return

		if(SECBOT_SUMMON)
			patrol_step()
			return

/mob/living/bot/secbot/UnarmedAttack(var/mob/M, var/proximity)
	if(!..())
		return

	if(!istype(M))
		return

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		var/cuff = 1
		if(istype(C, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(istype(H.back, /obj/item/weapon/rig) && istype(H.gloves,/obj/item/clothing/gloves/rig))
				cuff = 0
		if(!C.lying || C.handcuffed || arrest_type)
			cuff = 0
		if(!cuff)
			C.stun_effect_act(0, 60, null)
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			do_attack_animation(C)
			is_attacking = 1
			update_icons()
			addtimer(CALLBACK(src, .proc/stop_attacking_cb), 2)
			visible_message("<span class='warning'>[C] was prodded by [src] with a stun baton!</span>")
		else
			playsound(loc, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
			visible_message("<span class='warning'>[src] is trying to put handcuffs on [C]!</span>")
			if(do_mob(src, C, 60))
				if(!C.handcuffed)
					C.handcuffed = new /obj/item/weapon/handcuffs(C)
					C.update_inv_handcuffed()
				if(preparing_arrest_sounds.len)
					playsound(loc, pick(preparing_arrest_sounds), 50, 0)
	else if(istype(M, /mob/living/simple_animal) && !istype(M, /mob/living/bot/secbot))
		var/mob/living/simple_animal/S = M
		S.adjustBruteLoss(15)
		do_attack_animation(M)
		playsound(loc, "swing_hit", 50, 1, -1)
		is_attacking = 1
		update_icons()
		addtimer(CALLBACK(src, .proc/stop_attacking_cb), 2)
		visible_message("<span class='warning'>[M] was beaten by [src] with a stun baton!</span>")

/mob/living/bot/secbot/proc/stop_attacking_cb()
	is_attacking = FALSE
	update_icons()

/mob/living/bot/secbot/explode()
	visible_message("<span class='warning'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/weapon/melee/baton(Tsec)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	spark(src, 3, alldirs)

	new /obj/effect/decal/cleanable/blood/oil(Tsec)
	qdel(src)

/mob/living/bot/secbot/emag_act(var/remaining_charges, var/mob/user, var/feedback)
	if(!emagged)
		emagged = 1
		to_chat(user, (feedback ? feedback : "You short out the lock of \the [src]."))
		return 1

/mob/living/bot/secbot/proc/scan_view()
	target = null
	for(var/mob/living/M in view(7, src))
		if(M.invisibility >= INVISIBILITY_LEVEL_ONE)
			continue
		if(M.stat)
			continue

		var/threat = check_threat(M)

		if(threat >= 4)
			target = M
			say("Level [threat] infraction alert!")
			custom_emote(1, "points at [M.name]!")
			mode = SECBOT_HUNT
			break
	return

/mob/living/bot/secbot/proc/calc_path(var/turf/avoid = null)
	path = AStar(loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	if(isnull(path) || !path.len)
		path = list()
		return
	var/list/path_new = list()
	var/turf/last = path[path.len]
	path_new.Add(path[1])
	for(var/i = 2, i < path.len, i++)
		if((path[i + 1].x == path[i].x) || (path[i + 1].y == path[i].y)) // we have a straight line, scan for more to cut down
			path_new.Add(path[i])
			for(var/j = i + 1, j < path.len, j++)
				if((path[j + 1].x != path[j - 1].x) && (path[j + 1].y != path[j - 1].y)) // This is a corner and end point of our line
					path_new.Add(path[j])
					i = j + 1
					break
				else if(j == path.len - 1)
					path = list()
					path = path_new.Copy()
					path.Add(last)
					return
		else
			path_new.Add(path[i])
	path = list()
	path = path_new.Copy()
	path.Add(last)

/mob/living/bot/secbot/proc/check_threat(var/mob/living/M)
	if(!M || !istype(M) || M.stat || src == M)
		return 0

	if(emagged)
		return 10

	return M.assess_perp(access_scanner, 0, idcheck, check_records, check_arrest)

/mob/living/bot/secbot/proc/patrol_step()
	if(loc == patrol_target)
		patrol_target = null
		path = list()
		mode = SECBOT_IDLE
		walk_to(src, src, 0, move_to_delay + 2)
		return

	if(path.len && patrol_target)
		var/turf/next = path[1]
		if(loc == next)
			path -= next
			walk_to(src, src, 0, move_to_delay + 2)
			return
		walk_to(src, next, 0, move_to_delay + 2)
		return
	else
		mode = SECBOT_START_PATROL


/mob/living/bot/secbot/proc/find_patrol_target()
	send_status()
	nearest_beacon = null
	next_destination = "__nearest__"
	listener.post_signal(beacon_freq, "findbeacon", "patrol")

/mob/living/bot/secbot/proc/find_next_target()
	send_status()
	nearest_beacon = null
	listener.post_signal(beacon_freq, "findbeacon", "patrol")

/mob/living/bot/secbot/proc/send_status()
	var/list/kv = list(
	"type" = "secbot",
	"name" = name,
	"loca" = get_area(loc),
	"mode" = mode
	)
	listener.post_signal_multiple(control_freq, kv)

/obj/secbot_listener
	var/mob/living/bot/secbot/secbot = null

/obj/secbot_listener/Destroy()
	secbot = null
	return ..()

/obj/secbot_listener/proc/post_signal(var/freq, var/key, var/value) // send a radio signal with a single data key/value pair
	post_signal_multiple(freq, list("[key]" = value))

/obj/secbot_listener/proc/post_signal_multiple(var/freq, var/list/keyval) // send a radio signal with multiple data key/values
	var/tmp/datum/radio_frequency/frequency = SSradio.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = secbot
	signal.transmission_method = 1
	signal.data = keyval.Copy()

	if(signal.data["findbeacon"])
		frequency.post_signal(secbot, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == "secbot")
		frequency.post_signal(secbot, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(secbot, signal)

/obj/secbot_listener/receive_signal(datum/signal/signal)
	if(!secbot || !secbot.on)
		return

	var/recv = signal.data["command"]
	if(recv == "bot_status")
		secbot.send_status()
		return

	if(signal.data["active"] == secbot)
		switch(recv)
			if("stop")
				secbot.mode = SECBOT_IDLE
				secbot.auto_patrol = 0
				return

			if("go")
				secbot.mode = SECBOT_IDLE
				secbot.auto_patrol = 1
				return

			if("summon")
				secbot.patrol_target = signal.data["target"]
				secbot.next_destination = secbot.destination
				secbot.destination = null
				//secbot.awaiting_beacon = 0
				secbot.mode = SECBOT_SUMMON
				secbot.calc_path()
				secbot.say("Responding.")
				return

	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == secbot.next_destination) // This beacon is our target
		secbot.destination = secbot.next_destination
		secbot.patrol_target = signal.source.loc
		secbot.next_destination = signal.data["next_patrol"]
	else if(secbot.next_destination == "__nearest__")
		var/dist = get_dist(secbot, signal.source.loc)
		if(dist <= 1)
			return

		if(secbot.nearest_beacon)
			if(dist < secbot.closest_dist)
				secbot.nearest_beacon = recv
				secbot.patrol_target = secbot.nearest_beacon
				secbot.next_destination = signal.data["next_patrol"]
				secbot.closest_dist = dist
				return
		else
			secbot.nearest_beacon = recv
			secbot.patrol_target = secbot.nearest_beacon
			secbot.next_destination = signal.data["next_patrol"]
			secbot.closest_dist = dist

/mob/living/bot/secbot/attack_hand(mob/living/carbon/human/M as mob)
	..()

	if(M.a_intent == I_HURT ) //assume he wants to hurt us.
		idcheck = TRUE
		target = M
		mode = SECBOT_HUNT
		var/mob/living/carbon/human/H = M
		var/perpname = H.name
		var/obj/item/weapon/card/id/id = H.GetIdCard()
		if(id)
			perpname = id.registered_name

		var/datum/record/general/R = SSrecords.find_record("name", perpname)
		if(R && R.security)
			R.security.criminal = "*Arrest*"
		else
			check_records = TRUE
		broadcast_security_hud_message("[src] is under attack by <b>[target]</b>, [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect in <b>[get_area(src)]</b>. Requesting backup", src)

/mob/living/bot/secbot/attack_generic(var/mob/user, var/damage, var/attack_message)
	..()

	target = user
	mode = SECBOT_HUNT
	if(ishuman(user))
		idcheck = TRUE
		var/mob/living/carbon/human/H = user
		var/perpname = H.name
		var/obj/item/weapon/card/id/id = H.GetIdCard()
		if(id)
			perpname = id.registered_name

		var/datum/record/general/R = SSrecords.find_record("name", perpname)
		if(R && R.security)
			R.security.criminal = "*Arrest*"
		else
			check_records = TRUE
		broadcast_security_hud_message("[src] is under attack by <b>[target]</b>, [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect in <b>[get_area(src)]</b>. Requesting backup", src)

/mob/living/bot/secbot/bullet_act(var/obj/item/projectile/P, var/def_zone)
	..()

	if (ismob(P.firer))
		var/found = 0
		// Check if we can see them.
		for(var/mob/living/M in view(7, src))
			if(M.invisibility >= INVISIBILITY_LEVEL_ONE)
				continue
			if(M.stat)
				continue
			if(M == P.firer)
				found = 1
				break

		if(!found)
			broadcast_security_hud_message("[src] was shot with <b>[P]</b>, Unable to locate source! Requesting backup", src)
			return

		target = P.firer
		mode = SECBOT_HUNT
		if(ishuman(P.firer))
			idcheck = TRUE
			var/mob/living/carbon/human/H = P.firer
			var/perpname = H.name
			var/obj/item/weapon/card/id/id = H.GetIdCard()
			if(id)
				perpname = id.registered_name

			var/datum/record/general/R = SSrecords.find_record("name", perpname)
			if(R && R.security)
				R.security.criminal = "*Arrest*"
			else
				check_records = TRUE
			broadcast_security_hud_message("[src] was shot with <b>[P]</b>, projectile came from <b>[target]</b>, [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect in <b>[get_area(src)]</b>. Requesting backup", src)

/mob/living/bot/secbot/attackby(var/obj/item/O, var/mob/user)
	..()
	if(istype(O, /obj/item/weapon/card/id) || O.ispen() || istype(O, /obj/item/device/pda))
		return

	target = user
	mode = SECBOT_HUNT
	if(ishuman(user))
		idcheck = TRUE
		var/mob/living/carbon/human/H = user
		var/perpname = H.name
		var/obj/item/weapon/card/id/id = H.GetIdCard()
		if(id)
			perpname = id.registered_name

		var/datum/record/general/R = SSrecords.find_record("name", perpname)
		if(R && R.security)
			R.security.criminal = "*Arrest*"
		else
			check_records = TRUE
		broadcast_security_hud_message("[src] is under attack by <b>[target]</b> with <b>[O]</b>, [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect in <b>[get_area(src)]</b>. Requesting backup", src)

/mob/living/bot/secbot/hitby(atom/movable/AM as mob|obj,var/speed = THROWFORCE_SPEED_DIVISOR)
	..()

	if(istype(AM,/obj/))
		var/obj/O = AM
		if(ismob(O.thrower))
			target = O.thrower
			mode = SECBOT_HUNT
			if(ishuman(O.thrower))
				idcheck = TRUE
				var/mob/living/carbon/human/H = O.thrower
				var/perpname = H.name
				var/obj/item/weapon/card/id/id = H.GetIdCard()
				if(id)
					perpname = id.registered_name

				var/datum/record/general/R = SSrecords.find_record("name", perpname)
				if(R && R.security)
					R.security.criminal = "*Arrest*"
				else
					check_records = TRUE
				broadcast_security_hud_message("[src] is under attack by <b>[target]</b> with <b>[O]</b>, [arrest_type ? "detaining" : "arresting"] a level [check_threat(target)] suspect in <b>[get_area(src)]</b>. Requesting backup", src)

//Secbot Construction

/obj/item/clothing/head/helmet/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob)
	..()
	if(!issignaler(S))
		..()
		return

	if(type != /obj/item/clothing/head/helmet) //Eh, but we don't want people making secbots out of space helmets.
		return

	if(S.secured)
		qdel(S)
		var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
		user.put_in_hands(A)
		to_chat(user, "You add the signaler to the helmet.")
		user.drop_from_inventory(src)
		qdel(src)
		return 1
	else
		return

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron"

/obj/item/weapon/secbot_assembly/attackby(var/obj/item/O, var/mob/user)
	..()
	if(O.iswelder() && !build_step)
		var/obj/item/weapon/weldingtool/WT = O
		if(WT.remove_fuel(0, user))
			build_step = 1
			add_overlay("hs_hole")
			to_chat(user, "You weld a hole in \the [src].")
			return 1

	else if(isprox(O) && (build_step == 1))
		build_step = 2
		to_chat(user, "You add \the [O] to [src].")
		add_overlay("hs_eye")
		name = "helmet/signaler/prox sensor assembly"
		user.drop_from_inventory(O,get_turf(src))
		qdel(O)
		return 1

	else if((istype(O, /obj/item/robot_parts/l_arm) || istype(O, /obj/item/robot_parts/r_arm)) && build_step == 2)
		build_step = 3
		to_chat(user, "You add \the [O] to [src].")
		name = "helmet/signaler/prox sensor/robot arm assembly"
		add_overlay("hs_arm")
		user.drop_from_inventory(O,get_turf(src))
		qdel(O)
		return 1

	else if(istype(O, /obj/item/weapon/melee/baton) && build_step == 3)
		to_chat(user, "You complete the Securitron! Beep boop.")
		var/mob/living/bot/secbot/S = new /mob/living/bot/secbot(get_turf(src))
		S.name = created_name
		user.drop_from_inventory(O,get_turf(src))
		qdel(O)
		qdel(src)
		return 1

	else if(O.ispen())
		var/t = sanitizeSafe(input(user, "Enter new robot name", name, created_name), MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

#undef SECBOT_IDLE
#undef SECBOT_HUNT
#undef SECBOT_ARREST
#undef SECBOT_START_PATROL
#undef SECBOT_WAIT_PATROL
#undef SECBOT_PATROL
#undef SECBOT_SUMMON
