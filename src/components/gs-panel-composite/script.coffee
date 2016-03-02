Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties: 
    children:
      type: Array
      
  behaviors: [GS.Rezisable]
      
  created:->
    
  ready:->
    @children = []
  
  attached: ->
    if @panelHeight and not isNaN(@panelHeight) and @panelHeight isnt ''
      @style.maxHeight = @panelHeight + 'px'
    else
      maxHeight = window.getComputedStyle(@).maxHeight
      if /px$/.test maxHeight
        panel_height_and_resize_bar = parseFloat maxHeight.slice(0, -2)
        @panelHeight = panel_height_and_resize_bar - 7
      else
        @panelHeight = 0
  
  add: (element)->
    next = document.createElement 'gs-panel-simple'
    next.concretElement = element
    @__after_push next, 0
    @push 'children', next
 








