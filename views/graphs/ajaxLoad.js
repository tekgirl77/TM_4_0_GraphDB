var networkIsSetup = function()  { }

var showData = function(graphData)
    {
        $('#status').html('....rendering data')
        setTimeout (function()
            {
                $("#graph").css({'left': '2px', 'right': '2px', 'bottom': '2px', 'top': '80px'});
                var container = document.getElementById('graph');
                network = new vis.Network(container, graphData, options);
                $('#status').html('')

                networkIsSetup()

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