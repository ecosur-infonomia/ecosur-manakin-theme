<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

<xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

                                <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <!--MANDA A IMPRIMIR CADA TITULO DE LA LISTA-->
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">

<div class="item-wrapper clearfix">
                    <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">                        <xsl:with-param name="href" select="$href"/>                    </xsl:apply-templates>
                                                                                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                         mode="itemSummaryList-DIM-file">                               <xsl:with-param name="href" select="$href"/>                               
                                                            </xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="item-wrapper clearfix">
                <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                        <xsl:with-param name="href" select="$href"/>
                    </xsl:apply-templates>
                  <div class="artifact-description">
                      <ul>
                        <!--Titulo y Autor-->
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata">                                <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>

                        <!--Informacion por tipo de documento-->
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                         mode="informationTypeDocument"/>

                        <!--Resumen, temas y mas detalles-->
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                         mode="Topics_Abstract_Others">
                             <xsl:with-param name="href" select="$href"/>                        </xsl:apply-templates>
            </ul>
                    </div>
               </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-file">
        <xsl:param name="href"/>
        <xsl:variable name="metadataWidth" select="675 - $thumbnail.maxwidth - 30"/>
        <div class="item-metadata" style="width: {$metadataWidth}px;">
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.title</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </span>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.author</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <span>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.date</i18n:text><xsl:text>:</xsl:text></span>
                <span class="content" style="width: {$metadataWidth - 110}px;">
                    <xsl:value-of
                            select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    

            <!--handles the rendering of a single item in a list in metadata mode-->
    <!--IMPRIME LA INFORMACION DE CADA ITEM-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <xsl:variable name="handleItem" select="substring-after($href,'/xmlui/handle/123456789/')"/>
            <li class="artifact-title titleDocument" id="title{$handleItem}">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </li>
            <li class="artifact-info">
                <span class="author" id="autores{$handleItem}">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                      <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </a>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                    <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </a>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                    <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </a>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                </li>
    </xsl:template>


