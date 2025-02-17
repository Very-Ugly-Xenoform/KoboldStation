/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber_off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"
	use_power = 0
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 7500			//7500 W ~ 10 HP

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SCRUBBER //connects to regular and scrubber pipes

	level = 1

	var/area/initial_loc
	var/id_tag = null
	var/frequency = 1439
	var/tmp/datum/radio_frequency/radio_connection

	var/hibernate = 0 //Do we even process?
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/list/scrubbing_gas = list("carbon_dioxide")

	var/panic = 0 //is this scrubber panicked?

	var/area_uid
	var/radio_filter_out
	var/radio_filter_in

	var/welded = 0

/obj/machinery/atmospherics/unary/vent_scrubber/on
	use_power = 1
	icon_state = "map_scrubber_on"

/obj/machinery/atmospherics/unary/vent_scrubber/Initialize()
	. = ..()
	air_contents.volume = ATMOS_DEFAULT_VOLUME_FILTER

	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)

	radio_filter_in = frequency==initial(frequency)?(RADIO_FROM_AIRALARM):null
	radio_filter_out = frequency==initial(frequency)?(RADIO_TO_AIRALARM):null
	if (frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/unary/vent_scrubber/atmos_init()
	..()
	broadcast_status()

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	unregister_radio(src, frequency)
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/update_icon(var/safety = 0)
	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if (welded)
		icon_state = "weld"
		return

	if (!powered() || !use_power)
		icon_state = "off"
	else if (scrubbing)
		icon_state = "on"
	else
		icon_state = "in"

/obj/machinery/atmospherics/unary/vent_scrubber/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(!T.is_plating() && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data = list(
		"area" = area_uid,
		"tag" = id_tag,
		"device" = "AScr",
		"timestamp" = world.time,
		"power" = use_power,
		"scrubbing" = scrubbing,
		"panic" = panic,
		"filter_o2" = ("oxygen" in scrubbing_gas),
		"filter_n2" = ("nitrogen" in scrubbing_gas),
		"filter_co2" = ("carbon_dioxide" in scrubbing_gas),
		"filter_phoron" = ("phoron" in scrubbing_gas),
		"filter_n2o" = ("sleeping_agent" in scrubbing_gas),
		"sigtype" = "status"
	)

	var/area/A = get_area(src)
	if(!A.air_scrub_names[id_tag])
		var/new_name = "[A.name] Air Scrubber #[A.air_scrub_names.len+1]"
		A.air_scrub_names[id_tag] = new_name
		src.name = new_name
	A.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/machinery_process()
	..()

	if (hibernate > world.time)
		return 1

	if (!node)
		use_power = 0
	//broadcast_status()
	if(!use_power || (stat & (NOPOWER|BROKEN)))
		return 0
	if(welded)
		return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/power_draw = -1
	if(scrubbing)
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles*MAX_SCRUBBER_FLOWRATE/environment.volume)	//group_multiplier gets divided out here

		power_draw = scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, power_rating)
	else //Just siphon all air
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles*MAX_SIPHON_FLOWRATE/environment.volume)	//group_multiplier gets divided out here

		power_draw = pump_gas(src, environment, air_contents, transfer_moles, power_rating)

	if(scrubbing && power_draw <= 0)	//99% of all scrubbers
		//Fucking hibernate because you ain't doing shit.
		hibernate = world.time + (rand(100,200))

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

	if(network)
		network.update = 1

	return 1

