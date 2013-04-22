<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering specific to the item display page.

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
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

<!--
        http://www.facebook.com/sharer.php?u=http%3A//localhost:8084/xmlui/handle/123456789/4
http://www.facebook.com/sharer.php?u=http%3A//www.redalyc.org/articulo.oa%3Fid=31005009
https://twitter.com/intent/tweet?original_referer=http%3A//www.redalyc.org/articulo.oa%3Fid=31005009&amp;text=%20http%3A//www.redalyc.org/articulo.oa%3Fid=31005009%20%40redalyc"
https://plus.google.com/share?url=http%3A//www.redalyc.org/articulo.oa%3Fid=31005009
-->
        <xsl:copy-of select="$SFXLink" />
        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']">
                    <xsl:with-param name="context" select="."/>
                    <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']"/>
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

<!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>

</xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <xsl:call-template name="itemSummaryView-DIM-fields"/>
        </div>
    </xsl:template>

        <xsl:template name="itemSummaryView-DIM-fields">
      <xsl:param name="clause" select="'1'"/>
      <xsl:param name="phase" select="'even'"/>
      <xsl:variable name="otherPhase">
            <xsl:choose>
              <xsl:when test="$phase = 'even'">
                <xsl:text>odd</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>even</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
      </xsl:variable>

      <xsl:choose>
          <!-- Title row -->
          <xsl:when test="$clause = 1">

