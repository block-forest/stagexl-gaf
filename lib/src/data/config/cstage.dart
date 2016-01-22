 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CStage
	{
		 int fps;
		 int color;
		 int width;
		 int height;
		
		  CStage clone(Object source)
		{
			fps = source.fps;
			color = source.color;
			width = source.width;
			height = source.height;
			
			return this;
		}
	}
