package
{
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.setTimeout;
	
	public class Main extends MovieClip
	{
		[Embed(source="test.swf", mimeType="application/octet-stream")]
		private static var swf_class:Class;
		var workers:Vector.<Worker>;
 
		public function Main()
		{
			trace("Main, worker supported: " + WorkerDomain.isSupported);
			workers = new Vector.<Worker>();
			CreateWorker();
			setTimeout(ReadProp, 3000);
		}
		
		function CreateWorker()
		{
			trace("Creating worker");
			var _swf_data:ByteArray = new swf_class();
			var _worker:Worker = WorkerDomain.current.createWorker(_swf_data);
			_worker.start();
			workers.push(_worker);
			if(workers.length < 3){
				setTimeout(CreateWorker, 500);
			}
		}
		
		function ReadProp()
		{
			trace("Reading prop");
			for(var i:int = 0; i < workers.length; i++){
				var _data:Object = workers[i].getSharedProperty("data");
				trace("Worker " + i + " data: " + _data);
			}
		}
	}
}