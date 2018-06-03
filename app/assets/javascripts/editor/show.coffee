ready = ->
  draw = SVG('drawing').size(1000, 1000)
  count = ($('#count').data('count')) + 0
  for i in [0...count]
    polygon = draw.polygon(($('#editorData' + i).
                   data('points'))).
                   fill('none', opacity: 0.3).
                   stroke({ width: 1 }).
                   attr('id', i)
                  #  attr('name', i)

  fill         = null

  ($("tr")).on 'mouseover', ->
    if this.id
      fill = ($("polygon")[this.id]).attributes.fill.value

      ($("polygon")[this.id]).setAttribute("fill", "#FFFF66")
  ($("tr")).on 'mouseout', ->
    if this.id
      ($("polygon")[this.id]).setAttribute("fill", fill)




$(document).on 'page:load', ready
$(document).ready ready
