Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties: 
    children:
      type: Array
    panelHeight:
      type: Number 
      value: 0 
    orientation:
      type: String
  behaviors: [GS.Rezisable]
  
  observers: ['_update(children.*, panelHeight)']
      
  ready:->
    @children = []
    @orientation = @orientation or GS.HORIZONTAL
    @classList.add @orientation 
    @classList.add 'child-of-' + @parentOrientation
    
  _update:->
    if @children.length > 0
      @style.height = @panelHeight + 'px'
    else
      @style.height = 'none'
    #TODO do vertical mode
    last_index = @children.length - 1
    for child, index in @children
      child.panelHeight = @panelHeight
      child.notLast = index isnt last_index
      
  add: (element)->
    next = document.createElement 'gs-panel-simple'
    next.concretElement = element
    next.parentOrientation = @orientation
    @__after_push next, 0
    @push 'children', next
 








