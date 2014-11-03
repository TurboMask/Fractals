/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import AE.Fractals.Transformation;
	import AE.Fractals.GuiScrollbar;
	
	public class GuiTransform extends MovieClip
	{
		static const COLOR_CODES:Array = ["R", "G", "B", "A"];
		public var total_height:Number;
		public var changed:Boolean;
		public var deleted:Boolean;
		var transforms:Vector.<Transformation>;
		var color:ColorTransform;
		var scrollbars:Vector.<GuiScrollbar>;
		
		public function GuiTransform()
		{
			changed = false;
			deleted = false;
		}
		
		public function Init(_transforms:Vector.<Transformation>, _color:ColorTransform)
		{
			transforms = _transforms;
			color = _color;
			Draw();
		}
		
		public function Draw()
		{
			while(cont.numChildren > 0){
				cont.removeChildAt(0);
			}
			scrollbars = new Vector.<GuiScrollbar>();
			for(var i:int = 0; i < transforms.length; i++){
				AddScrollbar(transforms[i].type, transforms[i].p1, i, 0);
				if(transforms[i].type == Transformation.TRANSLATION || transforms[i].type == Transformation.SCALE){
					AddScrollbar(transforms[i].type, transforms[i].p2, i, 1);
				}
			}
			AddScrollbar(Transformation.COLOR, color.redOffset, -1, 0);
			AddScrollbar(Transformation.COLOR, color.greenOffset, -1, 1);
			AddScrollbar(Transformation.COLOR, color.blueOffset, -1, 2);
			AddScrollbar(Transformation.COLOR, color.alphaMultiplier, -1, 3);
			total_height = scrollbars.length * 14 + 20;
			gui_bg.scaleY = total_height / 100.0;
		}
		
		function AddScrollbar(type:int, value:Number, transf_num:int, param_num:int)
		{
			var scrollbar:GuiScrollbar = new GuiScrollbar();
			scrollbar.Init(type, value, transf_num, param_num);
			switch(type){
				case Transformation.TRANSLATION:
					scrollbar.t_title.text = "T." + (param_num == 0 ? "X" : "Y");
					break;
				case Transformation.ROTATION:
					scrollbar.t_title.text = "Rot";
					break;
				case Transformation.SCALE:
					scrollbar.t_title.text = "S." + (param_num == 0 ? "X" : "Y");
					break;
				case Transformation.COLOR:
					scrollbar.t_title.text = "C." + COLOR_CODES[param_num];
					break;
			}
			scrollbar.y = scrollbars.length * 14;
			scrollbars.push(scrollbar);
			cont.addChild(scrollbar);
		}
		
		function SaveChanges(scrollbar:GuiScrollbar)
		{
			if(scrollbar.type == Transformation.COLOR){
				if(scrollbar.param_num == 0){
					color.redOffset = scrollbar.value;
				}
				else if(scrollbar.param_num == 1){
					color.greenOffset = scrollbar.value;
				}
				else if(scrollbar.param_num == 2){
					color.blueOffset = scrollbar.value;
				}
				else if(scrollbar.param_num == 3){
					color.alphaMultiplier = scrollbar.value;
				}
			}
			else{
				transforms[scrollbar.transf_num].SetParam(scrollbar.param_num, scrollbar.value);
			}
		}
		
		public function Update()
		{
			if(btn_delete.clicked){
				deleted = true;
			}
			for(var i:int = 0; i < scrollbars.length; i++){
				scrollbars[i].Update();
				if(scrollbars[i].changed){
					SaveChanges(scrollbars[i]);
					scrollbars[i].changed = false;
					changed = true;
				}
			}
		}
	}
}