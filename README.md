# gs-panels

Gobstones Panels Polymer component

Version: 0.0.1

## deploy

```
npm update
bower update
grunt server
```

listen on `GS_PANELS_CHANGE` to detect changes in panels tree

Children can implement 'panelHeight' property or listen on 'GS_HAS_BEEN_RESIZED' in order to detect resize.

## using

```html
<gs-panel-root id="panels"></gs-panel-root>
```

```javascript
Polymer({
  is: 'my-custom-container',
  
  attached:function(){
    this.$.panels.add_horizontal('HORIZONTAL_CONTAINER');
    var custom_component = document.createElement('custom-component');
    this.$.panels.add(custom_component, {
      id:'CUSTOM-COMPONENT-ID', 
      into:'HORIZONTAL_CONTAINER'
    });
    var other_component = document.createElement('other-component');
    this.$.panels.add(other_component, {
      id:'OTHER-COMPONENT-ID', 
      into:'HORIZONTAL_CONTAINER'
    });
    //set 70% width
    this.$.panels.make_resize('OTHER-COMPONENT-ID', 70)
  }
    
});
```
