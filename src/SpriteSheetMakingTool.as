/**
 *
 *  빌드 환경 :  Adobe AIR SDK 13.0, Android
 *  
 */
package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import spritesheet.MainLayer;
	
	public class SpriteSheetMakingTool extends Sprite
	{
		public function SpriteSheetMakingTool()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			
			var mainLayer:MainLayer = new MainLayer();
			addChild(mainLayer);
			
		}
		
		
		private function deactivate(e:Event):void {
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
	}
}