<div class="dashlet">
   <div class="title">${title!msg("header.activity")}</div>
   <div class="body scrollableList">
	<#if entries?exists && entries?size &gt; 0>
		<#list entries as entry>
	   <div class="detail-list-item <#if (!entry_has_next)>last</#if>">
   		<div>
   		   <h4>${entry.title?html}</h4>
   		   ${entry.summary}
   		</div>
	   </div>
		</#list>
	<#else>
      <div class="detail-list-item">
		   ${msg("label.noActivities")}
		</div>
	</#if>
	</div>
</div>
<script type="text/javascript">//<![CDATA[
(function()
{
   var links = YAHOO.util.Selector.query("a[rel]", "${args.htmlid}");
   for (var i = 0, len = links.length; i < len; ++i)
   {
      links[i].setAttribute("target", links[i].getAttribute("rel"));
   }
})();
//]]></script>