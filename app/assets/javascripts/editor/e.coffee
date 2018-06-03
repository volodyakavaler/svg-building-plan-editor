# # Инициализация меню для редактора:
# menuInit = ->
#   $.contextMenu
#     selector: 'polygon'
#     items:
#       foo:
#         name: 'Удалить'
#         callback: (key, opt) ->
#           alert opt
#           return
#       bar:
#         name: 'Добавить точку'
#         callback: (key, opt) ->
#           alert 'Bar!'
#           return
#
# # Инициализация редактора:
# editorInit = ->
#   ####################### ОПРЕДЕЛЕНИЕ ПЕРЕМЕННЫХ ###############################
#   # Определение переменных:
#   polyMain_color = "white"             # цвет основного полигона
#   polySub_color  = "gray"              # цвет саб-полигона
#   grid           = 20                  # размер сетки
#   sqr            = 100                 # размер холста (sqr ед.^2)
#
#   draw = SVG('editor_canvas')          # полотно
#             .size(sqr * grid, sqr * grid)
#
#   chronology = new Chronology          # массив отмен
#
#   shapes         = []                  # массив фигур
#   deletedShapes  = [{}]                # массив удаленных фигур
#
#   i              = 0                   # индекс фигуры в массиве фигур
#   polysEventIsOn = false               # включен ли обработчик завершения
#                                        # рисования полигона?
#
#   polygon        = 1                   # тип фигуры: 1 - polygon
#   subpolygon     = 2                   # тип фигуры: 2 - subpolygon
#
#
#   ################################# ФУНКЦИИ ####################################
#   # Инициализировать полигон:
#   initDrawPolygon = (type) ->
#     if !!!shapes[i] || shapes.length == 1       #TODO
#       shape = getDrawingPolygon(type)
#       shapes[i] = [shape, type]
#       shape.draw(snapToGrid: grid)
#       polysEventIsOn = true
#
#     # хендлер завершения отрисовки полигона:
#     draw.on 'dblclick', (event) ->
#       stopDrawPolygon(event)
#         # $.contextMenu
#         #   selector: '.polygon'
#         #   items:
#         #     foo:
#         #       name: 'Удалить'
#         #       callback: (key, opt) ->
#         #         alert opt
#         #         return
#         #     bar:
#         #       name: 'Добавить точку'
#         #       callback: (key, opt) ->
#         #         alert 'Bar!'
#         #         return
#
#   # Действие с полигонами (добавить/удалить точку):
#   squareListiner = (square) ->
#     square[0].on 'click', ->
#       square[0].off 'click'
#
#       # преобразовываем точки полигона в массив, для удобного чтения:
#       p = square[0].array().valueOf()
#
#       # запрещаем манипуляции с полигоном, которым работаем:
#       square[0].selectize(false, {deepSelect: true}).draggable(false)
#
#       # стороны полигона превращаем в линии, на которых в дальнейшем будем до-
#       # бавлять точку:
#       lines = []
#       for i in [0 ... p.length - 1]
#         lines[i] = draw.line(p[i][0], p[i][1], p[i+1][0], p[i+1][1])
#                        .stroke({ width: 4 })
#                        .selectize({ deepSelect: true} )
#
#       lines[p.length - 1] = draw.line(p[p.length - 1][0], p[p.length - 1][1],
#                                       p[0][0], p[0][1])
#                                  .stroke({ width: 4 })
#                                  .selectize({ deepSelect: true })
#
#       # навешивам хэндлеры на линии, слушающие событие:
#       for i in [0...lines.length]
#         # - добавления точки в полигон
#         addPointToSquare(square, lines, lines[i], i)
#
#   # Добавление точки в полигон:
#   addPointToSquare = (shape, lines, line, lineNumber) ->
#     line.on 'click', ->
#       # удаляем старую фигуру:
#       shape[0].selectize(false, { deepSelect: true }).remove()
#
#       # ищем середину отрезка линии, с которой работаем:
#       l = line.array().valueOf()
#       aX = l[0][0]
#       aY = l[0][1]
#       bX = l[1][0]
#       bY = l[1][1]
#       cX = (aX + bX)/2.0
#       cY = (aY + bY)/2.0
#
#       # формируем новый массив для рендера новой фигуры и удаляем линии с полот-
#       # на:
#       newShape = []
#
#       for j in [0 .. lineNumber]
#         newShape.push(lines[j].array().valueOf()[0][0])
#         newShape.push(lines[j].array().valueOf()[0][1])
#         lines[j].selectize(false, { deepSelect: true }).remove()
#
#       newShape.push(cX)
#       newShape.push(cY)
#
#       for j in [lineNumber + 1 ... lines.length]
#         newShape.push(lines[j].array().valueOf()[0][0])
#         newShape.push(lines[j].array().valueOf()[0][1])
#         lines[j].selectize(false, { deepSelect: true }).remove()
#
#       # отрисовываем новую фигуру:
#       if shape[1] == polygon
#         draw.polygon(newShape)
#             .draggable(snapToGrid: grid)
#             .selectize({ deepSelect: true })
#             .resize(snapToGrid: grid)
#             .attr('stroke-width', 3)
#             .attr(fill: polyMain_color, opacity: 0.5)
#       else if shape[1] == subpolygon
#         draw.polygon(newShape)
#             .draggable(snapToGrid: grid)
#             .selectize({deepSelect:true})
#             .resize(snapToGrid: grid)
#             .attr('stroke-width', 2)
#             .attr(fill: polySub_color, opacity: 0.3)
#       squareListiner(newShape)
#
#   # Отрисовать многоугольник:
#   getDrawingPolygon = (type) ->
#     poly = draw.polygon().draggable(snapToGrid: grid)
#
#     # обрабатываем полигон в соответствии с его типом:
#     if type == polygon
#       poly.attr('stroke-width', 3).attr(fill: polyMain_color, opacity: 0.5)
#     else if type == subpolygon
#       poly.attr('stroke-width', 2).attr(fill: polySub_color, opacity: 0.3)
#
#   # возможность отмены перемещения фигуры:
#   # undoRedoShapeBeforeDrag = (shape) ->
#   #   (shape[0]).on 'beforedrag', ->
#   #     (shape[0]).remember 'oldX', (shape[0]).x()
#   #     (shape[0]).remember 'oldY', (shape[0]).y()
#   #     return
#   #   (shape[0]).on 'dragend', ->
#   #     oldX = (shape[0]).remember('oldX')
#   #     oldY = (shape[0]).remember('oldY')
#   #     newX = (shape[0]).x()
#   #     newY = (shape[0]).y()
#   #     chronology.add
#   #       up: ->
#   #         (shape[0]).move newX, newY
#   #         return
#   #       down: ->
#   #         (shape[0]).move oldX, oldY
#   #         return
#   #       call: false
#   #     (shape[0]).forget 'oldX'
#   #     (shape[0]).forget 'oldY'
#   #     return
#
#   # Отключить хендлеры, слушающие завершение отрисовки (без удаления последней
#   # фигуры):
#   stopDrawPolygon = (event) ->
#     # убираем 2 лишние точки, которые получаются при dblclick
#
#     (shapes[i][0]).plot((shapes[i][0])
#                       .array()
#                       .valueOf()
#                       .slice(0, -1)
#                       .slice(0, -1))
#
#     (shapes[i][0]).selectize({deepSelect:true})
#                       .resize(snapToGrid: grid)
#                       .draw('stop', event)
#     i++
#     polysEventIsOn = false
#     draw.off 'dblclick'
#
#     # undoRedoShapeBeforeDrag(shapes[i-1])
#
#     # Возможность добавлять точку в полигон:
#     squareListiner(shapes[i-1])
#
#
#
# # # TODO
#     # chronology.add
#     #   up: ->
#     #     shapes[i-1][0].selectize({deepSelect:true}).show()
#     #     # if deletedShapes.length > 0
#     #     #   redoShape = deletedShapes[deletedShapes.length - 1]
#     #     #   points = (redoShape[0]).array()
#     #     #   if redoShape[1] == polygon
#     #     #     poly = draw.polygon(points).draggable(snapToGrid: grid)
#     #     #             .attr('stroke-width', 3).attr(fill: polyMain_color, opacity: 0.5)
#     #     #             .selectize({deepSelect:true}).resize(snapToGrid: grid)
#     #     #   else
#     #     #     poly = draw.polygon(points).draggable(snapToGrid: grid)
#     #     #             .attr('stroke-width', 2).attr(fill: polySub_color, opacity: 0.3)
#     #     #             .selectize({deepSelect:true}).resize(snapToGrid: grid)
#     #     #
#     #     #   shapes.push(redoShape)
#     #     #   i++
#     #     #   deletedShapes.pop()
#     #     #   undoRedoShapeBeforeDrag(redoShape)
#     #     #   return
#     #     # return
#     #
#     #   down: ->
#     #     shapes[i-1][0].selectize(false, {deepSelect:true}).hide()
#     #     # if shapes.length > 0
#     #     #   undoShape = shapes[i-1]
#     #     #   deletedShapes.push(undoShape)
#     #     #   shapes.pop()
#     #     #   i--
#     #     #   undoShape[0].selectize(false, {deepSelect:true}).remove()
#     #     #   return
#     #     # return
#     #
#     #   call: false
#
#
#
#   # Отключить хендлеры, слушающие завершение отрисовки с удалением последней фи-
#   # гуры:
#   cancelDrawPolygon = (event) ->
#     (shapes[i][0]).selectize({deepSelect:true})
#                       .resize(snapToGrid: grid)
#                       .draw('cancel', event)
#     i++
#     polysEventIsOn = false
#     draw.off 'dblclick'
#
#
#   ################################ ХЕНДЛЕРЫ ####################################
#   # хендлер POLYGON:
#   ($("#polygon")).on 'click', ->
#     initDrawPolygon(1)
#
#   # хендлер SUBPOLYGON:
#   ($("#subpolygon")).on 'click', ->
#     initDrawPolygon(2)
#
#   # хендлер INFO:
#   ($("#info")).on 'click', ->
#     alert(
#       "Пользование\n
#       1......\n
#       2......\n
#       3......\n
#       ........")
#
#     # хендлер TRASH:
#   ($("#clear-canvas")).on 'click', (event) ->
#     if polysEventIsOn
#       cancelDrawPolygon(event)
#     clear = confirm("Данное действие очистит холст безвозвратно! Вы действительно хотите выполнить это?");
#     if clear
#       draw.remove()
#       draw = SVG('editor_canvas').size(sqr * grid, sqr * grid)
#       shapes = []
#       i = 0
#       chronology = new Chronology
#
#   # хендлер UNDO:
#   ($("#undo")).on 'click', ->
#     if polysEventIsOn
#       cancelDrawPolygon()
#     chronology.undo()
#
#   # хендлер REDO:
#   ($("#redo")).on 'click', ->
#     if polysEventIsOn
#       cancelDrawPolygon()
#     chronology.redo()
#
#
#   # отправка данных в Rails:
#   $('.qq').on 'click', ->
#     editorData = []
#     for i in [0...shapes.length]
#       editorData[i] = [shapes[i][0].array(), shapes[i][1]]
#
#     $.ajax
#       type: "POST",
#       url: '/floors',
#       data: {floor: {name: $("#floor_name").val(), description: $("#floor_description").val(), building_id: $("#floor_building_id").val()}, 'editorData[]': editorData},
#       # success:(data) ->
#       #   alert data.id
#       #   return false
#       # error:(data) ->
#       #   return false
#
# # ready:
# ready = ->
#   if ($("div").is("#editor_canvas"))
#     menuInit()
#     editorInit()
#
#
# $(document).on 'page:load', ready
# $(document).ready ready
