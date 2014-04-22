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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	
	import spritesheet.decoder.BMPDecoder;
	import spritesheet.encoder.AsyncPNGEncoder;
	import spritesheet.encoder.supportClasses.AsyncImageEncoderEvent;
	import spritesheet.encoder.supportClasses.IAsyncImageEncoder;
	
	public class MainLayer extends Sprite
	{
		
		private var _assets:Vector.<Object>;
		private var _assetsToLoad:int;
		private var _spriteSheetImage:Bitmap;
		private var _imgBorderRect:Vector.<Rectangle>;
		private var _imgBorderBitmap:Bitmap;
		
		private var _displayScaleX:Number;
		private var _displayScaleY:Number;
		
		private var _touchFlag:Boolean = false;
		
		private var _asyncPNGEncoder:IAsyncImageEncoder;
		private var _pngCompleteInfoField:TextField;
		
		public static const RESOURCE_PATH:String = "res/in/";
		public static const OUTPUT_RESOURCE_PATH:String = "res/out/";
		public static const WHITE_BACKGROUND_COLOR:uint = 0xffffff;
		
		
		
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
		
		
		/**
		 * 
		 * loader가 지원하지 않는 bmp파일 BMPDecoder를 통해서 따로 _assets에 저장, false를 반환하여 loader가 처리하지 않도록 처리
		 * loader가 지원하는 png, jpg 파일은 true를 반환하여 loader가 처리.
		 * 
		 */
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
				var sheetGeneratedResult:Object = sheetGenerator.generate(_assets);
				
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT; 
				
				makeAtlasXmlFile( makeAtlasXmlString(sheetGeneratedResult.atlas) );			//atlas.xml 파일 생성.
				
				
				settingForBetweenSheetAndDisplay(sheetGeneratedResult.bitmapData);			//실행 디바이스 별 display 설정.
				
				
				makeImgBorderRect(sheetGeneratedResult.atlas);								//이미지별 경계를 표시할 이미지_경계_도형 정보 저장.
				
				_spriteSheetImage.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
				_spriteSheetImage.stage.addEventListener(TouchEvent.TOUCH_END, onTouchUp);
				
				makeSpriteSheetPNGFile(sheetGeneratedResult.bitmapData);					//spritesheet.png 파일 생성.
				
				
				while(_assets.length)
				{
					_assets.pop();
				}
				
			}
		}
		
		
		/**
		 * 
		 * 생성된 spriteSheet와 디바이스의 크기를 비교하여 화면에 출력할 이미지 크기 변경.
		 * 
		 */
		private function settingForBetweenSheetAndDisplay(sheetBitmapData:BitmapData):void
		{
			
			trace(Capabilities.screenResolutionX + " : " + Capabilities.screenResolutionY);
			
			var tempsheetBitmapData:BitmapData = sheetBitmapData.clone();

			var matrix:Matrix = new Matrix();
			
			if(sheetBitmapData.width > sheetBitmapData.height)
			{
				if(sheetBitmapData.width < Capabilities.screenResolutionX)
				{
					_displayScaleX = Capabilities.screenResolutionX / sheetBitmapData.width;
				}
				else
				{
					_displayScaleX =  sheetBitmapData.width / Capabilities.screenResolutionX;
				}
				matrix.scale(_displayScaleX, _displayScaleX);
				sheetBitmapData = new BitmapData(tempsheetBitmapData.width * _displayScaleX, tempsheetBitmapData.height * _displayScaleX, true, WHITE_BACKGROUND_COLOR);
			}
			else if(sheetBitmapData.width < sheetBitmapData.height)
			{
				if(sheetBitmapData.height < Capabilities.screenResolutionY)
				{
					_displayScaleY = Capabilities.screenResolutionY / sheetBitmapData.height;
				}
				else
				{
					_displayScaleY =  sheetBitmapData.height / Capabilities.screenResolutionY;
				}
				matrix.scale(_displayScaleY, _displayScaleY);
				sheetBitmapData = new BitmapData(tempsheetBitmapData.width * _displayScaleY, tempsheetBitmapData.height * _displayScaleY, true, WHITE_BACKGROUND_COLOR);
			}
			else
			{
				if(Capabilities.screenResolutionX < Capabilities.screenResolutionY)
				{
					if(sheetBitmapData.width < Capabilities.screenResolutionX)
					{
						_displayScaleX = Capabilities.screenResolutionX / sheetBitmapData.width;
					}
					else
					{
						_displayScaleX =  sheetBitmapData.width / Capabilities.screenResolutionX;
					}
					matrix.scale(_displayScaleX, _displayScaleX);
					sheetBitmapData = new BitmapData(tempsheetBitmapData.width * _displayScaleX, tempsheetBitmapData.height * _displayScaleX, true, WHITE_BACKGROUND_COLOR);
				}
				else
				{
					if(sheetBitmapData.height < Capabilities.screenResolutionY)
					{
						_displayScaleY = Capabilities.screenResolutionY / sheetBitmapData.height;
					}
					else
					{
						_displayScaleY =  sheetBitmapData.height / Capabilities.screenResolutionY;
					}
					matrix.scale(_displayScaleY, _displayScaleY);
					sheetBitmapData = new BitmapData(tempsheetBitmapData.width * _displayScaleY, tempsheetBitmapData.height * _displayScaleY, true, WHITE_BACKGROUND_COLOR);
				}
			}
		
			sheetBitmapData.draw(tempsheetBitmapData, matrix);
			
			_spriteSheetImage = new Bitmap(sheetBitmapData);
			addChild(_spriteSheetImage);

		}
		

		
		private function onTouchDown(event:TouchEvent):void
		{
			if( false == _touchFlag )
			{
				var imgBorderBitmapData:BitmapData = new BitmapData(_spriteSheetImage.width, _spriteSheetImage.height ,true,WHITE_BACKGROUND_COLOR);
				for(var i:uint; i<_imgBorderRect.length; i++)
				{
					if(_imgBorderRect[i].contains(event.stageX, event.stageY))
					{
						var drawRectSprite:Sprite = new Sprite();
						
						drawRectSprite.graphics.lineStyle(2, 0x00ff00);
						drawRectSprite.graphics.drawRect(_imgBorderRect[i].x, _imgBorderRect[i].y, _imgBorderRect[i].width, _imgBorderRect[i].height);
						
						imgBorderBitmapData.draw(drawRectSprite);
						
						_imgBorderBitmap = new Bitmap(imgBorderBitmapData);
						addChild(_imgBorderBitmap);
						_touchFlag = true;
					}
				}
			}
		}		
		
		
		private function onTouchUp(event:TouchEvent):void
		{
			if( true == _touchFlag )
			{
				removeChild(_imgBorderBitmap);
				_touchFlag = false;
			}
		}
		
		
		/**
		 * 
		 * sheet의 각 이미지 Frame을 _imgBorderRect 에 저장.
		 * 
		 */
		private function makeImgBorderRect(xmlResult:Vector.<Frame>):void
		{
			
			_imgBorderRect = new Vector.<Rectangle>();
			
			for(var i:uint = 0; i<xmlResult.length; i++)
			{
				var imgRect:Rectangle;
				if( _displayScaleX )
				{
					imgRect = new Rectangle(xmlResult[i].dimension.x * _displayScaleX, xmlResult[i].dimension.y  * _displayScaleX, xmlResult[i].dimension.width * _displayScaleX, xmlResult[i].dimension.height * _displayScaleX);
				}
				else
				{
					imgRect = new Rectangle(xmlResult[i].dimension.x * _displayScaleY, xmlResult[i].dimension.y  * _displayScaleY, xmlResult[i].dimension.width * _displayScaleY, xmlResult[i].dimension.height * _displayScaleY);
				}
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

		
		
		/**
		 * 
		 * BitmapData 이미지를 AsyncPNGEncoder를 통해 png ByteArray 로 변환후 파일 출력.
		 * 비동기식으로 동작.
		 * 
		 */
		private function makeSpriteSheetPNGFile(spriteSheetBitmapData:BitmapData):void
		{
		
			
			_asyncPNGEncoder = new AsyncPNGEncoder();
			
			_asyncPNGEncoder.addEventListener(AsyncImageEncoderEvent.PROGRESS, encodeProgressHandler);
			_asyncPNGEncoder.addEventListener(AsyncImageEncoderEvent.COMPLETE, encodeCompleteHandler);
			
			
			var format:TextFormat = new TextFormat();
			format.size = 48;
			
			
			_pngCompleteInfoField = new TextField();
			_pngCompleteInfoField.defaultTextFormat = format;
			_pngCompleteInfoField.autoSize = TextFieldAutoSize.CENTER;
			_pngCompleteInfoField.x = (Capabilities.screenResolutionX / 2) - (_pngCompleteInfoField.width / 2);
			_pngCompleteInfoField.y = Capabilities.screenResolutionY - 200;
			trace(_pngCompleteInfoField.x + " : " + _pngCompleteInfoField.y);
			_pngCompleteInfoField.text = "[spritesheet.png] generation start.";
			addChild(_pngCompleteInfoField);
			
			_asyncPNGEncoder.start(spriteSheetBitmapData, 100);
			
			
		}
		
		private function encodeProgressHandler(event:AsyncImageEncoderEvent):void
		{
			_pngCompleteInfoField.text = "[spritesheet.png] generation : " + Math.floor(event.percentComplete) + "% complete";
			trace("encoding progress:", Math.floor(event.percentComplete)+"% complete");
		}
		
		private function encodeCompleteHandler(event:AsyncImageEncoderEvent):void
		{
			_asyncPNGEncoder.removeEventListener(AsyncImageEncoderEvent.PROGRESS, encodeProgressHandler);
			_asyncPNGEncoder.removeEventListener(AsyncImageEncoderEvent.COMPLETE, encodeCompleteHandler);

			trace("encoding completed:", _asyncPNGEncoder.encodedBytes.length + " bytes");
				
			var fileName:String = "spritesheet.png";
			
			//			var pngFile:File = File.applicationStorageDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);
			var pngFile:File = File.documentsDirectory.resolvePath(OUTPUT_RESOURCE_PATH + fileName);
			//Android documentsDirectory   :   /mnt/sdcard
			//iOS documentsDirectory 	   :   /var/mobile/Applications/uid/Documents
			
			var xmlStream:FileStream = new FileStream();
			xmlStream.open(pngFile, FileMode.WRITE);			
			xmlStream.writeBytes(_asyncPNGEncoder.encodedBytes, 0,0);
			xmlStream.close();
			
			_pngCompleteInfoField.text = "[spritesheet.png] generation : 100% completed.";

			
			_asyncPNGEncoder.dispose();				//PNG인코더 메모리 dispose
			
		}
	}
}