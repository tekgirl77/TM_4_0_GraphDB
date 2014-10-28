var showData = function(graphData)
    {
        $("#graph").css({'left':'2px','right':'2px' , 'bottom':'2px', 'top':'80px'});
        var container = document.getElementById('graph');
        network = new vis.Network(container, graphData, options);
    };

var ajaxLoad = function(url)
    {
        console.log("[loadData]");
        $.ajax({ type: "GET",  url: url})
            .done(function(graphData) { showData(graphData); });
    };
$(function()
    {
        ajaxLoad($("#dataUrl").attr('href'))
    });