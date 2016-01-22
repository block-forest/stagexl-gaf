/**
 * Created by Nazar on 05.03.14.
 */
 part of stagexl_gaf;


	/**
	 * An abstract class describes objects that contain all data used to initialize static GAF display objects such as <code>GAFImage</code>.
	 */
	 abstract class IGAFTexture
	{
		/**
		 * Returns Starling Texture object.
		 * @return a Starling Texture object
		 */
		 Texture get texture;

		/**
		 * Returns pivot matrix of the static GAF display object.
		 * @return a Matrix object
		 */
		 Matrix get pivotMatrix;

		/**
		 * An internal identifier of the region in a texture atlas.
		 * @return a String identifier
		 */
		 String get id;

		/**
		 * Returns a new object that is a clone of this object.
		 * @return object with abstract class <code>IGAFTexture</code>
		 */
		 IGAFTexture clone();

		/**
		 * Copies all of the data from the source object into the calling <code>IGAFTexture</code> object
		 * @param newTexture the <code>IGAFTexture</code> object from which to copy the data
		 */
		 void copyFrom(IGAFTexture newTexture);
	}
