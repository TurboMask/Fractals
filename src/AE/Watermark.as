/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
	
	Created:	2010-11-30
	Modified:	2014-01-03
*/

package AE
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import flash.events.KeyboardEvent;
	
	public class Watermark
	{
		private static var stage:Stage;
		private static var tekstas:String;
		private static var obj:MovieClip;
		private static var rodomas:Boolean;
		
		public static function Init(_stage:Stage)
		{
			if(_stage == null){
				return;
			}
			stage = _stage;
			tekstas = "-";
			obj = new MovieClip();
			obj.x = 10;
			obj.y = 10;
			obj.graphics.beginFill(0xFFFFFF, 0.9);
			obj.graphics.drawRect(0.0, 0.0, 170.0, 70.0);
			obj.graphics.endFill();
			var _t:TextField = new TextField();
			_t.width = 170.0;
			_t.text = "Code: Arvydas Burdulis\nhttp://cgart.lt\n(c) 2014";
			_t.x = 10.0;
			_t.y = 10.0;
			_t.setTextFormat(new TextFormat("_sans", 13, null, null, null, null, "http://cgart.lt", "_bank"));
			obj.addChild(_t);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, Klava);
			rodomas = false;
		}
		
		public static function Klava(ev:KeyboardEvent)
		{
			if(ev.keyCode == Keyboard.BACKSPACE){
				tekstas = "";
			}
			else{
				tekstas += String.fromCharCode(ev.charCode);
				if(tekstas.localeCompare(String(1337)) == 0){
					Rodyti(true);
				}
				else if(rodomas){
					Rodyti(false);
				}
			}
		}
		
		public static function Rodyti(stat:Boolean = false)
		{
			if(stat && !rodomas){
				setTimeout(Rodyti, 7000);
				stage.addChild(obj);
				rodomas = true;
			}
			else if(rodomas){
				stage.removeChild(obj);
				rodomas = false;
			}
		}
	}
}