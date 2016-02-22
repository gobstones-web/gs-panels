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
        firstChildrens = Polymer.dom(this).children
        removedWidth = e.detail.getBoundingClientRect().width
        console.log removedWidth
        widthToAddForEachChild = removedWidth / firstChildrens.length
        console.log widthToAddForEachChild
        
        this.addWidth(child, widthToAddForEachChild) for child in firstChildrens

    calculateWidth: ()->
      firstChildrens = Polymer.dom(this).children
      (child.offsetWidth for child in firstChildrens).reduce(((a, b)-> a + b) , 0)
      
    attached: ()->
      # Set content width for the first time
      this.setWidth(this, this.getInnerWidth(this))

    getInnerWidth: (htmlElement)->
      style = window.getComputedStyle(htmlElement, null)
      parseFloat(style.getPropertyValue("width"))
    
    setWidth: (htmlElement, newWidth)->
      htmlElement.style.width = newWidth + "px"

    addWidth: (htmlElement, widthToAdd)->
      newWidth = this.getInnerWidth(htmlElement) + widthToAdd
      this.setWidth(htmlElement, newWidth)