/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 30
	damage_type = BURN
	check_armour = "laser"
	eyeblur = 4
	var/frequency = 1
	hitscan = 1
	invisibility = 101	//beam projectiles are invisible as they are rendered by the effect engine

	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/practice
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	no_attack_log = 1
	check_armour = "laser"
	eyeblur = 2

/obj/item/projectile/beam/pistol
	damage = 30

/obj/item/projectile/beam/midlaser
	damage = 35
	armor_penetration = 10

/obj/item/projectile/beam/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 60
	armor_penetration = 30

	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/item/projectile/beam/xray
	name = "xray beam"
	icon_state = "xray"
	damage = 25
	armor_penetration = 50

	muzzle_type = /obj/effect/projectile/muzzle/xray
	tracer_type = /obj/effect/projectile/tracer/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	armor_penetration = 50

	muzzle_type = /obj/effect/projectile/muzzle/pulse
	tracer_type = /obj/effect/projectile/tracer/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/item/projectile/beam/pulse/on_hit(var/atom/target, var/blocked = 0)
	if(isturf(target))
		target.ex_act(2)
	..()

/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/item/projectile/beam/pulse/heavy/Collide(atom/A)
	A.bullet_act(src, def_zone)
	src.life -= 10
	if(life <= 0)
		qdel(src)

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 0 // The actual damage is computed in /code/modules/power/singularity/emitter.dm

	muzzle_type = /obj/effect/projectile/muzzle/emitter
	tracer_type = /obj/effect/projectile/tracer/emitter
	impact_type = /obj/effect/projectile/impact/emitter

/obj/item/projectile/beam/lastertag/blue
	name = "lasertag beam"
	icon_state = "bluelaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	no_attack_log = 1
	damage_type = BURN
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/item/projectile/beam/lastertag/blue/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/redtag))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/lastertag/red
	name = "lasertag beam"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	no_attack_log = 1
	damage_type = BURN
	check_armour = "laser"

/obj/item/projectile/beam/lastertag/red/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit, /obj/item/clothing/suit/bluetag))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/lastertag/omni//A laser tag bolt that stuns EVERYONE
	name = "lasertag beam"
	icon_state = "omnilaser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 0
	damage_type = BURN
	check_armour = "laser"

	muzzle_type = /obj/effect/projectile/muzzle/disabler
	tracer_type = /obj/effect/projectile/tracer/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/projectile/beam/lastertag/omni/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = target
		if((istype(M.wear_suit, /obj/item/clothing/suit/bluetag))||(istype(M.wear_suit, /obj/item/clothing/suit/redtag)))
			M.Weaken(5)
	return 1

/obj/item/projectile/beam/sniper
	name = "sniper beam"
	icon_state = "xray"
	damage = 50
	armor_penetration = 20
	stun = 3
	weaken = 3
	stutter = 3

	muzzle_type = /obj/effect/projectile/muzzle/xray
	tracer_type = /obj/effect/projectile/tracer/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/stun
	name = "stun beam"
	icon_state = "stun"
	nodamage = 1
	taser_effect = 1
	agony = 40
	damage_type = HALLOSS

	muzzle_type = /obj/effect/projectile/muzzle/stun
	tracer_type = /obj/effect/projectile/tracer/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/item/projectile/beam/gatlinglaser
	name = "diffused laser"
	icon_state = "heavylaser"
	damage = 10
	no_attack_log = 1

	muzzle_type = /obj/effect/projectile/muzzle/disabler
	tracer_type = /obj/effect/projectile/tracer/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/projectile/beam/mousegun
	name = "electrical arc"
	icon_state = "stun"
	nodamage = 1
	damage_type = HALLOSS

	muzzle_type = /obj/effect/projectile/muzzle/stun
	tracer_type = /obj/effect/projectile/tracer/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/item/projectile/beam/mousegun/on_impact(var/atom/A)
	mousepulse(A, 1)
	..()

/obj/item/projectile/beam/mousegun/proc/mousepulse(turf/epicenter, range, log=0)
	if(!epicenter)
		return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	for(var/mob/living/M in range(range, epicenter))
		var/distance = get_dist(epicenter, M)
		if(distance < 0)
			distance = 0
		if(distance <= range)
			if (M.mob_size <= 3 && (M.find_type() & TYPE_ORGANIC))
				M.visible_message("<span class='danger'>\The [M] gets fried!</span>")
				M.color = "#4d4d4d" //get fried
				M.death()
				spark(M, 3, alldirs)
			else if(iscarbon(M) && M.contents.len)
				for(var/obj/item/weapon/holder/H in M.contents)
					if(!H.contained)
						continue

					var/mob/living/A = H.contained
					if(!istype(A))
						continue

					if(A.mob_size <= 3 && (A.find_type() & TYPE_ORGANIC))
						H.release_mob()
						A.visible_message("<span class='danger'>\The [A] gets fried!</span>")
						A.color = "#4d4d4d" //get fried
						A.death()

			to_chat(M, 'sound/effects/basscannon.ogg')
	return TRUE