<xsl:choose>
                  <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                      <!-- display first title as h1 -->
                      <h1>
                          <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                      </h1>
                      <div class="simple-item-view-other">
                                                        <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:</span>
                          <span>
                              <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                                  <xsl:value-of select="./node()"/>
                                  <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                      <xsl:text>; </xsl:text>
                                      <br/>
                                  </xsl:if>
                              </xsl:for-each>
                          </span>
                                            </div>
                  </xsl:when>
                  <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                      <h1>
                          <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                      </h1>
                  </xsl:when>
                  <xsl:otherwise>
                      <h1>
                          <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                      </h1>
                  </xsl:otherwise>
              </xsl:choose>
            <xsl:call-template name="itemSummaryView-DIM-fields">
              <xsl:with-param name="clause" select="($clause + 1)"/>
              <xsl:with-param name="phase" select="$otherPhase"/>
            </xsl:call-template>
          </xsl:when>

          <!-- Author(s) row -->
          <xsl:when test="$clause = 2 and (dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='creator'] or dim:field[@element='contributor'])">
                    <div class="simple-item-view-authors">
	                    <xsl:choose>
	                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
	                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                                                                    <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                          <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                          </xsl:if>
	                                <xsl:copy-of select="node()"/>
                                        </a>
                                        
	                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
	                                    <xsl:text>, </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                        <xsl:when test="dim:field[@element='creator']">
	                            <xsl:for-each select="dim:field[@element='creator']">
	                                <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                            <xsl:copy-of select="node()"/>
	                                </a>
	                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
	                                    <xsl:text>, </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                        <xsl:when test="dim:field[@element='contributor']">
	                            <xsl:for-each select="dim:field[@element='contributor']">
	                                <a href="/xmlui/discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter={node()}">
                                            <xsl:copy-of select="node()"/>
	                                </a>
	                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
	                                    <xsl:text>; </xsl:text>
	                                </xsl:if>
	                            </xsl:for-each>
	                        </xsl:when>
	                        <xsl:otherwise>
	                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
	                        </xsl:otherwise>
	                    </xsl:choose>
	            </div>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

          <!-- identifier.uri row -->
          <xsl:when test="$clause = 3 and (dim:field[@element='identifier' and @qualifier='uri'])">
                    <div class="simple-item-view-other">
	                <div class="portada">
                        <span></span>
                      </div>
                    <div class="descripcion">
                        <ul>
                        <xsl:variable name="tipo" select="dim:field[@element='type'][1]/node()"/>
                           <xsl:choose>
                               <!--LIBRO-->
                                <xsl:when test="$tipo='Cuaderno de divulgación' or $tipo='Manual de divulgación' or $tipo='Libro con arbitraje' or $tipo='Informe técnico' or $tipo='Informe técnico final' or $tipo='Libro sin arbitraje' or $tipo='Material didáctico' or $tipo='Manual asociado a evento de capacitación'">
                                    <li>
                                    <xsl:if test="dim:field[@element = '260' and @qualifier='a']">
                                        <xsl:value-of select="dim:field[@element = '260' and @qualifier='a']/node()"/>
                                    </xsl:if>

                                    <xsl:if test="dim:field[@element='publisher']">
                                        <xsl:if test="dim:field[@element = '260' and @qualifier='a']">                                              <xsl:text>:</xsl:text>
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
                                        <b>Contenido en:</b> <xsl:text> </xsl:text><xsl:value-of select="dim:field[@element = 'relation' and @qualifier='ispartof']/node()"/>.
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
                                        <b>DOI:</b> <xsl:text> </xsl:text><xsl:value-of select="dim:field[@element = 'identifier'][1]/node()"/>
                                       </li>
                                    </xsl:if>
                                </xsl:when>

                                <!--CAPITULOs de LIBRO-->
                                <xsl:when test="$tipo='Capítulo de libro con arbitraje' or $tipo='Capítulo de libro sin arbitraje'">
	                <li>
	                	<xsl:if test="dim:field[@element = 'relation' and @qualifier='ispartof']">
		                    <b>Contenido en:</b> <xsl:value-of select="dim:field[@element = 'relation' and @qualifier='ispartof']/node()"/>
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
                                       [ISBN: <xsl:value-of select="dim:field[@element = 'identifier' and @qualifier='isbn']/node()"/>
]
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
	                <xsl:if test="dim:field[@element='publisher']">                                                <xsl:text>:</xsl:text>
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
                                <xsl:otherwise>
                                    OTRO
                                </xsl:otherwise>
                           </xsl:choose>

                        
                        <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn']">
                           <li>
                                <b>ISBN: <xsl:text> </xsl:text></b>
                                <xsl:value-of select="dim:field[@element='identifier' and @qualifier='isbn']"/>
                           </li>
                        </xsl:if>                        
                        <xsl:if test="dim:field[@element='rae' and @qualifier='nameposgrado']">
                           <li>
                                <b>Posgrado: <xsl:text> </xsl:text></b>
                                <xsl:value-of select="dim:field[@element='rae' and @qualifier='nameposgrado']"/>
                           </li>
                        </xsl:if>
                        

                        <xsl:if test="dim:field[@element='identifier' and @qualifier='issn']">
                           <li>
                                <b>ISSN de la revista:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='identifier' and @qualifier='issn']"/>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='format' and @qualifier='extent']">
                           <li>
                               <b> Páginas:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='format' and @qualifier='extent']"/>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='250' and @qualifier='a']">
                           <li>
                                <b>Edición:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='250' and @qualifier='a']"/>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
                           <li>
                                <b> Seríe:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='relation' and @qualifier='ispartofseries']"/>
                           </li>
                        </xsl:if>

                        <xsl:if test="dim:field[@element='rae' and @qualifier='dateinit']">
                           <li>
                                <b>Inicio de la tesis: <xsl:text> </xsl:text></b>
                                <xsl:value-of select="dim:field[@element='rae' and @qualifier='dateinit']"/>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='date' and @qualifier='submitted']">
                           <li>
                                <b>Examén de grado: <xsl:text> </xsl:text></b>
                                <xsl:value-of select="dim:field[@element='date' and @qualifier='submitted']"/>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='856'][@qualifier='u']">
                            <li> Enlaces
	                <ul>
		                <xsl:for-each select="dim:field[@element='856'][@qualifier='u']">
		                	<li>
                                      <xsl:copy-of select="node()"/>
		                	 </li>
                            </xsl:for-each>
                            </ul>
                           </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='rae' and @qualifier='dateaceptation']">
                         <li>
                                <b>Fecha de aceptación:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='rae' and @qualifier='dateaceptation']"/>
                         </li>
                        </xsl:if>
                        <xsl:if test="dim:field[@element='language' and @qualifier='iso']">
                            <li>
                               <b> Lenguaje:</b><xsl:text> </xsl:text>
                                <xsl:value-of select="dim:field[@element='language' and @qualifier='iso']"/>
                            </li>
                        </xsl:if>
                    <xsl:if test="dim:field[@element='subject']">
                           <li>
                               <b>Temas: </b> <xsl:text> </xsl:text>
                               <xsl:for-each select="dim:field[@element='subject'][not(@qualifier)]">
                                        <a href="/xmlui/browse?value={./node()}&amp;type=subject"><xsl:value-of select="./node()"/></a>
                                                  <xsl:if test="count(following-sibling::dim:field[@element='subject'][not(@qualifier)]) != 0">
	                    	<xsl:text>, </xsl:text>
	                    </xsl:if>
		                                               </xsl:for-each>
	                </li>
                       </xsl:if>
                       </ul>
                         </div>
	            </div>
                            <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

                    <!-- Abstract row -->
          <xsl:when test="$clause = 4 and (dim:field[@element='description' and @qualifier='abstract' and descendant::text()])">
                    <div class="simple-item-view-description">
	                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>:</h3>
	                <div>
	                <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
	                	<div class="spacer">&#160;</div>
	                </xsl:if>
	                <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
	                    </xsl:if>
	              	</xsl:for-each>
	              	<xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                          <div class="spacer">&#160;</div>
	                </xsl:if>
	                </div>
	            </div>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

          <!-- Description row -->
          <xsl:when test="$clause = 5 and (dim:field[@element='description' and not(@qualifier)])">
                <div class="simple-item-view-description">
	                <h3 class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-description</i18n:text>:</h3>
	                <div>
	                <xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1 and not(count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1)">
                        <div class="spacer">&#160;</div>
	                </xsl:if>
	                <xsl:for-each select="dim:field[@element='description' and not(@qualifier)]">
		                <xsl:copy-of select="./node()"/>
		                <xsl:if test="count(following-sibling::dim:field[@element='description' and not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
	                    </xsl:if>
	               	</xsl:for-each>
	               	<xsl:if test="count(dim:field[@element='description' and not(@qualifier)]) &gt; 1">
                           <div class="spacer">&#160;</div>
	                </xsl:if>
	                </div>
	            </div>
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$otherPhase"/>
              </xsl:call-template>
          </xsl:when>

          <xsl:when test="$clause = 6 and $ds_item_view_toggle_url != ''">
              <div class="enlaces">
                  <div>
                <!--ENLACE PERMANENTE-->
                   <ul id="enlacesOptFull">
                      <li id="linkFull"><!--Aqui se incluye el enlace al texto completo --></li>
                      <li>
                       <span class="permanentLink"><xsl:text> </xsl:text></span>
                       <span>
                            <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:copy-of select="./node()"/>
                                        </xsl:attribute>
                                        Enlace permanente
                                    </a>
                                    <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
              <br/>
                                    </xsl:if>
                            </xsl:for-each>
                        </span>
                      </li>
                      <li> <span class="full">
