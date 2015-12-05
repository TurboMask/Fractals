package
{
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.system.Worker;
	
	public class Test extends MovieClip
	{
		var _data:BitmapData;
		
		public function Test()
		{
			trace("Test");
			_data = new BitmapData(16000, 16000);
			Worker.current.setSharedProperty("data", _data);
		}
	}
}