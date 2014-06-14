// Generated by CoffeeScript 1.7.1
(function() {
  var fileToSVG, handleFileSelect, readFileToDiv;

  fileToSVG = function(file, filename) {
    var layer, p;
    console.log('converting to svg');
    p = new Plotter(file, filename.slice(-3));
    return layer = p.plot();
  };

  readFileToDiv = function(event, filename) {
    var drawDiv, imgsrc, layer, svg, svg64;
    if (event.target.readyState === FileReader.DONE) {
      layer = fileToSVG(event.target.result, filename);
      drawDiv = document.createElement('div');
      drawDiv.innerHTML = "<h3>" + filename + "</h3>";
      drawDiv.id = "layer-" + layer.name;
      drawDiv["class"] = 'layer-div';
      document.getElementById('layers').insertBefore(drawDiv, null);
      svg = layer.draw(drawDiv.id);
      svg64 = btoa(svg.node.outerHTML);
      imgsrc = "data:image/svg+xml;base64," + svg64;
      return drawDiv.innerHTML += "<a download='filename' href-lang='image/svg+xml' href='" + imgsrc + "'>download svg</a>";
    }
  };

  handleFileSelect = function(event) {
    var f, importFiles, output, _i, _j, _len, _len1, _results;
    importFiles = event.target.files;
    output = [];
    for (_i = 0, _len = importFiles.length; _i < _len; _i++) {
      f = importFiles[_i];
      output.push('<li><strong>', escape(f.name), '</li>');
    }
    document.getElementById('list').innerHTML = '<ul>' + output.join('') + '</ul>';
    _results = [];
    for (_j = 0, _len1 = importFiles.length; _j < _len1; _j++) {
      f = importFiles[_j];
      _results.push((function(f) {
        var reader;
        reader = new FileReader();
        reader.onloadend = function(event) {
          return readFileToDiv(event, f.name);
        };
        return reader.readAsText(f);
      })(f));
    }
    return _results;
  };

  document.getElementById('files').addEventListener('change', handleFileSelect, false);

}).call(this);
