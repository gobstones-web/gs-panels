Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties: 
    panelHeight:
      type: Number
    orientation:
      type: String
    children:
      type: Array
      
  listeners:
    'begin-resize': '_on_begin_resize'
  
  ready:->
    @children = []
    @_extend()
  
  #panelHeight can be provided via HTML attribute
  attached: ->
    @minHeightContainer = @$.minHeightContainer
    if @panelHeight and not isNaN(@panelHeight) and @panelHeight isnt ''
      @style.maxHeight = @panelHeight + 'px'
    else
      maxHeight = window.getComputedStyle(@).maxHeight
      if /px$/.test maxHeight
        @panelHeight = parseFloat maxHeight.slice(0, -2)
      else
        @panelHeight = 0
  
  _extend: ->
    @orientation = @orientation or 'horizontal'
    strategy = @strategies[@orientation]
    @[strategy.name] = true
    @_after_push = strategy.after_push
    @_begin_resize = strategy.begin_resize
    @_finish_resize = strategy.finish_resize
    @_rezise = strategy.rezise
  
  _on_begin_resize: (evnt)->
    evnt.cancelBubble = true
    context = {}
    _mousemove = @_rezise @, context
    _mouseup = (evnt) =>
      unless evnt.which is 1 then return 
      @_finish_resize @, context
      document.removeEventListener("mouseup", _mouseup)
      document.removeEventListener("mousemove", _mousemove)
    document.addEventListener("mouseup", _mouseup)
    document.addEventListener("mousemove", _mousemove)
    @_begin_resize @, context, evnt
    
  add: (element)->
    next = document.createElement 'gs-panel-simple'
    next.concretElement = element
    @_after_push next, 0
    @push 'children', next

  strategies:
    horizontal:
      name: 'horizontal'
      after_push: (element, position)->
        amount = @children.length + 1
        count = 0
        width = 100 / amount
        for children in @children
          children.style.width = width + '%'
          css_width = children.style.width
          if /%$/.test css_width
            real_width = parseFloat children.style.width.slice(0, -1)
          else
            real_width = width
          count += real_width
        last_width = 100 - count
        element.style.height = @panelHeight
        element.style.width  = last_width + '%'
        
      begin_resize: (self, context, evnt)->
        context.initial_frame_heigth = @clientHeight
        context.initial_mouse_y = evnt.detail.clientY
        
      rezise:(self, context)->(evnt)->
        y_delta = evnt.clientY - context.initial_mouse_y
        console.log 'y_delta: ' + y_delta
        console.log 'initial_frame_heigth: ' + context.initial_frame_heigth
        
        nextHeigth = context.initial_frame_heigth + y_delta
        console.log 'nextHeigth: ' + nextHeigth
        self.minHeightContainer.style.minHeight = self.panelHeigth = self.style.maxHeight = nextHeigth + 'px'
        
      finish_resize:(self, context)->
        self.minHeightContainer.style.minHeight = "30px"
        console.log 'height rezise end'
        
    vertical: 
      name: 'vertical'
      after_push: (element, position)->
      begin_resize: ->
      finish_resize: ->








