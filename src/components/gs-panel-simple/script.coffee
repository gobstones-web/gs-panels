Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties:
    concretElement:
      type: Object
    panelHeight:
      type: Number
      observer: '_panel_height_change'
    index:
      type: Number

  behaviors: [GS.Rezisable] 
  
  ready: ->
    @container = @$.container
  
  _panel_height_change:->
    @clientHeight = @panelHeight + 'px'
    @concretElement.style.height = @panelHeight + 'px'
  
    
