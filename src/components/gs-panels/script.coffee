Polymer
    is: '#GRUNT_COMPONENT_NAME'

    properties: 
      orientation:
        type: String
        value: "horizontal"
      childs:
        type: Array
        value:[]
    listeners:
      'closePanel': '_checkChilds'

    attached: ->
      # Revisar
      if this.orientation is "horizontal"
        this.style.flexDirection = "row"
      else
        this.style.flexDirection = "column" 

    addSingleElement: (htmlElement)->
      gsSimplePanel = document.createElement("gs-simple-panel")
      gsSimplePanel.appendChild(htmlElement)
      gsSimplePanel.classList.add("container")
      gsSimplePanel.classList.add(this.orientation)
      Polymer.dom(this).appendChild(gsSimplePanel)

    addMultipleElment: (htmlElementList, orientation)->
      gsCompoundPanel = document.createElement("gs-compound-panel")
      gsCompoundPanel.orientation = orientation
      for htmlElement in htmlElementList
        gsCompoundPanel.addSingleElement(htmlElement)
      Polymer.dom(this).appendChild(gsCompoundPanel)