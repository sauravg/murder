:- dynamic(suspect_in_room/2).
:- dynamic(weapon_in_room/3).

suspect(george).
suspect(john).
suspect(robert).
suspect(barbara).
suspect(christine).
suspect(yolanda).

man(george).
man(john).
man(robert).

woman(barbara).
woman(christine).
woman(yolanda).

weapon(bag).
weapon(firearm).
weapon(gas).
weapon(knife).
weapon(poison).
weapon(rope).

room(bathroom).
room(dining).
room(kitchen).
room(living).
room(pantry).
room(study).


/*clue_1 :-*/
suspect_in_room(kitchen, X) :-
	man(X).

/*clue_2 :-*/
suspect_in_room(R, barbara) :-
	/*
	assertz(suspect_in_room(bathroom, yolanda)),
	assertz(suspect_in_room(study, barbara)),
	*/
   room(R),
	R == study,
	suspect_in_room(bathroom, yolanda)
;
	R == bathroom,
	suspect_in_room(study, yolanda).

/*clue_2 :-*/
suspect_in_room(R, yolanda) :-
	/*
	retract(suspect_in_room(study, barbara)),
	retract(suspect_in_room(bathroom, yolanda)),
	/* these are final */
	 /*
	assertz(suspect_in_room(study, yolanda)),
	assertz(suspect_in_room(bathroom, barbara)),
	*/
   room(R),
	R == study,
	suspect_in_room(bathroom, barbara)
;
	R == bathroom,
	suspect_in_room(study, barbara).

/*clue_3 :-*/
suspect_in_room(bathroom, X) :-
	suspect(X),
	X \== barbara,
	X \== george.

/*clue_4 :-*/
suspect_in_room(study, X) :-
	woman(X).

/* clue 5 */
suspect_in_room(living, X) :-
	X = john
;
	X = george.

/* clue 7 */
 suspect_in_room(Room, yolanda) :-
	 room(Room),
	 Room \== study,
	 Room \== pantry.

/*clue_1 :-*/
weapon_in_room(kitchen, W) :-
	weapon(W),
	W \== rope,
	W \== knife,
	W \== bag,
	W \== firearm.

/*clue_3 :-*/
weapon_in_room(bathroom, bag) :- !, fail.
weapon_in_room(dining, bag) :- !, fail.

/*clue_4 :-*/
 weapon_in_room(study, rope) :- !.

/* clue 6 */
weapon_in_room(Room, knife) :-
	room(Room),
	Room \== dining.

/* clue 8 */
weapon_in_room(Room, firearm) :-
    room(Room),
	suspect_in_room(Room, george).

/* clue 9 */
 weapon_in_room(pantry, gas) :- !.

weapon_in_room(Room, W) :-
	room(Room),
	weapon(W).

murder_weapon(gas).
murder_room(pantry).


murder(X) :-
	murder_room(Room),
	suspect(X),
	suspect_in_room(Room, X).

murder(X) :-
    murder_weapon(W),
    room(R),
    weapon_in_room(R, W),
    suspect_in_room(R, X).
