 part of stagexl_gaf;
	/**
	 * The GAF class defines global GAF library settings
	 */
	 class GAF
	{
		/**
		 * Optimize draw calls when animation contain mixed objects with alpha &lt; 1 and with alpha = 1.
		 * This is done by setting alpha = 0.99 for all objects that has alpha = 1.
		 * In this case all objects will be rendered by one draw call.
		 * When use99alpha = false the number of draw call may be much more
		 * (the number of draw calls depends on objects order in display list)
		 */
		 static bool use99alpha;

		/**
		 * Play sounds, triggered by the event "gafPlaySound" in a frame of the GAFMovieClip.
		 */
		 static bool autoPlaySounds = true;

		/**
		 * Indicates if mipMaps will be created for PNG textures (or enabled for ATF textures).
		 */
		 static bool useMipMaps;

		/** @ */
		static bool useDeviceFonts;

		/** @ */
		static  num get maxAlpha
		{
			return use99alpha ? 0.99 : 1;
		}
	}
