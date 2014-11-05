require 'fluentnode'

Guid = require './Guid'

class Vis_Node
  constructor: (from, to, label) ->
    @from  = from  || new Guid().raw
    @to    = to    || new Guid().raw
    if (label)
      @label = label


  _color: (value)=>
    @['color']=value
    @

  _style: (value)=>
    @['style']=value
    @

  #colors
  blue        : ()=> @_color('blue')
  red         : ()=> @_color('red')

  #styles
  line        : ()-> @_style('line')
  arrow       : ()-> @_style('arrow')
  arrow_center: ()-> @_style('arrow-center')
  dash_line   : ()-> @_style('dash-line')

module.exports = Vis_Node