/*
	Author:		Arvydas Burdulis
	
	http://cgart.lt
	http://turbomask.com
*/

package AE.Fractals
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.utils.ByteArray;
	import com.adobe.images.PNGEncoder;
	
	public class ImageWriter
	{
		static const MAX_SIZE:int = 4096;
		public var completed:Boolean;
		public var msg:String;
		var data:BitmapData;
		var file:File;
		var path:String;
		var x_count:int;
		var y_count:int;
		var x_pos:int;
		var y_pos:int;
		
		public function ImageWriter(_data:BitmapData, _file:File)
		{
			data = _data;
			file = _file;
			path = file.url;
			completed = false;
			x_count = Math.ceil(data.width / MAX_SIZE);
			y_count = Math.ceil(data.height / MAX_SIZE);
			trace("Size: " + x_count + ", " + y_count);
			x_pos = 0;
			y_pos = 0;
			CheckState();
		}
		
		function CheckState()
		{
			if(y_pos < y_count){
				msg = "Saving " + String(y_pos * x_count + x_pos + 1) + " of " + String(x_count * y_count);
			}
			else{
				completed = true;
			}
		}
		
		public function Iterate()
		{
			var _bmp:BitmapData = new BitmapData(MAX_SIZE, MAX_SIZE, true, 0x00000000);
			_bmp.draw(data, new Matrix(1, 0, 0, 1, -x_pos * MAX_SIZE, -y_pos * MAX_SIZE));
			var _data:ByteArray = PNGEncoder.encode(_bmp);
			//var _data:ByteArray = fractal.data.getPixels(new Rectangle(0, 0, fractal.data.width, fractal.data.height));
			if(x_count > 1 || y_count > 1){
				var _url = path.replace(".png", "_" + String(x_pos + 1) + "-" + String(y_pos + 1) + ".png");
				file.url = _url;
			}
			var file_stream:FileStream = new FileStream();
			file_stream.open(file, FileMode.WRITE);
			file_stream.writeBytes(_data);
			file_stream.close();
			
			++x_pos;
			if(x_pos >= x_count){
				x_pos = 0;
				++y_pos;
			}
			CheckState();
		}
		
		public function Cleanup()
		{
			data = null;
		}
	}
}