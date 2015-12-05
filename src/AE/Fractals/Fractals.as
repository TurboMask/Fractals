/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.PixelSnapping;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.net.FileFilter;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import Apix.Input;
	import AE.Watermark;
	import AE.Fractals.Transformations;
	import AE.Fractals.Fractal;
	import AE.Fractals.ImageWriter;
	
	public class Fractals extends MovieClip
	{
		static const STAT_ENABLED:int			= 0;
		static const STAT_DRAG:int				= 1;
		static const STAT_SELECTING_NAME:int	= 2;
		static const STAT_GENERATING:int		= 3;
		static const STAT_SAVE_TIMEOUT:int		= 4;
		static const STAT_SAVING:int			= 5;
		static const STAT_OPENING:int			= 6;
		var state:int;
		var export_size:int;
		var bmp:Bitmap;
		var fractal:Fractal;
		var w:int;
		var h:int;
		var start_w:int = 0;
		var start_h:int = 0;
		var size:int;
		var iter:int = 0;
		var bg_num:int;
		var transformations:Transformations;
		var file:File;
		var iteration_count:int;
		var image_writer:ImageWriter;
		var timeout:Number;
		var last_time:int;
		
		public function Fractals()
		{
			state = STAT_ENABLED;
			bg_num = 1;
			transformations = new Transformations();
			fractal = new Fractal();
			fractal.transformations = transformations.transforms;
			fractal.colors = transformations.colors;
			gui_background.gotoAndStop(bg_num);
			gui.transforms = transformations.transf_params;
			gui.colors = transformations.colors;
			gui.SetBackground(bg_num);
			gui.t_info.text = "";
			bmp = new Bitmap(null, PixelSnapping.NEVER, true);
			cont.addChild(bmp);
			Input.Init(stage);
			Watermark.Init(stage);
			last_time = getTimer();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, Resize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyboardEv);
			stage.addEventListener(Event.ENTER_FRAME, Update);
			Resize();
		}
		
		function Resize(ev:Event = null)
		{
			w = stage.stageWidth;
			h = stage.stageHeight;
			size = w > h ? h : w;
			if(start_w == 0){
				start_w = w;
				start_h = h;
			}
			gui_background.scaleX = w / 100.0;
			gui_background.scaleY = h / 100.0;
			gui_background.x = -(w - start_w) / 2.0;
			gui_background.y = -(h - start_h) / 2.0;
			if(gui.controls_enabled && (w - size) / 2.0 < 320.0){
				bmp.x = -(w - start_w) / 2.0 + 320.0;
				bmp.y = -(size - start_h) / 2.0;
			}
			else{
				bmp.x = -(size - start_w) / 2.0;
				bmp.y = -(size - start_h) / 2.0;
			}
			border.x = bmp.x;
			border.y = bmp.y;
			border.scaleX = border.scaleY = h / 640.0;
			gui.x = gui_background.x;
			gui.y = gui_background.y;
			
			Draw(transformations.transf_params.length == 0);
		}
		
		function Draw(_new:Boolean = true)
		{
			if(_new){
				transformations.Generate();
				gui.DrawControls();
			}
			transformations.Prepare(size);
			bmp.bitmapData = fractal.Draw(size, (_new ? Fractal.ITERATIONS_DEFAULT : -1));
			gui.t_info.text = "Iterations: " + fractal.total_iterations;
			//Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, transformations.t_info);
		}
		
		function SwapBackground()
		{
			bg_num = bg_num % 2 + 1;
			gui_background.gotoAndStop(bg_num);
			gui.SetBackground(bg_num);
		}
		
		function SaveImg()
		{
			state = STAT_SELECTING_NAME;
			gui.t_info.text = "Selecting file";
			file = new File();
			file.addEventListener(Event.SELECT, FileEvent);
			file.addEventListener(Event.CANCEL, FileEvent);
			file.browseForSave("Save PNG");
		}
		
		function OpenTransf()
		{
			state = STAT_OPENING;
			file = new File();
			file.addEventListener(Event.SELECT, FileEvent);
			file.addEventListener(Event.CANCEL, FileEvent);
			file.browseForOpen("Open transformation", [new FileFilter("Transformation", "*.txt; *.xml")]);
		}
		
		function FileEvent(ev:Event)
		{
			if(ev.type == Event.SELECT){
				trace(file.url);
				if(state == STAT_SELECTING_NAME){
					state = STAT_GENERATING;
					//Save transformations data
					gui.t_info.text = "Saving transformations";
					if(file.url.indexOf(".png") < 0){
						file.url += ".png";
					}
					var file_transf:File = new File(file.url.replace(".png", ".xml"));
					file_stream = new FileStream();
					file_stream.open(file_transf, FileMode.WRITE);
					file_stream.writeUTFBytes(transformations.GetInfo());
					file_stream.close();
					//Prepare for generation
					gui.t_info.text = "Preparing " + export_size;
					transformations.Prepare(export_size);
					iteration_count = fractal.total_iterations;
					fractal.Draw(export_size, 0);
				}
				else if(state == STAT_OPENING){
					var file_stream:FileStream = new FileStream();
					file_stream.open(file, FileMode.READ);
					var transf_data:String = file_stream.readUTFBytes(file_stream.bytesAvailable);
					file_stream.close();
					transformations.Init(transf_data);
					transformations.Prepare(size);
					bmp.bitmapData = fractal.Draw(size, -1);
					gui.DrawControls();
					state = STAT_ENABLED;
				}
			}
			else if(ev.type == Event.CANCEL){
				state = STAT_ENABLED;
				gui.t_info.text = "";
			}
		}
		
		function PrepareImageWriter()
		{
			transformations.Prepare(size);	//Reset transformations
			image_writer = new ImageWriter(fractal.data, file);
			gui.t_info.text = image_writer.msg;
		}
		
		function KeyboardEv(ev:KeyboardEvent)
		{
			if(ev.keyCode == Keyboard.SPACE){
				Draw();
			}
			else if(ev.keyCode == Keyboard.NUMBER_0 || ev.keyCode == Keyboard.NUMPAD_0){
				bmp.bitmapData = fractal.Draw(size, 0);
			}
			else if(ev.keyCode == Keyboard.NUMBER_1 || ev.keyCode == Keyboard.NUMPAD_1){
				bmp.bitmapData = fractal.DrawIteration();
			}
			else if(ev.keyCode == Keyboard.TAB || ev.keyCode == Keyboard.C){
				transformations.GenerateColors();
				bmp.bitmapData = fractal.Draw(size, -1);
				gui.DrawControls();
			}
			else if(ev.keyCode == Keyboard.NUMPAD_SUBTRACT || ev.keyCode == Keyboard.DOWN){
				transformations.global_scale *= 0.97;
				transformations.Prepare(size);
				bmp.bitmapData = fractal.Draw(size, -1);
			}
			else if(ev.keyCode == Keyboard.NUMPAD_ADD || ev.keyCode == Keyboard.UP){
				transformations.global_scale *= 1.03;
				transformations.Prepare(size);
				bmp.bitmapData = fractal.Draw(size, -1);
			}
			else if(ev.keyCode == Keyboard.B){
				SwapBackground();
			}
			else if(ev.keyCode == Keyboard.F1){
				gui.t_params.visible = !gui.t_params.visible;
			}
			gui.t_info.text = "Iterations: " + fractal.total_iterations;
		}
		
		function CheckClick()
		{
			if(gui.btn_color.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				SwapBackground();
			}
			else if(gui.btn_full.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				if(stage.displayState != StageDisplayState.NORMAL){
					stage.displayState = StageDisplayState.NORMAL;
				}
				else{
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
			}
			else if(gui.btn_controls.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				gui.ToggleControls();
				Resize();
			}
			else if(gui.btn_save_4.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				export_size = 4096;
				SaveImg();
			}
			else if(gui.btn_save_8.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				export_size = 8192;
				SaveImg();
			}
			else if(gui.btn_save_12.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				export_size = 12288;
				SaveImg();
			}
			else if(gui.btn_save_16.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				export_size = 16384;
				SaveImg();
			}
			else if(gui.btn_open.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
				OpenTransf();
			}
			else if(!gui.controls_enabled){
				Draw();
			}
		}
		
		function Update(ev:Event)
		{
			var _curr_time:int = getTimer();
			var dt:Number = Number(_curr_time - last_time) / 1000.0;
			last_time = _curr_time;
			
			switch(state){
				case STAT_ENABLED:
					gui.Update();
					if(gui.controls_changed){
						gui.controls_changed = false;
						Draw(false);
					}
					if(Input.mouse_clicked){
						if(bmp.hitTestPoint(Input.mouse_pos.x, Input.mouse_pos.y)){
							state = STAT_DRAG;
						}
					}
					if(Input.mouse_released){
						CheckClick();
					}
					break;
				case STAT_DRAG:
					transformations.global_transf.x += Input.mouse_diff.x / transformations.size;
					transformations.global_transf.y += Input.mouse_diff.y / transformations.size;
					cont.x += Input.mouse_diff.x;
					cont.y += Input.mouse_diff.y;
					if(Input.mouse_released){
						state = STAT_ENABLED;
						cont.x = 0.0;
						cont.y = 0.0;
						transformations.Prepare(size);
						bmp.bitmapData = fractal.Draw(size, -1);
					}
					break;
				case STAT_SELECTING_NAME:
					break;
				case STAT_GENERATING:
					if(fractal.state == Fractal.STAT_READY){
						gui.t_info.text = "Generated " + String(fractal.total_iterations) + " of " + String(iteration_count);
						if(fractal.total_iterations < iteration_count){
							fractal.DrawIteration();
						}
						else{
							if(export_size < 10000){
								timeout = 0.5;
							}
							else{
								timeout = 5.0;
							}
							fractal.EndDraw();
							PrepareImageWriter();
							state = STAT_SAVE_TIMEOUT;
						}
					}
					else if(fractal.state == Fractal.STAT_ERROR){
						gui.t_info.text = "Error: not enough free memory";
						state = STAT_ENABLED;
					}
					break;
				case STAT_SAVE_TIMEOUT:
					timeout -= dt;
					if(timeout <= 0.0){
						state = STAT_SAVING;
					}
					break;
				case STAT_SAVING:
					if(image_writer.completed){
						state = STAT_ENABLED;
						gui.t_info.text = "Completed!";
						image_writer.Cleanup();
						image_writer = null;
					}
					else{
						image_writer.Iterate();
						gui.t_info.text = image_writer.msg;
						timeout = 1.0;
						state = STAT_SAVE_TIMEOUT;
					}
					break;
				case STAT_OPENING:
					break;
			}
			Input.Update();
		}
	}
}