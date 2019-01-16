

/obj/machinery/computer/security
	name = "Security Cameras"
	icon_state = "security"
	var/obj/machinery/camera/current = null
	var/list/obj/machinery/camera/favorites = list()
	var/const/favorites_Max = 8

	var/network = "SS13"
	var/maplevel = 1
	desc = "A computer that allows one to connect to a security camera network and view camera images."

	//This might not be needed. I thought that the proc should be on the computer instead of the mob switching, but maybe not
	proc/switchCamera(var/mob/living/user, var/obj/machinery/camera/C)
		if (!C)
			user.machine = null
			user.set_eye(null)
			return 0
			
		if (stat == 2 || C.network != src.network) return 0

		src.current = C
		user.set_eye(C)
		return 1

	//moved out of global to only be used in sec computers
	proc/move_security_camera(/*n,*/direct,var/mob/living/carbon/user)
		if(!user) return

		//pretty sure this should never happen since I'm adding the first camera found to be the current, but just in cases
		if (!src.current)
			boutput(user, "<span style=\"color:red\">No current active camera. Select a camera as an origin point.</span>")
			return


		// if(user.classic_move)
		var/obj/machinery/camera/closest = src.current
		if(closest)
			//do
			if(direct & NORTH)
				closest = closest.c_north
			else if(direct & SOUTH)
				closest = closest.c_south
			if(direct & EAST)
				closest = closest.c_east
			else if(direct & WEST)
				closest = closest.c_west
			//while(closest && !closest.status) //Skip disabled cameras - THIS NEEDS TO BE BETTER (static overlay imo)
		else
			closest = getCameraMove(user, direct) //Ok, let's do this then.

		if(!closest)
			return

		// user.tracker.cease_track()
		switchCamera(user, closest)
		// user.switchCamera(closest)		//from original

/obj/machinery/computer/security/wooden_tv
	name = "Security Cameras"
	icon_state = "security_det"

	small
		name = "Television"
		desc = "These channels seem to mostly be about robuddies. What is this, some kind of reality show?"
		network = "Zeta"
		icon_state = "security_tv"

		power_change()
			return

// -------------------- VR --------------------
/obj/machinery/computer/security/wooden_tv/small/virtual
	desc = "It's making you feel kinda twitchy for some reason."
	icon = 'icons/effects/VR.dmi'
// --------------------------------------------

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telescreen"
	network = "thunder"
	density = 0

	power_change()
		return

