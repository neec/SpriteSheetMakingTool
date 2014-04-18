package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import spritesheet.MainLayer;
	
	public class SpriteSheetMakingTool extends Sprite
	{
		public function SpriteSheetMakingTool()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var mainLayer:MainLayer = new MainLayer();
			addChild(mainLayer);
			
		}
	}
}