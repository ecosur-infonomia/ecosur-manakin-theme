
/***************************FUNCIONES DEL RIE *************************************************/
/***************************FUNCIONES DEL RIE *************************************************/
/***************************FUNCIONES DEL RIE *************************************************/
/***************************FUNCIONES DEL RIE *************************************************//***************************FUNCIONES DEL RIE *************************************************/


function validateURLIRE(){    

    /**Se oculta la seccion de login inferior*/
    $("#aspect_viewArtifacts_Navigation_list_account").hide();
    $(".ds-option-set-head:contains('Mi cuenta')").remove();  //Elimina el header de Mi cuenta
    if($("#ds-feed-option").length>0){  //Se mueve el div RSS a la parte inferior        
        $("#sectionRSS").html($("#ds-feed-option").html());
        $(".ds-option-set-head:contains('RSS Feeds')").remove();
        $("#ds-feed-option").remove();
    }

    var url=$(location).attr('href');
    var word="discover";        
    if(url.indexOf(word)!= -1){        
        reubicaCollections();
        return;
    }
    if(url.indexOf("handle")!= -1){
        reubicaDescripcionCollection();
        setLeyendas();
        return;
    }
    
    if(url.indexOf("browse?type=author")!= -1 || url.indexOf("browse?type=subject")!= -1){
        reubicaLeyendadeAutores();
        return;
    }
    if(url=='http://localhost:8084/xmlui/' || url.indexOf("discover")){
        setLeyendas();
    }
   if(url=='http://localhost:8084/xmlui/'){
        hiddenOptionSearch();
    }   

}

/**
 *Funcion que remueve las opciones de la busqueda en la pagina principal
 **/
function hiddenOptionSearch(){
    //Remueve todo los resultados de la busqueda del discovery
    $("#aspect_discovery_SimpleSearch_div_search .ds-div-head, .pagination-masked, #aspect_discovery_SimpleSearch_div_search-results").remove();
    $("#ds-body .ds-div-head").first().remove(); //REmueve la primer etiqueta del titulo del RIE
    $('#file_news_div_news').insertAfter('#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser');

}

/**
 * Mueve la leyenda del tipo de documento abajo del icono del documento
 */
function setLeyendas(){
    $(".tipoProduct").each(function(){
        var name="#leyenda"+$(this).parent().attr("id");
        $(name).html($(this).html());
        $(this).remove();
    });
}


function reubicaLeyendadeAutores(){
    if($(".ds-table-header-row").length>0){
            //Valida si esta en el registro completo para mover el enlace del texto completo            
            $(".ds-table-header-row").remove();
        }
}


/***
 * ELIMINA DEL DISCOVERY INICIAL LAS COLECCIONES ESTO ES CUANDO SE INICIA LA BUSQUEDA
 */
function reubicaCollections(){
    setLeyendas();
   // $(".ds-artifact-list > ul").first().remove();
    //$(".ds-head").remove();
}


/**
 * REUBICA LA DESCRIPCION DE LA COLECCION AL INICIO DE LA PAGINA
 */
function reubicaDescripcionCollection(){
      //Valida si esta en el registro completo para mover el enlace del texto completo
        if($(".urlDocumentFull").length>0){
            var opcionTF=$(".urlDocumentFull").html();
            $(".urlDocumentFull").remove();
            $("#linkFull").append(opcionTF);            
            var fileref=document.createElement('script');
            fileref.setAttribute("type","text/javascript");
            fileref.setAttribute("src", "http://w.sharethis.com/button/buttons.js");
            document.getElementsByTagName("head")[0].appendChild(fileref);
            stLight.options({publisher: "524c4c3c-85b3-4b75-ae39-925731226c21", doNotHash: false, doNotCopy: false, hashAddressBar: false});
    
        }

  if($('#aspect_artifactbrowser_CollectionViewer_div_collection-view').length)
      $('#aspect_artifactbrowser_CollectionViewer_div_collection-view').insertBefore("#aspect_artifactbrowser_CollectionViewer_div_collection-search-browse");
  if($('#aspect_discovery_CollectionSearch_div_collection-search').length)
  $('#aspect_discovery_CollectionSearch_div_collection-search').insertBefore("#aspect_artifactbrowser_CollectionViewer_div_collection-browse");

}

jQuery(document).ready(function() {
        //Cierra los popover
        $(document).on('click', '.popover-title', function() {
            var div="";
             if(typeof($(".popover-title").parent().parent().attr('id'))!= "undefined")
                 div="#popover"+$(".popover-title").parent().parent().attr('id');
             else                 
                 div="#resumen"+$(".popover-title").parent().parent().parent().attr('id');                 
            $(div).popover('hide');
        });


   //Muestra los videos en la lista rapida
   $('.videos').on('click',function(){
     var id=$(this).parent().parent().attr('id');
     var url=$(this).attr('name');
     if(url.indexOf('watch?v=')!= -1 && url.indexOf('youtube')!= -1 ){
         var n=url.split("watch?v=");
         url="http://www.youtube.com/embed/"+n[1];
     }
     var name='#video'+id;
     var path='<iframe width="100%"  id="23" height="315" src="'+url+'" frameborder="0" allowfullscreen></iframe>';
     $(name).html(path).parent().show();
   });

   //Cierra un video
   $(".closeVideo").on('click',function(){
     $(this).parent().hide();
   });

});