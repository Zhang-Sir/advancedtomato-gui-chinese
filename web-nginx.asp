<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

Tomato VLAN GUI
Copyright (C) 2011 Augusto Bott
http://code.google.com/p/tomato-sdhc-vlan/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>Nginx Web 服务</title>
<content>
	<script type='text/javascript'>

		//	<% nvram("nginx_enable,nginx_php,nginx_keepconf,nginx_port,nginx_upload,nginx_remote,nginx_fqdn,nginx_docroot,nginx_priority,nginx_custom,nginx_httpcustom,nginx_servercustom,nginx_user,nginx_phpconf,nginx_override,nginx_overridefile"); %>

		changed = 0;
		nginxup = parseInt ('<% psup("nginx"); %>');

		function toggle(service, isup)
		{
			if (changed) {
				if (!confirm("未保存的更改将丢失，仍然继续吗?")) return;
			}

			$('.nginx-control').html('<div class="spinner spinner-small"></div>');

			E('_' + service + '_button').disabled = true;
			form.submitHidden('/service.cgi', {
				_redirect: '/#web-nginx.asp',
				_sleep: ((service == 'nginxfp') && (!isup)) ? '10' : '5',
				_service: service + (isup ? '-stop' : '-start')
			});
		}

		function verifyFields(focused, quiet)
		{
			var ok = 1;
			var a = E('_f_nginx_enable').checked;
			var b = E('_f_nginx_override').checked;
			E('_f_nginx_php').disabled = !a ;
			E('_f_nginx_keepconf').disabled = !a || b;
			E('_nginx_port').disabled = !a || b;
			E('_nginx_upload').disabled = !a || b;
			E('_f_nginx_remote').disabled = !a;
			E('_nginx_fqdn').disabled = !a || b;
			E('_nginx_docroot').disabled = !a || b;
			E('_nginx_priority').disabled = !a || b;
			E('_nginx_custom').disabled = !a || b;
			E('_nginx_httpcustom').disabled = !a || b;
			E('_nginx_servercustom').disabled = !a || b;
			E('_nginx_user').disabled = !a;
			E('_nginx_phpconf').disabled = !a || b;
			E('_f_nginx_override').disabled = !a;
			E('_nginx_overridefile').disabled = !a || !b;
			return ok;
		}

		function save()
		{
			if (verifyFields(null, 0)==0) return;
			var fom = E('_fom');
			fom.nginx_enable.value = E('_f_nginx_enable').checked ? 1 : 0;
			if (fom.nginx_enable.value) {
				fom.nginx_php.value = fom.f_nginx_php.checked ? 1 : 0;
				fom.nginx_keepconf.value = fom.f_nginx_keepconf.checked ? 1 : 0;
				fom.nginx_remote.value = fom.f_nginx_remote.checked ? 1 : 0;
				fom.nginx_override.value = fom.f_nginx_override.checked ? 1 : 0;
				fom._service.value = 'nginx-restart';
			} else {
				fom._service.value = 'nginx-stop';
			}
			form.submit(fom, 1);
		}

		function init()
		{
			verifyFields(null, 1);
			$('.nginx-status').html((!nginxup ? '<small style="color: red;">(停止)</small>' : '<small style="color: green;">(运行中)</small>'));
			$('.nginx-status').after('<a href="#" data-toggle="tooltip" class="pull-right nginx-control" title="' +
				(nginxup ? '停止 NGINX 服务' : '启动 NGINX 服务') + '" onclick="toggle(\'nginxfp\', nginxup); return false;" id="_nginxfp_button">' + (nginxup ? '<i class="icon-stop"></i>' : '<i class="icon-play"></i>') + '</a>');
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#web-nginx.asp">
		<input type="hidden" name="_service" value="enginex-restart">
		<input type="hidden" name="_nextwait" value="10">
		<input type="hidden" name="_reboot" value="0">

		<input type="hidden" name="nginx_enable">
		<input type="hidden" name="nginx_php">
		<input type="hidden" name="nginx_keepconf">
		<input type="hidden" name="nginx_remote">
		<input type="hidden" name="nginx_override">

		<div class="box" data-box="nginx-webserver">
			<div class="heading">NGINX Web 服务 <span class="nginx-status"></span></div>
			<div class="content config-section"></div>
		</div>

		<div class="box" data-box="nginx-advset">
			<div class="heading">高级设置</div>
			<div class="content config-adv"></div>
		</div>

		<div class="box" data-box="nginx-usermanual">
			<div class="heading">用户手册</div>
			<div class="content">
				<ul>
					<li><b> 状态按钮:</b> 快速启动 - 停止服务，必须选中启用 Web 服务才能修改设置.<br>
					<li><b> 开机启动:</b> 激活 web 服务.<br>
					<li><b> 保留配置文件:</b> 您是否手动修改了配置文件？ 勾选此框，将保留更改.<br>
					<li><b> Web 服务器端口:</b> 要访问的 Web 服务器使用的端口。 当端口被其他服务使用时请检查冲突.<br>
					<li><b> Web 服务器名称:</b> 将出现在 Internet 浏览器顶部的名称.<br>
					<li><b> 文档根路径:</b> 路由器中存储 web 文档的路径.<br>
					<li><b> 例如:<br></b>
					/tmp/mnt/HDD/www/ 你可以在 USB mount 路径中找到的.<br>
					<li><b> NGINX 自定义配置:</b> 您可以添加其他值到 nginx.conf 以满足您的需要.</li>
					<li>
						<b> 服务器优先级:</b> 设置服务优先级高于在路由器上运行的其他进程.<br>
						操作系统内核具有优先级 -5.<br>
						不要选择比内核使用的值更低的值，不要使用服务测试页来调整<br>
						服务器性能，它的性能低于文件将被定位的确定媒体 <br>
						即：USB闪存盘，硬盘驱动器或SSD.<br>
					</li>
				</ul>
			</div>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>
	</form>

	<script type="text/javascript">
		$('.content.config-section').forms([
			{ title: '开机启动', name: 'f_nginx_enable', type: 'checkbox', value: nvram.nginx_enable == '1'},
			{ title: '启用 PHP 支持', name: 'f_nginx_php', type: 'checkbox', value: nvram.nginx_php == '1' },
			{ title: '进程用户', name: 'nginx_user', type: 'select',
				options: [['root','Root'],['nobody','Nobody']], value: nvram.nginx_user },
			{ title: '保留配置文件', name: 'f_nginx_keepconf', type: 'checkbox', value: nvram.nginx_keepconf == '1' },
			{ title: 'Web 服务器端口', name: 'nginx_port', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.nginx_port, 85), suffix: '<small> 默认: 85</small>' },
			{ title: '上传文件大小限制', name: 'nginx_upload', type: 'text', maxlen: 5, size: 7, value: nvram.nginx_upload, suffix: '<small> MB</small>'},
			{ title: '允许远程访问', name: 'f_nginx_remote', type: 'checkbox', value: nvram.nginx_remote == '1' },
			{ title: 'Web 服务器名称', name: 'nginx_fqdn', type: 'text', maxlen: 255, size: 20, value: nvram.nginx_fqdn },
			{ title: '文档根路径', name: 'nginx_docroot', type: 'text', maxlen: 255, size: 40, value: nvram.nginx_docroot, suffix: '<small>&nbsp;/index.html / index.htm / index.php</small>' },
			{ title: '服务器优先级', name: 'nginx_priority', type: 'text', maxlen: 8, size:3, value: nvram.nginx_priority, suffix:'<small> 最大: -20, 最小: 19, 默认: 10</small>' }
		]);

		$('.content.config-adv').forms([
			{ title: 'HTTP 部分 - 自定义配置 (<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX<i class="icon-info"></i></a>)', name: 'nginx_httpcustom', type: 'textarea', value: nvram.nginx_httpcustom, style: 'width: 100%; height: 140px;' },
			{ title: 'SERVER 部分 - 自定义配置 (<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX<i class="icon-info"></i></a>)', name: 'nginx_servercustom', type: 'textarea', value: nvram.nginx_servercustom, style: 'width: 100%; height: 140px;'},
			{ title: 'Nginx 自定义配置 (<a href="http://wiki.nginx.org/Configuration" target="_new">NGINX<i class="icon-info"></i></a>)', name: 'nginx_custom', type: 'textarea', value: nvram.nginx_custom, style: 'width: 100%; height: 140px;' },
			{ title: 'PHP 自定义配置 (<a href="http://php.net/manual/en/ini.php" target="_new">PHP<i class="icon-info"></i></a>)', name: 'nginx_phpconf', type: 'textarea', value: nvram.nginx_phpconf, style: 'width: 100%; height: 140px;' },
			{ title: '使用用户配置文件', name: 'f_nginx_override', type: 'checkbox', value: nvram.nginx_override == '1', suffix: '<small> 将使用用户配置文件，一些 GUI 中的设置将被忽略</small>' },
			{ title: '用户配置文件路径', name: 'nginx_overridefile', type: 'text', maxlen: 255, size: 40, value: nvram.nginx_overridefile }
		]);
	</script>
	<script type='text/javascript'>init(); verifyFields(null, 1);</script>
</content>