/obj/machinery/computer/security/attack_hand(var/mob/user as mob)
	if (stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	user.unlock_medal("Peeping Tom", 1)

	var/list/L = list()
	var/bool = 1
	for (var/obj/machinery/camera/C in machines)
		if (bool)
			src.current = C
			bool = 0
		L.Add(C)

	L = camera_sort(L)

	var/cameras_list 
	for (var/obj/machinery/camera/C in L)
		if (C.network == src.network)
			. = "[C.c_tag][C.status ? null : " (Deactivated)"]"
			// Don't draw if it's in favorites
			if (C in favorites)
				continue
			//the display:none is a holdover from another way I was trying to handle moving shit. might move back or not
			// &#128190; is save symbol
			cameras_list += \
{"<tr>
<td><a href='byond://?src=\ref[src];camera=\ref[C]' style='display:block;'>[.]</a></td> <td class='fav'>&#128190;</td>
</tr>
"}

	var/script = 	{"
	<script type='text/javascript'>
	//stolen from W3Schools.com. Simple filtering, works well enough, didn't bother to make anything special for this.
	function filterTable() {
		var input, filter, table, tr, td, i, txtValue;
		input = document.getElementById('searchbar');
		filter = input.value.toUpperCase();
		table = document.getElementById("cameraList");
		tr = table.getElementsByTagName("tr");

		// Loop through all table rows, and hide those who don't match the search query
		for (i = 0; i < tr.length; i++) {
			td = tr\[i\].getElementsByTagName("td")\[0\];
			if (td) {
				txtValue = td.textContent || td.innerText;
				if (txtValue.toUpperCase().indexOf(filter) > -1) {
					tr\[i\].style.display = "";
				} else {
					tr\[i\].style.display = "none";
				}
			} 
		}
	}


	</script>

	<script type='text/javascript'>
	//stole this debounce function from Kfir Zuberi at https://medium.com/walkme-engineering/debounce-and-throttle-in-real-life-scenarios-1cc7e2e38c68
		function debounce (func, interval) {
			var timeout;
			return function () {
				var context = this, args = arguments;
				var later = function () {
					timeout = null;
					func.apply(context, args);
				};
				clearTimeout(timeout);
				timeout = setTimeout(later, interval || 200);
		  }
		}

	$(document).delegate('button', 'keyup', debounce(function(e) {
		e.stopPropagation();
		var keyId = e.which;
		//takes arrows, wasd, and ijkl.
		//If any other key is pressed, just default to return
		switch(keyId) {
		case 37:
		case 65:
		case 74:
			keyId = 37;
			break;
		case 38:
		case 87:
		case 73:
			keyId = 38;
			break;
		case 39:
		case 68:
		case 76:
			keyId = 39;
			break;
		case 40:
		case 83:
		case 75:
			keyId = 40;
			break;
		default: 
		  	return;
		}
		window.location='byond://?src=\ref[src];move='+keyId;
		e.preventDefault();
		
	 },50));

	//for these just add a save link to those list items
	
	$(document).delegate('.fav', 'click', debounce(function(e) {
	  var table = $(this).parent().parent().parent()
	  
	  //check which list it's in. adding/removing. 
	  if (table.attr("id") == "cameraList") {
	  	if ($('#savedCameras tr').length >= [favorites_Max]) {
	  		alert('Cannot have more than [favorites_Max] favorites.');
	  		return;
	  	}



	    var tr = $(this).parent();
	    $(this).html('&#128165;');
	    tr.appendTo(document.getElementById("savedCameras"));

	    // make topic call from a href
	    var href = tr.find('a').attr('href');
	    var re = /.*camera=(.*)$/g;
	    var cameraID = re.exec(href)\[1\];


	    window.location='byond://?src=\ref[src];save='+cameraID;

	  //Removing shit
	  } else if(table.attr("id") == "savedCameras") {
	    var tr = $(this).parent();
	    $(this).html('&#128190');
	    tr.appendTo(document.getElementById("cameraList"));

	    var href = tr.find('a').attr('href');
	    var re = /.*camera=(.*)$/g;
	    var cameraID = re.exec(href)\[1\];


	    window.location='byond://?src=\ref[src];remove='+cameraID;
		}
  
},50));

	</script>

	<style>
		ul{
			list-style-type: none;
			margin: 0;
			padding: 0;
		}
		table{
			width:80;
		}
	    a {
    		color:green;
    	}

	#main_list{
		width:275px;
		margin:5px;
		padding:3px;
		float:left;
		display:inline-block;

	}
	#fav_list{
		width:275px;
		height:200px;
		border:2px solid green;
		margin:5px;
		padding:4px;
		float:right;
		display:inline-block;

		overflow:hidden;
	}

	</style>
	"}

	var/fav_cameras
	for (var/obj/machinery/camera/C in favorites)
		if (C.network == src.network)
			. = "[C.c_tag][C.status ? null : " (Deactivated)"]"

			fav_cameras += \
			{"<tr>
			<td><a href='byond://?src=\ref[src];camera=\ref[C]' style='display:block;'>[.]</a></td> <td class='fav'>&#128165;</td>
			</tr>"}

	var/dat = {"[script]
	<body>
		<a href='byond://?src=\ref[src];close=1' style='display:block;float:right;'>&times;</a>
		<button type='button' autofocus id='movementButton' style='width:100%;display:block;color:green;background-color:black;'> Keyboard Movement Mode</button>
		<div id='main_list'>

		<input type='text' id='searchbar' onkeyup='filterTable()' placeholder='Search for cameras..'>
		<table id='cameraList'>
			[cameras_list]
		</table>
		</div>
		<div id='fav_list'>
			<p>Favorite Cameras: </p>
			<table id='savedCameras'>
				[fav_cameras]
			</table>
		</div>
	</body>"}

	user.Browse(dat, "window=security_camera_computer;title=Security Cameras;size=650x500;can_resize=0;can_close=0;")
	// user.Subscribe(user.client)
	// onclose(user, "security_camera_computer", src)
	// winshow(user, "security_camera_computer", 1)


/obj/machinery/computer/security/Topic(href, href_list)
	if (!usr)
		return

	if (href_list["close"] || (!istype(usr, /mob/living/silicon/ai) && (get_dist(usr, src) > 1 || usr.machine != src || !usr.sight_check(1))))
		usr.set_eye(null)
		winshow(usr, "security_camera_computer", 0)
		return


	else if (href_list["camera"])
		var/obj/machinery/camera/C = locate(href_list["camera"])
		if (!istype(C, /obj/machinery/camera))
			return

		if (!C.status)
			usr.set_eye(null)
			winshow(usr, "security_camera_computer", 0)
			return

		else
			src.current = C
			usr.set_eye(C)
			use_power(50)

	else if (href_list["save"])
		var/obj/machinery/camera/C = locate(href_list["save"])

		if (C && favorites.len < favorites_Max)
			favorites += C
	else if (href_list["remove"])
		var/obj/machinery/camera/C = locate(href_list["remove"])

		if (C)
			favorites -= C

	//using arrowkeys/wasd/ijkl to move from camera to camera
	else if (href_list["move"])
		var/direction = href_list["move"]

		//validate direction returned. JS tries to sanitize client side keypresses so we won't be getting any keys other than arrow keycodes hopefully. But I added the others here just cause...
		//arrow keys, wasd, ijkl
		switch (direction)
			if ("37","65","74")
				direction = WEST
			if ("38","87","73")
				direction = NORTH
			if ("39", "68", "76")
				direction = EAST

			if ("40", "83", "75")
				direction = SOUTH

		move_security_camera(direction,usr)
	else
		usr.set_eye(null)
		// winshow(usr, "security_camera_computer", 0)
		usr.Browse(null, "window=security_camera_computer")
		return

/obj/machinery/computer/security/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/screwdriver))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				boutput(user, "<span style=\"color:blue\">The broken glass falls out.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				new /obj/item/raw_material/shard/glass( src.loc )
				var/obj/item/circuitboard/security/M = new /obj/item/circuitboard/security( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				boutput(user, "<span style=\"color:blue\">You disconnect the monitor.</span>")
				var/obj/computerframe/A = new /obj/computerframe( src.loc )
				if(src.material) A.setMaterial(src.material)
				var/obj/item/circuitboard/security/M = new /obj/item/circuitboard/security( A )
				for (var/obj/C in src)
					C.set_loc(src.loc)
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)
	return

proc/getr(col)
	return hex2num( copytext(col, 2,4))

proc/getg(col)
	return hex2num( copytext(col, 4,6))

proc/getb(col)
	return hex2num( copytext(col, 6))
