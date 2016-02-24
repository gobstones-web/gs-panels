(function() {
  document.addEventListener("DOMContentLoaded", function(event) {
    var addFooter, addHeader, addMultipleElement, addSingleElement200px, createDiv;
    document.getElementById("addHeader").addEventListener('click', function(event) {
      return addHeader();
    });
    document.getElementById("addFooter").addEventListener('click', function(event) {
      return addFooter();
    });
    document.getElementById("addButtonMultiple").addEventListener('click', function(event) {
      return addMultipleElement();
    });
    addSingleElement200px = function() {
      var div, panelManager;
      panelManager = document.getElementById("panel-manager");
      div = document.createElement("div");
      div.style.width = "200px";
      div.style.border = "solid 2px black";
      return panelManager.addSingleElement(div);
    };
    addHeader = function() {
      var div, panelManager;
      panelManager = document.getElementById("panel-manager");
      div = document.getElementById("header");
      return panelManager.addSingleElement(div);
    };
    addFooter = function() {
      var div, panelManager;
      panelManager = document.getElementById("panel-manager");
      div = document.createElement("div");
      div.style.border = "solid 2px black";
      div.style.height = "100px";
      div.style.width = "100%";
      return panelManager.addSingleElement(div);
    };
    createDiv = function() {
      var div;
      div = document.createElement("div");
      div.style.border = "solid 2px black";
      return div;
    };
    return addMultipleElement = function() {
      var div, each, elementList, panelManager, _i, _len, _ref;
      panelManager = document.getElementById("panel-manager");
      elementList = [];
      _ref = [1, 2, 3];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        each = _ref[_i];
        div = createDiv();
        div.innerHTML = div.innerHTML + 'Sarasa';
        elementList.push(div);
      }
      return panelManager.addMultipleElment(elementList, "vertical");
    };
  });

}).call(this);