</span>
                  <a>
                      <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                      <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
                  </a>
              </li>
                      <li><span class='st_sharethis' displayText='Compartir'></span></li>
                 </ul>
              </div>
              </div>
          </xsl:when>

          <!-- recurse without changing phase if we didn't output anything -->
          <xsl:otherwise>
            <!-- IMPORTANT: This test should be updated if clauses are added! -->
            <xsl:if test="$clause &lt; 7">
              <xsl:call-template name="itemSummaryView-DIM-fields">
                <xsl:with-param name="clause" select="($clause + 1)"/>
                <xsl:with-param name="phase" select="$phase"/>
              </xsl:call-template>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

         <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default) -->
        <xsl:apply-templates select="mets:fileSec/mets:fileGrp[@USE='CC-LICENSE']"/>
    </xsl:template>


    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <table class="ds-includeSet-table detailtable">
		    <xsl:apply-templates mode="itemDetailView-DIM"/>
		</table>
        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td>
              <xsl:copy-of select="./node()"/>
              <xsl:if test="./@authority and ./@confidence">
                <xsl:call-template name="authorityConfidenceIcon">
                  <xsl:with-param name="confidence" select="./@confidence"/>
                </xsl:call-template>
              </xsl:if>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

        <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
<!--
        <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
        <div class="file-list">-->
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <!--<xsl:sort data-type="number" select="boolean(./@ID=$primaryBitstream)" order="descending" />-->
                        <!--<xsl:sort select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        <!--</div>-->
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
<!--
        <div class="file-wrapper clearfix">
            <div class="thumbnail-wrapper">
                <a class="image-link">
                    <xsl:attribute name="href">
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
</xsl:attribute>
<xsl:choose>
                        <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
</xsl:attribute>
</img>
</xsl:when>
<xsl:otherwise>
                            <img alt="Icon" src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;"/>
</xsl:otherwise>
</xsl:choose>
</a>
            </div>-->
            <!--<div class="file-metadata" style="height: {$thumbnail.maxheight}px;">
                  <div>-->
                                <!--ICONO-->
<span class="urlDocumentFull">
                        <xsl:choose>
                        <xsl:when test="@MIMETYPE='application/pdf'">                        <xsl:text>                    </xsl:text>
                    <span class="iconPDF">
<xsl:text>                        </xsl:text>
</span>
                    <xsl:text>                        </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                                <!--URL al documento-->
                <span>
                    <xsl:choose>
                        <xsl:when test="@ADMID">
                            <xsl:call-template name="display-rights"/>
                            </xsl:when>
                        <xsl:otherwise>
                        <xsl:call-template name="view-open"/>                            </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </span>
                            <!--Caracteristicas -->
                <!--
                    <span>
<xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>-->
                                                                                    <!---->
                        <!-- Display the contents of 'Description' only if bitstream contains a description -->
                    <!--<xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                    <div>
                        <span class="bold">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </span>
                        <span>
                            <xsl:attribute name="title"><xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/></xsl:attribute>
                    -->
                <!--<xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>-->
            <!--       <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 17, 5)"/>
                        </span>
                    </div>
                </xsl:if>
</div>
                </div>-->
    </xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
