/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Fractal
	{
		public static const STAT_READY:int		= 0;
		public static const STAT_WORKING:int	= 1;
		public static const STAT_ERROR:int		= 2;
		public var state:int;
		public static const ITERATIONS_DEFAULT:int	= 15;
		public var data:BitmapData;
		var data2:BitmapData;
		public var transformations:Vector.<Matrix>;
		public var colors:Vector.<ColorTransform>;
		public var total_iterations:int;
		var data_empty:BitmapData;
		var size:Number;
		
		public function Fractal()
		{
			state = STAT_READY;
			total_iterations = ITERATIONS_DEFAULT;
		}
		
		public function Draw(_size:Number, _iterations:int):BitmapData
		{
			//trace("Fractal.Draw: " + _size);
			state = STAT_WORKING;
			size = _size;
			if(_iterations < 0){
				_iterations = total_iterations;
			}
			total_iterations = 0;
			data_empty = new BitmapData(size, size, true, 0x00FFFFFF);
			if(data_empty == null){
				trace("Bitmap data not created");
				state = STAT_ERROR;
				return null;
			}
			if(data_empty.width <= 0 || data_empty.height <= 0){
				state = STAT_ERROR;
				return null;
			}
			try{ data = data_empty.clone(); }
			catch(err:Error){
				state = STAT_ERROR;
				return null;
			}
			data.fillRect(new Rectangle(size / 4.0, size / 4.0, size / 2.0, size / 2.0), 0xFF000000);
			data2 = data_empty.clone();
			
			for(var i:int = 0; i < _iterations; i++){
				DrawIteration();
			}
			state = STAT_READY;
			return data;
		}
		
		public function DrawIteration():BitmapData
		{
			state = STAT_WORKING;
			++total_iterations;
			data2.copyPixels(data_empty, new Rectangle(0, 0, size, size), new Point(0, 0));
			for(var i:int = 0; i < transformations.length; i++){
				data2.draw(data, transformations[i], colors[i], null, null, true);
			}
			var tmp:BitmapData = data;
			data = data2;
			data2 = tmp;
			state = STAT_READY;
			return data;
		}
	}
}