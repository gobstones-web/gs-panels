Polymer
    is: '#GRUNT_COMPONENT_NAME'

    removePanel: ()->
    	console.log "Polymer closePanel event fired"
    	Polymer.dom(Polymer.dom(this).parentNode).removeChild(this)
    	this.fire('closePanel', this)
