Polymer
    is: '#GRUNT_COMPONENT_NAME'

    properties: 
      orientation:
        type: String
        value: "horizontal"

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