<!--MUESTRA LA INFORMACION POR TIPO DE DOCUMENTO-->
<xsl:template match="dim:dim" mode="informationTypeDocument">
            <!-- MUESTRA LA INFORMACION DE ACUERDO AL TIPO DE DOCUMENTO -->
               <xsl:variable name="tipo" select="dim:field[@element='type'][1]/node()"/>
               <xsl:choose>
                   <!--LIBRO-->
                    <xsl:when test="$tipo='Cuaderno de divulgación' or $tipo='Manual de divulgación' or $tipo='Libro con arbitraje' or $tipo='Informe técnico' or $tipo='Informe técnico final' or $tipo='Libro sin arbitraje' or $tipo='Material didáctico' or $tipo='Manual asociado a evento de capacitación'">
                        <li>
                        <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
                            <xsl:value-of select="dim:field[@element = '260' and @qualifier='a']/node()"/>
                        </xsl:if>

                        <xsl:if test="dim:field[@element='publisher']">
                            <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
                                  <xsl:text>:</xsl:text>
                            </xsl:if>
                            <xsl:value-of  select="dim:field[@element='publisher'][1]/node()"/>
                        </xsl:if>

                        <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
 <xsl:if test="dim:field[@element = '260' and @qualifier='a'] or dim:field[@element='publisher']">
                                        <xsl:text>, </xsl:text>
                </xsl:if>
                            <xsl:value-of select="dim:field[@element='date' and @qualifier='issued']"/>
                        </xsl:if>
                    </li>
                    </xsl:when>

                    <!--ARTICULO-->
                    <xsl:when test="$tipo='Artículo con arbitraje' or $tipo='Artículo sin arbitraje' or $tipo='Artículo sin arbitraje' or $tipo='Nota periodistica' or $tipo='Nota periodistica' or $tipo='Artículo de divulgacion'">
                        <li>
                        <xsl:if test="dim:field[@element = 'relation' and @qualifier='ispartof']">
                            Contenido en: <xsl:value-of select="dim:field[@element = 'relation' and @qualifier='ispartof']/node()"/>.
                        </xsl:if>
                        <xsl:if test="dim:field[@element = '773' and @qualifier='g']">
                           <xsl:value-of select="dim:field[@element = '773' and @qualifier='g']/node()"/>
                        </xsl:if>
                        <xsl:if test="dim:field[@element = 'date' and @qualifier='issued']">
                           <xsl:value-of select="dim:field[@element = 'date' and @qualifier='issued']/node()"/>
                        </xsl:if>
                        </li>
                        <xsl:if test="dim:field[@element = 'identifier']">
                            <li>
                            DOI: <xsl:value-of select="dim:field[@element = 'identifier'][1]/node()"/>
                           </li>
                        </xsl:if>
                    </xsl:when>

                    <!--CAPITULOs de LIBRO-->
                    <xsl:when test="$tipo='Capítulo de libro con arbitraje' or $tipo='Capítulo de libro sin arbitraje'">
                        <li>
                        <xsl:if test="dim:field[@element = 'relation' and @qualifier='ispartof']">
                            Contenido en: <xsl:value-of select="dim:field[@element = 'relation' and @qualifier='ispartof']/node()"/>
	                <xsl:if test="dim:field[@element = 'contributor' and @qualifier='other']">
	                    <xsl:text> / </xsl:text>
	                    <xsl:value-of select="dim:field[@element = 'contributor' and @qualifier='other']/node()"/>
                            </xsl:if>
                            <xsl:text>. </xsl:text>
                        </xsl:if>
                        <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
                           <xsl:value-of select="dim:field[@element = '260' and @qualifier='a']/node()"/>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='publisher']">
	                        <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
	                            <xsl:text> : </xsl:text>
                             </xsl:if>
                            <xsl:value-of  select="dim:field[@element='publisher'][1]/node()"/>
	                        </xsl:if>
	                        <xsl:text>, </xsl:text>
	                    <xsl:if test="dim:field[@element = 'date' and @qualifier='issued']">
                           <xsl:value-of select="dim:field[@element = 'date' and @qualifier='issued']/node()"/>
                           <xsl:text>. </xsl:text>
                        </xsl:if>
                        <xsl:if test="dim:field[@element = 'identifier' and @qualifier='isbn']">
                           [ISBN: <xsl:value-of select="dim:field[@element = 'identifier' and @qualifier='isbn']/node()"/>]
                           <xsl:text>. </xsl:text>
                        </xsl:if>
                        <xsl:if test="dim:field[@element = '773' and @qualifier='g']">
                            <xsl:if test="not(contains(dim:field[@element = '773' and @qualifier='g']/node(),'p.') or contains(dim:field[@element = '773' and @qualifier='g']/node(),'pag.')  )">
                                <xsl:text>p. </xsl:text>
                             </xsl:if>
                           <xsl:value-of select="dim:field[@element = '773' and @qualifier='g']/node()"/>
                        </xsl:if>
                        </li>
                    </xsl:when>

                    <!--TESIS-->
                    <xsl:when test="$tipo='Tesis'">
                        <li>
                            <xsl:if test="dim:field[@element='publisher']">
                                <xsl:value-of  select="dim:field[@element='publisher'][1]/node()"/>
                            </xsl:if>
                            <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
                                <xsl:if test="dim:field[@element='publisher']">
                                    <xsl:text> : </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="dim:field[@element = '260' and @qualifier='a']/node()"/>
                            </xsl:if>
	                    <xsl:if test="dim:field[@element = 'date' and @qualifier='issued']">
                                <xsl:if test="dim:field[@element='publisher'] or dim:field[@element = '260' and @qualifier='a']">
                                    <xsl:text>. </xsl:text>
                                 </xsl:if>
                            </xsl:if>
                        </li>
                    </xsl:when>
                    <!--VIDEO-->
                    <xsl:when test="$tipo='Video'">
                        <li>                            
                            <xsl:if test="dim:field[@element='publisher']">
                                <xsl:text>Duración </xsl:text>
                                <xsl:value-of  select="dim:field[@element='format'][1]/node()"/>
                            </xsl:if>
                        </li>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of  select="$tipo"/>
                    </xsl:otherwise>
               </xsl:choose>
