package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.media.Sound;
    import flash.media.SoundChannel;
	
	public class HangmanWilliam extends MovieClip { 		//switch to MovieClip to enable multiple frames (starting and ending part)
		private var textDisplay:TextField;
		private var phraseArray:Array;	//array for 3 phrases
		private var phrase1:String = "Imagination is more important than knowledge." // - Albert Einstein.
		private var phrase2:String =  "Every champion was once a contender who did't give up.";	// - Rocky Balboa
		private var phrase3:String = "If friendship is your weakest point, then you are the strongest person in the world";	// - Abraham Lincoln
		private var randomPhrase:Array;		//the array for storing random phrases
		private var phraseNum:int = 0;				//flagger for the current and next phrases
		private var shown:String;
		private var numWrong:int = 0;
		
		private var recordChar:String; 			//hold the previously pressed key
		private var hangmanTimer:Timer;			//timer for turn
		private var clock:Clock;				//set up clock display
		
		//game sprites
		private var gameSprite:Sprite;
		private var timerSprite:Sprite;
		
		//game sounds
		private var hangmanUp:CorrectGuess = new CorrectGuess();
		private var hangmanDown:WrongGuess = new WrongGuess();
		private var clockTicks:Ticks = new Ticks();
		
		public function startHangman() { //constructor 
		
			// create game sprite
			gameSprite = new Sprite();
			addChild(gameSprite);
			
			//display the timer and play the clockticks
			displayClock();
			playSound(clockTicks);
			
			//put each phrase in a new array
			phraseArray = new Array();
			phraseArray.push(phrase1);
			phraseArray.push(phrase2);
			phraseArray.push(phrase3);
			
			
			//randomize the phrases from an array
			randomPhrase = new Array();
			while (phraseArray.length > 0) {	//checks the phrases left
				var r:int = Math.floor(Math.random()*phraseArray.length);
				randomPhrase.push(phraseArray[r]);	//assign random phrase to the new array
				phraseArray.splice(r, 1);			//delete that phrase
			}
			
			// create a copy of text with _ for each letter
			shown = randomPhrase[phraseNum].replace(/[A-Za-z]/g,"_"); 	// /g is global flag - keep going until no more found
			numWrong = 0;
			
			// set up the visible text field 
			textDisplay = new TextField();
			textDisplay.defaultTextFormat = new TextFormat("Courier",30);
			textDisplay.width = 400;
			textDisplay.height = 200;
			textDisplay.wordWrap = true;
			textDisplay.selectable = false;
			textDisplay.text = shown;
			addChild(textDisplay);
			
			// listen for key presses
			stage.addEventListener(KeyboardEvent.KEY_UP,pressKey);
		}
		
		
		public function pressKey(event:KeyboardEvent) {
			//pause the timer when the keyboard is pressed
			hangmanTimer.stop();
			
			//resume the timer right after a key press by displaying it again
			displayClock();
			
			// get letter pressed
			var charPressed:String = (String.fromCharCode(event.charCode));
			
			// loop through and find matching letters
			var foundLetter:Boolean = false;
			
			for(var i:int=0;i<randomPhrase[phraseNum].length;i++) {
				if (randomPhrase[phraseNum].charAt(i).toLowerCase() == charPressed) {
					// match found, change shown phrase
					shown = shown.substr(0,i)+randomPhrase[phraseNum].substr(i,1)+shown.substr(i+1); // make a new string shown
					                                                                // from position 0 to i use shown
																					// for position i use letter from phrase
																					// use rest of shown from position i+1 forward
					foundLetter = true;
					playSound(hangmanUp);		//play sound for correct guess
				}
			}
			
			// update on-screen text
			textDisplay.text = shown;
			
			// update hangman if key doesn't match
			//check if the key is not pressed again (more than once)
			if (!foundLetter) {
				if (recordChar != charPressed) {
					playSound(hangmanDown);				//play sound for wrong guess
					numWrong++;					   		//then increment the wrong answer
					character.gotoAndStop(numWrong+1);	//make the hangman fall one step
				}
				recordChar = charPressed;
			}
			
			// update the game state by checking to see if hangman has fallen down (7 mistakes)
			//or if the player has guessed the expression, end the game if so	
			if (numWrong == 7 || shown == randomPhrase[phraseNum]) {
				endRound();
			}
		}
		
		//end the round
		public function endRound() {
			phraseNum++				//increment the flagger to choose another random phrase
			if (phraseNum > 2) {	//if the number of phrases exceeds the array, end of the game
				endGame();
			}
			else {					//else continue to the neext phrase
				removeChild(textDisplay);							//remove text display
				// recreate a copy of text with _ for each letter for the next phrase
				shown = randomPhrase[phraseNum].replace(/[A-Za-z]/g,"_"); 	// /g is global flag - keep going until no more found
				numWrong = 0;
				character.gotoAndStop(numWrong);
			
				// set up the visible text field 
				textDisplay = new TextField();
				textDisplay.defaultTextFormat = new TextFormat("Courier",30);
				textDisplay.width = 400;
				textDisplay.height = 200;
				textDisplay.wordWrap = true;
				textDisplay.selectable = false;
				textDisplay.text = shown;
				addChild(textDisplay);
			}
		}
		
		//end the game
		public function endGame() {
			phraseNum = 0;												//reset number of phrase to 0 to be used by startHangman()
			removeChild(textDisplay);									//remove text display
			removeChild(gameSprite);									//remove the game objects, clock
			hangmanTimer.stop();										//stop the timer
			stage.removeEventListener(KeyboardEvent.KEY_UP,pressKey);	//disable keyboard inputs
			gotoAndStop("gameover");
		}
		
		
		// prepare new timer sprite
		public function displayClock() {
			timerSprite = new Sprite();				//make a new timer object 
			gameSprite.addChild(timerSprite);		//add it to gameSprite
			//set up clock display
			clock = new Clock();
			clock.x = 150;
			clock.y = 300;
			timerSprite.addChild(clock);			//add clock to object
			hangmanTimer = new Timer(1000,10);		//make a new timer with 1000 milliseconds and 10 seconds
			hangmanTimer.addEventListener(TimerEvent.TIMER,updateClock);
			hangmanTimer.start();					//start timer as soon as it is displayed
		}
		
		// update or refresh the timer
		public function updateClock(event:TimerEvent) {
			clock.gotoAndStop(event.target.currentCount+1);
			//if clock has reached 10 seconds
			if (event.target.currentCount == event.target.repeatCount) {
				playSound(hangmanDown);	
				numWrong++;					   		//then increment the wrong answer
				character.gotoAndStop(numWrong+1);	//update hangman status
				displayClock();						//replay timer when it has reached 10 seconds
			}
			if (numWrong==7) {		//end the round after 7 mistakes
				endRound();
			} 
		}
		
		//play a sound
		function playSound(soundObject:Object) { 	//function to play sound
			var channel:SoundChannel = soundObject.play(); //call play method for soundobject
		}
	}
}