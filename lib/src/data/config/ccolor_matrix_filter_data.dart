 part of stagexl_gaf;

	/**
	 * @
	 */
	 class CColorMatrixFilterData implements ICFilterData
	{
		 List<num> matrix = new List<num>(20, true);

		  ICFilterData clone()
		{
			CColorMatrixFilterData copy = new CColorMatrixFilterData();

			Listtility.copyMatrix(copy.matrix, this.matrix);

			return copy;
		}
	}
