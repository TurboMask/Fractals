/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import Apix.Input;
	import AE.Fractals.Transformation;
	import AE.Fractals.GuiTransform;
	
	public class GuiWindow extends MovieClip
	{
		public var controls_enabled:Boolean;
		public var controls_changed:Boolean;
		var buttons:Vector.<MovieClip>;
		var transforms:Vector.<Vector.<Transformation>>;
		var colors:Vector.<ColorTransform>;
		var gui_transf:Vector.<GuiTransform>;
		var transf_height:Number;
		var cont_start_y:Number;
		var view_height:Number = 600.0;
		
		public function GuiWindow()
		{
			buttons = Vector.<MovieClip>([btn_color, btn_full, btn_controls, btn_save_4, btn_save_8, btn_save_12, btn_save_16, btn_open]);
			for(var i:int = 0; i < buttons.length; i++){
				buttons[i].buttonMode = true;
			}
			//t_params.visible = false;
			controls_enabled = false;
			controls_changed = false;
			cont.visible = controls_enabled;
			cont_start_y = cont.y;
		}
		
		public function SetBackground(bg_num:int)
		{
			for(var i:int = 0; i < buttons.length; i++){
				buttons[i].gotoAndStop(bg_num);
			}
		}
		
		public function ToggleControls()
		{
			controls_enabled = !controls_enabled;
			cont.visible = controls_enabled;
		}
		
		public function DrawControls()
		{
			while(cont.numChildren > 0){
				cont.removeChildAt(0);
			}
			gui_transf = new Vector.<GuiTransform>;
			transf_height = 0.0;
			for(var i:int = 0; i < transforms.length; i++){
				var _gui_transf:GuiTransform = new GuiTransform();
				_gui_transf.Init(transforms[i], colors[i]);
				_gui_transf.y = transf_height;
				transf_height += _gui_transf.total_height + 10;
				cont.addChild(_gui_transf);
				gui_transf.push(_gui_transf);
			}
		}
		
		public function Update()
		{
			if(!controls_enabled){
				return;
			}
			for(var i:int = 0; i < gui_transf.length; i++){
				gui_transf[i].Update();
				if(gui_transf[i].changed){
					gui_transf[i].changed = false;
					controls_changed = true;
				}
				if(gui_transf[i].deleted){
					gui_transf.splice(i, 1);
					transforms.splice(i, 1);
					colors.splice(i, 1);
					--i;
					DrawControls();
					controls_changed = true;
				}
			}
			if(controls_enabled && Input.mouse_wheel != 0){
				cont.y += Input.mouse_wheel * 30;
				if(cont.y > cont_start_y){
					cont.y = cont_start_y;
				}
				if(transf_height > view_height){
					if(cont.y < view_height + cont_start_y - transf_height){
						cont.y = view_height + cont_start_y - transf_height;
					}
				}
				else{
					cont.y = cont_start_y;
				}
			}
		}
	}
}