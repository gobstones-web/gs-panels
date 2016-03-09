Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  MIN_WIDTH: 150
  MIN_HEIGHT: 50
  
  properties: 
    orientation:
      type: String
  behaviors: [GS.Rezisable]
  
  listeners: do ->
    listeners = {}
    listeners[GS.EVENTS.CHILD_RESIZE_BEGIN]  = '__forward_child_resize_begin'
    listeners[GS.EVENTS.CHILD_RESIZE]        = '__forward_child_resize'
    listeners[GS.EVENTS.CHILD_RESIZE_FINISH] = '__forward_child_resize_finish'
    listeners[GS.EVENTS.CHILD_REMOVE]        = '__forward_child_remove'
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
  __forward_child_remove: (evnt)->
    evnt.cancelBubble = true
    @child_remove(evnt.detail.item)
      
  ready:->
    @deferred = []
    @panelChildren = []
  
  get_children_tree: ->
    id: @identifier
    items: (item.get_children_tree() for item in @panelChildren.concat(@deferred))
  
  process_deferred:->
    for deferred in @deferred
      @add_panel_children deferred
    @deferred.length = 0
  
  attached:->
    @be_attached = true
    @orientation = @orientation or GS.HORIZONTAL
    @classList.add @orientation 
    @extend @, @flow_strategies[@orientation]
    @process_deferred()
    @__propagate_height_change()
    
  _panel_children_change:->
    last_index = @panelChildren.length - 1
    for child, index in @panelChildren
      child.index = index
      child.notLast = index isnt last_index
    @__propagate_height_change()
      
  add_panel_children: (panel)->
    if @be_attached
      panel.parentOrientation = @orientation
      @_after_push panel, 0
      @push 'panelChildren', panel
      @_panel_children_change()
    else
      @deferred.push panel
      
  child_remove: (item)->
    @_after_remove item
    @splice 'panelChildren', item.index, 1
    @_panel_children_change()
    @fire GS.EVENTS.UNREGISTER, item:item
    
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
      
      _after_remove: (child)->
        if @panelChildren.length > 1
          fix_width_index = if child.index is 0 then 1 else (child.index - 1)
          @panelChildren[fix_width_index].panelWidth += child.panelWidth
        
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
        #context.item.style.transition = '0.5s'
        
      __fix_width_against: (fix_item)->
        count = 0
        for child in @panelChildren
          if child is fix_item
            continue
          count += child.resize_data.width
        fix_item.panelWidth = 100 - count   
        
      __propagate_height_change:->
        for child in @panelChildren 
          child.panelHeight = @fixedHeight

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
        
      _after_remove: (child)->
        if @panelChildren.length > 1
          fix_height_index = if child.index is 0 then 1 else (child.index - 1)
          @panelChildren[fix_height_index].panelHeight += child.panelHeight  
          
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
        
