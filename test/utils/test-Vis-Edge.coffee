Vis_Edge  = require('./../../src/utils/Vis-Edge')

describe 'Vis-Edge',->

  visEdge =  Vis_Edge.ctor()

  it 'ctor',->
    Vis_Edge.assert_Is_Function().ctor().assert_Is_Object()
                                 .to    .assert_Is_String()
    Vis_Edge.ctor('abc'            ).from .assert_Is("abc")
    Vis_Edge.ctor(null, 'abc'      ).to   .assert_Is("abc")
    Vis_Edge.ctor(null, null, 'abc').label.assert_Is("abc")
    Vis_Edge.ctor().from .assert_Contains("-")
    Vis_Edge.ctor().to   .assert_Contains("-")
    (Vis_Edge.ctor().label==undefined).assert_Is_True()
    Vis_Edge.ctor('abc', 'def','ghi').json_pretty().assert_Is("{\n  \"from\": \"abc\",\n  \"to\": \"def\",\n  \"label\": \"ghi\"\n}")
    Vis_Edge.ctor(null,null,null,'the-graph').graph().assert_Is('the-graph')

  it 'from_Node, to_Node',->
    Vis_Edge.ctor().from_Node.assert_Is_Function()
    Vis_Edge.ctor().to_Node.assert_Is_Function()
    #see 'Vis_Edge - from_Node,to_Node' test from test-Vis-Graph


  #colors
  colors = ['black', 'blue', 'green','red', 'white']
  for color in colors
    do (color)->
      it "color: #{color}", ->
        visEdge[color]().color.assert_Is(color)

  #_style
  styles = ['line', 'arrow', 'arrow_center', 'dash_line']
  for style in styles
    do (style)->
      it "style: #{style}", ->
        visEdge[style]().style.assert_Is(style.replace('_','-'))