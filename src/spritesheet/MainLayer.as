package spritesheet
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;

	
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
			
			_assets = new Vector.<Object>();
			
			var directory:File = File.applicationDirectory.resolvePath(RESOURCE_PATH);
			var list:Array = filterImgs(directory.getDirectoryListing());
			
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
		
		
		private function filterImgs(list:Array):Array 
		{
			return list.filter(imgFilter);
		}
		
		private function imgFilter(obj:Object, index:int, array:Array):Boolean 
		{
			
			
			if((obj.name.indexOf(".bmp") >= 0)){

				var file:File = File.applicationDirectory.resolvePath(RESOURCE_PATH + obj.name);
				
				var fstream:FileStream = new FileStream();
				fstream.open(file, FileMode.READ);

				
				
				var bmpImageStorageArray:ByteArray = new ByteArray();
				fstream.readBytes(bmpImageStorageArray);
					
				
				var decoder:BMPDecoder = new BMPDecoder();
				var bmd:BitmapData = decoder.decode(bmpImageStorageArray);
				var bm:Bitmap = new Bitmap(bmd,"auto",true);

				
				_assets.push({"bitmap":bm, "name":obj.name});
				return false;
				
			}
			
			return ((obj.name.indexOf(".png") >= 0) || (obj.name.indexOf(".jpg") >= 0));
		}
		
		
		
		
		private function onComplete(event:Event):void
		{
			_assetsToLoad--;
			
			var bitmap:Bitmap = event.target.content as Bitmap;
			var name:String = (event.target as LoaderInfo).loader.name;
			
			_assets.push({"bitmap":bitmap, "name":name});
			
			if (_assetsToLoad == 0) 
			{
				var i:int;
				
				
				var sheetGenerator:SpriteSheetGenerate =  new SpriteSheetGenerate();
				var result:Object = sheetGenerator.generate(_assets);
				
				
				var image:Bitmap = new Bitmap(result.bitmapData);
				addChild(image);
				
				
			}
		}		
	}
}