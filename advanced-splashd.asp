<!--
Tomato GUI
Copyright (C) 2006-2008 Jonathan Zarate
http://www.polarcloud.com/tomato/

Copyright (C) 2011 Ofer Chen (Roadkill), Vicente Soriano (Victek)
Adapted & Modified from Dual WAN Tomato Firmware.

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>网络通告</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,NC_enable,NC_Verbosity,NC_GatewayName,NC_GatewayPort,NC_ForcedRedirect,NC_HomePage,NC_DocumentRoot,NC_LoginTimeout,NC_IdleTimeout,NC_MaxMissedARP,NC_ExcludePorts,NC_IncludePorts,NC_AllowedWebHosts,NC_MACWhiteList,NC_BridgeLAN,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname"); %>

		function fix(name)
		{
			var i;
			if (((i = name.lastIndexOf('/')) > 0) || ((i = name.lastIndexOf('\\')) > 0))
				name = name.substring(i + 1, name.length);
			return name;
		}

		function uploadButton()
		{
			var fom;
			var name;
			var i;
			name = fix(E('upload-name').value);
			name = name.toLowerCase();
			if ((name.length <= 5) || (name.substring(name.length - 5, name.length).toLowerCase() != '.html')) {
				alert('错误的文件名称, 正确的文件后辍为 ".html".');
				return;
			}
			if (!confirm('请确定要上传 ' + name + '文件至设备?')) return;
			E('upload-button').disabled = 1;
			fields.disableAll(E('config-section'), 1);
			E('upload-form').submit();
		}

		function verifyFields(focused, quiet)
		{
			var a = E('_f_NC_enable').checked;

			E('_NC_Verbosity').disabled = !a;
			E('_NC_GatewayName').disabled = !a;
			E('_NC_GatewayPort').disabled = !a;
			E('_f_NC_ForcedRedirect').disabled = !a;
			E('_NC_HomePage').disabled = !a;
			E('_NC_DocumentRoot').disabled = !a;
			E('_NC_LoginTimeout').disabled = !a;
			E('_NC_IdleTimeout').disabled = !a;
			E('_NC_MaxMissedARP').disabled = !a;
			E('_NC_ExcludePorts').disabled = !a;
			E('_NC_IncludePorts').disabled = !a;
			E('_NC_AllowedWebHosts').disabled = !a;
			E('_NC_MACWhiteList').disabled = !a;
			E('_NC_BridgeLAN').disabled = !a;

			var bridge = E('_NC_BridgeLAN');
			if(nvram.lan_ifname.length < 1)
				bridge.options[0].disabled=true;
			if(nvram.lan1_ifname.length < 1)
				bridge.options[1].disabled=true;
			if(nvram.lan2_ifname.length < 1)
				bridge.options[2].disabled=true;
			if(nvram.lan3_ifname.length < 1)
				bridge.options[3].disabled=true;

			if ( (E('_f_NC_ForcedRedirect').checked) && (!v_length('_NC_HomePage', quiet, 1, 255))) return 0;
			if (!v_length('_NC_GatewayName', quiet, 1, 255)) return 0;
			if ( (E('_NC_IdleTimeout').value != '0') && (!v_range('_NC_IdleTimeout', quiet, 300))) return 0;
			return 1;
		}

		function save()
		{
			if (verifyFields(null, 0)==0) return;
			var fom = E('_fom');
			fom.NC_enable.value = E('_f_NC_enable').checked ? 1 : 0;
			fom.NC_ForcedRedirect.value = E('_f_NC_ForcedRedirect').checked ? 1 : 0;

			// blank spaces with commas
			e = E('_NC_ExcludePorts');
			e.value = e.value.replace(/\,+/g, ' ');

			e = E('_NC_IncludePorts');
			e.value = e.value.replace(/\,+/g, ' ');

			e = E('_NC_AllowedWebHosts');
			e.value = e.value.replace(/\,+/g, ' ');

			e = E('_NC_MACWhiteList');
			e.value = e.value.replace(/\,+/g, ' ');

			fields.disableAll(E('upload-section'), 1);
			if (fom.NC_enable.value == 0) {
				fom._service.value = 'splashd-stop';
			}
			else {
				fom._service.value = 'splashd-restart';
			}
			form.submit('_fom', 1);
		}

	</script>

	<div class="box">
		<div class="heading">网络通告管理</div>
		<div class="content">
			<form id="_fom" method="post" action="tomato.cgi">
				<input type="hidden" name="_nextpage" value="/#advanced-splashd.asp">
				<input type="hidden" name="_service" value="splashd-restart">
				<input type="hidden" name="NC_enable">
				<input type="hidden" name="NC_ForcedRedirect">
				<div id="cat-configure"></div><hr>
				<script type="text/javascript">
					$('#cat-configure').forms([
						{ title: '启用功能', name: 'f_NC_enable', type: 'checkbox', value: nvram.NC_enable == '1' },
						/* VLAN-BEGIN */
						{ title: '接口', multi: [
							{ name: 'NC_BridgeLAN', type: 'select', options: [
								['br0','LAN (br0)*'],
								['br1','LAN1 (br1)'],
								['br2','LAN2 (br2)'],
								['br3','LAN3 (br3)']
								], value: nvram.NC_BridgeLAN, suffix: ' <small>* 默认</small> ' } ] },
						/* VLAN-END */
						{ title: '网关名称', name: 'NC_GatewayName', type: 'text', maxlen: 255, size: 34, value: nvram.NC_GatewayName },
						{ title: '通告站点转发', name: 'f_NC_ForcedRedirect', type: 'checkbox', value: (nvram.NC_ForcedRedirect == '1') },
						{ title: '主页', name: 'NC_HomePage', type: 'text', maxlen: 255, size: 34, value: nvram.NC_HomePage },
						{ title: '欢迎页面目录', name: 'NC_DocumentRoot', type: 'text', maxlen: 255, size: 20, value: nvram.NC_DocumentRoot, suffix: '<span>&nbsp;/splash.html</span>' },
						{ title: '登录超时', name: 'NC_LoginTimeout', type: 'text', maxlen: 8, size: 4, value: nvram.NC_LoginTimeout, suffix: ' <small>秒</small>' },
						{ title: '空闲超时', name: 'NC_IdleTimeout', type: 'text', maxlen: 8, size: 4, value: nvram.NC_IdleTimeout, suffix: ' <small>秒 (0 - 无限制)</small>' },
						{ title: '最多同时在线', name: 'NC_MaxMissedARP', type: 'text', maxlen: 10, size: 2, value: nvram.NC_MaxMissedARP },
						null,
						{ title: '日志信息级别', name: 'NC_Verbosity', type: 'text', maxlen: 10, size: 2, value: nvram.NC_Verbosity },
						{ title: '网关端口', name: 'NC_GatewayPort', type: 'text', maxlen: 10, size: 7, value: fixPort(nvram.NC_GatewayPort, 5280) },
						{ title: '允许端口', name: 'NC_ExcludePorts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_ExcludePorts },
						{ title: '禁止端口', name: 'NC_IncludePorts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_IncludePorts },
						{ title: '允许直接访问的页面', name: 'NC_AllowedWebHosts', type: 'text', maxlen: 255, size: 34, value: nvram.NC_AllowedWebHosts },
						{ title: 'MAC 地址白名单', name: 'NC_MACWhiteList', type: 'text', maxlen: 255, size: 34, value: nvram.NC_MACWhiteList }
					]);
				</script>
			</form>


			<h4>自定义通告文件目录</h4>
			<div class="section" id="upload-section">
				<form id="upload-form" method="post" action="uploadsplash.cgi?_http_id=<% nv(http_id); %>" enctype="multipart/form-data">
					<fieldset><label class="col-sm-3 control-left-label" for="upload-name">自定义通告文件</label>
						<div class="col-sm-9">
							<input class="uploadfile" type="file" size="40" id="upload-name" name="upload_name">
							<button type="button" name="f_upload_button" id="upload-button" value="上传" onclick="uploadButton()" class="btn btn-danger">上传 <i class="icon-upload"></i></button>
						</div>
					</fieldset>
				</form>
			</div>
			<hr>
			<h5>用户指南 </h5>
			<div class="section" id="sesdivnotes">
				<ul>
					<li><b> 开启网络通告功能</b> - 开启此功能后, 局域网中的客户机访问网络时会弹出欢迎页面.<br>
					<li><b> 接口</b> - 请选择你想要在哪一个网络上启动通告功能.<br>
					<li><b> 网关名称</b> - 显示在欢迎页面上的网关名称.<br>
					<li><b> 网关端口</b> - 网关的端口号,默认= 5280.<br>
					<li><b> 通告站点转发</b> - 当激活后, 同意通告后将跳转至设置主页.<br>
					<li><b> 主页</b> - 通告跳转主页.<br>
					<li><b> 欢迎页面目录</b> - 本地欢迎页面的存放路径.<br>
					<li><b> 登录超时</b> - 超时后则转为重新通告状态, 默认为 3600 秒(1 小时).<br>
					<li><b> 空闲超时</b> - 超时后没有流量则转为重新通告状态.默认为 0 秒(不启用).<br>
					<li><b> 最多同时在线</b> - 最多同时在线用户数,默认为 5.<br>
					<li><b> 日志信息级别</b> - 该功能控制显示的日志信息级别. 0 为不显示, 10 为所有信息, 默认值为 2.<br>

					<li><b> Included ports</b> - TCP ports to allow access to after login, all others will be denied.<br>
					<li><b> Excluded ports</b> - TCP ports to denied access to after login, all others will be allowed.<br>
					Leave a blank space between each port number. Use only one of these two options to avoid conflicts.<br>

					<li><b> 禁止端口</b> - 只允许表内端口通过.<br>
					<li><b> 允许端口</b> - 只允许表外端口通过.<br>
					若要设置多个端口, 请以空格隔开.<br>
					<li><b> 允许直接访问的页面</b> - 设置的这些URL可以直接访问, 而不触发通告功能. 多个页面请以空格隔开. 例如：http://www.google.com http://www.google.es<br>
					<li><b> MAC地址白名单</b> - 设置的MAC地址将允许直接访问网络, 而不触发通告功能,多个MAC地址请以空格隔开.  例如：11:22:33:44:55:66 11:22:33:44:55:67<br>
					<li><b> 自定义通告文件目录</b> - 你可以上传自已的通告页面, 默认通告页面将被覆盖.<br>
					<span style="color:red">
						注意:如果登录超时,客户机需要重新进入通告页面以获得新的租约期.另外,超时并不会有通知,客户机可能已经无法访问互联网,你可以将租约期时间设置长一点来解决这个问题.
					</span>
				</ul>
			</div>

		</div>
	</div>

	<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
	<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
	<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span><br /><br />
	<script type="text/javascript">verifyFields(null, 1);</script>

</content>