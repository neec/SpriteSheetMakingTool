package spritesheet
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	
	public class MainLayer extends Sprite
	{
		
		private var _assets:Vector.<Object>;
		private var _assetsToLoad:int;

		public static const RESOURCE_PATH:String = "res/in/";
		
		public function MainLayer()
		{


			getFiles();
			
			
			
		}
		
		
		private function getFiles():void 
		{
			var directory:File = File.applicationDirectory.resolvePath(RESOURCE_PATH);
			var list:Array = filterPngs(directory.getDirectoryListing());
			
			_assets = new Vector.<Object>();
			_assetsToLoad = list.length;
			
			trace("_assetsToLoad : " + _assetsToLoad);
			
			for (var i:uint = 0; i < list.length; i++) 
			{
				var loader:Loader = new Loader();
				loader.name = list[i].name;
				
				trace(i + " : " + loader.name + "\n");
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.load(new URLRequest(RESOURCE_PATH + (list[i] as File).name));
				
			}
		}
		
		
		private function filterPngs(list:Array):Array 
		{
			return list.filter(imgFilter);
		}
		
		private function imgFilter(obj:Object, index:int, array:Array):Boolean 
		{
			return (obj.name.indexOf(".png") >= 0)  ||  (obj.name.indexOf(".jpg") >= 0)  ||  (obj.name.indexOf(".bmp") >= 0);
		}
		
		
		
		
		private function onComplete(event:Event):void
		{
			// TODO Auto-generated method stub
			trace("onComplete in\n");
		}		
		
		
		
	}
}