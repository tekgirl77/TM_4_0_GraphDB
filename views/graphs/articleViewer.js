open_Article = function(data)
    {
        node = data.nodes[0]
        console.log('selected node: ' + node)
        nodeData = network.nodesData._data[node]
        console.log(nodeData)
        if (nodeData!= undefined && nodeData.guid)
        {
            console.log(nodeData.guid)
            window.open('https://uno.teammentor.net/' + nodeData.guid, '_blank')//'articleView')
        }
    };

select_Nodes_with_same_Guid = function(data)
    {
        if(data.nodes.length ===1)
        {
            guidToFind = network.nodesData._data[data.nodes[0]].guid;

            if (guidToFind != undefined)
            {
                nodesToSelect = [];
                Object.keys(network.nodesData._data).forEach(function(key) {
                    node = network.nodesData._data[key];
                    guid = node.guid;
                    if(guid != undefined && guid === guidToFind)
                    {
                        console.log(guid);
                        nodesToSelect.push(node.id)
                    }
                });
                network.selectNodes(nodesToSelect)
            }
        }
        else
            network.selectNodes([])
    };

networkIsSetup = function()
    {
        network.on('doubleClick', open_Article);
        network.on('click'      , select_Nodes_with_same_Guid)
        /*
        if ($('#articleView').size() == 0)
            $("<iframe id='articleView' name ='articleView'/>").appendTo('body')
        $('#articleView').attr('src', 'http://localhost:1332').css(
            {
                position: 'absolute',
                right: '10px',
                bottom: '10px',
                width: '450px',
                height: '350px'
            })*/
    };
