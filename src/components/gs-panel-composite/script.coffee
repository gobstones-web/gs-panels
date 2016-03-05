Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  MIN_WIDTH: 150
  
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
  
  listeners: do ->
    listeners = {}
    listeners[GS.EVENTS.CHILD_RESIZE_BEGIN]  = '__forward_child_resize_begin'
    listeners[GS.EVENTS.CHILD_RESIZE]        = '__forward_child_resize'
    listeners[GS.EVENTS.CHILD_RESIZE_FINISH] = '__forward_child_resize_finish'
    listeners
    
  __forward_child_resize_begin: (evnt)->
    evnt.cancelBubble = true
    @__child_resize_begin(evnt.detail.context, evnt.detail.position)
  __forward_child_resize: (evnt)->
    evnt.cancelBubble = true
    @__child_resize(evnt.detail.context, evnt.detail.position)
  __forward_child_resize_finish: (evnt)->
    evnt.cancelBubble = true
    @__child_resize_finish(evnt.detail.context, evnt.detail.position)
      
  ready:->
    @children = []
    @orientation = @orientation or GS.HORIZONTAL
    @classList.add @orientation 
    @extend @, @flow_strategies[@orientation]
    
  _update:->
    if @children.length > 0
      @style.height = @panelHeight + 'px'
    else
      @style.height = 'none'
    last_index = @children.length - 1
    for child, index in @children
      child.index = index
      child.panelHeight = @panelHeight
      child.notLast = index isnt last_index
      
  add: (element)->
    next = document.createElement 'gs-panel-simple'
    next.resize_data = {}
    next.concretElement = element
    next.parentOrientation = @orientation
    @_after_push next, 0
    @push 'children', next
    
  parse_percent_width: (child)->
    @parse_percent child.style.width
  
  __set_width_percent: (child, percent)->
    child.style.width = percent + '%'
    child.resize_data.width = @parse_percent_width child
  
  flow_strategies:
    horizontal:
      _after_push: (element)->
        amount = @children.length + 1
        count = 0
        average = 100 / amount
        for child in @children
          @__set_width_percent child, average
          count += child.resize_data.width
        last_width = 100 - count
        @__set_width_percent element, last_width
        
      __child_resize_begin: (context, position)->
        #context.item cannot be the last child
        context.initial_mouse_x = position.clientX
        context.initial_width = context.item.clientWidth
        context.initial_width_percent = @parse_percent context.item.style.width
        next_item = @children[context.item.index + 1]
        context.max_width = context.item.clientWidth + next_item.clientWidth - @MIN_WIDTH
        context.item.style.transition = 'none'
      
      __fix_width_against: (fix_item)->
        count = 0
        for child in @children
          if child is fix_item
            continue
          count += child.resize_data.width
        @__set_width_percent fix_item, 100 - count
        
      __child_resize: (context, position)->
        #context.item cannot be the last child
        width = @clientWidth
        x_delta = position.clientX - context.initial_mouse_x
        next_px = context.initial_width + x_delta
        if next_px > context.max_width
          next_px = context.max_width
        if next_px < @MIN_WIDTH
          next_px = @MIN_WIDTH
        next_percent = context.initial_width_percent * next_px / context.initial_width
        @__set_width_percent context.item, next_percent
        @__fix_width_against @children[context.item.index + 1], context.item
        
      __child_resize_finish: (context, position)->
        context.item.style.transition = '0.5s'
          
    vertical:
      _after_push: (element)->






