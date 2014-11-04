package Apix
{
	import flash.display.MovieClip;
	import flash.media.Sound;
	import flash.events.MouseEvent;
	
	public class Button extends MovieClip
	{
		static var sound_over:Sound = null;
		public static var click_sound:Sound = null;
		public var over:Boolean;
		public var down:Boolean;
		public var active:Boolean;
		public var animation:Boolean;
		public var _clicked:Boolean;
		public var callback_click:Function;
		public var frame_over:int = 2;
		public var frame_out:int = 1;
		var _click_obj:MovieClip;
		
		public function Button()
		{
			over = false;
			down = false;
			active = true;
			animation = true;
			_clicked = false;
			if(getChildByName("click_obj") != null){
				_click_obj = getChildByName("click_obj") as MovieClip;
			}
			else{
				_click_obj = this;
			}
			_click_obj.buttonMode = true;
			_click_obj.mouseChildren = false;
			_click_obj.addEventListener(MouseEvent.MOUSE_OVER, MouseAction);
			_click_obj.addEventListener(MouseEvent.MOUSE_OUT, MouseAction);
			_click_obj.addEventListener(MouseEvent.MOUSE_DOWN, MouseAction);
			_click_obj.addEventListener(MouseEvent.MOUSE_UP, MouseAction);
			stop();
		}
		
		public function MouseAction(ev:MouseEvent)
		{
			if(!active){
				return;
			}
			switch(ev.type){
				case MouseEvent.MOUSE_OVER:
					over = true;
					if(animation)
						gotoAndStop(frame_over);
					if(sound_over != null)
						sound_over.play(0, 1);
					break;
				case MouseEvent.MOUSE_OUT:
					over = false;
					down = false;
					if(animation)
						gotoAndStop(frame_out);
					break;
				case MouseEvent.MOUSE_DOWN:
					down = true;
					if(animation)
						gotoAndStop(3);
					break;
				case MouseEvent.MOUSE_UP:
					if(animation){
						gotoAndStop(frame_over);
					}
					if(down){
						down = false;
						_clicked = true;
						if(click_sound != null){
							click_sound.play(0, 1);
						}
						if(callback_click != null){
							callback_click(this);
						}
					}
					break;
			}
		}
		
		public function get clicked():Boolean
		{
			if(_clicked){
				_clicked = false;
				return true;
			}
			else{
				return false;
			}
		}
		
		public function Reset()
		{
			over = false;
			down = false;
			active = true;
			animation = true;
			_clicked = false;
			gotoAndStop(1);
		}
		
		public function Clear()
		{
			if(_click_obj.hasEventListener(MouseEvent.MOUSE_OVER)){
				_click_obj.removeEventListener(MouseEvent.MOUSE_OVER, MouseAction);
				_click_obj.removeEventListener(MouseEvent.MOUSE_OUT, MouseAction);
				_click_obj.removeEventListener(MouseEvent.MOUSE_DOWN, MouseAction);
				_click_obj.removeEventListener(MouseEvent.MOUSE_UP, MouseAction);
			}
		}
	}
}