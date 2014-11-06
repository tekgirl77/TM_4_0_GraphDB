require 'fluentnode'

Guid = require './Guid'

class Vis_Node
  constructor: (id, label, graph)->
    @id = id || new Guid().raw
    if (label)
      @label = label
    @graph = ->
      graph

  add_Edge: (to,label)=>
    @graph().add_Edge(@id,to,label)

  _color: (value)=>
    @['color']=value
    @
  _mass: (value)=>
    @['mass']=value
    @
  _fontColor: (value)=>
    @['fontColor']=value
    @
  _fontSize: (value)=>
    @['fontSize']=value
    @
  _shape: (value)=>
    @['shape']=value
    @

  #colors
  black       : ()=> @_color('black')._fontColor('white')
  blue        : ()=> @_color('blue')
  green       : ()=> @_color('green')
  red         : ()=> @_color('red')

  #shapes
  box         : ()-> @_shape('box')
  circle      : ()-> @_shape('circle')
  dot         : ()-> @_shape('dot')
  eclipse     : ()-> @_shape('eclipse')
  database    : ()-> @_shape('database')
  image       : ()-> @_shape('image')
  #label       : ()-> @_shape('label')
  star        : ()-> @_shape('star')
  triangle    : ()-> @_shape('triangle')
  triangleDown: ()-> @_shape('triangleDown')




module.exports = Vis_Node