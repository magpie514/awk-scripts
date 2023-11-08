#!/usr/bin/env awk
# WireWorld cellular automaton in AWK. This is a brutish approach that can be optimized.
# AWK provides no timing mechanisms of its own, so this uses stdin to update. Every \n will update the map.
# If there is no stdin, it can be updated by pressing Enter.
# For example:
# bash$ { while true; do echo "x"; sleep 0.25; done } | awk -v _columns=$COLUMNS -v _rows=$LINES -v _file="test.ww" -f wireworld.awk
# Input files are simple ASCII numbers. 1 for wire, 2 for tail, 3 for head. Anything else for empty space.

BEGIN { #Set everything up.
	MAP_WIDTH  = _columns; MAP_HEIGHT = _rows - 2; MAP_LINEAR = MAP_HEIGHT * MAP_WIDTH;      WIRE = 1; TAIL = 2; HEAD = 3
	step = 0
	printf("\033[2J\033[H"); # Clear screen and move cursor to top left.
	#Prepare a header. Print a string, which will remain static, and grab the position to update the counter.
	COUNTER_POS = sprintf("FILE: %s - SIZE:(%i, %i) STEP:", _file, MAP_WIDTH, MAP_HEIGHT)
	print(COUNTER_POS); COUNTER_POS = length(COUNTER_POS) #While it's pointless to optimize with this whole redrawing the map every time, might as well.
	for(i = 0; i < MAP_LINEAR; i++) { map[i] = 0; out[i] = 0 } #Initialize map and "out" as temporary storage for the updated map.
	#Proceed to read a text file with a WireWorld contraption.
	l = 0 #Line counter.
	while(( getline line < _file) > 0 ) { #Ensure file exists from outside!
		split(line, chars, "") #Separate as individual characters.
    for(i = 1; i <= length(line); i++) map[(l*MAP_WIDTH) + i] = int(chars[i]) #Copy data. Assuming.
		l++
  }
}

function _update(){ #Update map.
	printf("\033[%1;%sH", COUNTER_POS + 1);	printf("%i\n",step) # Reset cursor and update header.
	for(i = 1; i <= MAP_LINEAR; i++){
		if     (map[i] == TAIL) out[i] = WIRE #Tail to wire
		else if(map[i] == HEAD) out[i] = TAIL #Head to tail
		else if(map[i] == WIRE){              #Wire becomes head if it counts 1 or 2 heads around it.
			n = 0 #Count heads in Moore neighborhood.
			if(map[i - MAP_WIDTH - 1] == HEAD) n++; if(map[i - MAP_WIDTH] == HEAD) n++;  if(map[i - MAP_WIDTH + 1] == HEAD) n++
			if(map[i - 1] == HEAD) n++            ;                                      if(map[i + 1] == HEAD) n++
			if(map[i + MAP_WIDTH - 1] == HEAD) n++; if(map[i + MAP_WIDTH] == HEAD) n++;  if(map[i + MAP_WIDTH + 1] == HEAD) n++
			if(n == 1 || n == 2) out[i] = HEAD #Only generate a head if 1 or 2 head neighbors.
			else out[i] = WIRE
		}
	}
	for(i = 1; i <= MAP_LINEAR; i++) { #Print the map.
		if     (out[i] == WIRE) printf("\033[0;31m█") #Wire as red.
		else if(out[i] == TAIL) printf("\033[0;33m█") #Tail as orange or dark yellow.
		else if(out[i] == HEAD) printf("\033[1;33m█") #Head as yellow.
		else                    printf("\033[m░");    #Thing.
		if(!(i % MAP_WIDTH)) printf("\n");            #Newline upon reaching a multiple of MAP_WIDTH.
		map[i] = out[i];                              #Copy back the updated map into map.
	}
	step++
}

{	_update() } #Update map on newline.