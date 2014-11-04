package Apix
{
	import flash.display.Stage;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	public class Input
	{
		public static const RELEASED:int	= 0;
		public static const RELEASING:int	= 1;
		public static const CLICKING:int	= 2;
		public static const CLICKED:int		= 3;
		public static var initialized:Boolean = false;
		public static var clicked:Boolean;
		public static var mouse_pos:Point;
		public static var mouse_diff:Point;
		public static var mouse_clicked:Boolean;
		public static var mouse_released:Boolean;
		public static var mouse_moved:Boolean;
		public static var mouse_wheel:int;
		public static var arrow_status:int;
		static var keys:Object = new Object;
		static var stage:Stage;
		static var kb_callbacks:Vector.<Function>;
		static var mouse_pos_last:Point;
		static var arrow_keys:Array;
		
		public function Input()
		{
		}
		
		public static function Init(_stage:Stage)
		{
			if(!initialized){
				stage = _stage;
				clicked = false;
				mouse_clicked = false;
				mouse_moved = false;
				mouse_wheel = 0;
				mouse_pos = new Point();
				mouse_diff = new Point();
				mouse_pos_last = new Point(0.0, 0.0);
				arrow_status = RELEASED;
				kb_callbacks = new Vector.<Function>();
				arrow_keys = [Keyboard.LEFT, Keyboard.A, Keyboard.RIGHT, Keyboard.D, Keyboard.UP, Keyboard.W, Keyboard.DOWN, Keyboard.S];
				stage.addEventListener(KeyboardEvent.KEY_DOWN, KBEvent);
				stage.addEventListener(KeyboardEvent.KEY_UP, KBEvent);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, MouseEv);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, MouseEv);
				stage.addEventListener(MouseEvent.MOUSE_UP, MouseEv);
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, MouseEv);
				initialized = true;
			}
		}
		
		public static function Destroy()
		{
			if(initialized){
				kb_callbacks = null;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, KBEvent);
				stage.removeEventListener(KeyboardEvent.KEY_UP, KBEvent);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, MouseEv);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, MouseEv);
				stage.removeEventListener(MouseEvent.MOUSE_UP, MouseEv);
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL, MouseEv);
				initialized = false;
			}
		}
		
		public static function AddKBCallback(_function:Function)
		{
			kb_callbacks.push(_function);
		}
		
		public static function RemoveKBCallback(_function:Function)
		{
			for(var i:int = 0; i < kb_callbacks.length; i++)
				if(kb_callbacks[i] == _function){
					kb_callbacks.splice(i, 1);
					break;
				}
		}
		
		public static function KBEvent(ev:KeyboardEvent)
		{
			var i:int;
			if(ev.type == KeyboardEvent.KEY_DOWN){
				keys[ev.keyCode] = CLICKING;
				clicked = true;
				for(i = 0; i < kb_callbacks.length; i++)
					kb_callbacks[i](ev.charCode, true);
			}
			else if(ev.type == KeyboardEvent.KEY_UP){
				keys[ev.keyCode] = RELEASING;
				for(i = 0; i < kb_callbacks.length; i++)
					kb_callbacks[i](ev.charCode, false);
			}
		}
		
		public static function MouseEv(ev:MouseEvent)
		{
			if(ev.type == MouseEvent.MOUSE_MOVE){
				mouse_moved = true;
				//trace(ev.target + " " + ev.eventPhase + " " + ev.bubbles);
				/*mouse_diff.x = ev.stageX - mouse_pos.x;
				mouse_diff.y = ev.stageY - mouse_pos.y;
				mouse_pos.x = ev.stageX;
				mouse_pos.y = ev.stageY;*/
			}
			else if(ev.type == MouseEvent.MOUSE_DOWN){
				mouse_clicked = true;
			}
			else if(ev.type == MouseEvent.MOUSE_UP){
				mouse_released = true;
			}
			else if(ev.type == MouseEvent.MOUSE_WHEEL){
				if(ev.delta > 0){
					++mouse_wheel;
				}
				else{
					--mouse_wheel;
				}
			}
			mouse_pos.x = ev.stageX;
			mouse_pos.y = ev.stageY;
			mouse_diff.x = mouse_pos.x - mouse_pos_last.x;
			mouse_diff.y = mouse_pos.y - mouse_pos_last.y;
		}
		
		public static function GetKey(num:int):int
		{
			if(keys.hasOwnProperty(num))
				return keys[num];
			else
				return 0;
		}
		
		public static function PreUpdate()
		{
			arrow_status = RELEASED;
			for(var i:int = 0; i < arrow_keys.length; i++){
				var _stat:int = GetKey(arrow_keys[i]);
				if(_stat > arrow_status){
					arrow_status = _stat;
				}
			}
		}
		
		public static function Update()
		{
			for(var _key in keys){
				if(keys[_key] == RELEASING)
					keys[_key] = RELEASED;
				else if(keys[_key] == CLICKING)
					keys[_key] = CLICKED;
			}
			clicked = false;
			mouse_clicked = false;
			mouse_released = false;
			mouse_moved = false;
			mouse_wheel = 0;
			mouse_diff.x = 0.0;
			mouse_diff.y = 0.0;
			mouse_pos_last.x = mouse_pos.x;
			mouse_pos_last.y = mouse_pos.y;
		}
	}
}