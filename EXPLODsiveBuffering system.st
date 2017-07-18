;==============================================================================================
;==============================================================================================
;================================<EXPLODsive Buffering System>=================================
;====================================<by JustMorphPointman>====================================
;==============================================================================================
;==============================================================================================

;==============================================================================================
;INTRODUCTION; INSTALLATION INSTRUCTIONS, AND HOW TO USE THIS SYSTEM
;==============================================================================================
;The following block of code is an explod-based buffering system, designed to overcome several
;different errors and bugs related to MUGEN's default method of processing commands, as well as
;offering creators more control over how the commands of their character should work. It is designed
;to be easy to use, understand, and install.

;MUGEN's default command system has many limitations: the reverse command bug [actually save this shit for the thread]

;The system is completely customizable, and can be modified to suit the preference of the creator.
;However, it can also be installed as is; requiring no modifications you other than switching out
;the triggers for the various ChangeState controllers in State -1. In this section, we will explain
;how to change those triggers; a more thorough explanation of how the system works and how to modify
;it and add more commands can be found below this introductory section.

;To properlly "install" this system, you have to copy and paste this block of code to the start of your
;-1 State, which is usually located in the character's .cmd file. It's vital that this block of code
;is placed at the very top of State -1!!!

;In addition, you need to add the following commands to your .cmd file:

;[Command]
;name = "dfwd"
;command = DF
;time = 1

;[Command]
;name = "dback"
;command = DB
;time = 1

;[Command]
;name = "ufwd"
;command = UF
;time = 1

;[Command]
;name = "uback"
;command = UB
;time = 1

;You must also create a helper, which this system will use to process the player's input. Just copy and paste
;the following into your character's State -2:

;[State -2, EXPLODsive Buffering Helper]
;type = Helper
;trigger1 = !NumHelper(90000005)
;helpertype = Normal
;stateNo = 90000005
;ID = 90000005
;name = "EXPLODsive Buffering helper"
;posType = P1
;facing = ifElse(Facing = 1, 1, -1)
;keyCtrl = 1
;ignoreHitPause = 1

;The helper state must also be added. Make sure not to place it inside another state!

;========================<EXPLODSIVE BUFFERING HELPER>=============================
;[StateDef 90000005]
;type = A
;physics = N
;moveType = I
;anim = 1
;velSet = 0,0
;ctrl = 0

;[State 90000005, DisplayToClipboard]
;type = DisplayToClipboard
;trigger1 = 1
;text = "by JustMorphPointman"
;ignoreHitPause = 1

;Now you just need to switch out the triggers in your character's ChangeStates in -1, and you'll
;be good to go! The only other thing you need to do (other than switching out the triggers) to make
;this system work is to set the "command.buffer.time" to 1. This will ensure the buffer system can
;properly read all of the player's inputs! You must also make sure that int variables 47, 48, 49, and
;50 are free, if you are including the charge moves. ;These variables are used by the system to store
;charge move buffer times and other information needed to have charge move behave properly. If you are
;not using the charge moves at all, you can safely make use of those four variables, as long as you
;delete the lines of code in the buffer system that deal with charge moves (for more information about
;deleting uneeded moves, see the advanced section below this introductory section.
;==============================================================================================
;The basic concept of this system is that we generate a series of explods based on the input of the
;player; for example, if the player hits "down", an explod with a unique ID, representing the "down"
;direction will be created, with a certain RemoveTime. If the player then hits "down-forward" before
;the "down" explod has been removed, a "down-forward" explod would be created. This process would repeat
;if the player then inputs "forward". If MUGEN checks to see if that "forward" explod exists, then
;it will know that a quarter circle forward motion has been successfully completed. This is what we
;use as triggers: instead of checking to see if command = "QCF", we check NumExplod(QCF). We use explods
;instead of variables in this system to keep the character's own variables (mostly) free; and we have to
;avoid using a helper

;However, unlike MUGEN, we won't be using "forward" and "back"; the explod system is based entirely
;on absolute, not relative, directional inputs. That means left and right, instead of forward or back.
;This is to avoid problems in situations where the characters are switching sides, and their commands
;reverse. By defining everything in terms of left and right, we can ensure that a player can always perform
;the move they want to perform, and not have engine limitations get in the way. So instead of checking for a
;quarter circle forward motion (D, DF, F), we check for both a quarter circle right/left motion
;(D, DR, R and D, DL, L). For a quarter circle forward motion, we would check if the quarter circle right
;explod exists when the character is facing to the right, and check for the quarter circle left explod
;if the character was facing left. This is required even if the character you are making only has a QCF, or
;only a QCB, or what have you!

;Here is a very simplified version of a Hadoken ChangeState, using MUGEN's old method:

;[State -1, Hadoken (light strength)]
;type = ChangeState
;value = 1000
;trigger1 = command = "QCF+x"
;trigger1 = ctrl && StateType = S

;We can very easily switch this out by looking up the explods that represent quarter circle right, left,
;and "x" button (check the handy chart at the bottom of this section), and adding the appropriate triggers.
;In this case, we find quarter-circle right corresponds to "90010006", quarter-circle left is "90010104",
;and "x" is 90000200. So, we modify the ChangeState to look like this:

;[State -1, Hadoken]
;type = ChangeState
;value = 1000
;trigger1 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90010006)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90010104))
;trigger1 = NumExplod(90000200)
;trigger1 = ctrl && StateType = S

;It might look more imposing, but it's pretty simple! We check to make sure that if the player is facing
;right, then we check if an explod with ID 90010006 exists (and if the player is on the left, then we check
;for an explod ID of 90010104); these explods represent the quarter circle motion. If one of those exist
;(and the character is facing the appropriate direction), and an explod that represents the "x" button
;also exists, then that means the player has sucessfully completed the quarter circle motion and has
;pressed "x", which means it's time to fire off a Hadoken!
;==============================================================================================
;Most moves, special, super, or otherwise, can be pretty easily updated to use this system, just by
;copying and pasting the appropriate triggers. For moves that require directional input(s), this statement
;(with the appropriate explod ID replacing the text in all caps) should be used (except in rarer cases covered below):

;triggerAll = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_RIGHT)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_LEFT))

;The above statement is how the vast majority of fighting game moves on the ground work. But moves performed in air
;are where things get a little trickier. In most Capcom games, when you jump over an opponent, your commands don't flip over
;until you land. So if you're playing as Akuma, and you start out on the left side of the screen before jumping over the
;opponent, your air fireball move is still performed by rotating the joystick from down to the right, a quarter-circle
;right motion. However, in most SNK games (and Street Fighter III and Capcom vs. SNK!), things work differently. In those games
;as soon as you jump over an opponent, your commands flip. So to use the same Akuma example again, if Akuma starts on the left
;and jumps over the opponent in one of these games, the player will have to move the joystick from down to *left* to get his air
;fireball move, because their commands have already been switched, as soon as they switched sides with their opponent. The SNK
;way of handling aerial moves doesn't require any changes to the above ifElse statements. With the Capcom games that don't
;flip directions in the air, however, a different set of triggers are required:

;triggerAll = ifElse(Facing = 1, NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_RIGHT), NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_LEFT))

;And in the very unlikely event you have a move that can be used in both the air and the ground, and that uses the same State for
;both versions, AND you want to use the Capcom's method of handling air commands, use this set of triggers:

;triggerAll = (ifElse(P2dist x < 0 && StateType != A, Facing = -1, Facing = 1) && NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_RIGHT)) || (ifElse(P2dist x < 0  && StateType != A, Facing = 1, Facing = -1) && NumExplod(DIRECTIONAL_COMMAND_WHEN_FACING_LEFT))
;==============================================================================================
;Buttons can be handled a lot more easily; no need for complicated ifElse statements or the like. Just check
;to see whether the appropriate button has been input (or released) using NumExplod. You can check for multiple
;buttons by chaining together NumExplod statements with MUGEN's logical operators.
;==============================================================================================
;BIG LIST OF EXPLOD ID #'s:

