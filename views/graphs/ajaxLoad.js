var showData = function(graphData)
    {
        $('#status').html('....rendering data')
        setTimeout (function()
            {
                $("#graph").css({'left': '2px', 'right': '2px', 'bottom': '2px', 'top': '80px'});
                var container = document.getElementById('graph');
                network = new vis.Network(container, graphData, options);
                $('#status').html('')

                openArticle = function(data)
                {
                    node = data.nodes[0]
                    console.log('selected node: ' + node)
                    nodeData = network.nodesData._data[node]
                    console.log(nodeData)
                    if (nodeData!= undefined && nodeData.guid)
                    {
                        console.log(nodeData.guid)
                        window.open('https://tmdev01-sme.teammentor.net/' + nodeData.guid, '_blank')
                    }
                }
                network.on('doubleClick', openArticle)
            }, 10)
    };

var ajaxLoad = function(url)
    {
        $('#status').html('....loading data')
        console.log("[loadData]");
        $.ajax({type: "GET", url: url})
            .done(function (graphData) {
                showData(graphData);
            })
            .fail( function(xhr, textStatus, errorThrown) {
                $('#status').html('....Error loading data' + xhr.responseText);
            });
    };
$(function()
    {
        ajaxLoad($("#dataUrl").attr('href'))
    });