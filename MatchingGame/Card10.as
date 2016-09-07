package {
	import flash.display.*;
	import flash.events.*;
	
	public dynamic class Card10 extends MovieClip { //card10 class - dynamic so we can add cardface 
		private var flipStep:uint; // counter for flipping
		private var isFlipping:Boolean = false; //flag if it is flipping
		private var flipToFrame:uint; // frame we want to change to
		
		// begin the flip, remember which frame to jump to
		public function startFlip(flipToWhichFrame:uint) { // startflip function - input is frame # to flip to
			isFlipping = true; // starting to flip 
			flipStep = 10; // counter set to 10 - there will be 10 steps in the flip
			flipToFrame = flipToWhichFrame; // which frame do we want to have when card is flipped
			this.addEventListener(Event.ENTER_FRAME, flip); // flipping will run with the frame rate
		}
		
		// take 10 steps to flip
		public function flip(event:Event) { // flip function called on each frame
			flipStep--; // next step
			
			if (flipStep > 5) { // first half of flip
				this.scaleX = .20*(flipStep-6);
			} else { // second half of flip
				this.scaleX = .20*(5-flipStep);
			}
			
			// when it is the middle of the flip, go to new frame
			if (flipStep == 5) {
				gotoAndStop(flipToFrame);
			}
			
			// at the end of the flip, stop the animation
			if (flipStep == 0) {
				this.removeEventListener(Event.ENTER_FRAME, flip); //remove frame listener at end of flip
			}
		}
	}
}
		
		