;BASIC DIRECTIONAL INPUTS (these are active whenever the specified direction is currently being input, and
;disappear as soon as they are released. They are used by the system to detect directional release, but can
;also be used by you to detect when a specific direction is being input or held down)
;Down:						90000002
;Down-right:					90000003
;Right:						90000006
;Up-right:					90000009
;Up:						90000008
;Up-left:					90000007
;Left:						90000004
;Down-left:					90000001

;BUTTON PRESS
;x:						90000200
;y:						90000210
;z:						90000220
;a:						90000230
;b:						90000240
;c:						90000250
;start:						90000195

;BUTTON RELEASE
;x:						90000205
;y:						90000215
;z:						90000225
;a:						90000235
;b:						90000245
;c:						90000255

;SYSTEM MOTIONS
;R, R:						90001016
;L, L:						90001064
;R, DR, D					90007502
;L, DL, D					90007552


;SPECIAL/SUPER MOTIONS

;R, R:						90001016
;L, L:						90001064
;D, DR, R:					90010006
;D, DL, L:					90010104
;R, D, DR:					90010203
;L, D, DL:					90010301
;L, DL, D, DR, R:				90010406
;R, DR, D, DL, L:				90010504
;(charge) L, R:					90010606
;(charge) R, L:					90010704
;(charge) D, U:					90010808
;360/L, D, R, U:				90011008
;360/L, U, R, D:				90011102
;360/D, R, U, L:				90011204
;360/D, L, U, R:				90011306
;360/R, D, L, U:				90011408
;360/R, U, L, D:				90011502
;360/U, R, D, L:				90011604
;360/U, L, D, R:				90011706
;R, D, L, R:					90012016
;L, D, R, L:					90012114
;R, L, R:					90012216
;L, R, L:					90012314


;D, DR, R, D, DR, R:				90030006
;D, DL, L, D, DL, L:				90030104
;L, DL, D, DR, R, L, DL, D, DR, R:		90030406
;R, DR, D, DL, L, R, DR, D, DL, L:		90030504
;(charge) L, R, L, R:				90030606
;(charge) R, L, R, L:				90030704
;(charge) DL, DR, DL, UR:			90030809
;(charge) DR, DL, DR, UL:			90030907
;720/L, D, R, U, L, D, R, U:			90031008
;720/L, U, R, D, L, U, R, D:			90031102
;720/D, R, U, L, D, R, U, L:			90031204
;720/D, L, U, R, D, L, U, R:			90031306
;720/R, D, L, U, R, D, L, U:			90031408
;720/R, U, L, D, R, U, L, D:			90031502
;720/U, R, D, L, U, R, D, L:			90031604
;720/U, L, D, R, U, L, D, R:			90031706
;R, L, D, R:					90032016
;L, R, D, L:					90032114
;D, DR, R, D, L:				90032204
;D, DL, L, D, R:				90032306
;x, x, F, a, z:					90040220



;==============================================================================================
;ADVANCED SECTION; IN-DEPTH EXPLANATION ABOUT HOW THE SYSTEM WORKS; HOW TO CUSTOMIZE THE SYSTEM;
;HOW TO DELETE UNNEEDED COMMANDS; HOW TO ADD NEW MOVES
;==============================================================================================
;3. How to customize the code block (adjusting remove time [and how charge move command times differ], clearing out commands you don't need). Need to explain "linked commands";
;   commands like QCFx2 that are reliant on another set of commands, the QCF command can't be removed (even if they don't use it) if they want to use QCFx2!
;   List all the linked commands contained in the code block (QCRx2; QCLx2; HCRx2; HCLx2; 720s; QCL, HCR; QCR, HCL)
;==============================================================================================
;this is the start of the advanced section, where pretty much every aspect of the system is explained in detail. the first "block" is the directional detector explods.
;ME: REWRITE BELOW SECTION
;ALSO ME: add notes about how to emulate KOF98. allow the 8 below explod sctrls to create multiple explods, which will allow the player to determine how many ticks
;a direction / button has been input.



;This block of explods flip on when a certain direction is input; they are used as "detectors" to tell the character when that direction has been released.
;These explods are used instead of MUGEN's own inbuilt release direction system (i.e., "rlsdown", "rlsfwd", etc.) because of a serious bug involving the latter;
;see this thread for details: http://mugenguild.com/forum/msg.2324083

;These explods will exist for as long as the direction they represent is held; as soon as that direction is released, a corresponding removeexplod (near the very
;bottom of this file) will remove it.

;For most fighting game special/super moves, the very first directional command is a "release" directional input. For most characters, they'll only need release detectors
;for the four cardinal directions (Up, Down, Left, Right), but you should double check your movelist to see whether you might have a command that starts with a diagonal.
;You'll need the corresponding detector to get that move working!

;==============================================================================================
;===================================<DIRECTIONAL COMMANDS>=====================================
;==============================================================================================
[State -1, Release Down Detector]
type = Explod
;make sure explod doesn't already exist
triggerAll = !NumExplod(90000002)
;check to make sure Helper exists, and that the entity running this code isn't the helper
triggerAll = NumHelper(90000005) && !IsHelper
;explod will be created if down is input
trigger1 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
;no other directions may be input, otherwise it wouldn't be a down input!
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90000002
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Down-Right Detector]
type = Explod
triggerAll = !NumExplod(90000003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger1 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90000003
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Right Detector]
type = Explod
triggerAll = !NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown" && Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90000006
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Up-Right Detector]
type = Explod
triggerAll = !NumExplod(90000009)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger1 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
anim = 1
ID = 90000009
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Up Detector]
type = Explod
triggerAll = !NumExplod(90000008)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
anim = 1
ID = 90000008
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Up-Left Detector]
type = Explod
triggerAll = !NumExplod(90000007)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger1 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
anim = 1
ID = 90000007
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Left Detector]
type = Explod
triggerAll = !NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown" && Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90000004
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release Down-Left Detector]
type = Explod
triggerAll = !NumExplod(90000001)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger1 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90000001
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1



;==============================================================================================
;==========================================<BUTTONS>===========================================
;==============================================================================================

[State -1, Press x]
type = Explod
;if there already exists a "press x" explod, and the player is in hitpausetime, then we don't need another!
trigger1 = !HitPauseTime || !NumExplod(90000200)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "x"
anim = 1
ID = 90000200
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press y]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000210)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "y"
anim = 1
ID = 90000210
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press z]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000220)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "z"
anim = 1
ID = 90000220
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press a]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000230)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "a"
anim = 1
ID = 90000230
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press b]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000240)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "b"
anim = 1
ID = 90000240
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press c]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000250)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "c"
anim = 1
ID = 90000250
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1

[State -1, Press start]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000195)
trigger1 = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "start"
anim = 1
ID = 90000195
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;
;==============================================================================================
[State -1, Release x Detector]
type = Explod
triggerAll = !NumExplod(90000201)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "x" || Helper(90000005), command = "holdx"
anim = 1
ID = 90000201
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release y Detector]
type = Explod
triggerAll = !NumExplod(90000211)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "y" || Helper(90000005), command = "holdy"
anim = 1
ID = 90000211
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release z Detector]
type = Explod
triggerAll = !NumExplod(90000221)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "z" || Helper(90000005), command = "holdz"
anim = 1
ID = 90000221
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release a Detector]
type = Explod
triggerAll = !NumExplod(90000231)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "a" || Helper(90000005), command = "holda"
anim = 1
ID = 90000231
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release b Detector]
type = Explod
triggerAll = !NumExplod(90000241)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "b" || Helper(90000005), command = "holdb"
anim = 1
ID = 90000241
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release c Detector]
type = Explod
triggerAll = !NumExplod(90000251)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "c" || Helper(90000005), command = "holdc"
anim = 1
ID = 90000251
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1

[State -1, Release start Detector]
type = Explod
triggerAll = !NumExplod(90000194)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "start"
anim = 1
ID = 90000194
removeTime = -1
pauseMoveTime = -1
superMoveTime = -1
ignoreHitPause = 1



;==============================================================================================
;Relase button inputs don't persist through hitpause!
;==============================================================================================

