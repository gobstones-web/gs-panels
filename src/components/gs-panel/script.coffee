Polymer
    is: '#GRUNT_COMPONENT_NAME'

    listeners:
    	'iron-resize': 'resize',

    resize: (event) ->
        alert("Thank you for tapping")

    removeElement: ()->
    	console.log "llame a la funcion"
    	Polymer.dom(Polymer.dom(this).parentNode).removeChild(this)
    	this.fire('closePanel', this)
