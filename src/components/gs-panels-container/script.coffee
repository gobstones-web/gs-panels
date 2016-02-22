Polymer
    is: '#GRUNT_COMPONENT_NAME'

    properties: 
      height:
        type: String
        value: "600px"
      orientation:
        type: String
        value: "horizontal"

    listeners: 
      'closePanel': '_checkChilds'

    attached: ()->
      # Set content width for the first time
      if this.orientation == "horizontal"
        this.setComponent(this, this.getInner(this, "width"), "width")
        this.style.height = this.height
      else
        if this.orientation == "vertical"
          this.setComponent(this, this.getInner(this, "height"), "height")
          this.style.width = this.width
      this._fixLayout()
    
    _fixLayout: ()->
      firstChildrens = Polymer.dom(this).children
      #Check if children is empty throw exception or do nothing
      if this.orientation == "horizontal"
        child.style.height = "100%" for child in firstChildrens
      else
        if this.orientation == "vertical"
          child.style.width = "100%" for child in firstChildrens

    _checkChilds: (eventData)->
      children = Polymer.dom(this).children
      if children.length == 0 or children == []
        Polymer.dom(Polymer.dom(this).parentNode).removeChild(this)
        this.fire('closePanel', {})
      else
        firstChildrens = Polymer.dom(this).children
        removedWidth = eventData.detail.getBoundingClientRect().width
        
        widthToAddForEachChild = removedWidth / firstChildrens.length
        
        this.incrementComponent(child, widthToAddForEachChild, "width") for child in firstChildrens

    getInner: (htmlElement, component)->
      style = window.getComputedStyle(htmlElement, null)
      parseFloat(style.getPropertyValue(component))
    
    setComponent: (htmlElement, newWidth, component)->
      htmlElement.style[component] = newWidth + "px"
    
    incrementComponent: (htmlElement, toIncrement, component)->
      newDimension = this.getInner(htmlElement, component) + toIncrement
      this.setComponent(htmlElement, newDimension, component)