[State -1, Release x]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000205)
triggerAll = NumExplod(90000201)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "x" && Helper(90000005), command != "holdx"
anim = 1
ID = 90000205
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release y]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000215)
triggerAll = NumExplod(90000211)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "y" && Helper(90000005), command != "holdy"
anim = 1
ID = 90000215
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release z]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000225)
triggerAll = NumExplod(90000221)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "z" && Helper(90000005), command != "holdz"
anim = 1
ID = 90000225
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release a]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000235)
triggerAll = NumExplod(90000231)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "a" && Helper(90000005), command != "holda"
anim = 1
ID = 90000235
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release b]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000245)
triggerAll = NumExplod(90000241)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "b" && Helper(90000005), command != "holdb"
anim = 1
ID = 90000245
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release c]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000255)
triggerAll = NumExplod(90000251)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "c" && Helper(90000005), command != "holdc"
anim = 1
ID = 90000255
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1

[State -1, Release start]
type = Explod
trigger1 = !HitPauseTime || !NumExplod(90000196)
triggerAll = NumExplod(90000194)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "start" && Helper(90000005), command != "holdstart"
anim = 1
ID = 90000196
removeTime = 3
pauseMoveTime = 3
superMoveTime = 3
ignoreHitPause = 1



;==============================================================================================
;================================<FORWARD, FORWARD/BACK, BACK>=================================
;==============================================================================================

;==============================================================================================
;this is the first commmand block. this is where the vast majority of comments will be; need to explain why commands must be mirrored, and explain all the various compenents of the
;explods (why the timer [and what it means and how long it needs to be], how the first input must be formatted, etc.)

;also mention something about how the first input of a F,F/B,B command in SNK games is a release command


;OLD, REWRITE THIS SHIT
;All commands (unless they are solely performed with Up or Down) must be defined using two versions: one assuming the character is facing the right, and one for the left.
;This is to correct an oversight in MUGEN's command parser. For example, a traditional quarter-circle forward motion will be defined here as two commands: a Down, Down-Right, Right
;motion; and a Down, Down-Left, Left motion. This will allow the user to be able to correctly buffer commands while switching sides.
;==============================================================================================

;=======================================<RIGHT, RIGHT>=========================================
[State -1, R, R: 1st Right]
type = Explod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90001006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, R: Neutral]
type = Explod
triggerAll = NumExplod(90000006) && NumExplod(90001006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown" && Helper(90000005), command != "back" && Helper(90000005), command != "holdback" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90001005
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, Remove R, R: Neutral]
type = RemoveExplod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = NumExplod(90000002) || NumExplod(90000003) || NumExplod(90000009) || NumExplod(90000008) || NumExplod(90000007) || NumExplod(90000004) || NumExplod(90000001)
trigger2 = !NumExplod(90001006)
ID = 90001005
ignoreHitPause = 1

[State -1, R, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90001005) && NumExplod(90001006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90001016
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=======================================<LEFT, LEFT>=========================================
[State -1, L, L: 1st Left]
type = Explod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90001054
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, L: Neutral]
type = Explod
triggerAll = NumExplod(90000004) && NumExplod(90001054)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown" && Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd" && Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
anim = 1
ID = 90001055
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, Remove L, L: Neutral]
type = RemoveExplod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = NumExplod(90000002) || NumExplod(90000003) || NumExplod(90000006) || NumExplod(90000009) || NumExplod(90000008) || NumExplod(90000007) || NumExplod(90000001)
trigger2 = !NumExplod(90001054)
ID = 90001055
ignoreHitPause = 1

[State -1, L, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90001055) && NumExplod(90001054)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90001064
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===================================<DOWN, UP (SUPER JUMP)>====================================
;==============================================================================================

;==============================================================================================
;Super jump commands can be done with any down directional input, followed by any up directional.
;==============================================================================================

;=======================================<RIGHT, RIGHT>=========================================
[State -1, D, U: Down]
type = Explod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" || Helper(90000005), command = "dfwd" || Helper(90000005), command = "dback"
trigger1 = Helper(90000005), command != "up"
anim = 1
ID = 90000402
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, U: Up]
type = Explod
triggerAll = NumExplod(90000402)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" || Helper(90000005), command = "ufwd" || Helper(90000005), command = "uback"
trigger1 = Helper(90000005), command != "down"
anim = 1
ID = 90000408
removeTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 3 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===================================<QUARTER CIRCLE DOWN>======================================
;==============================================================================================

;================================<RIGHT, DOWN-RIGHT, DOWN>=====================================
[State -1, R, DR, D: Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90007506
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D: Down]
type = Explod
triggerAll = NumExplod(90007506)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90007503
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D: Down-Right]
type = Explod
triggerAll = NumExplod(90007503)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "fwd"
anim = 1
ID = 90007502
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<LEFT, DOWN-LEFT, DOWN>======================================
[State -1, L, DL, D: Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90007554
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D: Down]
type = Explod
triggerAll = NumExplod(90007554)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90007551
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D: Down-Left]
type = Explod
triggerAll = NumExplod(90007551)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "fwd"
anim = 1
ID = 90007552
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===============================<QUARTER CIRCLE FORWARD/BACK>==================================
;==============================================================================================

;================================<DOWN, DOWN-RIGHT, RIGHT>=====================================
[State -1, D, DR, R: Down]
type = Explod
;check to see if the Release Down Detector explod exists. If it exists and down is no longer being input, that means it was released!
triggerAll = NumExplod(90000002)
triggerAll = NumHelper(90000005) && !IsHelper
;if down isn't currently being input by the user, then down was released!
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
;... but if down is currently being input by the user, AND there's another direction being input, then down is still considered to have been released.
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R: Down-Right]
type = Explod
;the "Down" explod needs to exist before the next command in sequence is allowed
triggerAll = NumExplod(90010002)
triggerAll = NumHelper(90000005) && !IsHelper
;the helper is facing to the right, so all "fwd" commands are actually "right" inputs
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90010003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R: Right]
type = Explod
triggerAll = NumExplod(90010003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010006
;if this is the last command in sequence, then add this, so the command will stay alive during hitpause. THIS ONLY APPLIES TO THE LAST COMMAND IN SEQUENCE.
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;Now for the reversed command:
;==============================================================================================

;=================================<DOWN, DOWN-LEFT, LEFT>======================================
[State -1, D, DL, L: Down]
type = Explod
triggerAll = NumExplod(90000002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010102
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DL, L: Down-Left]
type = Explod
triggerAll = NumExplod(90010102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90010101
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DL, L: Left]
type = Explod
triggerAll = NumExplod(90010101)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010104
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===========================<DOUBLE QUARTER CIRCLE FORWARD/BACK>===============================
;==============================================================================================

;==============================================================================================
;quick aside about how this command is mostly identical to the QCF command just with a different IDs

;also mention how Capcom games use a shortcut (QCF,D,DF) but also allows QCFx2!!! SNK DOESNT DO THIS!!!
;==============================================================================================

;===========================<DOUBLE DOWN, DOWN-RIGHT, RIGHT>===============================
;must explain why the final command from QCF (R/L) is repeated here (and why the remove Down-Right explod is here too). The hitpause extension on QCF:R/L means you can input QCF during a
;hitpause, wait a long time, then enter in another QCF and complete the command, if these steps weren't taken!
[State -1, D, DR, R, D, DR, R: 1st Right]
type = Explod
triggerAll = NumExplod(90010003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030005
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, D, DR, R: 2nd Down]
type = Explod
triggerAll = NumExplod(90030005)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90030002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, D, DR, R: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90030002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90030003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, D, DR, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90030003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030006
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1


;===========================<DOUBLE DOWN, DOWN-LEFT, LEFT>===============================
[State -1, D, DL, L, D, DL, L: 1st Left]
type = Explod
triggerAll = NumExplod(90010101)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030105
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DL, L, D, DL, L: 2nd Down]
type = Explod
triggerAll = NumExplod(90030105)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90030102
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DL, L, D, DL, L: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90030102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90030101
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DL, L, D, DL, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90030101)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030104
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;=====<QUARTER CIRCLE FORWARD, HALF CIRCLE BACK/QUARTER CIRCLE BACK, HALF CIRCLE FORWARD>======
;==============================================================================================

