Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  MIN_WIDTH: 150
  MIN_HEIGHT: 100
  
  properties: 
    children:
      type: Array
      value: []
    panelWidth:
      type: Number 
      value: 100
      observer: '_panel_width_change'
    orientation:
      type: String
  behaviors: [GS.Rezisable]
  
  __fresh: true
  INITIAL_HEIGHT: 400
  
  observers: ['_children_change(children.*)']
  
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
    
  attached:->
    @orientation = @orientation or GS.HORIZONTAL
    @classList.add @orientation 
    @extend @, @flow_strategies[@orientation]
    
  _children_change:->
    if @children.length > 0
      @style.height = @panelHeight + 'px'
    else
      @style.height = 'none'
    last_index = @children.length - 1
    for child, index in @children
      child.index = index
      child.notLast = index isnt last_index

  add: (element)->
    next = document.createElement 'gs-panel-simple'
    next.resize_data = {}
    next.concretElement = element
    next.parentOrientation = @orientation
    @_after_push next, 0
    @push 'children', next
  
  _panel_width_change: ->
    @__set_width_percent @panelWidth
    
  flow_strategies:
    horizontal:
      _after_push: (element)->
        amount = @children.length + 1
        count = 0
        average = 100 / amount
        for child in @children
          child.panelWidth = average
          count += child.resize_data.width
        last_width = 100 - count
        element.panelWidth = last_width
        element.panelHeight = @panelHeight
        
      __child_resize_begin: (context, position)->
        #context.item cannot be the last child
        context.initial_mouse_x = position.clientX
        context.initial_width = context.item.clientWidth
        context.initial_width_percent = @parse_percent context.item.style.width
        next_item = @children[context.item.index + 1]
        context.max_width = context.item.clientWidth + next_item.clientWidth - @MIN_WIDTH
        context.item.style.transition = 'none'

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
        context.item.panelWidth = next_percent
        @__fix_width_against @children[context.item.index + 1]

      __child_resize_finish: (context, position)->
        context.item.style.transition = '0.5s'
        
      __fix_width_against: (fix_item)->
        count = 0
        for child in @children
          if child is fix_item
            continue
          count += child.resize_data.width
        fix_item.panelWidth = 100 - count   

    vertical:
      _after_push: (element)->
        amount = @children.length + 1
        count = 0
        total = @fixedHeight
        average = total / amount
        for child in @children
          child.panelHeight = average
          count += child.resize_data.height
        last_height = total - count
        element.panelHeight = last_height

      __child_resize_begin: (context, position)->
        #context.item cannot be the last child
        context.initial_mouse_y = position.clientY
        context.initial_height = context.item.clientHeight
        context.initial_height_px = @parse_px context.item.style.height
        next_item = @children[context.item.index + 1]
        context.max_height = context.item.clientHeight + next_item.clientHeight - @MIN_HEIGTH
        context.item.style.transition = 'none'
        
      __child_resize: (context, position)->
        #context.item cannot be the last child
        height = @clientHeight
        x_delta = position.clientY - context.initial_mouse_y
        next_px = context.initial_height + x_delta
        if next_px > context.max_height
          next_px = context.max_height
        if next_px < @MIN_HEIGHT
          next_px = @MIN_HEIGHT
        next_percent = context.initial_height_px * next_px / context.initial_height
        context.item.panelHeight = next_percent
        @__fix_height_against @children[context.item.index + 1]
        
      __fix_height_against: (fix_item)->
        count = 0
        for child in @children
          if child is fix_item
            continue
          count += child.resize_data.height
        fix_item.panelHeight = @fixedHeight - count 
         
      __child_resize_finish: (context, position)->
      
      __propagate_height_change:->
        amount = @children.length
        if amount > 0
          last_item = @children[amount - 1]
          count = 0
          total = @fixedHeight
          average = total / amount
          for child in @children
            if child is last_item then continue
            child.panelHeight = average
            count += child.resize_data.height
          last_height = total - count
          last_item.panelHeight = last_height
        
