String::replaceAll = (search, replace) ->
  @split(search).join replace

ready = ->
  if ($("div").is("#editorShow"))
    draw = SVG('drawing').size(1000, 1000)
    count = ($('#count').data('count')) + 0
    for i in [0...count]
      polygon = draw.polygon(($('#editorData' + i).
                     data('points'))).
                     fill('none', opacity: 0.3).
                     stroke({ width: 1 }).
                     attr('id', i)


      textCoordinates = polygon.attr('points').replaceAll(', ', ',').split(' ')
      console.log(textCoordinates)
      sumX = 0
      sumY = 0
      for j in [0 ... textCoordinates.length]
        p = textCoordinates[j].split(',')
        sumX += parseFloat(p[0])
        sumY += parseFloat(p[1])
      sumX /= textCoordinates.length
      sumY /= textCoordinates.length

      draw.text(($('#editorData' + i).data('name')) + "")
          .dx(sumX - (($('#editorData' + i).data('name')) + "").length * 4)
          .dy(sumY - 20)

    fill = null
    ($("tr")).on 'mouseover', ->
      if this.id
        fill = ($("polygon")[this.id]).attributes.fill.value

        ($("polygon")[this.id]).setAttribute("fill", "#FFFF66")
    ($("tr")).on 'mouseout', ->
      if this.id
        ($("polygon")[this.id]).setAttribute("fill", fill)


$(document).on 'page:load', ready
$(document).ready ready