;===============<DOWN, DOWN-RIGHT, RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, LEFT>===================
[State -1, D, DR, R, DR, D, DL, L: Right]
type = Explod
triggerAll = NumExplod(90010003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032206
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, DR, D, DL, L: Down-Right]
type = Explod
triggerAll = NumExplod(90032206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90032203
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, DR, D, DL, L: Down]
type = Explod
triggerAll = NumExplod(90032203) || NumExplod(90032206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90032202
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, DR, D, DL, L: Down-Left]
type = Explod
triggerAll = NumExplod(90032202)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90032201
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, D, DR, R, DR, D, DL, L: Left]
type = Explod
triggerAll = NumExplod(90032201) || NumExplod(90032202)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032204
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;================<DOWN, DOWN-LEFT, LEFT, DOWN-LEFT, DOWN, DOWN-RIGHT, RIGHT>===================
[State -1, R, DR, D, DL, L: Left]
type = Explod
triggerAll = NumExplod(90010101)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032304
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down-Left]
type = Explod
triggerAll = NumExplod(90032304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90032301
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down]
type = Explod
triggerAll = NumExplod(90032301) || NumExplod(90032304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90032302
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down-Right]
type = Explod
triggerAll = NumExplod(90032302)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90032303
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Right]
type = Explod
triggerAll = NumExplod(90032303) || NumExplod(90032302)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032306
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;====================<FORWARD, DOWN, DOWN-FORWARD/BACK, DOWN, DOWN-BACK>=======================
;==============================================================================================

;================================<RIGHT, DOWN, DOWN-RIGHT>=====================================
[State -1, R, D, DR: Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010206
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, D, DR: Down]
type = Explod
triggerAll = NumExplod(90010206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "fwd"
anim = 1
ID = 90010202
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, D, DR: Down-Right]
type = Explod
triggerAll = NumExplod(90010202)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90010203
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<LEFT, DOWN, DOWN-LEFT>======================================
[State -1, L, D, DL: Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010304
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, D, DL: Down]
type = Explod
triggerAll = NumExplod(90010304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "fwd"
anim = 1
ID = 90010302
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, D, DL: Down-Left]
type = Explod
triggerAll = NumExplod(90010302)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90010301
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;=================================<HALF CIRCLE FORWARD/BACK>===================================
;==============================================================================================

;==============================================================================================
;talk about how SNK games often have command shortcuts (F,D,B, etc)
;==============================================================================================

;========================<LEFT, DOWN-LEFT, DOWN, DOWN-RIGHT, RIGHT>============================
[State -1, L, DL, D, DR, R: Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010404
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R: Down-Left]
type = Explod
triggerAll = NumExplod(90010404)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90010401
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R: Down]
type = Explod
triggerAll = NumExplod(90010401)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90010402
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R: Down-Right]
type = Explod
triggerAll = NumExplod(90010402)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90010403
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R: Right]
type = Explod
triggerAll = NumExplod(90010403)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010406
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;========================<RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, LEFT>============================
[State -1, R, DR, D, DL, L: Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90010506
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down-Right]
type = Explod
triggerAll = NumExplod(90010506)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90010503
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down]
type = Explod
triggerAll = NumExplod(90010503)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90010502
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Down-Left]
type = Explod
triggerAll = NumExplod(90010502)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90010501
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L: Left]
type = Explod
triggerAll = NumExplod(90010501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010504
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;==============================<DOUBLE HALF CIRCLE FORWARD/BACK>===============================
;==============================================================================================

;=====================<DOUBLE LEFT, DOWN-LEFT, DOWN, DOWN-RIGHT, RIGHT>========================
[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 1st Right]
type = Explod
triggerAll = NumExplod(90010403)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030405
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 2nd Left]
type = Explod
triggerAll = NumExplod(90030405)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030404
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90030404)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90030401
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 2nd Down]
type = Explod
triggerAll = NumExplod(90030401)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90030402
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90030402)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90030403
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L, DL, D, DR, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90030403)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030406
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;========================<DOUBLE RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, LEFT>============================
[State -1, R, DR, D, DL, L, R, DR, D, DL, L: Left]
type = Explod
triggerAll = NumExplod(90010501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030505
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R, DR, D, DL, L: 2nd Right]
type = Explod
triggerAll = NumExplod(90030505)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030506
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R, DR, D, DL, L: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90030506)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90030503
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R, DR, D, DL, L: 2nd Down]
type = Explod
triggerAll = NumExplod(90030503)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90030502
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R, DR, D, DL, L: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90030502)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90030501
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R, DR, D, DL, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90030501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030504
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;=================================<CHARGE BACK, FORWARD>===================================
;==============================================================================================

;==============================================================================================
;need to explain the two different methods of charging (Capcom and SNK), and how they work. Remember to remind user to check to make sure the variables are free!!!

;SNK style charge moves charges based on the input (left/right), regardless of direction character is currently facing. Capcom style charge moves "reset"
;whenever the player changes directions. Additionally, SNK style charge commands allow charging during hitpause; SFA does not allow this.
;==============================================================================================

;=================================<(SNK) CHARGE LEFT, RIGHT>===================================
;[State -1, Left Charge Increment]
;type = VarAdd
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = !AILevel
;trigger1 = Helper(90000005), command = "holdback"
;trigger2 = AILevel
;var(47) = 1
;ignoreHitPause = 1

;[State -1, Left Charge Reset]
;type = VarSet
;triggerAll = var(47) > 0
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = !AILevel
;trigger1 = Helper(90000005), command != "holdback"
;trigger2 = AILevel
;trigger2 = StateNo = 0 || (StateNo = 20 && vel x > 0) || (StateNo = [760,762])
;trigger3 = AILevel
;trigger3 = (StateNo = 40 && sysvar(1) != -1)
;trigger4 = AILevel
;trigger4 = (StateNo = [1000, 4999]) && Time = 1
;var(47) = 0
;ignoreHitPause = 1



;=================================<(SNK) CHARGE RIGHT, LEFT>===================================
;[State -1, Right Charge Increment]
;type = VarAdd
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = !AILevel
;trigger1 = Helper(90000005), command = "holdfwd"
;trigger2 = AILevel
;var(47) = -1
;ignoreHitPause = 1

;[State -1, Right Charge Reset]
;type = VarSet
;triggerAll = var(47) < 0
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = !AILevel
;trigger1 = Helper(90000005), command != "holdfwd"
;trigger2 = AILevel
;trigger2 = StateNo = 0 || (StateNo = 20 && vel x > 0) || (StateNo = [760,762])
;trigger3 = AILevel
;trigger3 = (StateNo = 40 && sysvar(1) != -1)
;trigger4 = AILevel
;trigger4 = (StateNo = [1000, 4999]) && Time = 1
;var(47) = 0
;ignoreHitPause = 1

;[State -1, Left/Right Charge Buffer Activation]
;type = VarSet
;trigger1 = abs(var(47)) >= 45
;var(48) = 10

;[State -1, Left/Right Charge Buffer Decrement]
;type = VarAdd
;trigger1 = abs(var(47)) < 45 && var(48) > 0
;var(48) = -1

;[State -1, Charge Left, Right: Right]
;type = Explod
;triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
;anim = 1
;ID = 90010606
;removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;ignoreHitPause = 1

;[State -1, Charge Right, Left: Left]
;type = Explod
;triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
;triggerAll = NumHelper(90000005) && !IsHelper
;trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
;anim = 1
;ID = 90010704
;removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
;ignoreHitPause = 1



;===============================<(CAPCOM) CHARGE BACK, FORWARD>================================
[State -1, Back Charge Increment]
type = VarAdd
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = !AILevel
trigger1 = ifElse(P2dist x < 0 && StateType = A, Facing = -1, Facing = 1) && Helper(90000005), command = "holdback"
trigger2 = !AILevel
trigger2 = ifElse(P2dist x < 0 && StateType = A, Facing = 1, Facing = -1) && Helper(90000005), command = "holdfwd"
trigger3 = AILevel
var(47) = 1

