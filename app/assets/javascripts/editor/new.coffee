# Инициализация редактора:
editorInit = ->

  # Определение переменных:
  MainPolygonColor     = "white"             # цвет основного полигона
  SubMainPolygonColor  = "gray"              # цвет саб-полигона
  grid                 = 20                  # размер сетки
  sqr                  = 100                 # размер холста (sqr ед.^2)

  draw = SVG('editor_canvas')                # полотно
        .size(sqr * grid, sqr * grid)


  # В случае невалидного вволда основной формы (исключение удаление поля):
  submainPolygonsString = $("#floor_editor_data")[0].value
  if submainPolygonsString.length > 0
    submainPolygons = submainPolygonsString.split('<END>')
    submainPolygons.pop()
    for i in [0 ... submainPolygons.length]
      data = submainPolygons[i].split('<NEXT>')
      draw.polygon(data[6])
          .draggable(snapToGrid: grid)
          .selectize({ deepSelect: true })
          .attr('stroke-width', 2)
          .attr(fill: SubMainPolygonColor, opacity: 0.3)
          .attr('object', 'submain')
          .attr('name', data[1] + "")
          .attr('description', data[2] + "")
          .attr('capacity', data[3] + "")
          .attr('computers', data[4] + "")
          .attr('type', data[5] + "")

  chronology = new Chronology          # массив отмен

  polysEventIsOn = false               # включен ли обработчик завершения
                                       # рисования полигона?
  currentShape   = null

  polygon        = 1                   # тип фигуры: 1 - polygon
  subpolygon     = 2                   # тип фигуры: 2 - subpolygon


  # Инициализация контекстного меню в редакторе:
  $.contextMenu
    selector: 'polygon'
    items:
      shapeAttributeEdit:
        name: 'Изменить данные об объекте'
        callback: (key, opt) ->
          shapeAttributeEdit(this)
      "sep1": "---------"
      shapeAddPoint:
        name: 'Добавить точку'
        callback: (key, opt) ->
          squareListiner(this, 0)
      shapeRemoveLine:
          name: 'Удалить линию'
          callback: (key, opt) ->
            squareListiner(this, 1)
      "sep2": "---------"
      shapeDelete:
        name: 'Удалить объект'
        callback: (key, opt) ->
            this.off('dragmove')
            this.off('dragend')
            removeTextOnBaryCenter(this)
            this.next()[0].remove()
            this[0].remove()


  # Инициализировать полигон:
  initDrawPolygon = (type) ->
    shape          = getDrawingPolygon(type)
    shape.draw(snapToGrid: grid)
    currentShape   = shape

    # хендлер завершения отрисовки полигона:
    draw.on 'dblclick', (event) ->
      stopDrawPolygon(event, shape)


  # Отрисовать многоугольник:
  getDrawingPolygon = (type) ->
    poly = draw.polygon().draggable(snapToGrid: grid)

    # обрабатываем полигон в соответствии с его типом:
    if type == polygon
      poly.attr('stroke-width', 3)
          .attr(fill: MainPolygonColor, opacity: 0.5)
          .attr('object', 'main')
    else if type == subpolygon
      poly.attr('stroke-width', 2)
          .attr(fill: SubMainPolygonColor, opacity: 0.3)
          .attr('object', 'submain')


  # Отрисовка текста в геометрическом центре фигуры:
  addTextOnBarycenter = (shape) ->
    textCoordinates = shape.attr('points').split(' ')
    sumX = 0
    sumY = 0
    for i in [0 ... textCoordinates.length]
      p = textCoordinates[i].split(',')
      sumX += parseFloat(p[0])
      sumY += parseFloat(p[1])
    sumX /= textCoordinates.length
    sumY /= textCoordinates.length

    draw.text(shape.attr('name') + "")
        .dx(sumX - (shape.attr('name') + "").length * 4)
        .dy(sumY - 20)
        .attr('polygon_id', shape.attr('id'))

  # Удаление текста:
  removeTextOnBaryCenter = (shape) ->
    texts = $("text")
    for i in [0 ... texts.length]
      if texts[i].attributes.polygon_id.value == shape.attr('id')
        texts[i].remove()


  # Отключить хендлеры, слушающие завершение отрисовки (без удаления последней
  # фигуры):
  stopDrawPolygon = (event, shape) ->
    # убираем 2 лишние точки, которые получаются при dblclick
    shape.plot(shape.array()
                    .valueOf()
                    .slice(0, -1)
                    .slice(0, -1))

    shape.selectize({deepSelect:true})
                      .resize(snapToGrid: grid)
                      .draw('stop', event)

    shape.attr('name', 'Undefined' + new Date().getTime())
    shape.attr('description', '')
    shape.attr('capacity', '')
    shape.attr('computers', '')
    shape.attr('type', '')


    # отрисовка текста при перемещении фигуры:
    addTextOnBarycenter(shape)
    shape.on 'dragmove', (event) ->
      removeTextOnBaryCenter(this)
    shape.on 'dragend', (event) ->
      addTextOnBarycenter(this)


    polysEventIsOn = false
    currentShape   = null
    shapeAttributeEdit(shape)
    draw.off 'dblclick'


  # Отключить хендлеры, слушающие завершение отрисовки с удалением последней фи-
  # гуры:
  cancelDrawPolygon = (event) ->
    currentShape.draw('stop', event)
    currentShape.remove()
    polysEventIsOn = false
    currentShape   = null
    draw.off 'dblclick'


  # Изменение атрибутов объекта(вызов модального окна):
  shapeAttributeEdit = (shape) ->
    # заполнение полей формы модального окна данными выбранной фигуры:
    $("#name").val(shape.attr("name"));
    $("#description").val(shape.attr("description"));
    $("#capacity").val(shape.attr("capacity"));
    $("#computers").val(shape.attr("computers"));
    $("#type").val(shape.attr("type"));

    # рендер модального окна:
    $('#shapeAttributeEdit').modal 'show'

    # Хендлер, слушающий submit, и запись измененных атрибутов:
    ($("#edit_submit")).on 'click', shape, ->
      shape.attr("name", $("#name").val())
      shape.attr("description", $("#description").val())
      shape.attr("capacity", $("#capacity").val())
      shape.attr("computers", $("#computers").val())
      if $("#type").val() == null
        shape.attr("type", "")
      else
        shape.attr("type", $("#type").val())

      $('#shapeAttributeEdit').modal 'hide'

      removeTextOnBaryCenter(shape)
      addTextOnBarycenter(shape)

      # Отключение хендлера, слушающего submit:
      ($("#edit_submit")).off 'click'


  # Действие с полигонами (добавить/удалить точку):
  squareListiner = (shape, action) ->
    # action == 0 -- добавление точки; action == 1 -- удаление линии.

    shape.off('dragmove')
    shape.off('dragend')

    removeTextOnBaryCenter(shape)

    shape.next()[0].remove()
    shape_array = shape[0]

    # преобразовываем точки полигона в массив, для удобного чтения:
    svg_point_array = shape_array.points
    point_array     = []
    point_string    = " "
    for i in [0 ... svg_point_array.length]
      point_array[i] = [svg_point_array[i].x, svg_point_array[i].y]
      point_string  += svg_point_array[i].x + "," + svg_point_array[i].y + " "

    # атрибуты старой фигуры:
    fill         = shape.attr("fill")
    opacity      = shape.attr("opacity")
    stroke_width = shape.attr("stroke-width")
    object       = shape.attr('object')
    name         = shape.attr('name')
    description  = shape.attr('description')
    capacity     = shape.attr('capacity')
    computers    = shape.attr('computers')
    type         = shape.attr('type')

    # удаляем старую фигуру и отрисовываем временную:
    shape.remove()
    shape = draw.polygon(point_string)
                .attr('stroke-width', stroke_width)
                .attr(fill: fill, opacity: opacity)
                .attr('object', object)
                .attr('name', name)
                .attr('description', description)
                .attr('capacity', capacity)
                .attr('computers', computers)
                .attr('type', type)

    # стороны полигона превращаем в линии, на которых в дальнейшем будем до-
    # бавлять точку:
    lines = []
    for i in [0 ... point_array.length - 1]
      lines[i] = draw.line(point_array[i][0], point_array[i][1], point_array[i+1][0], point_array[i+1][1])
                     .stroke({ width: 4 })
                     .selectize({ deepSelect: true} )

    lines[point_array.length - 1] = draw.line(point_array[point_array.length - 1][0], point_array[point_array.length - 1][1],
                                    point_array[0][0], point_array[0][1])
                               .stroke({ width: 4 })
                               .selectize({ deepSelect: true })

    # навешивам хэндлеры на линии, слушающие событие:
    if action == 0
      for i in [0...lines.length]
        # - добавления точки в полигон
        addPointToSquare(shape, lines, lines[i], i)
    else if action == 1
      for i in [0...lines.length]
        # - удаление линии из полигона
        removeLineOfSquare(shape, lines, lines[i], i)


  # Добавление точки в полигон:
  addPointToSquare = (shape, lines, line, lineNumber) ->
    line.on 'click', ->
      # удаляем временную фигуру:
      shape.remove()

      # ищем середину отрезка линии, с которой работаем:
      l = line.array().valueOf()
      aX = l[0][0]
      aY = l[0][1]
      bX = l[1][0]
      bY = l[1][1]
      cX = (aX + bX)/2.0
      cY = (aY + bY)/2.0

      # формируем новый массив для рендера новой фигуры и удаляем линии с полот-
      # на:
      newShape = []

      for j in [0 .. lineNumber]
        newShape.push(lines[j].array().valueOf()[0][0])
        newShape.push(lines[j].array().valueOf()[0][1])
        lines[j].selectize(false, { deepSelect: true }).remove()

      newShape.push(cX)
      newShape.push(cY)

      for j in [lineNumber + 1 ... lines.length]
        newShape.push(lines[j].array().valueOf()[0][0])
        newShape.push(lines[j].array().valueOf()[0][1])
        lines[j].selectize(false, { deepSelect: true }).remove()

      # атрибуты старой фигуры:
      fill         = shape.attr("fill")
      opacity      = shape.attr("opacity")
      stroke_width = shape.attr("stroke-width")
      object       = shape.attr('object')
      name         = shape.attr('name')
      description  = shape.attr('description')
      capacity     = shape.attr('capacity')
      computers    = shape.attr('computers')
      type         = shape.attr('type')

      # отрисовываем новую фигуру (в виду атрибутов (выше)):
      p = draw.polygon(newShape)
              .draggable(snapToGrid: grid)
              .selectize({ deepSelect: true })
              .resize(snapToGrid: grid)
              .attr('stroke-width', stroke_width)
              .attr(fill: fill, opacity: opacity)
              .attr('object', object)
              .attr('name', name)
              .attr('description', description)
              .attr('capacity', capacity)
              .attr('computers', computers)
              .attr('type', type)

      addTextOnBarycenter(p)
      p.on 'dragmove', (event) ->
        removeTextOnBaryCenter(this)
      p.on 'dragend', (event) ->
        addTextOnBarycenter(this)


  # Удаление линии из полигона:
  removeLineOfSquare = (shape, lines, line, lineNumber) ->
    line.on 'click', ->
      # удаляем временную фигуру:
      shape.remove()

      # формируем новый массив для рендера новой фигуры и удаляем линии с полот-
      # на:
      newShape = []

      for j in [0 .. lineNumber]
        newShape.push(lines[j].array().valueOf()[0][0])
        newShape.push(lines[j].array().valueOf()[0][1])
        lines[j].selectize(false, { deepSelect: true }).remove()

      newShape.pop()
      newShape.pop()

      for j in [lineNumber + 1 ... lines.length]
        newShape.push(lines[j].array().valueOf()[0][0])
        newShape.push(lines[j].array().valueOf()[0][1])
        lines[j].selectize(false, { deepSelect: true }).remove()

      # атрибуты старой фигуры:
      fill         = shape.attr("fill")
      opacity      = shape.attr("opacity")
      stroke_width = shape.attr("stroke-width")
      object       = shape.attr('object')
      name         = shape.attr('name')
      description  = shape.attr('description')
      capacity     = shape.attr('capacity')
      computers    = shape.attr('computers')
      type         = shape.attr('type')

      # отрисовываем новую фигуру (в виду атрибутов (выше)):
      p = draw.polygon(newShape)
              .draggable(snapToGrid: grid)
              .selectize({ deepSelect: true })
              .resize(snapToGrid: grid)
              .attr('stroke-width', stroke_width)
              .attr(fill: fill, opacity: opacity)
              .attr('object', object)
              .attr('name', name)
              .attr('description', description)
              .attr('capacity', capacity)
              .attr('computers', computers)
              .attr('type', type)

      addTextOnBarycenter(p)
      p.on 'dragmove', (event) ->
        removeTextOnBaryCenter(this)
      p.on 'dragend', (event) ->
        addTextOnBarycenter(this)


  # хендлер POLYGON:
  ($("#polygon")).on 'click', ->
    if polysEventIsOn
      cancelDrawPolygon()
    else
      polysEventIsOn = true
      initDrawPolygon(1)


  # хендлер SUBPOLYGON:
  ($("#subpolygon")).on 'click', ->
    if polysEventIsOn
      cancelDrawPolygon()
    else
      polysEventIsOn = true
      initDrawPolygon(2)

  # хендлер INFO:
  # ($("#info")).on 'click', ->
  #   # Сбор информации о всех полигонах:
  #   elems = document.getElementById('SvgjsSvg1001').getElementsByTagName('polygon')
  #
  #   editorData = []   # массив для данных, которые будут отправлены в контроллер
  #   for i in [0...elems.length]
  #     editorData[i] = [elems[i].attributes.name.value
  #                     ,elems[i].attributes.description.value
  #                     ,elems[i].attributes.capacity.value
  #                     ,elems[i].attributes.computers.value
  #                     ,elems[i].attributes.type.value
  #                     ,elems[i].attributes.points.value
  #                     ]
  #
  #   # Отправка данных:
  #   $.ajax
  #     type: "POST",
  #     url: '/floors',
  #     data: {floor: {name: $("#floor_name").val(), description: $("#floor_description").val(), building_id: $("#floor_building_id").val()}, 'editorData[]': editorData}


  # хендлер TRASH:
  ($("#clear-canvas")).on 'click', (event) ->
    if polysEventIsOn
      cancelDrawPolygon(event)
    clear = confirm("Данное действие очистит холст безвозвратно! Вы действительно хотите выполнить это?");
    if clear
      draw.remove()
      draw = SVG('editor_canvas').size(sqr * grid, sqr * grid)
      chronology = new Chronology

  # # хендлер UNDO:
  # ($("#undo")).on 'click', ->
  #   if polysEventIsOn
  #     cancelDrawPolygon()
  #   chronology.undo()
  #
  #
  # # хендлер REDO:
  # ($("#redo")).on 'click', ->
  #   if polysEventIsOn
  #     cancelDrawPolygon()
  #   chronology.redo()


  # отправка данных в контроллер Rails:
  $("#ok").on 'click', ->
    # Сбор информации о всех полигонах:
    elems = ($("#editor_canvas polygon"))
    editorData = ""  # массив для данных, которые будут отправлены в контроллер
    for i in [0...elems.length]
      editorData += elems[i].attributes.object.value + "<NEXT>" +
                    elems[i].attributes.name.value + "<NEXT>" +
                    elems[i].attributes.description.value + "<NEXT>" +
                    elems[i].attributes.capacity.value + "<NEXT>" +
                    elems[i].attributes.computers.value + "<NEXT>" +
                    elems[i].attributes.type.value + "<NEXT>" +
                    elems[i].attributes.points.value + "<END>"

    # Отправка данных:
    ($("#floor_editor_data")).val(editorData);

    # Отправка формы:
    ($("form")).submit()


# ready:
ready = ->
  if ($("div").is("#editorNew"))
    editorInit()


$(document).on 'page:load', ready
$(document).ready ready
