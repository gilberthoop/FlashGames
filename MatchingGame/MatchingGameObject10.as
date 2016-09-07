package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.getTimer;
	import flash.utils.Timer; // need some other libraries for timer and sound
	import flash.media.Sound;
    import flash.media.SoundChannel;
	
	public class MatchingGameObject10 extends MovieClip {
		// game constants
		private static const boardWidth:uint = 6;
		private static const boardHeight:uint = 6;
		private static const cardHorizontalSpacing:Number = 52;
		private static const cardVerticalSpacing:Number = 52;
		private static const boardOffsetX:Number = 145;
		private static const boardOffsetY:Number = 70;
		private static const pointsForMatch:int = 100;
		private static const pointsForMiss:int = -5;
		
		// variables
		private var firstCard:Card10;
		private var secondCard:Card10;
		private var cardsLeft:uint;
		private var gameScore:int;
		private var gameStartTime:uint;
		private var gameTime:uint;
		
		// text fields
		private var gameScoreField:TextField;
		private var gameTimeField:TextField;
		
		// timer to return cards to face-down
		private var flipBackTimer:Timer; //we are going to use a timer to flip back now
		
		// set up sounds
		var theFirstCardSound:FirstCardSound = new FirstCardSound(); // make sound
		var theMissSound:MissSound = new MissSound();
		var theMatchSound:MatchSound = new MatchSound();

		// initialization function
		public function MatchingGameObject10():void {
			// make a list of card numbers
			var cardlist:Array = new Array();
			for(var i:uint=0;i<boardWidth*boardHeight/2;i++) {
				cardlist.push(i);
				cardlist.push(i);
			}
			
			// create all the cards, position them, and assign a randomcard face to each
			cardsLeft = 0;
			for(var x:uint=0;x<boardWidth;x++) { // horizontal
				for(var y:uint=0;y<boardHeight;y++) { // vertical
					var c:Card10 = new Card10(); // copy the movie clip - now card10 class
					c.stop(); // stop on first frame
					c.x = x*cardHorizontalSpacing+boardOffsetX; // set position
					c.y = y*cardVerticalSpacing+boardOffsetY;
					var r:uint = Math.floor(Math.random()*cardlist.length); // get a random face
					c.cardface = cardlist[r]; // assign face to card
					cardlist.splice(r,1); // remove face from list
					c.addEventListener(MouseEvent.CLICK,clickCard); // have it listen for clicks
					c.buttonMode = true; //change cursor now when over card
					addChild(c); // show the card
					cardsLeft++;
				}
			}
			
			// set up the score
			gameScoreField = new TextField();
			addChild(gameScoreField);
			gameScore = 0;
			showGameScore();
			
			// set up the clock
			gameTimeField = new TextField();
			gameTimeField.x = 450;
			addChild(gameTimeField);
			gameStartTime = getTimer();
			gameTime = 0;
			addEventListener(Event.ENTER_FRAME,showTime);
		}
		
		// player clicked on a card
		public function clickCard(event:MouseEvent) {
			var thisCard:Card10 = (event.target as Card10); // what card?
			
			if (firstCard == null) { // first card in a pair
				firstCard = thisCard; // note it
				thisCard.startFlip(thisCard.cardface+2);  // call startflip method now from card10 class
				playSound(theFirstCardSound); // and we play the first card sound
				
			} else if (firstCard == thisCard) { // clicked first card again
				firstCard.startFlip(1); // flip back if unselecting the card
				firstCard = null;
				playSound(theMissSound); // play the miss sound
				
			} else if (secondCard == null) { // second card in a pair
				secondCard = thisCard; // note it
				thisCard.startFlip(thisCard.cardface+2); //call startflip method
					
				// compare two cards
				if (firstCard.cardface == secondCard.cardface) {
					// remove a match
					removeChild(firstCard); //remove cards from stage if there is a match
					removeChild(secondCard);
					// reset selection
					firstCard = null;
					secondCard = null;
					// add points
					gameScore += pointsForMatch;
					showGameScore();
					playSound(theMatchSound); // play the matching sound for a match
					// check for game over
					cardsLeft -= 2; // 2 less cards
					if (cardsLeft == 0) {
						MovieClip(root).gameScore = gameScore;
						MovieClip(root).gameTime = clockTime(gameTime);
						MovieClip(root).gotoAndStop("gameover");
					}
				} else {
					gameScore += pointsForMiss;
					showGameScore();
					playSound(theMissSound); //play miss sound - two cards are not a match
					flipBackTimer = new Timer(2000,1); // make new timer for flip back - 2 seconds
					                                   //timer is set to run one time
					// timer event listener setup
					// call returncards function when 2 seconds are up for timerevent
					flipBackTimer.addEventListener(TimerEvent.TIMER_COMPLETE,returnCards); 
					
					flipBackTimer.start(); //start timer
				}
				
			} else { // starting to pick another pair
				returnCards(null); // call function returncards manually- null event- return cards face down
				playSound(theFirstCardSound); //play first card sound 
				// select first card in next pair
				firstCard = thisCard;
				firstCard.startFlip(thisCard.cardface+2); //flip first card
			}
		}
		
		// return cards to face-down
		public function returnCards(event:TimerEvent) {
			if (firstCard != null) firstCard.startFlip(1); //call startflip for cards
			if (secondCard != null) secondCard.startFlip(1);
			firstCard = null; //reset value to null
			secondCard = null;
			flipBackTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,returnCards); //remove flipback event listener
		}
		
		public function showGameScore() {
			gameScoreField.text = "Score: "+String(gameScore);
		}
		
		public function showTime(event:Event) {
			gameTime = getTimer()-gameStartTime;
			gameTimeField.text = "Time: "+clockTime(gameTime);
		}
		
		public function clockTime(ms:int) {
			var seconds:int = Math.floor(ms/1000);
			var minutes:int = Math.floor(seconds/60);
			seconds -= minutes*60;
			var timeString:String = minutes+":"+String(seconds+100).substr(1,2);
			return timeString;
		}
		
		public function playSound(soundObject:Object) { //function to play sound
			var channel:SoundChannel = soundObject.play(); //call play method for soundobject
		}
	}
}