[State -1, Back Charge Reset]
type = VarSet
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = !AILevel
trigger1 = ifElse(P2dist x < 0 && StateType = A, Facing = -1, Facing = 1) && Helper(90000005), command != "holdback"
trigger2 = !AILevel
trigger2 = ifElse(P2dist x < 0 && StateType = A, Facing = 1, Facing = -1) && Helper(90000005), command != "holdfwd"
trigger3 = AILevel
trigger3 = StateNo = 0 || (StateNo = 20 && vel x > 0) || (StateNo = [760,762])
trigger4 = AILevel
trigger4 = (StateNo = 40 && sysvar(1) != -1)
trigger5 = AILevel
trigger5 = (StateNo = [1000, 4999]) && Time = 1
var(47) = 0

[State -1, Back Charge Buffer Activation]
type = VarSet
trigger1 = var(47) >= 60
var(48) = 16

[State -1, Back Charge Buffer Decrement]
type = VarAdd
trigger1 = var(47) < 60 && var(48) > 0
var(48) = -1



;==============================================================================================
;gotta explain the different way explod timers work with these charge commands!
;==============================================================================================

;=====================================<CHARGE RIGHT, LEFT>=====================================
[State -1, Charge Left, Right: Right]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010606
removeTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=====================================<CHARGE LEFT, RIGHT>=====================================
[State -1, Charge Right, Left: Left]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90010704
removeTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;============================<CHARGE BACK, FORWARD, BACK, FORWARD>=============================
;==============================================================================================

;==============================================================================================
;explain the gist of things
;==============================================================================================

;==============================<CHARGE LEFT, RIGHT, LEFT, RIGHT>===============================

[State -1, Charge Left, Right, Left, Right: 1st Right]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030605
removeTime = var(48)
pauseMoveTime = var(48)
superMoveTime = var(48)
ignoreHitPause = 1

[State -1, Charge Left, Right, Left, Right: 2nd Left]
type = Explod
triggerAll = NumExplod(90030605)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030604
removeTime = var(48)
pauseMoveTime = var(48)
superMoveTime = var(48)
ignoreHitPause = 1

[State -1, Charge Left, Right, Left, Right: 2nd Right]
type = Explod
triggerAll = NumExplod(90030604)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030606
removeTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================<CHARGE RIGHT, LEFT, RIGHT, LEFT>===============================
[State -1, Charge Right, Left, Right, Left: 1st Left]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030705
removeTime = var(48)
pauseMoveTime = var(48)
superMoveTime = var(48)
ignoreHitPause = 1

[State -1, Charge Right, Left, Right, Left: 2nd Right]
type = Explod
triggerAll = NumExplod(90030705)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030706
removeTime = var(48)
pauseMoveTime = var(48)
superMoveTime = var(48)
ignoreHitPause = 1

[State -1, Charge Right, Left, Right, Left: 2nd Left]
type = Explod
triggerAll = NumExplod(90030706)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90030704
removeTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(48) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;======================================<CHARGE DOWN, UP>=======================================
;==============================================================================================

;==============================================================================================
;quick note about how much easier this is cuz no reversing directions i guess
;==============================================================================================

[State -1, Down Charge Increment]
type = VarAdd
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = !AIlevel
trigger1 = Helper(90000005), command = "holddown"
trigger2 = AIlevel
var(49) = 1

[State -1, Down Charge Reset]
type = VarSet
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = !AILevel
trigger1 = Helper(90000005), command != "holddown"
trigger3 = AILevel
trigger3 = StateNo = 0 || StateNo = 20 || (StateNo = 40 && Time = 1) || StateNo = 760
trigger4 = AILevel
trigger4 = (StateNo = [1000,4999]) && Time = 1
trigger5 = AILevel
trigger5 = (StateNo = [120,155]) && StateType != C
var(49) = 0

[State -1, Down Charge Buffer Activation]
type = VarSet
trigger1 = var(49) >= 60
var(50) = 16

[State -1, Down Charge Buffer Decrement]
type = VarAdd
trigger1 = var(49) < 60 && var(50) > 0
var(50) = -1

[State -1, Charge Down, Up: Up]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(50) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90010808
removeTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===================<CHARGE DOWN-BACK, DOWN-FORWARD, DOWN-BACK, UP-FORWARD>====================
;==============================================================================================

;=====================<CHARGE DOWN-LEFT, DOWN-RIGHT, DOWN-LEFT, UP-RIGHT>======================
[State -1, Charge Down-Left, Down-Right, Down-Left, Up-Right: Down-Right]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0 && var(50) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90030803
removeTime = var(50)
pauseMoveTime = var(50)
superMoveTime = var(50)
ignoreHitPause = 1

[State -1, Charge Down-Left, Down-Right, Down-Left, Up-Right: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90030803)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90030801
removeTime = var(50)
pauseMoveTime = var(50)
superMoveTime = var(50)
ignoreHitPause = 1

[State -1, Charge Down-Left, Down-Right, Down-Left, Up-Right: Up-Right]
type = Explod
triggerAll = NumExplod(90030801)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90030809
removeTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=====================<CHARGE DOWN-RIGHT, DOWN-LEFT, DOWN-RIGHT, UP-LEFT>======================
[State -1, Charge Down-Right, Down-Left, Down-Right, Up-Left: Down-Left]
type = Explod
triggerAll = ifElse(var(20) > 0 || (StateNo = [1000, 4999]), 1, var(48) > 0 && var(50) > 0)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90030901
removeTime = var(50)
pauseMoveTime = var(50)
superMoveTime = var(50)
ignoreHitPause = 1

[State -1, Charge Down-Right, Down-Left, Down-Right, Up-Left: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90030901)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90030903
removeTime = var(50)
pauseMoveTime = var(50)
superMoveTime = var(50)
ignoreHitPause = 1

[State -1, Charge Down-Right, Down-Left, Down-Right, Up-Left: Up-Left]
type = Explod
triggerAll = NumExplod(90030903)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90030907
removeTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = var(50) + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===========================================<360>==============================================
;==============================================================================================

;==============================================================================================
;quickly explain that most characters dont need this and to feel free to delete it if your char doesnt have any 360 moves.
;==============================================================================================

