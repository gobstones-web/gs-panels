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
    listeners[GS.EVENTS.CHILD_MAKE_RESIZE]   = '__forward_child_make_resize'
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
  __forward_child_make_resize: (evnt)->
    evnt.cancelBubble = true
    @__child_make_resize(evnt.detail.item, evnt.detail.percent)
  __forward_child_remove: (evnt)->
    evnt.cancelBubble = true
    @child_remove(evnt.detail.item)
      
  ready:->
    @deferred_panels = []
    @panelChildren = []
  
  get_children_tree: ->
    id: @identifier
    items: (item.get_children_tree() for item in @panelChildren.concat(@collect_deferred_panels()))
  
  process_deferred_panels:->
    for deferred in @deferred_panels
      @add_panel_children deferred.panel, deferred.pos
    @deferred_panels.length = 0
  
  attached:->
    @orientation = @orientation or GS.HORIZONTAL
    @classList.add @orientation 
    @extend @, @flow_strategies[@orientation]
    @process_deferred_panels()
    @__propagate_height_change @fixedHeight, 0
    
  _panel_children_change:->
    last_index = @panelChildren.length - 1
    for child, index in @panelChildren
      child.index = index
      child.notLast = index isnt last_index
      
  next_index_by_position: (pos)->
    len = @panelChildren.length
    if len is 0 or pos is 'FIRST'
      index = 0
    else if pos is 'LAST' or not pos
      index = len
    else 
      index = Math.floor(len/2)
    index
    
  add_panel_children: (panel, pos)->
    if @be_attached
      panel.parentOrientation = @orientation
      
      @_after_push panel, 0
      @splice 'panelChildren',
        @next_index_by_position(pos), 0,
        panel
      @_panel_children_change()
    else
      deferred = 
        panel: panel
        pos: pos
      @deferred_panels.push deferred
      
  collect_deferred_panels: ->
    deferred.panel for deferred in @deferred_panels
      
  child_remove: (item)->
    @_after_remove item
    @splice 'panelChildren', item.index, 1
    @_panel_children_change()
    @fire GS.EVENTS.UNREGISTER, item:item
    
  add_composite: (ori, item_id, pos)->
    item_id ?= GS.Rezisable.next_id()
    next = document.createElement 'gs-panel-composite'
    next.orientation = ori
    next.identifier = item_id
    @add_panel_children next, pos
    next
  
  add_simple: (element, item_id, pos)->
    item_id ?= GS.Rezisable.next_id()
    next = document.createElement 'gs-panel-simple'
    element.identifier = item_id + '-concret-element'
    next.identifier = item_id
    next.concretElement = element
    @add_panel_children next, pos
    next

  HasBeenResized: do ->
    error = () ->
      this.name = 'HasBeenResized'
      this.message = "Cannot set a percent programmatically once user has made a resize"
    error.prototype = Error.prototype
    error

  ResizeNotAllowed: do ->
    error = () ->
      this.name = 'ResizeNotAllowed'
      this.message = "Cannot exceed 100% size"
    error.prototype = Error.prototype
    error

  flow_strategies:
    horizontal:
      _after_push: (element)->
        #element is not added yet
        current_amount = @panelChildren.length
        next_amount = @panelChildren.length + 1
        width_fixer = current_amount / next_amount
        count = 0
        for child in @panelChildren
          child.panelWidth = child.panelWidth * width_fixer
          count += child.resize_data.width
        last_width = 100 - count
        element.panelWidth = last_width
        element.panelHeight = @panelHeight
      
      _after_remove: (child)->
        if @panelChildren.length > 1
          fix_width_index = if child.index is 0 then 1 else (child.index - 1)
          @panelChildren[fix_width_index].panelWidth += child.panelWidth
        
      __child_resize_begin: (context, position)->
        #has_been_resized: used to skip make_resize()
        @has_been_resized = true
        #context.item cannot be the last child
        context.initial_mouse_x = position.clientX
        context.initial_width = context.item.clientWidth
        context.initial_width_percent = @parse_percent context.item.style.width
        next_item = @panelChildren[context.item.index + 1]
        current_width = context.item.clientWidth
        context.min_width = if @MIN_WIDTH < current_width then @MIN_WIDTH else current_width
        expand_width = if next_item.clientWidth < @MIN_WIDTH then 0 else next_item.clientWidth - @MIN_WIDTH
        context.max_width = current_width + expand_width
        context.item.style.transition = 'none'

      __child_resize: (context, position)->
        #context.item cannot be the last child
        width = @clientWidth
        x_delta = position.clientX - context.initial_mouse_x
        next_px = context.initial_width + x_delta
        if next_px > context.max_width
          next_px = context.max_width
        if next_px < context.min_width
          next_px = context.min_width
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
        
      __propagate_height_change:(newValue, oldValue)->
        for child in @panelChildren
          child.panelHeight = @fixedHeight
          
      __child_make_resize: (item, percent)->
        if @has_been_resized then throw new @HasBeenResized()
        available_space = 100
        available_items = 0
        for child in @panelChildren
          if child is item then continue
          if child.resize_data.forced_resize
            available_space -= child.resize_data.width
          else
            available_items += 1
        space_change = item.resize_data.width - percent
        if available_space < space_change then throw new @ResizeNotAllowed()
        space_change_per_child = space_change / available_items
        count = 0
        for child in @panelChildren
          if child is item then continue
          unless child.resize_data.forced_resize 
            child.panelWidth = child.panelWidth + space_change_per_child
          count += child.resize_data.width 
        item.panelWidth = 100 - count
        item.resize_data.forced_resize = percent
        
    vertical:
      _after_push: (element)->
        current_amount = @panelChildren.length
        next_amount = @panelChildren.length + 1
        height_fixer = current_amount / next_amount
        count = 0
        for child in @panelChildren
          child.panelHeight = child.panelHeight * height_fixer
          count += child.resize_data.height
        last_height = @fixedHeight - count
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
      
      __propagate_height_change:(newValue, oldValue)->
        amount = @panelChildren.length
        if amount > 0
          last_item = @panelChildren[@panelChildren.length - 1]
          count = 0
          if oldValue is 0
            child_height = newValue / amount
            for child in @panelChildren
              if child is last_item then continue
              child.panelHeight = child_height
              count += child.resize_data.height
          else  
            height_fixer = newValue / oldValue
            for child in @panelChildren
              if child is last_item then continue
              child.panelHeight = child.panelHeight * height_fixer
              count += child.resize_data.height
          last_height = @fixedHeight - count
          last_item.panelHeight = last_height
      
      __child_make_resize: (item, percent)->
        if @has_been_resized then throw new @HasBeenResized()
        next_height = @fixedHeight / 100 * percent
        available_space = @fixedHeight
        available_items = 0
        for child in @panelChildren
          if child is item then continue
          if child.resize_data.forced_resize
            available_space -= child.resize_data.height
          else
            available_items += 1
        space_change = item.resize_data.height - next_height
        if available_space < space_change then throw new @ResizeNotAllowed()
        space_change_per_child = space_change / available_items
        count = 0
        for child in @panelChildren
          if child is item then continue
          unless child.resize_data.forced_resize 
            child.panelHeight = child.panelHeight + space_change_per_child
          count += child.resize_data.height 
        item.panelHeight = @fixedHeight - count
        item.resize_data.forced_resize = next_height  
        
        
