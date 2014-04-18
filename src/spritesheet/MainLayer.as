package spritesheet
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	
	public class MainLayer extends Sprite
	{
		
		private var _assets:Vector.<Object>;
		private var _assetsToLoad:int;

		
		
		public function MainLayer()
		{


			getFiles();
			
			
			
		}
		
		
		private function getFiles():void 
		{
			var directory:File = File.applicationDirectory.resolvePath("res/in/");
			var list:Array = directory.getDirectoryListing();
			
			_assets = new Vector.<Object>();
			_assetsToLoad = list.length;
			
			trace("_assetsToLoad : " + _assetsToLoad);
			
			for (var i:uint = 0; i < list.length; i++) 
			{
				var loader:Loader = new Loader();
				loader.name = list[i].name;
				
				trace(i + " : " + loader.name + "\n");
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.load(new URLRequest((list[i] as File).name));
				
			}
		}
		
		private function onComplete(event:Event):void
		{
			// TODO Auto-generated method stub
			trace("onComplete in\n");
			trace("onComplete in\n");
			trace("onComplete in\n");
			trace("onComplete in\n");
		}		
		
		
		
	}
}