Polymer
    is: '#GRUNT_COMPONENT_NAME'

    ready: ()->
      
      this.attach = ()->
        div = document.createElement('div')
        Polymer.dom(this).appendChild(div)
        $(this).on('DOMNodeInserted', ()->
          this.distributeChilds())

    attached: ()-> 
      this.distributeChilds()

    distributeChilds: ()->
      console.log ("distributeChilds_called")
      
      # Covert HtmlCollection given by Polymer, to an Array
      directChilds = [].slice.call(Polymer.dom(this).children)
      console.log directChilds
      gsPanelsHeight = $(this).height()
      gsPanelsWidth = $(this).width()
      console.log gsPanelsHeight
      console.log gsPanelsWidth

      if (typeof directChilds != 'undefined') && (directChilds.length > 0)
        console.log directChilds.length
        heigthOfEachPanel = Math.round(gsPanelsHeight / directChilds.length)
        widthOfEachPanel = Math.round(gsPanelsWidth / directChilds.length)

      mkPanel = (panel, width, height)->
        console.log width
        console.log height

        $(panel).outerWidth(width)
        $(panel).outerHeight(height)

      arrayInit = (array)->
        if array.length > 0
          return array.slice(0,-1)
        else
          console.log "Array is Empty"

      mkVerticalLayout = (panels, panelW, panelH, containerWidth) ->
        directChildsWithoutLast = arrayInit(panels)
        for panel in directChildsWithoutLast
          containerWidth -= panelW
          console.log containerWidth
          console.log "containerWidth"
          mkPanel(panel, panelW, panelH)
        mkPanel(panels.slice(-1)[0], containerWidth, panelH)

      mkHorizontalLayout = (panels, panelW, panelH, containerHeight) ->
        if panels.length == 1
          mkPanel(panels[0], panelW, panelH)
        else
          directChildsWithoutLast = arrayInit(panels)
          for panel in directChildsWithoutLast
            containerHeight -= panelH
            console.log containerHeight
            mkPanel(panel, panelW, panelH)
          mkPanel(panels.slice(-1)[0], panelW, containerHeight)

      if (typeof directChilds != 'undefined') && (directChilds.length > 0)
        mkHorizontalLayout(directChilds, gsPanelsWidth, heigthOfEachPanel, gsPanelsHeight)
        # mkVerticalLayout(directChilds, widthOfEachPanel, gsPanelsHeight, gsPanelsWidth)
