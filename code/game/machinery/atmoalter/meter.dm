/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	power_channel = ENVIRON
	var/frequency = 0
	var/id
	use_power = 1
	idle_power_usage = 15


/obj/machinery/meter/Initialize()
	. = ..()
	if (!target)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/machinery_process()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/tmp/datum/radio_frequency/radio_connection = SSradio.return_frequency(frequency)

		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/examine(mob/user)
	var/t = "A gas flow meter. "

	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || istype(user, /mob/abstract)))
		t += "<span class='warning'>You are too far away to read it.</span>"

	else if(stat & (NOPOWER|BROKEN))
		t += "<span class='warning'>The display is off.</span>"

	else if(src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."

	to_chat(user, t)

/obj/machinery/meter/Click()

	if(istype(usr, /mob/living/silicon/ai)) // ghosts can call ..() for examine
		usr.examinate(src)
		return 1

	return ..()

/obj/machinery/meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (!W.iswrench())
		return ..()
	playsound(src.loc, W.usesound, 50, 1)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (do_after(user, 40/W.toolspeed))
		user.visible_message( \
			"<span class='notice'>\The [user] unfastens \the [src].</span>", \
			"<span class='notice'>You have unfastened \the [src].</span>", \
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		qdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/Initialize()
	. = ..()
	src.target = loc
	if (!target)
		src.target = loc

/obj/machinery/meter/turf/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	return