/obj/item/projectile/beam/mousegun/emag
	name = "diffuse electrical arc"

	taser_effect = 1
	agony = 60

/obj/item/projectile/beam/mousegun/emag/mousepulse(turf/epicenter, range, log=0)
	if(!epicenter)
		return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	for(var/mob/living/M in range(range, epicenter))
		var/distance = get_dist(epicenter, M)
		if(distance < 0)
			distance = 0
		if(distance <= range)
			if(M.mob_size <= 4 && (M.find_type() & TYPE_ORGANIC))
				M.visible_message("<span class='danger'>[M] bursts like a balloon!</span>")
				M.gib()
				spark(M, 3, alldirs)
			else if(iscarbon(M) && M.contents.len)
				for(var/obj/item/weapon/holder/H in M.contents)
					if(!H.contained)
						continue

					var/mob/living/A = H.contained
					if(!istype(A))
						continue

					if(A.mob_size <= 4 && (A.find_type() & TYPE_ORGANIC))
						H.release_mob()
						A.visible_message("<span class='danger'>[A] bursts like a balloon!</span>")
						A.gib()

			to_chat(M, 'sound/effects/basscannon.ogg')
	return TRUE

/obj/item/projectile/beam/shotgun
	name = "diffuse laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 15
	eyeblur = 4

	muzzle_type = /obj/effect/projectile/muzzle/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/megaglaive
	name = "thermal lance"
	icon_state = "megaglaive"
	damage = 10
	incinerate = 5
	armor_penetration = 10
	no_attack_log = 1

	muzzle_type = /obj/effect/projectile/muzzle/solar
	tracer_type = /obj/effect/projectile/tracer/solar
	impact_type = /obj/effect/projectile/impact/solar

/obj/item/projectile/beam/megaglaive/on_impact(var/atom/A)
	if(isturf(A))
		if(istype(A, /turf/simulated/mineral))
			if(prob(75)) //likely because its a mining tool
				var/turf/simulated/mineral/M = A
				if(prob(10))
					M.GetDrilled(1)
				else if(!M.emitter_blasts_taken)
					M.emitter_blasts_taken += 1
				else if(prob(33))
					M.emitter_blasts_taken += 1
	if(ismob(A))
		var/mob/living/M = A
		M.apply_effect(1, INCINERATE, 0)
	explosion(A, -1, 0, 2)
	..()

/obj/item/projectile/beam/thermaldrill
	name = "thermal drill"
	icon_state = "megaglaive"
	damage = 1
	no_attack_log = 1

	muzzle_type = /obj/effect/projectile/muzzle/solar
	tracer_type = /obj/effect/projectile/tracer/solar
	impact_type = /obj/effect/projectile/impact/solar

/obj/item/projectile/beam/thermaldrill/on_impact(var/atom/A)
	if(isturf(A))
		if(istype(A, /turf/simulated/mineral))
			if(prob(75)) //likely because its a mining tool
				var/turf/simulated/mineral/M = A
				if(prob(33))
					M.GetDrilled(1)
				else if(!M.emitter_blasts_taken)
					M.emitter_blasts_taken += 2
				else if(prob(66))
					M.emitter_blasts_taken += 2
	..()


/obj/item/projectile/beam/energy_net
	name = "energy net projection"
	icon_state = "xray"
	nodamage = 1
	damage_type = HALLOSS

	muzzle_type = /obj/effect/projectile/muzzle/xray
	tracer_type = /obj/effect/projectile/tracer/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/energy_net/on_hit(var/atom/netted)
	do_net(netted)
	..()

/obj/item/projectile/beam/energy_net/proc/do_net(var/mob/M)
	var/obj/item/weapon/energy_net/net = new (get_turf(M))
	net.throw_impact(M)

/obj/item/projectile/beam/tachyon
	name = "particle beam"
	icon_state = "xray"
	damage = 25
	armor_penetration = 65
	penetrating = 1
	maiming = 1
	maim_rate = 5
	clean_cut = 1
	maim_type = DROPLIMB_BURN

	muzzle_type = /obj/effect/projectile/muzzle/tachyon
	tracer_type = /obj/effect/projectile/tracer/tachyon
	impact_type = /obj/effect/projectile/impact/tachyon