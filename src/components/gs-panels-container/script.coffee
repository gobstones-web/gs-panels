Polymer
    is: '#GRUNT_COMPONENT_NAME'

    properties: 
      orientation:
        type: String
        value: "Vertical"

    listeners: 
      'closePanel': '_checkChilds'

    _checkChilds: (e)->
      children = Polymer.dom(this).children
      if children.length == 0 or children == []
        Polymer.dom(Polymer.dom(this).parentNode).removeChild(this)
        this.fire('closePanel', {})
      else
        removedHeigth = e.detail.offsetWidth
        porcent = (removedHeigth * 100) / this.offsetWidth
        firstChildrens = Polymer.dom(this).children
        child.getBoundingClientRect() for child in firstChildrens

    calculateWidth: ()->
      firstChildrens = Polymer.dom(this).children
      (child.offsetWidth for child in firstChildrens).reduce(((a, b)-> a + b) , 0)
      
    attached: ()->
      this.setWidth(this, this.getWidth(htmlElement))
    
    getWidth: (htmlElement)->
      htmlElement.getBoundingClientRect().width
    
    setWidth: (htmlElement, newWidth )->
      htmlElement.style.width = newWidth  + "px"

    setWithPlusPercent: (htmlElement, percent)->
      newWidth = this.getWidth(htmlElement) * percent
      this.setWidth()