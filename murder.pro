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


/*clue_2 + clue 7*/
suspect_in_room(study, barbara) :- !.
suspect_in_room(bathroom, yolanda) :- !.

/*clue_1 :-*/
suspect_in_room(kitchen, X) :-
	man(X).

/*clue_3 :-*/
suspect_in_room(bathroom, barbara) :- fail.
suspect_in_room(bathroom, george) :- fail.

/*clue_4 :-*/
suspect_in_room(study, X) :-
	woman(X).

/* clue 7 */
suspect_in_room(study, yolanda) :- fail.
suspect_in_room(pantry, yolanda) :- fail.

/* clue 5 */
suspect_in_room(living, X) :-
	X = john
;
	X = george.

/*clue_4 :-*/
 weapon_in_room(study, rope) :- !.

/*clue_3 :-*/
weapon_in_room(bathroom, bag) :- !, fail.
weapon_in_room(dining, bag) :- !, fail.

/*clue_1 :-*/
weapon_in_room(kitchen, W) :-
	weapon(W),
	W \== rope,
	W \== knife,
	W \== bag,
	W \== firearm.

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

murder_weapon(gas).
murder_room(pantry).

% anybody could be in any room unless some clause proves otherwise
could_be_in_room(Room, X) :-
	clause(suspect_in_room(Room, X), Body),
	(call(Body) -> fail; !, fail).

/* only comes here if no suspect_in_room/3 fails, i.e. explicitly
 * proves the suspect cannot be here. So the suspect could be in this room */
could_be_in_room(_, _).

murderer(X) :-
	murder_room(Room),
	suspect(X),
	suspect_in_room(Room, X).

murderer(X) :-
    murder_weapon(W),
    room(R),
    weapon_in_room(R, W),
    suspect_in_room(R, X).
