package spritesheet
{
	import flash.geom.Rectangle;

	public class Frame {

		private var _name:String;
		private var _dimension:Rectangle;
		
		
		public function Frame(n:String, d:Rectangle) {
			_name = n;
			_dimension = d;
		}
		
		public function get name():String
		{
			return _name;
		}
		

		
		public function get dimension():Rectangle
		{
			return _dimension;
		}
	}
}