;=================================<360/LEFT, DOWN, RIGHT, UP>==================================
[State -1, 360/L, D, R, U: Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011004
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Down-Left]
type = Explod
triggerAll = NumExplod(90011004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011001
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Down]
type = Explod
triggerAll = NumExplod(90011001) || NumExplod(90011004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Down-Right]
type = Explod
triggerAll = NumExplod(90011002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Right]
type = Explod
triggerAll = NumExplod(90011003) || NumExplod(90011002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Up-Right]
type = Explod
triggerAll = NumExplod(90011006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011009
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, D, R, U: Up]
type = Explod
triggerAll = NumExplod(90011006) || NumExplod(90011009)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011008
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/LEFT, UP, RIGHT, DOWN>==================================
[State -1, 360/L, U, R, D: Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011104
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Up-Left]
type = Explod
triggerAll = NumExplod(90011104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011107
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Up]
type = Explod
triggerAll = NumExplod(90011107) || NumExplod(90011104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011108
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Up-Right]
type = Explod
triggerAll = NumExplod(90011108)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011109
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Right]
type = Explod
triggerAll = NumExplod(90011108) || NumExplod(90011109)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011106
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Down-Right]
type = Explod
triggerAll = NumExplod(90011106)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011103
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/L, U, R, D: Down]
type = Explod
triggerAll = NumExplod(90011106) || NumExplod(90011103)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011102
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/DOWN, RIGHT, UP, LEFT>==================================
[State -1, 360/D, R, U, L: Down]
type = Explod
triggerAll = NumExplod(90000002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011202
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Down-Right]
type = Explod
triggerAll = NumExplod(90011202)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011203
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Right]
type = Explod
triggerAll = NumExplod(90011202) || NumExplod(90011203)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011206
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Up-Right]
type = Explod
triggerAll = NumExplod(90011206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011209
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Up]
type = Explod
triggerAll = NumExplod(90011206) || NumExplod(90011209)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011208
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Up-Left]
type = Explod
triggerAll = NumExplod(90011208)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011207
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, R, U, L: Left]
type = Explod
triggerAll = NumExplod(90011208) || NumExplod(90011207)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011204
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/DOWN, LEFT, UP, RIGHT>==================================
[State -1, 360/D, L, U, R: Down]
type = Explod
triggerAll = NumExplod(90000002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011302
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Down-Left]
type = Explod
triggerAll = NumExplod(90011302)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011301
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Left]
type = Explod
triggerAll = NumExplod(90011302) || NumExplod(90011301)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011304
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Up-Left]
type = Explod
triggerAll = NumExplod(90011304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011307
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Up]
type = Explod
triggerAll = NumExplod(90011304) || NumExplod(90011307)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011308
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Up-Right]
type = Explod
triggerAll = NumExplod(90011308)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011309
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/D, L, U, R: Right]
type = Explod
triggerAll = NumExplod(90011308) || NumExplod(90011309)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011306
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/RIGHT, DOWN, LEFT, UP>==================================
[State -1, 360/R, D, L, U: Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011406
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Down-Right]
type = Explod
triggerAll = NumExplod(90011406)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011403
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Down]
type = Explod
triggerAll = NumExplod(90011406) || NumExplod(90011403)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011402
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Down-Left]
type = Explod
triggerAll = NumExplod(90011402)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011401
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Left]
type = Explod
triggerAll = NumExplod(90011402) || NumExplod(90011401)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011404
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Up-Left]
type = Explod
triggerAll = NumExplod(90011404)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011407
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, D, L, U: Up]
type = Explod
triggerAll = NumExplod(90011404) || NumExplod(90011407)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011408
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/RIGHT, UP, LEFT, DOWN>==================================
 [State -1, 360/R, U, L, D: Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90011506
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Up-Right]
type = Explod
triggerAll = NumExplod(90011506)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011509
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Up]
type = Explod
triggerAll = NumExplod(90011506) || NumExplod(90011509)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90011508
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Up-Left]
type = Explod
triggerAll = NumExplod(90011508)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011507
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Left]
type = Explod
triggerAll = NumExplod(90011508) || NumExplod(90011507)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011504
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Down-Left]
type = Explod
triggerAll = NumExplod(90011504)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011501
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/R, U, L, D: Down]
type = Explod
triggerAll = NumExplod(90011504) || NumExplod(90011501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011502
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/UP, RIGHT, DOWN, LEFT>==================================
[State -1, 360/U, R, D, L: Up]
type = Explod
triggerAll = NumExplod(90000008)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
trigger2 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
anim = 1
ID = 90011608
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Up-Right]
type = Explod
triggerAll = NumExplod(90011608)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90011609
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Right]
type = Explod
triggerAll = NumExplod(90011608) || NumExplod(90011609)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011606
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Down-Right]
type = Explod
triggerAll = NumExplod(90011606)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011603
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Down]
type = Explod
triggerAll = NumExplod(90011606) || NumExplod(90011603)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011602
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Down-Left]
type = Explod
triggerAll = NumExplod(90011602)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011601
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, R, D, L: Left]
type = Explod
triggerAll = NumExplod(90011602) || NumExplod(90011601)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011604
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/UP, LEFT, DOWN, RIGHT>==================================
[State -1, 360/U, L, D, R: Up]
type = Explod
triggerAll = NumExplod(90000008)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
trigger2 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
anim = 1
ID = 90011708
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, L, D, R: Up-Left]
type = Explod
triggerAll = NumExplod(90011708)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90011707
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, L, D, R: Left]
type = Explod
triggerAll = NumExplod(90011708) || NumExplod(90011707)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011704
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, L, D, R: Down-Left]
type = Explod
triggerAll = NumExplod(90011704)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90011701
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1


[State -1, 360/U, L, D, R: Down]
type = Explod
triggerAll = NumExplod(90011704) || NumExplod(90011701)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90011702
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, L, D, R: Down-Right]
type = Explod
triggerAll = NumExplod(90011702)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90011703
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 360/U, L, D, R: Right]
type = Explod
triggerAll = NumExplod(90011702) || NumExplod(90011703)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90011706
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===========================================<720>==============================================
;==============================================================================================

;======================<720/LEFT, DOWN, RIGHT, UP, LEFT, DOWN, RIGHT, UP>======================
[State -1, 720/L, D, R, U, L, D, R, U: 1st Up]
type = Explod
triggerAll = NumExplod(90011006) || NumExplod(90011009)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031005
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: Up-Left]
type = Explod
triggerAll = NumExplod(90031005)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031007
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Left]
type = Explod
triggerAll = NumExplod(90031005) || NumExplod(90031007)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031004
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031001
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Down]
type = Explod
triggerAll = NumExplod(90031001) || NumExplod(90031004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Right]
type = Explod
triggerAll = NumExplod(90031003) || NumExplod(90031002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031009
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: 2nd Up]
type = Explod
triggerAll = NumExplod(90031006) || NumExplod(90031009)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031008
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=====================<720/LEFT, UP, RIGHT, DOWN, LEFT, UP, RIGHT, DOWN>=======================
[State -1, 720/L, U, R, D, L, U, R, D: 1st Down]
type = Explod
triggerAll = NumExplod(90011106) || NumExplod(90011103)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031105
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: Down-Left]
type = Explod
triggerAll = NumExplod(90031105)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031101
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Left]
type = Explod
triggerAll = NumExplod(90031105) || NumExplod(90031101)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031104
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031107
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Up]
type = Explod
triggerAll = NumExplod(90031107) || NumExplod(90031104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031108
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031108)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031109
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Right]
type = Explod
triggerAll = NumExplod(90031108) || NumExplod(90031109)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031106
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031106)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031103
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, U, R, D, L, U, R, D: 2nd Down]
type = Explod
triggerAll = NumExplod(90031106) || NumExplod(90031103)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031102
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;======================<720/DOWN, RIGHT, UP, LEFT, DOWN, RIGHT, UP, LEFT>======================
[State -1, 720/D, R, U, L, D, R, U, L: 1st Left]
type = Explod
triggerAll = NumExplod(90011208) || NumExplod(90011207)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031205
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/L, D, R, U, L, D, R, U: Down-Left]
type = Explod
triggerAll = NumExplod(90031205)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031201
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Down]
type = Explod
triggerAll = NumExplod(90031205) || NumExplod(90031201)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031202
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031202)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031203
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Right]
type = Explod
triggerAll = NumExplod(90031202) || NumExplod(90031203)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031206
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031209
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Up]
type = Explod
triggerAll = NumExplod(90031206) || NumExplod(90031209)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031208
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031208)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031207
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, R, U, L, D, R, U, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90031208) || NumExplod(90031207)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031204
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<360/DOWN, LEFT, UP, RIGHT>==================================
[State -1, 720/D, L, U, R, D, L, U, R: 1st Right]
type = Explod
triggerAll = NumExplod(90011308) || NumExplod(90011309)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031305
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: Down-Right]
type = Explod
triggerAll = NumExplod(90031305)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031303
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Down]
type = Explod
triggerAll = NumExplod(90031305) || NumExplod(90031303)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031302
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031302)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031301
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Left]
type = Explod
triggerAll = NumExplod(90031302) || NumExplod(90031301)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031304
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031307
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Up]
type = Explod
triggerAll = NumExplod(90031304) || NumExplod(90031307)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031308
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031308)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031309
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/D, L, U, R, D, L, U, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90031308) || NumExplod(90031309)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031306
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;======================<720/RIGHT, DOWN, LEFT, UP, RIGHT, DOWN, LEFT, UP>======================
[State -1, 720/R, D, L, U, R, D, L, U: 1st Up]
type = Explod
triggerAll = NumExplod(90011404) || NumExplod(90011407)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031405
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: Up-Right]
type = Explod
triggerAll = NumExplod(90031405)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031409
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Right]
type = Explod
triggerAll = NumExplod(90031405) || NumExplod(90031409)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031406
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031406)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031403
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Down]
type = Explod
triggerAll = NumExplod(90031406) || NumExplod(90031403)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031402
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031402)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031401
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Left]
type = Explod
triggerAll = NumExplod(90031402) || NumExplod(90031401)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031404
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031404)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031407
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: 2nd Up]
type = Explod
triggerAll = NumExplod(90031404) || NumExplod(90031407)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031408
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;======================<720/RIGHT, UP, LEFT, DOWN, RIGHT, UP, LEFT, DOWN>======================
[State -1, 720/R, U, L, D, R, U, L, D: 1st Down]
type = Explod
triggerAll = NumExplod(90011504) || NumExplod(90011501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031505
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, D, L, U, R, D, L, U: Down-Right]
type = Explod
triggerAll = NumExplod(90031505)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031503
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Right]
type = Explod
triggerAll = NumExplod(90031505) || NumExplod(90031503)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031506
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031506)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031509
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Up]
type = Explod
triggerAll = NumExplod(90031506) || NumExplod(90031509)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031508
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031508)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031507
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Left]
type = Explod
triggerAll = NumExplod(90031508) || NumExplod(90031507)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031504
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031504)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031501
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/R, U, L, D, R, U, L, D: 2nd Down]
type = Explod
triggerAll = NumExplod(90031504) || NumExplod(90031501)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031502
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;======================<720/UP, RIGHT, DOWN, LEFT, UP, RIGHT, DOWN, LEFT>======================
[State -1, 720/U, R, D, L, U, R, D, L: 1st Left]
type = Explod
triggerAll = NumExplod(90011602) || NumExplod(90011601)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031605
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: Up-Left]
type = Explod
triggerAll = NumExplod(90031605)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031607
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Up]
type = Explod
triggerAll = NumExplod(90031605) || NumExplod(90031607)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031608
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Up-Right]
type = Explod
triggerAll = NumExplod(90031608)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031609
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Right]
type = Explod
triggerAll = NumExplod(90031608) || NumExplod(90031609)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031606
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031606)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031603
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Down]
type = Explod
triggerAll = NumExplod(90031606) || NumExplod(90031603)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031602
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031602)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031601
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, R, D, L, U, R, D, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90031602) || NumExplod(90031601)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031604
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=================================<720/UP, LEFT, DOWN, RIGHT>==================================
[State -1, 720/U, L, D, R, U, L, D, R: 1st Right]
type = Explod
triggerAll = NumExplod(90011702) || NumExplod(90011703)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031705
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: Up-Right]
type = Explod
triggerAll = NumExplod(90031705)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "ufwd" && Helper(90000005), command != "back" && Helper(90000005), command != "down"
anim = 1
ID = 90031709
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Up]
type = Explod
triggerAll = NumExplod(90031705) || NumExplod(90031709)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "up" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down" && Helper(90000005), command != "back"
anim = 1
ID = 90031708
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Up-Left]
type = Explod
triggerAll = NumExplod(90031708)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "uback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "down"
anim = 1
ID = 90031707
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Left]
type = Explod
triggerAll = NumExplod(90031708) || NumExplod(90031707)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031704
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Down-Left]
type = Explod
triggerAll = NumExplod(90031704)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90031701
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Down]
type = Explod
triggerAll = NumExplod(90031704) || NumExplod(90031701)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90031702
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Down-Right]
type = Explod
triggerAll = NumExplod(90031702)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90031703
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, 720/U, L, D, R, U, L, D, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90031702) || NumExplod(90031703)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90031706
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===================<HALF CIRCLE FORWARD, BACK/HALF CIRCLE BACK, FORWARD>======================
;==============================================================================================

