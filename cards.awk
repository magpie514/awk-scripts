#!/bin/awk
# Helper funcs ####################################################################################
func randi(_n) { return int(rand() * _n) } #Helper for generating random ints.
func shuffle(_arr,_size,        i, j, t) { #Shuffle a number-indexed array. This will preserve string indices!
	for(i = 1; i < _size; i++) {
		j = int(i + randi(RAND_MAX) / (RAND_MAX / (_size - i) + 1))
		t = _arr[j]; _arr[j] = _arr[i]; _arr[i] = t #Swap values.
	}
}
# Main funcs ######################################################################################
func card_icon(_n) { #Print card icon.
	if(_n > 0 && _n <= 55) return substr(CARDS, _n, 1);	else return substr(CARDS, 55, 1)
}

func card_id(_n,        v,s) { #Identify and print card information.
	if(_n > 0 && _n <= DECK_SIZE) {
		v = _n % 13 #Value
		s = int((_n - 1) / 13) #Suit
		return _n ":" (v in NAMES ? NAMES[v] : v) " of " SUITS[s]
	} else {
		if(_n == 53) return _n ": Joker"
		if(_n == 54) return _n ": Joker"
		return _n ": Unknown"
	}
}

func deck_init(_deck){ #Initialize deck.
	delete _deck
	_deck["top"] = DECK_SIZE #This is used as a stack size. Allows to get the top card of the deck, then it's decreased.
	#This is done because AWK arrays are all "dictionaries" and I'm only operating on integer entries.
	for(i = 1; i <= DECK_SIZE; i++){ _deck[i] = i } #Set a fresh, ordered deck.
}

func deck_print(_deck){ #Print deck contents.
	printf("Deck:%s/%s [ ", _deck["top"], DECK_SIZE)
	for(i = 1; i <= _deck["top"]; i++){ printf("%s ", card_icon(_deck[i])) }
	printf("]\n")
}

func deck_draw(_deck, _hand){ #"Pop" a value from the top, then "shrink" the array.
	if(_deck["top"] > 0){
		_hand[_hand["top"]] = _deck[_deck["top"]]
		_hand["top"]++; _deck["top"]-- #Adjust deck data.
	} else { printf("[Draw] deck is empty") } #Do nothing.
}

func hand_init(_hand){ #Initialize hand.
	delete _hand
	hand["top"] = 0
}

func hand_print(_hand,        i){ #Print hand contents.
	for(i = 0; i < _hand["top"]; i++) { printf("%s ", card_icon(_hand[i])) }
}

func hand_print_detail(_hand,        i){ #Print hand contents verbosely.
	for(i = 0; i < _hand["top"]; i++) { printf("[%d]%s :%s\n", i+1, card_icon(_hand[i]), card_id(_hand[i])) }
}

BEGIN { #♠♥♦♣
	#Set up RNG.
	srand(SEED) #Seed should be defined externally (awk -v SEED=$RANDOM). I can use "date" or other commands, but I wanted the script to be plain AWK.
	RAND_MAX = 2^32-1	#I can use a much higher number, but let's go with 32b integers for randi().
	#This probably won't give *every* value in the 32b range, since I'm using multiplication and rounding, but will most likely work for shuffling a small deck.
	DECK_SIZE = 52 #53-54 adds two jokers.
	# Initializations
	#Names for special values. I get the card value with a modulo 14, so if it's 0 it's a King.
	NAMES[1] = "Ace"; NAMES[11] = "Jack"; NAMES[12] = "Queen"; NAMES[0] = "King"
	#Cards are ordered so you can obtain a suit just from dividing by 14.
	SUITS[0] = "spades"; SUITS[1] = "hearts"; SUITS[2] = "diamonds"; SUITS[3] = "clubs"
	CARDS = "🂡🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂱🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🃁🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃑🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃞🃏🃟🂠"
	# Main program
	deck[""] = 0; hand[""] = 0 #I don't need to "declare" these, but I prefer to do so.
	deck_init(deck); hand_init(hand) #Initialize deck and hand.
	shuffle(deck, DECK_SIZE); shuffle(deck, DECK_SIZE); shuffle(deck, DECK_SIZE) #Shuffle 3 times.
	for(i=0; i<5; i++) { deck_draw(deck, hand) }
	hand_print(hand)
	deck_print(deck)
	hand_print_detail(hand)
}
