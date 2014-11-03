/*
	Author:		Arvydas Burdulis, http://cgart.lt, http://turbomask.com
*/

package AE.Fractals
{
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.ColorTransform;
	import AE.Fractals.Transformation;
	
	public class Transformations
	{
		public var transforms:Vector.<Matrix>;
		public var transf_params:Vector.<Vector.<Transformation>>;
		public var colors:Vector.<ColorTransform>;
		public var global_transf:Point;
		public var global_scale:Number;
		public var size:Number;
		
		public function Transformations()
		{
			transf_params = new Vector.<Vector.<Transformation>>();
			transforms = new Vector.<Matrix>();
			colors = new Vector.<ColorTransform>();
			global_transf = new Point(0.0, 0.0);
			global_scale = 1.0;
			size = 0.0;
		}
		
		function Clear()
		{
			global_transf = new Point(0.0, 0.0);
			global_scale = 1.0;
			if(transf_params.length > 0){
				transf_params.splice(0, transf_params.length);
			}
			if(colors.length > 0){
				colors.splice(0, colors.length);
			}
		}
		
		public function Init(_data:String)
		{
			var i:int;
			var j:int;
			var transfs:Vector.<Transformation>;
			Clear();
			if(_data.indexOf("<?xml") >= 0){
				trace("Open XML");
				var _xml:XML = new XML(_data);
				global_transf.x = parseFloat(_xml.global_data.transf_x);
				global_transf.y = parseFloat(_xml.global_data.transf_y);
				global_scale = parseFloat(_xml.global_data.scale);
				for(i = 0; i < _xml.transformation.length(); i++){
					transfs = new Vector.<Transformation>();
					for(j = 0; j < _xml.transformation[i].transf.length(); j++){
						var _xml_part:XML = _xml.transformation[i].transf[j];
						if(_xml_part.@type == "translate"){
							transfs.push(new Transformation(Transformation.TRANSLATION, parseFloat(_xml_part.@x), parseFloat(_xml_part.@y)));
						}
						else if(_xml_part.@type == "rotate"){
							transfs.push(new Transformation(Transformation.ROTATION, parseFloat(_xml_part.@rot)));
						}
						else if(_xml_part.@type == "scale"){
							transfs.push(new Transformation(Transformation.SCALE, parseFloat(_xml_part.@x), parseFloat(_xml_part.@y)));
						}
					}
					transf_params.push(transfs);
					if(_xml.transformation[i].hasOwnProperty("color")){
						colors.push(new ColorTransform(1.0, 1.0, 1.0, 0.95,
							parseFloat(_xml.transformation[i].color.@r),
							parseFloat(_xml.transformation[i].color.@g),
							parseFloat(_xml.transformation[i].color.@b)
						));
					}
					else{
						colors.push(GenerateColor());
					}
				}
			}
			else{
				//Legacy support for old data format
				trace("Open old format");
				var rows:Array = _data.split(/[\x0A\x0D]+/);
				trace("Rows: " + rows.length);
				var num:int = 0;
				var _transf_count:int = parseInt(rows[num++].substr(2));
				trace("Transf count: " + _transf_count);
				for(i = 0; i < _transf_count; i++){
					var _count:int = parseInt(rows[num++]);
					transfs = new Vector.<Transformation>();
					for(j = 0; j < _count; j++){
						var row_data:Array = rows[num++].split(" ");
						if(row_data[0] == "T"){
							transfs.push(new Transformation(Transformation.TRANSLATION, parseFloat(row_data[1]), parseFloat(row_data[2])));
						}
						else if(row_data[0] == "R"){
							transfs.push(new Transformation(Transformation.ROTATION, parseFloat(row_data[1])));
						}
						else if(row_data[0] == "S"){
							transfs.push(new Transformation(Transformation.SCALE, parseFloat(row_data[1]), parseFloat(row_data[2])));
						}
					}
					transf_params.push(transfs);
					var color:ColorTransform = GenerateColor();
					colors.push(color);
				}
			}
		}
		
		public function Generate()
		{
			Clear();
			var count:int = int(Math.random() * 7) + 2;
			for(var i:int = 0; i < count; i++){
				var transf:Vector.<Transformation> = GenerateTransformation();
				transf_params.push(transf);
				var color:ColorTransform = GenerateColor();
				colors.push(color);
			}
		}
		
		public function Prepare(_size:Number)
		{
			size = _size;
			var cx:Number = size / 2.0;
			var cy:Number = size / 2.0;
			if(transforms.length > 0){
				transforms.splice(0, transforms.length);
			}
			for(var i:int = 0; i < transf_params.length; i++){
				var _transf:Matrix = new Matrix();
				_transf.translate(-cx - global_transf.x * size, -cy - global_transf.y * size);
				for(var j:int = 0; j < transf_params[i].length; j++){
					var params:Transformation = transf_params[i][j];
					if(params.type == Transformation.TRANSLATION){
						_transf.translate(params.p1 * cx * global_scale, params.p2 * cy * global_scale);
					}
					else if(params.type == Transformation.ROTATION){
						_transf.rotate(params.p1);
					}
					else if(params.type == Transformation.SCALE){
						_transf.scale(params.p1, params.p2);
					}
				}
				_transf.translate(cx + global_transf.x * size, cy + global_transf.y * size);
				transforms.push(_transf);
			}
		}
		
		public function GenerateColors()
		{
			for(var i:int = 0; i < colors.length; i++){
				colors[i] = GenerateColor();
			}
		}
		
		public function GetInfo():String
		{
			var _res:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<data>\n";
			_res += "<global_data>\n";
			_res += "\t<transf_x>" + global_transf.x + "</transf_x>\n";
			_res += "\t<transf_y>" + global_transf.y + "</transf_y>\n";
			_res += "\t<scale>" + global_scale + "</scale>\n";
			_res += "</global_data>\n";
			for(var i:int = 0; i < transf_params.length; i++){
				_res += "<transformation>\n";
				for(var j:int = 0; j < transf_params[i].length; j++){
					_res += "\t<transf type=\"";
					var params:Transformation = transf_params[i][j];
					if(params.type == Transformation.TRANSLATION){
						_res += "translate\" x=\"" + params.p1 + "\" y=\"" + params.p2 + "\" />\n";
					}
					else if(params.type == Transformation.ROTATION){
						_res += "rotate\" rot=\"" + params.p1 + "\" />\n";
					}
					else if(params.type == Transformation.SCALE){
						_res += "scale\" x=\"" + params.p1 + "\" y=\"" + params.p2 + "\" />\n";
					}
				}
				_res += "\t<color r=\"" + colors[i].redOffset + "\" g=\"" + colors[i].greenOffset + "\" b=\"" + colors[i].blueOffset + "\" />\n";
				_res += "</transformation>\n";
			}
			_res += "</data>";
			return _res;
		}
		
		function GenerateTransformation():Vector.<Transformation>
		{
			var transfs:Vector.<Transformation> = new Vector.<Transformation>();
			var dx:Number = (Math.random() - 0.5) * 0.1;
			var dy:Number = (Math.random() - 0.5) * 0.1;
			var rot:Number = (Math.random() - 0.5) * 2.0;
			var sx:Number = 0.2 + Math.random() * 0.8;
			var sy:Number = 0.2 + Math.random() * 0.8;
			var dx2:Number = (Math.random() - 0.5) * 0.4;
			var dy2:Number = (Math.random() - 0.5) * 0.4;
			transfs.push(new Transformation(Transformation.TRANSLATION, dx, dy));
			transfs.push(new Transformation(Transformation.ROTATION, rot));
			transfs.push(new Transformation(Transformation.SCALE, sx, sy));
			transfs.push(new Transformation(Transformation.TRANSLATION, dx2, dx2));
			//trace("Matrix: \n" + transf.a + "\n" + transf.b + "\n0.0\n" + transf.c + "\n" + transf.d + "\n0.0\n" + transf.tx + "\n" + transf.ty + "\n1.0\n");
			return transfs;
		}
		
		function GenerateColor():ColorTransform
		{
			var color:ColorTransform = new ColorTransform(1.0, 1.0, 1.0, 0.95, Math.random() * 40 - 20, Math.random() * 40 - 20, Math.random() * 40 - 20);
			return color;
		}
	}
}