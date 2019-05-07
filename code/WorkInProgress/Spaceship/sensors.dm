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
		end_tracking()
		scanning = 0

	proc/build_html_gps_form()
//		<form name="consoleinput" action="byond://?src=\ref[src]" method="get" onsubmit="javascript:return lineEnter()">

		return {"
			<A href='byond://?src=\ref[src];getcords=1'>Get Local Coordinates</A><BR>
			<button id='dest' onClick='(showInput())' >Destination Coordinates</button><BR>
			<div style='display:none' id = 'destInput'>
				X Coordinate: <input id='idX'  type='number' min='0' max='500' name='X' value='0'><br>
				Y Coordinate: <input id='idY' type='number' min='0' max='500' name='Y' value='0'><br>
				<div style='display: none;'>
					Z Coordinate: <input id='idZ' type='number' name='Z' value='-1'><br>
				</div>

				<button onclick='send()'>Enter</button>
			</div>
			<script>
				function showInput() {
				  var x = document.getElementById('destInput');
				  if (x.style.display === 'none') {
				    x.style.display = 'block';
				  } else {
				    x.style.display = 'none';
				  }
				}

				function send() {
					var x = document.getElementById('idX').value;
					var y = document.getElementById('idY').value;
					var z = document.getElementById('idZ').value;

					window.location='byond://?src=\ref[src];dest_cords=1;x='+x+';y='+y+';z='+z;

				}
			</script>

			"}


	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		user.machine = src

		var/dat = "<B>[src] Console</B><BR><HR><BR>"
		if(src.active)

			dat += build_html_gps_form()

			dat += {"<BR><A href='?src=\ref[src];scan=1'>Scan Area</A>"}
			if (src.tracking_target)
				dat += {"<BR>Currently Tracking: [src.tracking_target.name]
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

	proc/obtain_target_from_coords(href_list)
	//The default Z coordinate given. Just use current Z-Level where the object is. Pods won't
		#define DEFAULT_Z_VALUE -1		
		scanning = 1
		if (href_list["dest_cords"])
			tracking_target = null
			var/x = text2num(href_list["x"])
			var/y = text2num(href_list["y"])
			var/z = text2num(href_list["z"])
			if (!x || !y || !z)
				boutput(usr, "<span style=\"color:red\">Bad Topic call, if you see this something has gone wrong. And it's probably YOUR FAULT!</span>")
				return
			//Using -1 as the default value
			if (z == DEFAULT_Z_VALUE)
				if (src.loc)
					z = src.loc.z

			boutput(usr, "<span style=\"color:blue\">Attempting to pinpoint: <b>X</b>: [x], <b>Y</b>: [y], Z</b>: [z]</span>")
			playsound(ship.loc, "sound/machines/signal.ogg", 50, 0)
			sleep(10)
			var/turf/T = locate(x,y,z) 

			//Set located turf to be the tracking_target
			if (isturf(T))
				src.tracking_target = T
				boutput(usr, "<span style=\"color:blue\">Now tracking: <b>X</b>: [T.x], <b>Y</b>: [T.y], Z</b>: [T.z]</span>")
				begin_tracking(1)
		sleep(10)
		scanning = 0
		#undef DEFAULT_Z_VALUE

	Topic(href, href_list)
		if(usr.stat || usr.restrained())
			return

		if (usr.loc == ship)
			usr.machine = src
			if (href_list["scan"] && !scanning)
				scan(usr)

			if (href_list["tracking_ship"] && !scanning)
				obtain_tracking_target(href_list["tracking_ship"])
			if (href_list["stop_tracking"])
				end_tracking()
			if(href_list["getcords"])
				boutput(usr, "<span style=\"color:blue\">Located at: <b>X</b>: [src.ship.x], <b>Y</b>: [src.ship.y]</span>")
			if(href_list["dest_cords"] && !scanning)
				obtain_target_from_coords(href_list)

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
		var/obj/dir = src.ship.myhud.tracking.dir
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

	//If our target is a turf from the GPS coordinate picker. Our range will be much higher
	proc/begin_tracking(var/gps=0)
		// src.ship.tracking = create_screen("leave", "Leave Pod", 'icons/mob/hud_pod.dmi', "arrow", "SOUTH+1,WEST+1")
		src.ship.myhud.tracking.icon_state = "dots"
		track_target(gps)

	//nulls the tracking target, sets the hud object to turn off end center on the ship and updates the dilaogue
	proc/end_tracking()
		src.tracking_target = null
		src.ship.myhud.tracking.dir = 1
		src.ship.myhud.tracking.screen_loc = "CENTER,CENTER"

		src.ship.myhud.tracking.icon_state = "off"
		src.updateDialog()

	//Tracking loop
	proc/track_target(var/gps)
		var/last_dir = 0
		var/cur_dist = 0

		while (src.tracking_target && src.ship.myhud && src.ship.myhud.tracking)
			cur_dist = get_dist(src,src.tracking_target)
			//change position and icon dir based on direction to target. And make sure it's using the dots.
			if (cur_dist <= seekrange)
				last_dir = src.ship.myhud.tracking.dir
				src.ship.myhud.tracking.dir = get_dir(ship, src.tracking_target)
				src.ship.myhud.tracking.icon_state = "dots"
				
				//Change if HuD position if the direction has changed since last tic
				if (last_dir != src.ship.myhud.tracking.dir)
					update_icon_position()

			//If the target is out of seek range, move to top and change to lost state
			else 
				src.ship.myhud.tracking.dir = 1
				src.ship.myhud.tracking.icon_state = "lost"
				src.ship.myhud.tracking.screen_loc = "CENTER,CENTER+1"

				//if we're twice as far out or off the z-level, lose the signal
				//If it's a static gps target from the coordinate picker, we can track from 5x away
				if ((cur_dist > seekrange*2) || (gps && cur_dist > seekrange*5))
					end_tracking()
					boutput(usr, "<span style=\"color:red\">Tracking signal lost.</span>")
					playsound(src.loc, "sound/machines/whistlebeep.ogg", 50, 1)
					break;

			sleep(10)


	proc/obtain_tracking_target(var/O as text)
		scanning = 1
		src.tracking_target = null
		boutput(usr, "<span style=\"color:blue\">Attempting to pinpoint energy source...</span>")
		playsound(ship.loc, "sound/machines/signal.ogg", 50, 0)
		sleep(10)

		for (var/obj/v in range(src.seekrange,ship.loc))
			if (istype(v, /obj/machinery/vehicle/) || istype(v, /obj/critter/gunbot/drone/))
				if(v.name == O)
					src.tracking_target = v
					break

		if (src.tracking_target && get_dist(src,src.tracking_target) <= seekrange)
			boutput(usr, "<span style=\"color:blue\">Tracking target: [src.tracking_target.name]</span>")
			begin_tracking()
			src.updateDialog()
		else
			boutput(usr, "<span style=\"color:blue\">Unable to locate target: [src.tracking_target.name]</span>")
		sleep(10)
		scanning = 0

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