;==============================================================================================
;this command uses SNK-style command shortcuts; you can skip the diagonal inputs and still
;complete the move. But diagonal inputs aren't ignored entirely; if the player does use a diagonal
;input, it will keep the command "alive", in the same way that a non-diagonal input would.
;==============================================================================================

;====================<RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, LEFT, RIGHT>=========================
[State -1, R, DR, D, DL, L, R: 1st Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90012006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R: Down-Right]
type = Explod
triggerAll = NumExplod(90012006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90012003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R: Down]
type = Explod
triggerAll = NumExplod(90012003) || NumExplod(90012006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90012002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R: Down-Left]
type = Explod
triggerAll = NumExplod(90012002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90012001
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R: Left]
type = Explod
triggerAll = NumExplod(90012001) || NumExplod(90012002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012004
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, DR, D, DL, L, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90012004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012016
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;=====================<LEFT, DOWN-LEFT, DOWN, DOWN-RIGHT, RIGHT, LEFT>=========================
[State -1, L, DL, D, DR, R, L: 1st Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90012104
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L: Down-Left]
type = Explod
triggerAll = NumExplod(90012104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90012101
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L: Down]
type = Explod
triggerAll = NumExplod(90012101) || NumExplod(90012104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90012102
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L: Down-Right]
type = Explod
triggerAll = NumExplod(90012102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90012103
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L: Right]
type = Explod
triggerAll = NumExplod(90012103) || NumExplod(90012102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012106
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, DL, D, DR, R, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90012106)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012114
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;========================<FORWARD, BACK, FORWARD/BACK, FORWARD, BACK>==========================
;==============================================================================================

;====================================<RIGHT, LEFT, RIGHT>======================================
[State -1, R, L, R: 1st Right]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90012206
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, R: Left]
type = Explod
triggerAll = NumExplod(90012206)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012204
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90012204)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012216
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;====================================<LEFT, RIGHT, LEFT>=======================================
[State -1, L, R, L: 1st Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90012304
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, L: Right]
type = Explod
triggerAll = NumExplod(90012304)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012306
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, L: 2nd Left]
type = Explod
triggerAll = NumExplod(90012306)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90012314
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===================<FORWARD, HALF CIRCLE FORWARD/BACK, HALF CIRCLE BACK>======================
;==============================================================================================
;=====================<RIGHT, LEFT, DOWN-LEFT, DOWN, DOWN-RIGHT, RIGHT>========================
[State -1, R, L, DL, D, DR, R: 1st Left]
type = Explod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90032006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, DL, D, DR, R: Left]
type = Explod
triggerAll = NumExplod(90032006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032004
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, DL, D, DR, R: Down-Left]
type = Explod
triggerAll = NumExplod(90032004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90032001
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, DL, D, DR, R: Down]
type = Explod
triggerAll = NumExplod(90032001) || NumExplod(90032004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90032002
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, DL, D, DR, R: Down-Right]
type = Explod
triggerAll = NumExplod(90032002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90032003
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, R, L, DL, D, DR, R: 2nd Right]
type = Explod
triggerAll = NumExplod(90032003) || NumExplod(90032002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032016
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==================<LEFT, RIGHT, DOWN-RIGHT, DOWN, DOWN-LEFT, LEFT>======================
[State -1, L, DL, D, DR, R, L: 1st Left]
type = Explod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
anim = 1
ID = 90032104
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1


[State -1, L, R, DR, D, DL, L, R: Right]
type = Explod
triggerAll = NumExplod(90032104)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032106
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, DR, D, DL, L, R: Down-Right]
type = Explod
triggerAll = NumExplod(90032106)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dfwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up"
anim = 1
ID = 90032103
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, DR, D, DL, L, R: Down]
type = Explod
triggerAll = NumExplod(90032103) || NumExplod(90032106)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "down" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "back"
anim = 1
ID = 90032102
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, DR, D, DL, L, R: Down-Left]
type = Explod
triggerAll = NumExplod(90032102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "dback" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up"
anim = 1
ID = 90032101
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, L, R, DR, D, DL, L, R: 2nd Left]
type = Explod
triggerAll = NumExplod(90032101) || NumExplod(90032102)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90032114
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1



;==============================================================================================
;===========================<SHUN GOKU SATSU/x, x, FORWARD, a, z>==============================
;==============================================================================================
;this goes above the first x explod because otherwise a single press of x would activate both explods!
[State -1, x, x, F, a, z: 2nd x]
type = Explod
triggerAll = NumExplod(90040200)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "x"
anim = 1
ID = 90040205
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, x, x, F, a, z: 1st x]
type = Explod
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "x"
anim = 1
ID = 90040200
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

