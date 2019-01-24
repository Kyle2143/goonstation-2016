
chui/window/security_cameras
	name = "Security Cameras"
	var/obj/machinery/computer/security/owner
	//windowSize = "650x500"					//windowSize is not in 2016
	flags = CHUI_FLAG_MOVABLE

	New(var/obj/machinery/computer/security/seccomp)
		..()
		owner = seccomp

	GetBody()
		var/list/L = list()
		var/bool = 1
		for (var/obj/machinery/camera/C in machines)
			if (bool)
				owner.current = C
				bool = 0
			L.Add(C)

		L = camera_sort(L)

		var/cameras_list
		for (var/obj/machinery/camera/C in L)
			if (C.network == owner.network)
				. = "[C.c_tag][C.status ? null : " (Deactivated)"]"
				// Don't draw if it's in favorites
				if (C in owner.favorites)
					continue
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
		/**		
 * Debounce and throttle function's decorator plugin 1.0.5
 *
 * Copyright (c) 2009 Filatov Dmitry (alpha@zforms.ru)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 */

(function($) {

$.extend({

	debounce : function(fn, timeout, invokeAsap, ctx) {

		if(arguments.length == 3 && typeof invokeAsap != 'boolean') {
			ctx = invokeAsap;
			invokeAsap = false;
		}

		var timer;

		return function() {

			var args = arguments;
            ctx = ctx || this;

			invokeAsap && !timer && fn.apply(ctx, args);

			clearTimeout(timer);

			timer = setTimeout(function() {
				!invokeAsap && fn.apply(ctx, args);
				timer = null;
			}, timeout);

		};

	},

	throttle : function(fn, timeout, ctx) {

		var timer, args, needInvoke;

		return function() {

			args = arguments;
			needInvoke = true;
			ctx = ctx || this;

			if(!timer) {
				(function() {
					if(needInvoke) {
						fn.apply(ctx, args);
						needInvoke = false;
						timer = setTimeout(arguments.callee, timeout);
					}
					else {
						timer = null;
					}
				})();
			}

		};

	}

});
})(jQuery);

		function handle_key_movement(e) {
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
			e.stopPropagation();

			e.preventDefault();
			e.stopPropagation();
		}
    
    
		$(document).delegate('button', 'keyup', $.throttle(handle_key_movement,1000));


		//for these just add a save link to those list items

		$(document).delegate('.fav', 'click', function(e) {
			var table = $(this).parent().parent().parent()

			//check which list it's in. adding/removing.
			if (table.attr("id") == "cameraList") {
				if ($('#savedCameras tr').length >= [owner.favorites_Max]) {
					alert('Cannot have more than [owner.favorites_Max] favorites.');
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

	});

		</script>

		<style>
		table {
			  width: 80;
			}
	    a {
	      color:green;
	    }
	    p {
	    	color:green
	    }
	    button {
			width:100%;
			display:block;
			color:green;
			background-color:black;
			border: 1px solid green;
	    }
		#main_list {
			margin: 5px;
	    	padding: 5px;
			border: 3px solid green;
			display: inline-block;
	    	background-color: black;
			width: 275px;
			height: 375px;
			float: left;
			overflow: scroll;
		}

		#fav_list {
			margin: 5px;
			padding: 5px;
			border: 3px solid green;
			display: inline-block;
			background-color: black;
			width: 275px;
			height: 250px;
			float: right;
			overflow: hidden;
		}
		</style>
		"}

		var/fav_cameras
		for (var/obj/machinery/camera/C in owner.favorites)
			if (C.network == owner.network)
				. = "[C.c_tag][C.status ? null : " (Deactivated)"]"
				fav_cameras += \
				{"<tr>
				<td><a href='byond://?src=\ref[src];camera=\ref[C]' style='display:block;'>[.]</a></td> <td class='fav'>&#128165;</td>
				</tr>"}

		var/dat = {"[script]
		<body>
			<button type='button' autofocus id='movementButton'> Keyboard Movement Mode</button>
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

		return dat

	OnTopic( href, href_list[] )
		if (!usr || !islist(href_list))
			return

		else if (href_list["camera"])
			var/obj/machinery/camera/C = locate(href_list["camera"])
			if (!istype(C, /obj/machinery/camera))
				return

			//maybe I should change this, could be dumb for the movement mode - Kyle
			if (!C.status)
				boutput(usr, "<span style=\"color:red\">BEEEEPP. Camera broken.</span>")
				// usr.set_eye(null)
				// if( IsSubscribed( usr.client ) )
				// 	Unsubscribe( usr.client )
				return

			else
				owner.current = C
				usr.set_eye(C)
				owner.use_power(50)

		else if (href_list["save"])
			var/obj/machinery/camera/C = locate(href_list["save"])

			if (istype(C) && owner.favorites.len < owner.favorites_Max)
				owner.favorites += C
		else if (href_list["remove"])
			var/obj/machinery/camera/C = locate(href_list["remove"])

			if (istype(C))
				owner.favorites -= C

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
				else
					return

			owner.move_security_camera(direction,usr)

	Unsubscribe( client/who )
		..()
		who.mob.set_eye(null)