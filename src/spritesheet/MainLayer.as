package spritesheet
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	
	import spritesheet.decoder.BMPDecoder;
	import spritesheet.encoder.PNGEncoder;
	
	public class MainLayer extends Sprite
	{
		
		private var _assets:Vector.<Object>;
		private var _assetsToLoad:int;
		private var _spriteSheetImage:Bitmap;
		private var _drawRectSprite:Sprite;
		private var _imgBorderRect:Vector.<Rectangle>;
		private var _imgBorderBitmap:Bitmap;
		
		public static const RESOURCE_PATH:String = "res/in/";
		public static const OUTPUT_RESOURCE_PATH:String = "res/out/";
		
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
				
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT; 
				
				makeAtlasXmlFile( makeAtlasXmlString(result.atlas) );			//atlas.xml 파일 생성.
				
				
				_spriteSheetImage = new Bitmap(result.bitmapData);
				addChild(_spriteSheetImage);
				_drawRectSprite = new Sprite();
				
				
				_imgBorderRect = new Vector.<Rectangle>();
				makeImgBorderRect(result.atlas);
				
				_spriteSheetImage.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
				_spriteSheetImage.stage.addEventListener(TouchEvent.TOUCH_END, onTouchUp);
				
				makeSpriteSheetPNGFile(result.bitmapData);						//spritesheet.png 파일 생성.
				
			}
		}
		

		
		private function onTouchDown(event:TouchEvent):void
		{
			var imgBorderBitmapData:BitmapData = new BitmapData(_spriteSheetImage.width, _spriteSheetImage.height ,true,0xffffff);
			for(var i:uint; i<_imgBorderRect.length; i++)
			{
				if(_imgBorderRect[i].contains(event.stageX, event.stageY))
				{
					_drawRectSprite.graphics.lineStyle(2, 0x00ff00);
					_drawRectSprite.graphics.drawRect(_imgBorderRect[i].x, _imgBorderRect[i].y, _imgBorderRect[i].width, _imgBorderRect[i].height);
					
					imgBorderBitmapData.draw(_drawRectSprite);
					
					_imgBorderBitmap = new Bitmap(imgBorderBitmapData);
					addChild(_imgBorderBitmap);
				}
			}
		}		
		
		
		private function onTouchUp(event:TouchEvent):void
		{
			
			removeChild(_imgBorderBitmap);
			_drawRectSprite = new Sprite();
			
		}
		
		
		private function makeImgBorderRect(xmlResult:Vector.<Frame>):void
		{
			for(var i:uint = 0; i<xmlResult.length; i++)
			{
				var imgRect:Rectangle = new Rectangle(xmlResult[i].dimension.x, xmlResult[i].dimension.y, xmlResult[i].dimension.width, xmlResult[i].dimension.height);
				_imgBorderRect.push(imgRect);
			}
		}
		
		private function makeAtlasXmlString(xmlResult:Vector.<Frame>):String
		{
			var xmlString:String = "<atlas>\n";
			
			for(var i:uint = 0; i<xmlResult.length; i++)
			{
				xmlString += "<atlasItem name=\"" + xmlResult[i].name + "\" x=\"" + xmlResult[i].dimension.x + "\" y=\"" + xmlResult[i].dimension.y + "\" width=\"" + xmlResult[i].dimension.width + "\" height=\"" + xmlResult[i].dimension.height + "\" />\n"
			}
			xmlString += "</atlas>"
			
			return xmlString
		}
		
		private function makeAtlasXmlFile(atlasXmlString:String):void
		{
			
			trace(atlasXmlString);
			
			var fileName:String = "atlas.xml";
//			var xmlFile:File = File.applicationStorageDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);

			var xmlFile:File = File.documentsDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);
			//Android documentsDirectory   :   /mnt/sdcard
			//iOS documentsDirectory 	   :   /var/mobile/Applications/uid/Documents
			
			var xmlStream:FileStream = new FileStream();
			xmlStream.open(xmlFile, FileMode.WRITE);			
			xmlStream.writeUTFBytes(atlasXmlString);
			xmlStream.close();	
		}
		
		private function makeSpriteSheetPNGFile(spriteSheetBitmapData:BitmapData):void
		{
		
			var encodedPngFileByteArray:ByteArray = PNGEncoder.encode(spriteSheetBitmapData);
			
			var fileName:String = "spritesheet.png";

//			var pngFile:File = File.applicationStorageDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);
			var pngFile:File = File.documentsDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);
			//Android documentsDirectory   :   /mnt/sdcard
			//iOS documentsDirectory 	   :   /var/mobile/Applications/uid/Documents
			
			var xmlStream:FileStream = new FileStream();
			xmlStream.open(pngFile, FileMode.WRITE);			
			xmlStream.writeBytes(encodedPngFileByteArray, 0,0);
			xmlStream.close();	
			
		}
	}
}