;this is done using traditional Capcom style rules; i.e., if you jump over an opponent while inputting this command
;"forward" won't have flipped directions until you land. Remove the "StateType != A" to have it work like SNK/SFIII.
[State -1, x, x, F, a, z: Forward]
type = Explod
triggerAll = NumExplod(90040205)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = ifElse(P2dist x < 0 && StateType != A, Facing = -1, Facing = 1)
trigger1 = Helper(90000005), command = "fwd" && Helper(90000005), command != "back" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
trigger2 = ifElse(P2dist x < 0 && StateType != A, Facing = 1, Facing = -1)
trigger2 = Helper(90000005), command = "back" && Helper(90000005), command != "fwd" && Helper(90000005), command != "up" && Helper(90000005), command != "down"
anim = 1
ID = 90040006
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, x, x, F, a, z: a]
type = Explod
triggerAll = NumExplod(90040006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "a"
anim = 1
ID = 90040230
removeTime = 10
pauseMoveTime = 10
superMoveTime = 10
ignoreHitPause = 1

[State -1, x, x, F, a, z: z]
type = Explod
triggerAll = NumExplod(90040230)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command = "z"
anim = 1
ID = 90040220
removeTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
pauseMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
superMoveTime = 10 + ifElse(HitPauseTime, HitPauseTime - 1, 0)
ignoreHitPause = 1



;==============================================================================================
;===============================<REMOVE DIRECTIONAL DETECTORS>=================================
;==============================================================================================

;==============================================================================================
;this just needs a quick reminder about the detectors (should have already explained that there's a block of code at the very end of the system that removes them
;==============================================================================================
;---------------------------------------------------
;This block of RemoveExplods gets rid of any active release detector explods; if the specific direction isn't currently being input, or if the direction is being input but
;other directions are also being input, then the detector explod is removed.
;---------------------------------------------------

[State -1, Remove Down Detector]
type = RemoveExplod
triggerAll = NumExplod(90000002)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "down" && Helper(90000005), command != "holddown"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
id = 90000002
ignoreHitPause = 1

[State -1, Remove Down-Right Detector]
type = RemoveExplod
triggerAll = NumExplod(90000003)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = (Helper(90000005), command != "down" && Helper(90000005), command != "holddown") || (Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd")
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
id = 90000003
ignoreHitPause = 1

[State -1, Remove Right Detector]
type = RemoveExplod
triggerAll = NumExplod(90000006)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
id = 90000006
ignoreHitPause = 1

[State -1, Remove Up-Right Detector]
type = RemoveExplod
triggerAll = NumExplod(90000009)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = (Helper(90000005), command != "up" && Helper(90000005), command != "holdup") || (Helper(90000005), command != "fwd" && Helper(90000005), command != "holdfwd")
trigger2 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
id = 90000009
ignoreHitPause = 1

[State -1, Remove Up Detector]
type = RemoveExplod
triggerAll = NumExplod(90000008)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "up" && Helper(90000005), command != "holdup"
trigger2 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "back" || Helper(90000005), command = "holdback" || Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
id = 90000008
ignoreHitPause = 1

[State -1, Remove Up-Left Detector]
type = RemoveExplod
triggerAll = NumExplod(90000007)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = (Helper(90000005), command != "up" && Helper(90000005), command != "holdup") || (Helper(90000005), command != "back" && Helper(90000005), command != "holdback")
trigger2 = Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
id = 90000007
ignoreHitPause = 1

[State -1, Remove Left Detector]
type = RemoveExplod
triggerAll = NumExplod(90000004)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "back" && Helper(90000005), command != "holdback"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown" || Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
id = 90000004
ignoreHitPause = 1

[State -1, Remove Down-Left Detector]
type = RemoveExplod
triggerAll = NumExplod(90000001)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = (Helper(90000005), command != "down" && Helper(90000005), command != "holddown") || (Helper(90000005), command != "back" && Helper(90000005), command != "holdback")
trigger2 = Helper(90000005), command = "down" || Helper(90000005), command = "holddown"
trigger2 = Helper(90000005), command = "back" || Helper(90000005), command = "holdback"
trigger2 = Helper(90000005), command = "fwd" || Helper(90000005), command = "holdfwd" || Helper(90000005), command = "up" || Helper(90000005), command = "holdup"
id = 90000001
ignoreHitPause = 1



;==============================================================================================
;==============================<REMOVE RELEASE BUTTON DETECTORS>===============================
;==============================================================================================
[State -1, Remove x Detector]
type = RemoveExplod
triggerAll = NumExplod(90000201)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "x" && Helper(90000005), command != "holdx"
ID = 90000201
ignoreHitPause = 1

[State -1, Remove y Detector]
type = RemoveExplod
triggerAll = NumExplod(90000211)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "y" && Helper(90000005), command != "holdy"
ID = 90000211
ignoreHitPause = 1

[State -1, Remove z Detector]
type = RemoveExplod
triggerAll = NumExplod(90000221)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "z" && Helper(90000005), command != "holdz"
ID = 90000221
ignoreHitPause = 1

[State -1, Remove a Detector]
type = RemoveExplod
triggerAll = NumExplod(90000231)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "a" && Helper(90000005), command != "holda"
ID = 90000231
ignoreHitPause = 1

[State -1, Remove b Detector]
type = RemoveExplod
triggerAll = NumExplod(90000241)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "b" && Helper(90000005), command != "holdb"
ID = 90000241
ignoreHitPause = 1

[State -1, Remove c Detector]
type = RemoveExplod
triggerAll = NumExplod(90000251)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "c" && Helper(90000005), command != "holdc"
ID = 90000251
ignoreHitPause = 1

[State -1, Remove start Detector]
type = RemoveExplod
triggerAll = NumExplod(90000194)
triggerAll = NumHelper(90000005) && !IsHelper
trigger1 = Helper(90000005), command != "start" && Helper(90000005), command != "holdstart"
ID = 90000194
ignoreHitPause = 1


;==============================================================================================
;==========================================<GUARDING>==========================================
;==============================================================================================

;==============================================================================================
;Here, we override the MUGEN's default guard system, and add our own triggers. This will ensure
;that the player can always block as long as they are holding a direction away from the opponent.
;This block of code also adds "chicken guarding", which is allowing the player to air guard by holding
;not only back, but down-back and up-back.

;It is also recommended that you also override the guard states (120, 130, 131, 132, 140, 150, 151, 152, 154, 155)
;with an updated version that uses the EXPLODsive buffering system. A copy of those fixed states
;can be found in this character, and also in the release thread (here:PUT LINK HERE).
;==============================================================================================

[State -1, AssertSpecial: NoAirGuard]
type = AssertSpecial
trigger1 = 1
flag = NoAirGuard
ignoreHitPause = 0

[State -1, AssertSpecial: No StandGuard and NoCrouchGuard when landing from jump after switching sides]
type = AssertSpecial
trigger1 = P2dist x < 0 && StateType != A
flag = NoStandGuard
flag2 = NoCrouchGuard
ignoreHitPause = 0

[State -1, Stand Blocking]
type = ChangeState
triggerAll = !AILevel
triggerAll = InGuardDist
triggerAll = P2dist x < 0 && StateType != A
triggerAll = StateType = S
triggerAll = ctrl
trigger1 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90000004)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90000006))
value = 120

[State -1, Crouch Blocking]
type = ChangeState
triggerAll = !AILevel
triggerAll = InGuardDist
triggerAll = P2dist x < 0 && StateType != A
triggerAll = StateType = C
triggerAll = ctrl
trigger1 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90000001)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90000003))
value = 120

[State -1, Air Blocking]
type = ChangeState
triggerAll = !AILevel
triggerAll = InGuardDist
triggerAll = StateType = A
triggerAll = ctrl
triggerAll = !(StateNo = [120,155])
trigger1 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90000004)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90000006))
trigger2 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90000001)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90000003))
trigger3 = (ifElse(P2dist x < 0, Facing = -1, Facing = 1) && NumExplod(90000007)) || (ifElse(P2dist x < 0, Facing = 1, Facing = -1) && NumExplod(90000009))
value = 120



;==============================================================================================
;==============================================================================================
;=============================<End of EXPLODsive Buffering System>=============================
;==============================================================================================
;==============================================================================================