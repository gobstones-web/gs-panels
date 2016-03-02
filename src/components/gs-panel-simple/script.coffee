Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties:
    concretElement:
      type: Object
    panelHeight:
      type: Number  
      observer: '_panel_height_change'
      
  behaviors: [GS.Rezisable] 
  
  ready: ->
    @container = @$.container
    @classList.add 'child-of-' + @parentOrientation
  
  _panel_height_change:->
    @clientHeight = @panelHeight + 'px'
    @concretElement.style.height = @panelHeight + 'px'