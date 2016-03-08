Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  MIN_WIDTH: 150
  MIN_HEIGHT: 100
  
  properties: 
    #panelChildren:
    #  type: Array
    #  value: []
    #  observer: '_panel_children_change'
    panelWidth:
      type: Number 
      value: 100
      observer: '_panel_width_change'
    orientation:
      type: String
  behaviors: [GS.Rezisable]
  
  observers: ['_children_change(panelChildren.*)']
  
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
    @panelChildren = []
    
  _panel_children_change:->
    console.log @panelChildren
    
  attached:->
    @orientation = @orientation or GS.HORIZONTAL
    console.log @identifier + ' [composite] attached'
    @classList.add @orientation 
    @extend @, @flow_strategies[@orientation]
    @_children_change()
  
  detached:->
    console.log @identifier + ' [composite] detached'
    
  _children_change:->
    if @panelChildren.length > 0
      @style.height = @panelHeight + 'px'
    else
      @style.height = 'none'
    last_index = @panelChildren.length - 1
    for child, index in @panelChildren
      child.index = index
      child.notLast = index isnt last_index
      
  add_panel_children: (panel)->
    console.log 'self: ' + @identifier
    console.log 'panel: ' + panel.identifier
    panel.parentOrientation = @orientation
    @_after_push panel, 0
    @push 'panelChildren', panel
    @_panel_children_change()
  
  add_composite: (ori, item_id)->
    next = document.createElement 'gs-panel-composite'
    next.orientation = ori
    next.identifier = item_id
    @add_panel_children next
    next
  
  add_simple: (element, item_id)->
    next = document.createElement 'gs-panel-simple'
    element.identifier = item_id + '-concret-element'
    next.concretElement = element
    next.identifier = item_id
    @add_panel_children next
    next
  
  _panel_width_change: ->
    @__set_width_percent @panelWidth
    
  flow_strategies:
    horizontal:
      _after_push: (element)->
        amount = @panelChildren.length + 1
        count = 0
        average = 100 / amount
        for child in @panelChildren
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
        next_item = @panelChildren[context.item.index + 1]
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
        @__fix_width_against @panelChildren[context.item.index + 1]

      __child_resize_finish: (context, position)->
        context.item.style.transition = '0.5s'
        
      __fix_width_against: (fix_item)->
        count = 0
        for child in @panelChildren
          if child is fix_item
            continue
          count += child.resize_data.width
        fix_item.panelWidth = 100 - count   

    vertical:
      _after_push: (element)->
        amount = @panelChildren.length + 1
        count = 0
        total = @fixedHeight
        average = total / amount
        for child in @panelChildren
          child.panelHeight = average
          count += child.resize_data.height
        last_height = total - count
        element.panelHeight = last_height

      __child_resize_begin: (context, position)->
        #context.item cannot be the last child
        context.initial_mouse_y = position.clientY
        context.initial_height  = context.item.panelHeight
        next_item = @panelChildren[context.item.index + 1]
        context.max_height = context.item.panelHeight + next_item.panelHeight - @MIN_HEIGHT
        #context.item.style.transition = 'none'
        
      __child_resize: (context, position)->
        #context.item cannot be the last child
        height = @clientHeight
        y_delta = position.clientY - context.initial_mouse_y
        next_px = context.initial_height + y_delta
        if next_px > context.max_height
          next_px = context.max_height
        if next_px < @MIN_HEIGHT
          next_px = @MIN_HEIGHT
        context.item.panelHeight = next_px
        @__fix_height_against @panelChildren[context.item.index + 1]
        
      __fix_height_against: (fix_item)->
        count = 0
        for child in @panelChildren
          if child is fix_item then continue
          count += child.resize_data.height
        fix_item.panelHeight = @fixedHeight - count 
         
      __child_resize_finish: (context, position)->
        #context.item.style.transition = '0.5s'
      
      __propagate_height_change:->
        amount = @panelChildren.length
        if amount > 0
          last_item = @panelChildren[amount - 1]
          count = 0
          total = @fixedHeight
          average = total / amount
          for child in @panelChildren
            if child is last_item then continue
            child.panelHeight = average
            count += child.resize_data.height
          last_height = total - count
          last_item.panelHeight = last_height
        
