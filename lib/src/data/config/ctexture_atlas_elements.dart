 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CTextureAtlasElements
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

		 List<CTextureAtlasElement> _elementsList;
		 Map _elementsMap;
		 Map _elementsByLinkage;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		  void CTextureAtlasElements()
		{
			this._elementsList= new List<CTextureAtlasElement>();
			this._elementsMap = {};
			this._elementsByLinkage = {};
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void addElement(CTextureAtlasElement element)
		{
			if (!this._elementsMap[element.id])
			{
				this._elementsMap[element.id] = element;

				this._elementsLis.add(element);

				if (element.linkage)
				{
					this._elementsByLinkage[element.linkage] = element;
				}
			}
		}

		  CTextureAtlasElement getElement(String id)
		{
			if (this._elementsMap[id])
			{
				return this._elementsMap[id];
			}
			else
			{
				return null;
			}
		}

		  CTextureAtlasElement getElementByLinkage(String linkage)
		{
			if (this._elementsByLinkage[linkage])
			{
				return this._elementsByLinkage[linkage];
			}
			else
			{
				return null;
			}
		}

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

		 List<CTextureAtlasElement> get elementsList
		{
			return this._elementsList;
		}

	}
