<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>名称管理</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,router_name,wan_hostname,wan_domain"); %>

		function verifyFields(focused, quiet)
		{
			if (!v_hostname('_wan_hostname', quiet)) return 0;
			return v_length('_router_name', quiet, 1) && v_length('_wan_hostname', quiet, 0) && v_length('_wan_domain', quiet, 0);
		}

		function save()
		{
			if (!verifyFields(null, false)) return;
			form.submit('_fom', 1);
		}
	</script>


	<form id="_fom" method="post" action="tomato.cgi">

		<input type="hidden" name="_nextpage" value="/#basic.asp">
		<input type="hidden" name="_service" value="*">

		<div class="box">
			<div class="heading">路由器名称</div>
			<div class="content">
				<div id="identification" class="section"></div>
				<script type="text/javascript">
					$('#identification').forms([
						{ title: '路由器名称', name: 'router_name', type: 'text', maxlen: 32, size: 34, value: nvram.router_name },
						{ title: '主机名称', name: 'wan_hostname', type: 'text', maxlen: 63, size: 34, value: nvram.wan_hostname },
						{ title: '所在域', name: 'wan_domain', type: 'text', maxlen: 32, size: 34, value: nvram.wan_domain }
					]);
				</script>
			</div>
		</div>
	</form>

	<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
	<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
	<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	<script type="text/javascript">verifyFields(null, true);</script>
</content>