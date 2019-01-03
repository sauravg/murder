/*
 * Copyright (C) 2018 Saurav Ghosh <sauravg@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

:- dynamic(suspect_in_room/2).
:- dynamic(weapon_in_room/2).
:- dynamic(suspect_in_room_fact/2).
:- dynamic(weapon_in_room_fact/2).
:- initialization(investigate).

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
suspect_in_room_fact(study, barbara).
suspect_in_room_fact(bathroom, yolanda).

/*clue_1 :-*/
suspect_in_room(kitchen, X) :-
	atom(X),
	man(X).

/*clue_3 :-*/
suspect_in_room(bathroom, barbara) :- fail.
suspect_in_room(bathroom, george) :- fail.

/*clue_4 :-*/
suspect_in_room(study, X) :-
	atom(X),
	woman(X).

/* clue 7 */
suspect_in_room(study, yolanda) :- fail.
suspect_in_room(pantry, yolanda) :- fail.

/* clue 5 */
suspect_in_room(living, X) :-
	X == john
;
	X == george.

/* clue 8 */
suspect_in_room(Room, george) :-
	weapon_possibly_in_room(Room, firearm).

/*clue_4 :-*/
 weapon_in_room_fact(study, rope).

/* clue 9 */
 weapon_in_room_fact(pantry, gas).


/*clue_3 :-*/
weapon_in_room(bathroom, bag) :- fail.
weapon_in_room(dining, bag) :- fail.

/*clue_1 :-*/
weapon_in_room(kitchen, rope) :- fail.
weapon_in_room(kitchen, knife) :- fail.
weapon_in_room(kitchen, bag) :- fail.
weapon_in_room(kitchen, firearm) :- fail.

/* clue 6 */
weapon_in_room(dining, knife) :- fail.

murder_weapon(gas).
murder_room(pantry).

suspect_could_be_in_room(Room, X) :-
   suspect_in_room_fact(Room, Y),
   atom(Y),
   X \== Y,
   !,
   fail.

suspect_could_be_in_room(Room, X) :-
	suspect_in_room_fact(OtherRoom, X),
	atom(OtherRoom),
	OtherRoom \== Room,
	!,
	fail.

% anybody could be in any room unless some clause proves otherwise
suspect_could_be_in_room(Room, X) :-
	clause(suspect_in_room(Room, X), Body),
	(call(Body) -> fail; !, fail).

/* only comes here if no suspect_in_room/3 fails, i.e. explicitly
 * proves the suspect cannot be here. So the suspect could be in this room */
suspect_could_be_in_room(_, _).

weapon_possibly_in_room(Room, W) :-
    weapon_in_room_fact(Room, K),
    W \= K,
    !, fail.

weapon_possibly_in_room(Room, W) :-
    weapon_in_room_fact(OtherRoom, W),
    OtherRoom \= Room,
    !, fail.

weapon_possibly_in_room(Room, W) :-
    clause(weapon_in_room(Room, W), Body),
    (call(Body) -> fail; !, fail).

weapon_possibly_in_room(_, _).

murderer(X) :-
	murder_room(Room),
	suspect(X),
	suspect_could_be_in_room(Room, X).

murderer(X) :-
    murder_weapon(W),
    room(R),
    weapon_possibly_in_room(R, W),
    suspect_could_be_in_room(R, X).

tie_suspects_to_rooms :-
	room(R),
	findall(X, (suspect(X), suspect_could_be_in_room(R, X)), L),
	length(L, 1),
	nth(1, L, S),
	\+(suspect_in_room_fact(R, S)),
	%format("Suspect ~w must have been in ~w", [S, R]), nl,
	assertz(suspect_in_room_fact(R, S)),
	fail.

tie_suspects_to_rooms.

tie_weapons_to_rooms :-
	room(R),
	findall(X, (weapon(X), weapon_possibly_in_room(R, X)), L),
	%format("Possible weapons in room ~w are: ~w", [R, L]), nl,
	length(L, 1),
	nth(1, L, W),
	\+(weapon_in_room_fact(R, W)),
	%format("Weapon ~w must have been in ~w", [W, R]), nl,
	assertz(weapon_in_room_fact(R, W)),
	fail.

tie_weapons_to_rooms.

all_suspects_tied_to_rooms :-
	findall(X, suspect(X), Suspects),
	findall(Y, suspect_in_room_fact(_,Y), SuspectsTied),
	length(Suspects, N),
	length(SuspectsTied, NTied),
	N == NTied.

reduce_possibilities :-
	tie_suspects_to_rooms,
	tie_weapons_to_rooms,
	/*
	murder_room(R),
	findall(X, (suspect(X), suspect_could_be_in_room(R, X)), L),
	%format("Suspect list reduced to ~w", [L]), nl,
	length(L, 1)
	*/
	all_suspects_tied_to_rooms
	; reduce_possibilities.


investigate :-
	reduce_possibilities,
	print_investigation_report.

print_investigation_report :-
	suspect(X),
	suspect_in_room_fact(R, X),
	weapon_in_room_fact(R, W),
	format("~w was found in ~w with ~w", [X, R, W]), nl,
	fail.

print_investigation_report.

answer_questions :-
	suspect_in_room_fact(kitchen, SuspectInKitchen), format("Suspect ~w was found in the kitchen", [SuspectInKitchen]), nl,
	weapon_in_room_fact(kitchen, WeaponInKitchen), format("Weapon ~w was found in the kitchen", [WeaponInKitchen]), nl,
	suspect_in_room_fact(BarbarasRoom, barbara), format("Barbara was found in ~w", [BarbarasRoom]), nl,
	weapon_in_room_fact(BagRoom, bag), suspect_in_room_fact(BagRoom, SuspectWithBag), format("~w was found with bag", [SuspectWithBag]), nl,
	suspect_in_room_fact(study, SuspectInStudy), woman(SuspectInStudy), format("Suspect ~w (woman) was found in study", [SuspectInStudy]), nl,
	weapon_in_room_fact(RoomWithKnfie, knife), format("Knife was found in ~w", [RoomWithKnfie]), nl,
	suspect_in_room_fact(YolandasRoom, yolanda), weapon_in_room_fact(YolandasRoom, YolandasWeapon), format("Yolanda was found with ~w", [YolandasWeapon]), nl,
	weapon_in_room_fact(RoomWithFirearm, firearm), format("Firearm was found in ~w", [RoomWithFirearm]), nl,
	findall(X, murderer(X), M),
	format("~w is the murderer", M), nl.
