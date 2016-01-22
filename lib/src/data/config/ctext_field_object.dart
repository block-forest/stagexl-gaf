/**
 * Created by Nazar on 03.03.14.
 */
 part of stagexl_gaf;

	/**
	 * @
	 */
	 class CTextFieldObject
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------

		 String _id;
		 num _width;
		 num _height;
		 String _text;
		 bool _embedFonts;
		 bool _multiline;
		 bool _wordWrap;
		 String _restrict;
		 bool _editable;
		 bool _selectable;
		 bool _displayAsPassword;
		 int _maxChars;
		 TextFormat _textFormat;
		 Point _pivotPoint;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CTextFieldObject(String id,String text,TextFormat textFormat,num width,num height)
		{
			_id = id;
			_text = text;
			_textFormat = textFormat;

			_width = width;
			_height = height;

			_pivotPoint = new Point(0,0);
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  EVENT HANDLERS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		  String get id
		{
			return this._id;
		}

		  void set id(String value)
		{
			this._id = value;
		}

		  String get text
		{
			return this._text;
		}

		  void set text(String value)
		{
			this._text = value;
		}

		  TextFormat get textFormat
		{
			return this._textFormat;
		}

		  void set textFormat(TextFormat value)
		{
			this._textFormat = value;
		}

		  num get width
		{
			return this._width;
		}

		  void set width(num value)
		{
			this._width = value;
		}

		  num get height
		{
			return this._height;
		}

		  void set height(num value)
		{
			this._height = value;
		}

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------

		  bool get embedFonts
		{
			return this._embedFonts;
		}

		  void set embedFonts(bool value)
		{
			this._embedFonts = value;
		}

		  bool get multiline
		{
			return this._multiline;
		}

		  void set multiline(bool value)
		{
			this._multiline = value;
		}

		  bool get wordWrap
		{
			return this._wordWrap;
		}

		  void set wordWrap(bool value)
		{
			this._wordWrap = value;
		}

		  String get restrict
		{
			return this._restrict;
		}

		  void set restrict(String value)
		{
			this._restrict = value;
		}

		  bool get editable
		{
			return this._editable;
		}

		  void set editable(bool value)
		{
			this._editable = value;
		}

		  bool get selectable
		{
			return this._selectable;
		}

		  void set selectable(bool value)
		{
			this._selectable = value;
		}

		  bool get displayAsPassword
		{
			return this._displayAsPassword;
		}

		  void set displayAsPassword(bool value)
		{
			this._displayAsPassword = value;
		}

		  int get maxChars
		{
			return this._maxChars;
		}

		  void set maxChars(int value)
		{
			this._maxChars = value;
		}

		  Point get pivotPoint
		{
			return this._pivotPoint;
		}

		  void set pivotPoint(Point value)
		{
			this._pivotPoint = value;
		}
	}
