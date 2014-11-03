/*
	Author:		Arvydas Burdulis, http://cgart.lt, http://turbomask.com
*/

package AE.Fractals
{
	public class Transformation
	{
		public static const TRANSLATION:int	= 0;
		public static const ROTATION:int	= 1;
		public static const SCALE:int		= 2;
		public static const COLOR:int		= 3;
		public var type:int;
		public var p1:Number;
		public var p2:Number;
		
		public function Transformation(_type:int, _p1:Number, _p2:Number = 0.0)
		{
			type = _type;
			p1 = _p1;
			p2 = _p2;
		}
		
		public function SetParam(num:int, value:Number)
		{
			if(num == 0){
				p1 = value;
			}
			else if(num == 1){
				p2 = value;
			}
		}
	}
}