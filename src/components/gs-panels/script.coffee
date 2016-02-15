Polymer
    is: '#GRUNT_COMPONENT_NAME'

    attached: ()->

      # Covert HtmlCollection given by Polymer, to an Array
      directChilds = [].slice.call(this.children)

      gsPanelsHeight = $(this).height()
      gsPanelsWidth = $(this).width()
      
      heigthOfEachPanel = Math.round(gsPanelsHeight / directChilds.length)
      widthOfEachPanel = Math.round(gsPanelsWidth / directChilds.length)
      
      console.log gsPanelsWidth
      console.log gsPanelsHeight

      mkPanel = (panel, width, height)->
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
          mkPanel(panel, panelW, panelH)
        mkPanel(panels.slice(-1)[0], containerWidth, panelH)


      mkHorizontalLayout = (panels, panelW, panelH, containerHeight) ->
        directChildsWithoutLast = arrayInit(panels)
        for panel in directChildsWithoutLast
          containerHeight -= panelH
          mkPanel(panel, panelW, panelH)
        mkPanel(panels.slice(-1)[0], panelW, containerHeight)

      mkHorizontalLayout(directChilds, gsPanelsWidth, heigthOfEachPanel, gsPanelsHeight)
      # mkVerticalLayout(directChilds, widthOfEachPanel, gsPanelsHeight, gsPanelsWidth)