</xsl:template>


    <xsl:template match="dim:dim" mode="Topics_Abstract_Others">
        <xsl:param name="href"/>
        <xsl:variable name="handleItem">
            <xsl:choose>
                   <xsl:when test="contains($href,'/xmlui/handle/')">
                     <xsl:value-of select="substring-after($href,'/xmlui/handle/123456789/')"/>
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:value-of select="substring-after($href,'123456789/')"/>
                   </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="abstractTopicResum" >
            <ul class="descriptionProducto" id="{$handleItem}">
                    <li class="tipoProduct">                        
                        <xsl:value-of select="dim:field[@element='type'][1]/node()"/>
                         <!--Si es una tesis le agrega el grado-->
                         <xsl:if test="dim:field[@element='type'][1]/node()='Tesis'">
                               <xsl:text> de </xsl:text>
                               <b> <xsl:value-of select="dim:field[@element='rae' and @qualifier='grado']"/></b>
                         </xsl:if>
                    </li>
                    <!--Si es un video agrega el enlace para ver el video en la lista rapida-->
                    <xsl:if test="dim:field[@element='type'][1]/node()='Video'">
                        <xsl:if test="dim:field[@element='856'][@qualifier='u']">
                            <li>
                                <xsl:variable name="url">
	                        <xsl:value-of select="dim:field[@element='856'][@qualifier='u']"/>
	                    </xsl:variable>
	                    <span class="image imageVideo" ><xsl:text>  </xsl:text>
