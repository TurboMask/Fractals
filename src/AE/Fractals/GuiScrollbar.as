/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import Apix.Input;
	
	public class GuiScrollbar extends MovieClip
	{
		public var type:int;
		static const MIN_X:Number = 30.0;
		static const MAX_X:Number = 278.0;
		public var changed:Boolean;
		public var value:Number;
		public var transf_num:int;
		public var param_num:int;
		var clicked:Boolean;
		var start_value:Number;
		var start_pos:Number;
		var val_min:Number;
		var val_max:Number;
		var bounds:Point;
		
		public function GuiScrollbar()
		{
		}
		
		public function Init(_type:int, _value:Number, _transf_num:int, _param_num:int)
		{
			type = _type;
			value = _value;
			transf_num = _transf_num;
			param_num = _param_num;
			changed = false;
			clicked = false;
			t_value.text = value.toPrecision(4);
			if(type == Transformation.TRANSLATION){
				val_min = -1000.0;
				val_max = 1000.0;
			}
			else if(type == Transformation.ROTATION){
				val_min = -180.0;
				val_max = 180.0;
			}
			else if(type == Transformation.SCALE){
				val_min = 0.01;
				val_max = 2.0;
			}
			else if(type == Transformation.COLOR){
				if(param_num < 3){
					val_min = -255.0;
					val_max = 255.0;
					bounds = new Point(-255, 255);
				}
				else{
					val_min = 0.0;
					val_max = 1.0;
					bounds = new Point(0.0, 1.0);
				}
			}
			if(value < val_min){
				value = val_min;
			}
			else if(value > val_max){
				value = val_max;
			}
			
			if(bounds != null){
				obj.x = MIN_X + (MAX_X - MIN_X) * (value - bounds.x) / (bounds.y - bounds.x);
			}
			else{
				obj.x = (MAX_X - MIN_X) / 2.0 + MIN_X;
			}
		}
		
		public function Update()
		{
			if(Input.mouse_clicked){
				if(obj.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
					start_pos = obj.x - Input.mouse_pos.x;
					start_value = value;
					clicked = true;
				}
			}
			if(clicked){
				var pos:Number = Input.mouse_pos.x + start_pos;
				if(pos < MIN_X){
					pos = MIN_X;
				}
				else if(pos > MAX_X){
					pos = MAX_X;
				}
				obj.x = pos;
				pos = Number(pos - MIN_X) / (MAX_X - MIN_X) * 2.0 - 1.0;
				if(type == Transformation.TRANSLATION){
					value = start_value + pos * 0.2;
				}
				else if(type == Transformation.ROTATION){
					value = start_pos + pos * Math.abs(pos);
					while(value < -180.0){
						value += 360.0;
					}
					while(value > 180.0){
						value -= 360.0;
					}
				}
				else if(type == Transformation.SCALE){
					value = start_value + pos * Math.abs(pos) / 2.0;
				}
				else if(type == Transformation.COLOR){
					value = (pos + 1.0) / 2.0 * (bounds.y - bounds.x) + bounds.x;
				}
				if(Input.mouse_released){
					clicked = false;
					changed = true;
					if(bounds == null){
						obj.x = (MAX_X - MIN_X) / 2.0 + MIN_X;
					}
					trace(value);
				}
				t_value.text = value.toPrecision(4);
			}
		}
	}
}