<!--
Tomato GUI
Copyright (C) 2007-2011 Shibby
http://openlinksys.info
For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>TOR Project</title>
<content>
	<style type="text/css">
		textarea {
			width: 98%;
			height: 15em;
		}
	</style>
	<script type="text/javascript">
		//<% nvram("tor_enable,tor_socksport,tor_transport,tor_dnsport,tor_datadir,tor_users,tor_ports,tor_ports_custom,tor_custom,tor_iface,lan_ifname,lan1_ifname,lan2_ifname,lan3_ifname"); %>

		function verifyFields( focused, quiet ) {
			var ok = 1;

			var a = E( '_f_tor_enable' ).checked;
			var o = (E( '_tor_iface' ).value == 'custom');
			var p = (E( '_tor_ports' ).value == 'custom');

			E( '_tor_socksport' ).disabled = !a;
			E( '_tor_transport' ).disabled = !a;
			E( '_tor_dnsport' ).disabled   = !a;
			E( '_tor_datadir' ).disabled   = !a;
			E( '_tor_iface' ).disabled     = !a;
			E( '_tor_ports' ).disabled     = !a;
			E( '_tor_custom' ).disabled    = !a;

			elem.display( '_tor_users', o && a );
			elem.display( '_tor_ports_custom', p && a );

			var bridge = E( '_tor_iface' );
			if ( nvram.lan_ifname.length < 1 )
				bridge.options[ 0 ].disabled = true;
			if ( nvram.lan1_ifname.length < 1 )
				bridge.options[ 1 ].disabled = true;
			if ( nvram.lan2_ifname.length < 1 )
				bridge.options[ 2 ].disabled = true;
			if ( nvram.lan3_ifname.length < 1 )
				bridge.options[ 3 ].disabled = true;

			var s = E( '_tor_custom' );

			if ( s.value.search( /SocksPort/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“SocksPort”选项。 您可以在 Tomato GUI 中设置它', quiet );
				ok = 0;
			}

			if ( s.value.search( /SocksBindAddress/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“SocksBindAddress”选项。', quiet );
				ok = 0;
			}

			if ( s.value.search( /AllowUnverifiedNodes/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“AllowUnverifiedNodes”选项。', quiet );
				ok = 0;
			}

			if ( s.value.search( /Log/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“日志”选项。', quiet );
				ok = 0;
			}

			if ( s.value.search( /DataDirectory/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“DataDirectory”选项。 您可以在 Tomato GUI 中设置它', quiet );
				ok = 0;
			}

			if ( s.value.search( /TransPort/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“TransPort”选项。 您可以在 Tomato GUI 中设置它', quiet );
				ok = 0;
			}

			if ( s.value.search( /TransListenAddress/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“TransListenAddress”选项。', quiet );
				ok = 0;
			}

			if ( s.value.search( /DNSPort/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“DNSPort”选项。 您可以在 Tomato GUI 中设置它', quiet );
				ok = 0;
			}

			if ( s.value.search( /DNSListenAddress/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“DNSListenAddress”选项。', quiet );
				ok = 0;
			}

			if ( s.value.search( /User/ ) == 0 ) {
				ferror.set( s, '无法在此处设置“用户”选项。', quiet );
				ok = 0;
			}

			return ok;
		}

		function save() {
			if ( verifyFields( null, 0 ) == 0 ) return;
			var fom              = E( '_fom' );
			fom.tor_enable.value = E( '_f_tor_enable' ).checked ? 1 : 0;

			if ( fom.tor_enable.value == 0 ) {
				fom._service.value = 'tor-stop';
			}
			else {
				fom._service.value = 'tor-restart,firewall-restart';
			}
			form.submit( '_fom', 1 );
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#advanced-tor.asp">
		<input type="hidden" name="_service" value="tor-restart">
		<input type='hidden' name='tor_enable'>

		<div class="box">
			<div class="heading">Tor Project 设置</div>
			<div class="content">
				<div id="tor-settings"></div><hr>

				<script type="text/javascript">
					$('#tor-settings').forms([
	                     { title: '启用 TOR', name: 'f_tor_enable', type: 'checkbox', value: nvram.tor_enable == '1' },
	                     null,
	                     { title: 'Socks 端口', name: 'tor_socksport', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.tor_socksport, 9050) },
	                     { title: 'Trans 端口', name: 'tor_transport', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.tor_transport, 9040) },
	                     { title: 'DNS 端口', name: 'tor_dnsport', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.tor_dnsport, 9053) },
	                     { title: '数据目录', name: 'tor_datadir', type: 'text', maxlen: 24, size: 28, value: nvram.tor_datadir },
	                     null,
	                     { title: '重定向所有用户自', multi: [
	                         { name: 'tor_iface', type: 'select', options: [
		                         ['br0','LAN (br0)'],
		                         ['br1','LAN1 (br1)'],
		                         ['br2','LAN2 (br2)'],
		                         ['br3','LAN3 (br3)'],
		                         ['custom','选择的 IP 地址']
	                         ], value: nvram.tor_iface },
	                         { name: 'tor_users', type: 'text', maxlen: 512, size: 64, value: nvram.tor_users } ] },
	                     { title: '重定向 TCP 端口', multi: [
	                         { name: 'tor_ports', type: 'select', options: [
		                         ['80','仅 HTTP (TCP 80)'],
		                         ['80,443','HTTP/HTTPS (TCP 80,443)'],
		                         ['custom','所选端口']
	                         ], value: nvram.tor_ports },
	                         { name: 'tor_ports_custom', type: 'text', maxlen: 512, size: 64, value: nvram.tor_ports_custom } ] },
	                     null,
	                     { title: '自定义配置', name: 'tor_custom', type: 'textarea', value: nvram.tor_custom }
	                 ]);
				</script>

				<h4>说明</h4>
				<div class="section">
					<ul>
						<li><b>启用 TOR</b> - 耐心一点。启动Tor客户端可能需要几秒钟到几分钟。
						<li><b>选择 IP 地址</b> - 例如: 1.2.3.4,1.1.0/24,1.2.3.1-1.2.3.4
						<li><b>所选端口</b> - 例如：一个端口（80），几个端口（80,443,8888），端口范围（80:88），混合（80,8000：9000,9999）
						<li><span style="color: red;">警告!</span> 如果你的路由器只有 32MB RAM，你必须使用交换分区。
					</ul>
				</div>
			</div>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type='text/javascript'>verifyFields(null,1);</script>
</content>