</span>
	                <span class="videos" name="{$url}"> Video </span>
                </li>
                        </xsl:if>
            </xsl:if>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <li>
                        <span class="abstract"><xsl:text> </xsl:text></span>
                        <span class="ResumenName" id="resumen{$handleItem}">Resumen</span></li>
                        <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div id="ContentResumen{$handleItem}">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
                                                                                    <!--Activa el emergente-->
                        <script type="text/javascript">
                            var nameContent="#"+"ContentResumen"+<xsl:value-of select="$handleItem"/>;
                            var options={
                                        content:$(nameContent).html(),
                                        html:"true",
                                        placement:"right",
                                        trigger:"click",
                                        rel:"popover",
                                        title:"x"
                            }
                            $("#resumen<xsl:value-of select="$handleItem"/>").popover(options);
                            $(nameContent).remove();
                        </script>
                    </xsl:if>

                   <!--Inserta el enlace para ver el popover emergente con la información restante-->
                   <li id="popover{$handleItem}">
                       <span class="details"><xsl:text> </xsl:text></span>
                       <span class="showMoreDetails">Más información</span>
                   </li>

                   <!--Inserta el shareThis de cada resultado-->
                   <li>
                       <span id="share{$handleItem}" >
                           <img src="http://cdn.sharethis.com/devtools/images/sharethis_16_bw.png"/>
                           <span>Compartir</span>
                       </span>
                   </li>
            </ul>
            <!--Inserta el div oculto para mostrar el video si tiene el documento -->
            <xsl:if test="dim:field[@element='type'][1]/node()='Video'">
                <xsl:if test="dim:field[@element='856'][@qualifier='u']">
                    <div style="display:none" class="video">
                                <div class="closeVideo"><span >x</span></div>
                                <xsl:variable name="url">
                                    <xsl:value-of select="dim:field[@element='856'][@qualifier='u']"/>
                                </xsl:variable>
                                <div id="video{$handleItem}">
                                </div>
                    </div>
                </xsl:if>
            </xsl:if>
        </div>
                            <!--Para ver rapido los detalles-->
          <div  style="display:none" id="moreDetails{$handleItem}">
                    <xsl:variable name="titulo">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                    </xsl:variable>
                   <table>
                        <xsl:if test="dim:field[@element='subject']">
                           <tr id="{$handleItem}" class="asociadoemergente">
                               <td class="labelTitle"><b>Temas:</b> </td>
                               <td>
                                           <xsl:for-each select="dim:field[@element='subject'][not(@qualifier)]">
                                                <li>                                                    
                                                    <a href="/xmlui/browse?value={./node()}&amp;type=subject"><xsl:value-of select="./node()"/></a>
                                                    <xsl:if test="count(following-sibling::dim:field[@element='subject'][not(@qualifier)]) != 0">
                                                      <xsl:text>, </xsl:text>
                                                    </xsl:if>
                                                 </li>
                                           </xsl:for-each>                                    
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='rae' and @qualifier='nameposgrado']">
                           <tr><td class="labelTitle"> <b>Posgrado: <xsl:text> </xsl:text></b></td>
                                <td>
                                    <xsl:value-of select="dim:field[@element='rae' and @qualifier='nameposgrado']"/>
                                </td>
                           </tr>
                        </xsl:if>
                       <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn']">
                           <tr> <td class="labelTitle">
                                <b>ISBN: <xsl:text> </xsl:text></b>
                                </td>  <td>
                                    <xsl:value-of select="dim:field[@element='identifier' and @qualifier='isbn']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='format' and @qualifier='extent']">
                           <tr><td class="labelTitle">
                               <b> Páginas:</b><xsl:text> </xsl:text>
                              </td>   <td>
                                <xsl:value-of select="dim:field[@element='format' and @qualifier='extent']"/>
                              </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='rae' and @qualifier='dateaceptation']">
                            <tr><td class="labelTitle">
                                    <b>Fecha aceptación:</b><xsl:text> </xsl:text>
                                    </td><td>
                                    <xsl:value-of select="dim:field[@element='rae' and @qualifier='dateaceptation']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='identifier' and @qualifier='issn']">
                           <tr><td class="labelTitle">
                                <b>ISSN de la revista:</b><xsl:text> </xsl:text>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='identifier' and @qualifier='issn']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='250' and @qualifier='a']">
                           <tr><td class="labelTitle">
                                <b>Edición:</b><xsl:text> </xsl:text>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='250' and @qualifier='a']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
                           <tr><td class="labelTitle">
                                <b> Seríe:</b><xsl:text> </xsl:text>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='relation' and @qualifier='ispartofseries']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='rae' and @qualifier='dateinit']">
                           <tr><td class="labelTitle">
                                <b>Inicio de la tesis: <xsl:text> </xsl:text></b>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='rae' and @qualifier='dateinit']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='date' and @qualifier='submitted']">
                           <tr><td class="labelTitle">
                                <b>Examén de grado: <xsl:text> </xsl:text></b>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='date' and @qualifier='submitted']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='language' and @qualifier='iso']">
                            <tr><td class="labelTitle">
                                <b> Lenguaje:</b><xsl:text> </xsl:text>
                                </td><td>
                                <xsl:value-of select="dim:field[@element='language' and @qualifier='iso']"/>
                                </td>
                           </tr>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='856'][@qualifier='u']">
                            <tr><td class="labelTitle"><b> Enlaces </b> </td>
                              <td>
                                <ul>
                                <xsl:for-each select="dim:field[@element='856'][@qualifier='u']">
                                    <li>
                                          <xsl:copy-of select="node()"/>
                                    </li>
                                </xsl:for-each>
                                </ul>
                             </td>
                           </tr>                           
                        </xsl:if>
                        <tr>

                               <td colspan="2">
                                   <div class="fullRegisterDiv">                                       
                                         <xsl:element name="a">
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="$href"/>
                                            </xsl:attribute>
                                            <span class="fullRegister"> </span>  Ir al registro completo
                                        </xsl:element>
                                 </div>
                               </td>
                           </tr>
                        </table>
                </div>                
               <script type="text/javascript">
                    var nameContent="#"+"moreDetails"+<xsl:value-of select="$handleItem"/>;
                    var options={
                                content:$(nameContent).html(),
                                html:"true",
                                placement:"right",
                                trigger:"click",
                                rel:"popover",
                                title:"x"
                    }
                    $("#popover<xsl:value-of select="$handleItem"/>").popover(options);
                    /*Se agrega el share de cada */
                    var tituloS="<xsl:value-of select="dim:field[@element='title'][1]/node()"/>";
                    var url="http://localhost:8084"+"<xsl:value-of select="$href"/>";
                    var nameAu="#autores"+"<xsl:value-of select="$handleItem"/>";
                    var autores=$(nameAu).html();
                    stWidget.addEntry({
                        "service":"sharethis",
                        "element":document.getElementById('share<xsl:value-of select="$handleItem"/>'),
                        "url":url,
                        "title":tituloS,
                        "type":"custom",
                        "text":"ShareThis",
                        "image":"http://bibliotecasibe.ecosur.mx/sibe/css/images/newGUI/logo-ECOSUR-pie.png",
                        "summary":autores
                        });
                </script>
    </xsl:template>

                <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <xsl:variable name="handleItem">
            <xsl:choose>
                   <xsl:when test="contains($href,'/xmlui/handle/')">
                     <xsl:value-of select="substring-after($href,'/xmlui/handle/123456789/')"/>
                   </xsl:when>
                   <xsl:otherwise>
                     <xsl:value-of select="substring-after($href,'123456789/')"/>
                   </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="thumbnail-wrapper">
            <div class="artifact-preview">
                <div>
                        <a class="image-link" href="{$href}">
                    <xsl:choose>
                        <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="imgType"> </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
        <div id="leyenda{$handleItem}" class="leyendaItem"></div>
            </div>
            
        </div>
    </xsl:template>


</xsl:stylesheet>
