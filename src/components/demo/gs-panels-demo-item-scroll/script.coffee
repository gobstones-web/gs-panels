Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  properties:
    elementName:
      type: String
      value: 'unknow'
      
    elementClasses:
      type: String
      value: 'unknow'
      observer: '_update'
      
    lines:
      type: Number
      value: 10
  
  created:->
    @_elementClasses = []
    
  ready:->
    @_update()
    
  _kleasses: ()->
    next = []
    if not @elementClasses or typeof @elementClasses isnt 'string' 
      return next
    for elementClass in @elementClasses.split(/\s+/)
      unless /^\s*$/.test elementClass then next.push elementClass
    next
    
  _add: (klasses)->
    for klass in klasses
      @classList.add klass
        
  _remove: (klasses)->
    for klass in klasses
      @classList.remove klass
    
  _update:->
    remove = []
    add = []
    next = @_kleasses()
    for klass in @_elementClasses
      index = next.indexOf klass
      if index is -1 then remove.push klass
    for klass in next
      index = @_elementClasses.indexOf klass
      if index is -1 then add.push klass
    @_elementClasses = next
    @_remove remove
    @_add add
     

