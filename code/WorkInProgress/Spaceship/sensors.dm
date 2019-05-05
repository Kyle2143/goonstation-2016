/obj/item/shipcomponent/sensor
	name = "Standard Sensor System"
	desc = "Advanced scanning system for ships."
	power_used = 20
	system = "Sensors"
	var/ships = 0
	var/list/shiplist = list()
	var/lifeforms = 0
	var/list/lifelist = list()
	var/seekrange = 30
	var/sight = SEE_SELF
	var/see_in_dark = SEE_DARK_HUMAN + 3
	var/see_invisible = 2
	var/scanning = 0
	var/atom/tracking_target = null
	icon_state = "sensor"

	mob_deactivate(mob/M as mob)
		M.sight &= ~SEE_TURFS
		M.sight &= ~SEE_MOBS
		M.sight &= ~SEE_OBJS
		M.see_in_dark = initial(M.see_in_dark)
		M.see_invisible = 0

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		user.machine = src

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat += "<A href='byond://?src=\ref[src];getcords=1'>Get Local Coordinates</A><BR>"
			dat += "<A href='byond://?src=\ref[src];getcords=1'>Get Local Coordinates</A><BR>"
			obtain_tracking_target_coords
			dat += {"<BR><A href='?src=\ref[src];scan=1'>Scan Area</A>"}
			if (src.tracking_target)
				dat += {"\nCurrently Tracking: [src.tracking_target.name]
				<a href=\"byond://?src=\ref[src];stop_tracking=1\">Stop Tracking</a>"}
			dat += {"<HR><B>[ships] Ships Detected:</B><BR>"}
			if(shiplist.len)
				for(var/shipname in shiplist)
					// dat += {"<HR> | <a href=\"byond://?src=\ref[src];tracking_ship=\ref[shipname]\">[shipname]</a> [shiplist[shipname]]"}
					dat += {"<HR> | <a href=\"byond://?src=\ref[src];tracking_ship=[shipname]\">[shipname]</a> [shiplist[shipname]]"}

			dat += {"<HR>[lifeforms] Lifeforms Detected:</B><BR>"}
			if(lifelist.len)
				for(var/lifename in lifelist)
					dat += {"[lifename] | "}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user << browse(dat, "window=ship_sensor")
		onclose(user, "ship_sensor")
		return

	Topic(href, href_list)
		if(usr.stat || usr.restrained())
			return

		if (usr.loc == ship)
			usr.machine = src

			if (href_list["scan"] && !scanning)
				scan(usr)

			if (href_list["tracking_ship"])
				obtain_tracking_target(href_list["tracking_ship"])
			if (href_list["stop_tracking"])
				end_tracking()
			if(href_list["getcords"])
				boutput(usr, "<span style=\"color:blue\">Located at: <b>X</b>: [src.ship.x], <b>Y</b>: [src.ship.y]</span>")
			if(href_list["tracking_coordinates"])
				obtain_tracking_target_coords(href_list["tracking_coordinates"])

			src.add_fingerprint(usr)
			for(var/mob/M in ship)
				if ((M.client && M.machine == src))
					src.opencomputer(M)
		else
			usr << browse(null, "window=ship_sensor")
			return
		return

	//change the HuD icon location based on its current direction
	proc/update_icon_position()
		// var/obj/hud/pod/tracking/T = src.ship.myhud.tracking
		// if (istype(T))
		var/dir = src.ship.myhud.tracking.dir

		switch(dir)
			if (1)
				src.ship.myhud.tracking.screen_loc = "CENTER,CENTER+1"
			if (2)
				src.ship.myhud.tracking.screen_loc = "CENTER,CENTER-1"
			if (4)
				src.ship.myhud.tracking.screen_loc = "CENTER+1,CENTER"
			if (8)
				src.ship.myhud.tracking.screen_loc = "CENTER-1,CENTER"
			if (5)
				src.ship.myhud.tracking.screen_loc = "CENTER+1,CENTER+1"
			if (6)
				src.ship.myhud.tracking.screen_loc = "CENTER+1,CENTER-1"
			if (9)
				src.ship.myhud.tracking.screen_loc = "CENTER-1,CENTER+1"
			if (10)
				src.ship.myhud.tracking.screen_loc = "CENTER-1,CENTER-1"


	proc/begin_tracking()
		// src.ship.tracking = create_screen("leave", "Leave Pod", 'icons/mob/hud_pod.dmi', "arrow", "SOUTH+1,WEST+1")
		src.ship.myhud.tracking.icon_state = "arrow"
		track_target()

	proc/end_tracking()
		src.ship.myhud.tracking.icon_state = "off"
		src.updateDialog()

	proc/track_target()
		var/last_dir = 0
		while (src.tracking_target && src.ship.myhud && src.ship.myhud.tracking)
			last_dir = src.ship.myhud.tracking.dir
			src.ship.myhud.tracking.dir = get_dir(ship, src.tracking_target)
			if (last_dir != src.ship.myhud.tracking.dir)
				update_icon_position()

			sleep(10)

	proc/obtain_tracking_target_coords(var/x as num, var/y as num)

	proc/obtain_tracking_target(var/O as text)
		src.tracking_target = null
		boutput(usr, "<span style=\"color:blue\">Attempting to pinpoint energy source...</span>")
		sleep(10)

		for (var/obj/v in range(src.seekrange,ship.loc))
			if (istype(v, /obj/machinery/vehicle/) || istype(v, /obj/critter/gunbot/drone/))
				if(v.name == O)
					src.tracking_target = v
					break
		src.updateDialog()

		// //For tracking pods
		// if (istype(O, /obj/machinery/vehicle))
		// 	var/obj/machinery/vehicle/target_vehicle = O
		// 	for (var/obj/machinery/vehicle/V in range(src.seekrange,ship.loc))
		// 		if(V == target_vehicle)
		// 			src.tracking_target = V
		// 			break
					
		// //For tracking critter drones
		// if (istype(O, /obj/critter/gunbot/drone))
		// 	var/obj/critter/gunbot/drone/target_drone = O
		// 	for (var/obj/critter/gunbot/drone/V in range(src.seekrange,ship.loc))
		// 		if(V == target_drone)
		// 			src.tracking_target = V
		// 			break

		if (src.tracking_target && get_dist(src,src.tracking_target) <= seekrange)
			boutput(usr, "<span style=\"color:blue\">Tracking target: [src.tracking_target.name]</span>")
			begin_tracking()
		else
			boutput(usr, "<span style=\"color:blue\">Unable to locate target: [src.tracking_target.name]</span>")


	proc/dir_name(var/direction)
		switch (direction)
			if (1)
				return "north"
			if (2)
				return "south"
			if (4)
				return "east"
			if (8)
				return "west"
			if (5)
				return "northeast"
			if (6)
				return "southeast"
			if (9)
				return "northwest"
			if (10)
				return "southwest"

	proc/scan(mob/user as mob)
		scanning = 1
		lifeforms = 0
		ships = 0
		lifelist = list()
		shiplist = list()
		playsound(ship.loc, "sound/machines/signal.ogg", 50, 0)
		ship.visible_message("<b>[ship] begins a sensor sweep of the area.</b>")
		boutput(usr, "<span style=\"color:blue\">Scanning...</span>")
		sleep(30)
		boutput(usr, "<span style=\"color:blue\">Scan complete.</span>")
		for (var/mob/living/C in range(src.seekrange,ship.loc))
			if(C.stat != 2)
				lifeforms++
				lifelist += C.name
		for (var/obj/critter/C in range(src.seekrange,ship.loc))
			if(C.alive && !istype(C,/obj/critter/gunbot))
				lifeforms++
				lifelist += C.name
		for (var/obj/npc/C in range(src.seekrange,ship.loc))
			if(C.alive)
				lifeforms++
				lifelist += C.name
		for (var/obj/machinery/vehicle/V in range(src.seekrange,ship.loc))
			if(V != ship)
				ships++
				shiplist[V.name] = "[dir_name(get_dir(ship, V))]"
		for (var/obj/critter/gunbot/drone/V in range(src.seekrange,ship.loc))
			ships++
			shiplist[V.name] ="[dir_name(get_dir(ship, V))]"
		src.updateDialog()
		sleep(10)
		scanning = 0
		return


/obj/item/shipcomponent/sensor/ecto
	name = "Ecto-Sensor 900"
	desc = "The number one choice for reasearchers of the supernatural."
	see_invisible = 15
	power_used = 40

/obj/item/shipcomponent/sensor/mining
	name = "Conclave A-1984 Sensor System"
	desc = "Advanced geological meson scanners for ships."
	sight = SEE_TURFS
	power_used = 35

	scan(mob/user as mob)
		..()
		mining_scan(get_turf(user), user, 6)