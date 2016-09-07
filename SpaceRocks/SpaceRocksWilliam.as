﻿package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.media.Sound;
    import flash.media.SoundChannel;
	
	public class SpaceRocksWilliam extends MovieClip {
		static const shipRotationSpeed:Number = .1;
		static const rockSpeedStart:Number = .03;
		static const rockSpeedIncrease:Number = .02;
		static const missileSpeed:Number = .2;
		static const thrustPower:Number = .15;
		static const shipRadius:Number = 20;
		static const startingShips:uint = 3;
	
		// game objects
		private var ship:Ship;
		private var rocks:Array;
		private var missiles:Array;
		
		// animation timer
		private var lastTime:uint;
		
		// arrow keys
		private var rightArrow:Boolean = false;
		private var leftArrow:Boolean = false;
		private var upArrow:Boolean = false;
		private var spaceBar:Boolean = true;
		
		// ship velocity
		private var shipMoveX:Number;
		private var shipMoveY:Number;
		
		// timers
		private var delayTimer:Timer;
		private var shieldTimer:Timer;
		private var missileTimer:Timer;
		
		// game mode
		private var gameMode:String;
		private var shieldOn:Boolean;
		
		// ships and shields
		private var shipsLeft:uint;
		private var shieldsLeft:uint;
		private var shipIcons:Array;
		private var shieldIcons:Array;
		private var warpIcons:Array;	//the warp icons

		// score and level
		private var gameScore:Number;
		private var scoreDisplay:TextField;
		private var gameLevel:uint;

		// sprites
		private var gameObjects:Sprite;
		private var scoreObjects:Sprite;	//stores the ship, shield, and warp icons
											//including the score
		
		//set up game sounds
		private var theCollision:Collisions = new Collisions;
		private var theMissile:MissileSound = new MissileSound;
		private var theShield:ShieldSound = new ShieldSound;
		private var theThruster:Thrusters = new Thrusters;
		
		
		// start the game
		public function startSpaceRocks() {
			// set up sprites
			gameObjects = new Sprite();
			addChild(gameObjects);
			scoreObjects = new Sprite();
			addChild(scoreObjects);
			
			// reset score objects
			gameLevel = 1;
			shipsLeft = startingShips;
			gameScore = 0;
			createShipIcons();
			createScoreDisplay();
						
			// set up listeners
			addEventListener(Event.ENTER_FRAME,moveGameObjects);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			
			// start 
			gameMode = "delay";
			shieldOn = false;
			missiles = new Array();
			nextRockWave(null);
			newShip(null);
		}
		
		
		// SCORE OBJECTS
		
		// draw number of ships left
		public function createShipIcons() {
			shipIcons = new Array();
			for(var i:uint=0;i<shipsLeft;i++) {
				var newShip:ShipIcon = new ShipIcon();
				newShip.x = 20+i*15;
				newShip.y = 375;
				scoreObjects.addChild(newShip);
				shipIcons.push(newShip);
			}
		}
		
		// draw number of shields left
		public function createShieldIcons() {
			shieldIcons = new Array();
			for(var i:uint=0;i<shieldsLeft;i++) {
				var newShield:ShieldIcon = new ShieldIcon();
				newShield.x = 530-i*15;
				newShield.y = 375;
				scoreObjects.addChild(newShield);
				shieldIcons.push(newShield);
			}
		}
		
		//draw number of warps left and display above the shield icons							
		public function createWarpIcons() {
			warpIcons = new Array();
			for (var i:uint=0;i<shieldsLeft;i++) {	
				var newWarp:WarpIcon = new WarpIcon();
				newWarp.x = 545-i*18;
				newWarp.y = 365;
				scoreObjects.addChild(newWarp);
				warpIcons.push(newWarp);
			}
		}
		
		// put the numerical score at the upper right
		public function createScoreDisplay() {
			scoreDisplay = new TextField();
			scoreDisplay.x = 500;
			scoreDisplay.y = 10;
			scoreDisplay.width = 40;
			scoreDisplay.selectable = false;
			var scoreDisplayFormat = new TextFormat();
			scoreDisplayFormat.color = 0xFFFFFF;
			scoreDisplayFormat.font = "Arial";
			scoreDisplayFormat.align = "right";
			scoreDisplay.defaultTextFormat = scoreDisplayFormat;
			scoreObjects.addChild(scoreDisplay);
			updateScore();
		}
		
		// new score to show
		public function updateScore() {
			scoreDisplay.text = String(gameScore);
		}
		
		// remove a ship icon
		public function removeShipIcon() {
			scoreObjects.removeChild(shipIcons.pop());
		}
		
		// remove a shield icon
		public function removeShieldIcon() {
			scoreObjects.removeChild(shieldIcons.pop());
		}
		
		// remove a warp icon
		public function removeWarpIcon() {
			scoreObjects.removeChild(warpIcons.pop());
		}
		
		// remove the rest of the ship icons
		public function removeAllShipIcons() {
			while (shipIcons.length > 0) {
				removeShipIcon();
			}
		}
		
		// remove the rest of the shield icons
		public function removeAllShieldIcons() {
			while (shieldIcons.length > 0) {
				removeShieldIcon();
			}
		}
		
		// remove the rest of the warp icons
		public function removeAllWarpIcons() {
			while (warpIcons.length > 0) {
				removeWarpIcon();
			}
		}
		
		
		// SHIP CREATION AND MOVEMENT
		
		// create a new ship
		public function newShip(event:TimerEvent) {
			// if ship exists, remove it
			if (ship != null) {
				gameObjects.removeChild(ship);
				ship = null;
			}
			
			// no more ships
			if (shipsLeft < 1) {
				endGame();
				return;
			}
			
			// create, position, and add new ship
			ship = new Ship();
			ship.gotoAndStop(1);
			ship.x = 275;
			ship.y = 200;
			ship.rotation = -90;
			ship.shield.visible = false;
			gameObjects.addChild(ship);
			
			// set up ship properties
			shipMoveX = 0.0;
			shipMoveY = 0.0;
			gameMode = "play";
			
			// set up the shield and warp icons
			shieldsLeft = 3;
			createShieldIcons();
			createWarpIcons();
			
			// all lives but the first start with a free shield
			if (shipsLeft != startingShips) {
				startShield(true);	
			}
		}
		
		// register key presses
		public function keyDownFunction(event:KeyboardEvent) {
			if (event.keyCode == 37) {
					leftArrow = true;
			} else if (event.keyCode == 39) {
					rightArrow = true;
			} else if (event.keyCode == 38) {
					upArrow = true;
					// show thruster
					if (gameMode == "play") {
						ship.gotoAndStop(2);
						playSound(theThruster);
					}
			} else if (event.keyCode == 32) { // space
					if (spaceBar) {
						newMissile();
						playSound(theMissile);
					}
					spaceBar = false;	//disable firing
			} else if (event.keyCode == 90) { // z
					startShield(false);
			}
		}
			
		// register key ups
		public function keyUpFunction(event:KeyboardEvent) {
			if (event.keyCode == 37) {
				leftArrow = false;
			} else if (event.keyCode == 39) {
				rightArrow = false;
			} else if (event.keyCode == 38) {
				upArrow = false;
				// remove thruster
				if (gameMode == "play")	ship.gotoAndStop(1);
			} else if (event.keyCode == 32) {
				spaceBar = true;	//enable firing when key not pressed
			}
			
		}
		
		// animate ship
		public function moveShip(timeDiff:uint) {
			
			// rotate and thrust
			if (leftArrow) {
				ship.rotation -= shipRotationSpeed*timeDiff;
			} else if (rightArrow) {
				ship.rotation += shipRotationSpeed*timeDiff;
			} else if (upArrow) {
				shipMoveX += Math.cos(Math.PI*ship.rotation/180)*thrustPower;
				shipMoveY += Math.sin(Math.PI*ship.rotation/180)*thrustPower;
			}
			
			// move
			ship.x += shipMoveX;
			ship.y += shipMoveY;
			
			// wrap around screen
			if ((shipMoveX > 0) && (ship.x > 570)) {
				ship.x -= 590;
			}
			if ((shipMoveX < 0) && (ship.x < -20)) {
				ship.x += 590;
			}
			if ((shipMoveY > 0) && (ship.y > 420)) {
				ship.y -= 440;
			}
			if ((shipMoveY < 0) && (ship.y < -20)) {
				ship.y += 440;
			}
		}
		
		// remove ship
		public function shipHit() {
			gameMode = "delay";
			ship.gotoAndPlay("explode");
			removeAllShieldIcons();
			removeAllWarpIcons();
			delayTimer = new Timer(2000,1);
			delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,newShip);
			delayTimer.start();
			removeShipIcon();
			shipsLeft--;
		}
		
		//display the ship randomly
		public function warpShip() {
			ship.x = randomNum(450)+50;
			ship.y = randomNum(300)+50;
		}
		
		// turn on shield for 3 seconds
		public function startShield(freeShield:Boolean) {
			if (shieldsLeft < 1) return; // no shields left
			if (shieldOn) return; // shield already on
			
			// turn on shield and set timer to turn off
			ship.shield.visible = true;
			shieldTimer = new Timer(3000,1);
			shieldTimer.addEventListener(TimerEvent.TIMER_COMPLETE,endShield);
			shieldTimer.start();
			
			// update shields and warps remaining
			if (!freeShield) {
				removeShieldIcon();
				removeWarpIcon();
				shieldsLeft--;
			}
			shieldOn = true;
			//make the ship warp and appear randomly
			warpShip();
			playSound(theShield);
		}
		
		// turn off shield
		public function endShield(event:TimerEvent) {
			ship.shield.visible = false;
			shieldOn = false;
		}
		
		// ROCKS		
		
		// create a single rock of a specific size
		public function newRock(x,y:int, rockType:String) {
			
			// create appropriate new class
			var newRock:MovieClip;
			var rockRadius:Number;
			if (rockType == "Big") {
				newRock = new Rock_Big();
				rockRadius = 35;
			} else if (rockType == "Medium") {
				newRock = new Rock_Medium();
				rockRadius = 20;
			} else if (rockType == "Small") {
				newRock = new Rock_Small();
				rockRadius = 10;
			}
			
			// Here is an alternate way to do the above, without a case statement
			// Need to import flash.utils.getDefinitionByName to use
			/*
			var rockClass:Object = getDefinitionByName("Rock_"+rockType);
			var newRock:MovieClip = new rockClass();
			*/
			
			// choose a random look
			newRock.gotoAndStop(Math.ceil(Math.random()*3));
			
			// set start position
			newRock.x = x;
			newRock.y = y;
			
			// set random movement and rotation
			var dx:Number = Math.random()*2.0-1.0;
			var dy:Number = Math.random()*2.0-1.0;
			var dr:Number = Math.random();
			
			// add to stage and to rocks list
			gameObjects.addChild(newRock);
			rocks.push({rock:newRock, dx:dx, dy:dy, dr:dr, rockType:rockType, rockRadius: rockRadius});
		}
		
		// create four rocks
		public function nextRockWave(event:TimerEvent) {
			rocks = new Array();
			newRock(100,100,"Big");
			newRock(100,300,"Big");
			newRock(450,100,"Big");
			newRock(450,300,"Big");
			gameMode = "play";
		}
		
		// animate all rocks
		public function moveRocks(timeDiff:uint) {
			for(var i:int=rocks.length-1;i>=0;i--) {
				
				// move the rocks
				var rockSpeed:Number = rockSpeedStart + rockSpeedIncrease*gameLevel;
				rocks[i].rock.x += rocks[i].dx*timeDiff*rockSpeed;
				rocks[i].rock.y += rocks[i].dy*timeDiff*rockSpeed;
				
				// rotate rocks
				rocks[i].rock.rotation += rocks[i].dr*timeDiff*rockSpeed;
				
				// wrap rocks
				if ((rocks[i].dx > 0) && (rocks[i].rock.x > 570)) {
					rocks[i].rock.x -= 590;
				}
				if ((rocks[i].dx < 0) && (rocks[i].rock.x < -20)) {
					rocks[i].rock.x += 590;
				}
				if ((rocks[i].dy > 0) && (rocks[i].rock.y > 420)) {
					rocks[i].rock.y -= 440;
				}
				if ((rocks[i].dy < 0) && (rocks[i].rock.y < -20)) {
					rocks[i].rock.y += 440;
				}
			}
		}
		
		public function rockHit(rockNum:uint) {
			// create two smaller rocks
			if (rocks[rockNum].rockType == "Big") {
				newRock(rocks[rockNum].rock.x,rocks[rockNum].rock.y,"Medium");
				newRock(rocks[rockNum].rock.x,rocks[rockNum].rock.y,"Medium");
			} else if (rocks[rockNum].rockType == "Medium") {
				newRock(rocks[rockNum].rock.x,rocks[rockNum].rock.y,"Small");
				newRock(rocks[rockNum].rock.x,rocks[rockNum].rock.y,"Small");
			}
			// remove original rock
			gameObjects.removeChild(rocks[rockNum].rock);
			rocks.splice(rockNum,1);
		}

		
		// MISSILES
		
		// create a new Missile
		public function newMissile() {
			// create
			var newMissile:Missile = new Missile();
			
			// set direction
			newMissile.dx = Math.cos(Math.PI*ship.rotation/180);
			newMissile.dy = Math.sin(Math.PI*ship.rotation/180);
			
			// placement
			newMissile.x = ship.x + newMissile.dx*shipRadius;
			newMissile.y = ship.y + newMissile.dy*shipRadius;
			
			// add to stage and array
			gameObjects.addChild(newMissile);
			missiles.push(newMissile);
		}
		
		// animate missiles
		public function moveMissiles(timeDiff:uint) {
			for(var i:int=missiles.length-1;i>=0;i--) {
				// move
				missiles[i].x += missiles[i].dx*missileSpeed*timeDiff;
				missiles[i].y += missiles[i].dy*missileSpeed*timeDiff;
				// moved off screen
				if ((missiles[i].x < 0) || (missiles[i].x > 550) || (missiles[i].y < 0) || (missiles[i].y > 400)) {
					gameObjects.removeChild(missiles[i]);
					delete missiles[i];
					missiles.splice(i,1);
				}
			}
		}
			
		// remove a missile
		public function missileHit(missileNum:uint) {
			gameObjects.removeChild(missiles[missileNum]);
			missiles.splice(missileNum,1);
		}
		
		
		// GAME INTERACTION AND CONTROL
		
		public function moveGameObjects(event:Event) {
			// get timer difference and animate
			var timePassed:uint = getTimer() - lastTime;
			lastTime += timePassed;
			moveRocks(timePassed);
			if (gameMode != "delay") {
				moveShip(timePassed);
			}
			moveMissiles(timePassed);
			checkCollisions();
		}
		
		// look for missiles colliding with rocks
		public function checkCollisions() {
			// loop through rocks
			rockloop: for(var j:int=rocks.length-1;j>=0;j--) {
				// loop through missiles
				missileloop: for(var i:int=missiles.length-1;i>=0;i--) {
					// collision detection 
					if (Point.distance(new Point(rocks[j].rock.x,rocks[j].rock.y),
							new Point(missiles[i].x,missiles[i].y))
								< rocks[j].rockRadius) {
						
						playSound(theCollision);
						// remove rock and missile
						rockHit(j);
						missileHit(i);
						
						// add score
						gameScore += 10;
						updateScore();
						
						// break out of this loop and continue next one
						continue rockloop;
					}
				}
				
				// check for rock hitting ship
				if (gameMode == "play") {
					if (shieldOn == false) { // only if shield is off
						if (Point.distance(new Point(rocks[j].rock.x,rocks[j].rock.y),
								new Point(ship.x,ship.y))
									< rocks[j].rockRadius+shipRadius) {
							
							// remove ship and rock
							shipHit();
							rockHit(j);
						}
					}
				}
			}
			
			// all out of rocks, change game mode and trigger more
			if ((rocks.length == 0) && (gameMode == "play")) {
				gameMode = "betweenlevels";
				gameLevel++; // advance a level
				delayTimer = new Timer(2000,1);
				delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,nextRockWave);
				delayTimer.start();
			}
		}
		
		public function endGame() {
			// remove all objects and listeners
			removeChild(gameObjects);
			removeChild(scoreObjects);
			gameObjects = null;
			scoreObjects = null;
			removeEventListener(Event.ENTER_FRAME,moveGameObjects);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			
			gotoAndStop("gameover");
		}
		
		public function randomNum(num):uint {
			return  Math.round(Math.random()*num);
		}
		
		//play a sound
		function playSound(soundObject:Object) { //function to play sound
		var channel:SoundChannel = soundObject.play(); //call play method for soundobject
		}
	}
}
		
	