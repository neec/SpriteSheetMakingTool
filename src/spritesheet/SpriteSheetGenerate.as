package spritesheet
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class SpriteSheetGenerate
	{
		
		private var _insertionTree:Array;
		private var _insertedImagesMap:Array;

		
		public function SpriteSheetGenerate()
		{
			_insertionTree = new Array();
			_insertedImagesMap = new Array();
		}


		
		/**
		 * 
		 * SpriteSheet 제작, xml 문서 제작에 필요한 Frame 값 저장.
		 *
		 * 
		 */
		public function generate(frames:Vector.<Object>):Object 	
		{
			
			var size:Point = new Point(256, 256);
			//	 var size:Point = new Point(512, 512);
			//	 var size:Point = new Point(1024, 1024);
			//	 var size:Point = new Point(2048, 2048);
			//	 var size:Point = new Point(1080, 1920);	 //갤럭시 노트3 해상도
			
			var atlas:Vector.<Frame> = new Vector.<Frame>();
			var sortedFrames:Vector.<Object> = frames.concat().sort(compareSizes);
			var spriteSheet:BitmapData = new BitmapData(size.x, size.y, true, 0);
			_insertionTree.push(spriteSheet.rect);
			
			for (var i:int = 0; i < sortedFrames.length; ++i) 
			{
				var currentFrame:Object = sortedFrames[i];
				var f:Frame;
				var rect:Rectangle = currentFrame.bitmap.bitmapData.rect.clone();
				
				rect.width += 2;
				rect.height += 2;
				
				var point:Point = insert(rect);
				
				
				//spriteSheet의 사이즈가 이미지를 모두 표현하기에 작을 경우,
				//가로 세로 2배의 크기로 사이즈 변경 후 제작.
				if(!point)
				{
					size = new Point(size.x * 2, size.y * 2);
					spriteSheet.dispose();
					spriteSheet = new BitmapData(size.x, size.y, true, 0);
					
					_insertedImagesMap = new Array();
					atlas = new Vector.<Frame>();
					
					_insertionTree = new Array();
					_insertionTree.push(spriteSheet.rect);
					
					i= -1;
					continue;
				}
				
				
				var frameRegion:Rectangle = new Rectangle(point.x, point.y, currentFrame.bitmap.width, currentFrame.bitmap.height);
				
				f = new Frame(currentFrame.name, frameRegion);
				atlas.push(f);
				
				spriteSheet.copyPixels(currentFrame.bitmap.bitmapData, currentFrame.bitmap.bitmapData.rect, point);
				
			}
			
			trace("size : " + size.x +  ", " + size.y);
			return {"bitmapData": spriteSheet, "atlas": atlas};
			
		}
		
		
		/**
		 * 
		 * SpriteSheet 제작시 공간 활용을 위한 알고리즘.
		 * parking lightmaps 알고리즘 http://www.blackpawn.com/texts/lightmaps/default.html 참고.
		 *  
		 * 
		 */
		private function insert(imgRect:Rectangle, index:int = 0):Point 
		{
			
			trace("index : " + index)
			
			var currentRect:Rectangle = _insertionTree[index] as Rectangle;
			
			if (!currentRect) 
			{
				var point:Point = insert(imgRect, _insertionTree[index][0]);
				
				if (point)
					return point;
				
				return insert(imgRect, _insertionTree[index][1]);
			} 
			else 
			{
				//이미 이미지가 공간을 차지해서 사용할 수 없는 공간일 경우,
				if (_insertedImagesMap[index])
					return null;
				
				//이미지가 들어갈 공간보다 커서 들어갈 수 없을 경우,
				if (imgRect.width > currentRect.width || imgRect.height > currentRect.height)
					return null;
				
				//이미지가 들어갈 공간과 딱 맞아 떨어질 경우,
				if (imgRect.width == currentRect.width && imgRect.height == currentRect.height) 
				{
					_insertedImagesMap[index] = true;
					return new Point(currentRect.x, currentRect.y);
				}
				
				var dw:int = currentRect.width - imgRect.width;
				var dh:int = currentRect.height - imgRect.height;
				
				_insertionTree[index] = new Array();
				_insertionTree[index].push(_insertionTree.length);
				_insertionTree[index].push(_insertionTree.length + 1);
				
				
				if (dw > dh) //dw > dh 일 경우, currentRect.x + imgRect.width를 기준으로 수직선으로 Rectangle을 나눈다.
				{
					_insertionTree.push(new Rectangle(currentRect.x, currentRect.y, imgRect.width, currentRect.height));
					_insertionTree.push(new Rectangle(currentRect.x + imgRect.width, currentRect.y, dw, currentRect.height));
				} 
				else //dw < dh 일 경우, currentRect.y + imgRect.height를 기준으로 수평선으로 Rectangle을 나눈다.
				{
					_insertionTree.push(new Rectangle(currentRect.x, currentRect.y, currentRect.width, imgRect.height));
					_insertionTree.push(new Rectangle(currentRect.x, currentRect.y + imgRect.height, currentRect.width, dh));
				}

				return insert(imgRect, _insertionTree.length - 2);
			}
		}
		
		private function compareSizes(leftObject:Object, rightObject:Object):Number 
		{
			return rightObject.bitmap.height - leftObject.bitmap.height;
		}
	}
}