/obj/machinery/atmospherics/unary/vent_scrubber/hide(var/i) //to make the little pipe section invisible, the icon changes.
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0

	if(signal.data["power"] != null)
		use_power = text2num(signal.data["power"])
	if(signal.data["power_toggle"] != null)
		use_power = !use_power

	if(signal.data["panic_siphon"]) //must be before if("scrubbing" thing
		panic = text2num(signal.data["panic_siphon"])
		if(panic)
			use_power = 1
			scrubbing = 0
		else
			scrubbing = 1
	if(signal.data["toggle_panic_siphon"] != null)
		panic = !panic
		if(panic)
			use_power = 1
			scrubbing = 0
		else
			scrubbing = 1

	if(signal.data["scrubbing"] != null)
		scrubbing = text2num(signal.data["scrubbing"])
		if(scrubbing)
			panic = 0
	if(signal.data["toggle_scrubbing"])
		scrubbing = !scrubbing
		if(scrubbing)
			panic = 0

	var/list/toggle = list()

	if(!isnull(signal.data["o2_scrub"]) && text2num(signal.data["o2_scrub"]) != ("oxygen" in scrubbing_gas))
		toggle += "oxygen"
	else if(signal.data["toggle_o2_scrub"])
		toggle += "oxygen"

	if(!isnull(signal.data["n2_scrub"]) && text2num(signal.data["n2_scrub"]) != ("nitrogen" in scrubbing_gas))
		toggle += "nitrogen"
	else if(signal.data["toggle_n2_scrub"])
		toggle += "nitrogen"

	if(!isnull(signal.data["co2_scrub"]) && text2num(signal.data["co2_scrub"]) != ("carbon_dioxide" in scrubbing_gas))
		toggle += "carbon_dioxide"
	else if(signal.data["toggle_co2_scrub"])
		toggle += "carbon_dioxide"

	if(!isnull(signal.data["tox_scrub"]) && text2num(signal.data["tox_scrub"]) != ("phoron" in scrubbing_gas))
		toggle += "phoron"
	else if(signal.data["toggle_tox_scrub"])
		toggle += "phoron"

	if(!isnull(signal.data["n2o_scrub"]) && text2num(signal.data["n2o_scrub"]) != ("sleeping_agent" in scrubbing_gas))
		toggle += "sleeping_agent"
	else if(signal.data["toggle_n2o_scrub"])
		toggle += "sleeping_agent"

	scrubbing_gas ^= toggle

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		addtimer(CALLBACK(src, .proc/broadcast_status), 2, TIMER_UNIQUE)
		return //do not update_icon

//			log_debug("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	addtimer(CALLBACK(src, .proc/broadcast_status), 2, TIMER_UNIQUE)
	update_icon()
	return

/obj/machinery/atmospherics/unary/vent_scrubber/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/atmospherics/unary/vent_scrubber/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (W.iswrench())
		if (!(stat & NOPOWER) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench \the [src], turn it off first.</span>")
			return 1
		var/turf/T = src.loc
		if (node && node.level==1 && isturf(T) && !T.is_plating())
			to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
			return 1
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
			to_chat(user, "<span class='warning'>You cannot unwrench \the [src], it is too exerted due to internal pressure.</span>")
			add_fingerprint(user)
			return 1
		playsound(src.loc, W.usesound, 50, 1)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
		if (do_after(user, 40/W.toolspeed, act_target = src))
			user.visible_message( \
				"<span class='notice'>\The [user] unfastens \the [src].</span>", \
				"<span class='notice'>You have unfastened \the [src].</span>", \
				"You hear a ratchet.")
			new /obj/item/pipe(loc, make_from=src)
			qdel(src)
		return 1

	if(W.iswelder())
		var/obj/item/weapon/weldingtool/WT = W
		if (!WT.welding)
			to_chat(user, "<span class='danger'>\The [WT] must be turned on!</span>")
		else if (WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>Now welding \the [src].</span>")
			if(do_after(user, 20/W.toolspeed, act_target = src))
				if(!src || !WT.isOn()) return
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				if(!welded)
					user.visible_message("<span class='danger'>\The [user] welds \the [src] shut.</span>", "<span class='notice'>You weld \the [src] shut.</span>", "You hear welding.")
					welded = 1
					update_icon()
				else
					user.visible_message("<span class='danger'>[user] unwelds \the [src].</span>", "<span class='notice'>You unweld \the [src].</span>", "You hear welding.")
					welded = 0
					update_icon()
			else
				to_chat(user, "<span class='notice'>You fail to complete the welding.</span>")
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
		return 1
	return ..()

/obj/machinery/atmospherics/unary/vent_scrubber/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W")
	else
		to_chat(user, "You are too far away to read the gauge.")
	if(welded)
		to_chat(user, "It seems welded shut.")

/obj/machinery/atmospherics/unary/vent_scrubber/Destroy()
	if(initial_loc)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag

	return ..()
