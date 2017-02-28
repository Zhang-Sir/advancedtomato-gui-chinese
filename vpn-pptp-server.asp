<!--
Tomato PPTPd GUI
Copyright (C) 2012 Augusto Bott
http://code.google.com/p/tomato-sdhc-vlan/

Tomato GUI
Copyright (C) 2006-2007 Jonathan Zarate
http://www.polarcloud.com/tomato/
For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>PPTP 服务端</title>
<content>
	<script type="text/javascript">
		//    <% nvram("at_update,tomatoanon_answer,lan_ipaddr,lan_netmask,pptpd_enable,pptpd_remoteip,pptpd_forcemppe,pptpd_broadcast,pptpd_users,pptpd_dns1,pptpd_dns2,pptpd_wins1,pptpd_wins2,pptpd_mtu,pptpd_mru,pptpd_custom,pptpd_ipup_script,pptpd_ipdown_script"); %>

		if (nvram.pptpd_remoteip == '') nvram.pptpd_remoteip = '172.19.0.1-6';
		if (nvram.pptpd_forcemppe == '') nvram.pptpd_forcemppe = '1';
		var ul = new TomatoGrid();
		ul.setup = function() {
			this.init('ul-grid', 'sort', 6, [
				{ type: 'text', maxlen: 32, size: 32 },
				{ type: 'text', maxlen: 32, size: 32 } ]);
			this.headerSet(['用户名', '密码']);
			var r = nvram.pptpd_users.split('>');
			for (var i = 0; i < r.length; ++i) {
				var l = r[i].split('<');
				if (l.length == 2)
					ul.insertData(-1, l);
			}

			ul.recolor();
			ul.showNewEditor();
			ul.resetNewEditor();
			ul.sort(0);

		}
		ul.exist = function(f, v) {
			var data = this.getAllData();
			for (var i = 0; i < data.length; ++i) {
				if (data[i][f] == v) return true;
			}
			return false;
		}
		ul.existUser = function(user) {
			return this.exist(0, user);
		}
		function v_pptpd_secret(e, quiet) {
			var s;
			if ((e = E(e)) == null) return 0;
			s = e.value.trim().replace(/\s+/g, '');
			if (s.length < 1) {
				ferror.set(e, "用户名和密码不能为空.", quiet);
				return 0;
			}
			if (s.length > 32) {
				ferror.set(e, "输入错误：最多32个字符.", quiet);
				return 0;
			}
			if (s.search(/^[.a-zA-Z0-9_\- ]+$/) == -1) {
				ferror.set(e, "输入错误.  仅支持\"A-Z 0-9 . - _\"等字符.", quiet);
				return 0;
			}
			e.value = s;
			ferror.clear(e);
			return 1;
		}
		ul.verifyFields = function(row, quiet) {
			var f, s;
			f = fields.getAll(row);
			if (!v_pptpd_secret(f[0], quiet)) return 0;
			if (this.existUser(f[0].value)) {
				ferror.set(f[0], '重复的用户名', quiet);
				return 0;
			}
			if (!v_pptpd_secret(f[1], quiet)) return 0;
			return 1;
		}
		ul.dataToView = function(data) {
			return [data[0], '<small><i>******</i></small>'];
		}
		function save() {
			if (ul.isEditing()) return;
			if ((E('_f_pptpd_enable').checked) && (!verifyFields(null, 0))) return;
			if ((E('_f_pptpd_enable').checked) && (ul.getDataCount() < 1)) {
				var e = E('footer-msg');
				e.innerHTML = '无法保存: 至少需要添加一个用户.';
				e.style.visibility = 'visible';
				setTimeout(
					function() {
						e.innerHTML = '';
						e.style.visibility = 'hidden';
					}, 5000);
				return;
			}
			ul.resetNewEditor();
			var fom = E('_fom');
			var uldata = ul.getAllData();
			var s = '';
			for (var i = 0; i < uldata.length; ++i) {
				s += uldata[i].join('<') + '>';
			}
			fom.pptpd_users.value = s;
			fom.pptpd_enable.value = E('_f_pptpd_enable').checked ? 1 : 0;
			var a = E('_f_pptpd_startip').value;
			var b = E('_f_pptpd_endip').value;
			if ((fixIP(a) != null) && (fixIP(b) != null)) {
				var c = b.split('.').splice(3, 1);
				fom.pptpd_remoteip.value = a + '-' + c;
			}
			if (fom.pptpd_dns1.value == '0.0.0.0') fom.pptpd_dns1.value = '';
			if (fom.pptpd_dns2.value == '0.0.0.0') fom.pptpd_dns2.value = '';
			if (fom.pptpd_wins1.value == '0.0.0.0') fom.pptpd_wins1.value = '';
			if (fom.pptpd_wins2.value == '0.0.0.0') fom.pptpd_wins2.value = '';
			form.submit(fom, 1);
		}
		function submit_complete() {
			verifyFields(null, 1);
		}
		function verifyFields(focused, quiet) {
			var c = !E('_f_pptpd_enable').checked;
			E('_pptpd_dns1').disabled = c;
			E('_pptpd_dns2').disabled = c;
			E('_pptpd_wins1').disabled = c;
			E('_pptpd_wins2').disabled = c;
			E('_pptpd_mtu').disabled = c;
			E('_pptpd_mru').disabled = c;
			E('_pptpd_forcemppe').disabled = c;
			E('_pptpd_broadcast').disabled = c;
			E('_f_pptpd_startip').disabled = c;
			E('_f_pptpd_endip').disabled = c;
			E('_pptpd_custom').disabled = c;
			E('_pptpd_ipup_script').disabled = c;
			E('_pptpd_ipdown_script').disabled = c;
			var a = E('_f_pptpd_startip');
			var b = E('_f_pptpd_endip');
			if (Math.abs((aton(a.value) - (aton(b.value)))) > 5) {
				ferror.set(a, '错误的IP地址范围 (最多6个IP)', quiet);
				ferror.set(b, '错误的IP地址范围 (最多6个IP)', quiet);
				elem.setInnerHTML('pptpd_count', '(?)');
				return 0;
			} else {
				ferror.clear(a);
				ferror.clear(b);
			}
			if (aton(a.value) > aton(b.value)) {
				var d = a.value;
				a.value = b.value;
				b.value = d;
			}
			elem.setInnerHTML('pptpd_count', '(' + ((aton(b.value) - aton(a.value)) + 1) + ')');
			if (!v_ipz('_pptpd_dns1', quiet)) return 0;
			if (!v_ipz('_pptpd_dns2', quiet)) return 0;
			if (!v_ipz('_pptpd_wins1', quiet)) return 0;
			if (!v_ipz('_pptpd_wins2', quiet)) return 0;
			if (!v_range('_pptpd_mtu', quiet, 576, 1500)) return 0;
			if (!v_range('_pptpd_mru', quiet, 576, 1500)) return 0;
			if (!v_ip('_f_pptpd_startip', quiet)) return 0;
			if (!v_ip('_f_pptpd_endip', quiet)) return 0;
			return 1;
		}
		function init() {
			var c;
			if (((c = cookie.get('vpn_pptpd_notes_vis')) != null) && (c == '1')) toggleVisibility("notes");
			if (nvram.pptpd_remoteip.indexOf('-') != -1) {
				var tmp = nvram.pptpd_remoteip.split('-');
				E('_f_pptpd_startip').value = tmp[0];
				E('_f_pptpd_endip').value = tmp[0].split('.').splice(0,3).join('.') + '.' + tmp[1];
			}
			ul.setup();
			verifyFields(null, 1);
		}
		function toggleVisibility(whichone) {
			if (E('sesdiv_' + whichone).style.display == '') {
				E('sesdiv_' + whichone).style.display = 'none';
				E('sesdiv_' + whichone + '_showhide').innerHTML = '<i class="icon-chevron-up"></i>';
				cookie.set('vpn_pptpd_' + whichone + '_vis', 0);
			} else {
				E('sesdiv_' + whichone).style.display='';
				E('sesdiv_' + whichone + '_showhide').innerHTML = '<i class="icon-chevron-down"></i>';
				cookie.set('vpn_pptpd_' + whichone + '_vis', 1);
			}
		}

	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#vpn-pptpd.asp">
		<input type="hidden" name="_nextwait" value="5">
		<input type="hidden" name="_service" value="firewall-restart,pptpd-restart,dnsmasq-restart">
		<input type="hidden" name="pptpd_users">
		<input type="hidden" name="pptpd_enable">
		<input type="hidden" name="pptpd_remoteip">

		<div class="box" data-box="pptp-server">
			<div class="heading">PPTP 服务设置</div>
			<div class="content">

				<div id="pptp-server-settings"></div><hr>
				<script type="text/javascript">
					$('#pptp-server-settings').forms([
						{ title: '启用', name: 'f_pptpd_enable', type: 'checkbox', value: nvram.pptpd_enable == '1' },
						{ title: '本地 IP地址/子网掩码', text: (nvram.lan_ipaddr + ' / ' + nvram.lan_netmask) },
						{ title: '远程 IP 地址池', multi: [
							{ name: 'f_pptpd_startip', type: 'text', maxlen: 15, size: 17, value: nvram.dhcpd_startip, suffix: '&nbsp;-&nbsp;' },
							{ name: 'f_pptpd_endip', type: 'text', maxlen: 15, size: 17, value: nvram.dhcpd_endip, suffix: ' <i id="pptpd_count"></i>' }
						] },
						{ title: '广播中继模式', name: 'pptpd_broadcast', type: 'select',
							options: [['disable','禁用'], ['br0','LAN至VPN客户端'], ['ppp','VPN客户端至LAN'], ['br0ppp','全部']],
							value: nvram.pptpd_broadcast, suffix: ' <span style="color: red; font-size: 80%">启用此功能可能会导致 CPU 使用率过高</span>' },
						{ title: '加密方式', name: 'pptpd_forcemppe', type: 'select', options: [[0, 'None'], [1, 'MPPE-128']], value: nvram.pptpd_forcemppe },
						{ title: 'DNS 服务', name: 'pptpd_dns1', type: 'text', maxlen: 15, size: 17, value: nvram.pptpd_dns1 },
						{ title: '', name: 'pptpd_dns2', type: 'text', maxlen: 15, size: 17, value: nvram.pptpd_dns2 },
						{ title: 'WINS 服务', name: 'pptpd_wins1', type: 'text', maxlen: 15, size: 17, value: nvram.pptpd_wins1 },
						{ title: '', name: 'pptpd_wins2', type: 'text', maxlen: 15, size: 17, value: nvram.pptpd_wins2 },
						{ title: 'MTU', name: 'pptpd_mtu', type: 'text', maxlen: 4, size: 6, value: (nvram.pptpd_mtu ? nvram.pptpd_mtu : 1450)},
						{ title: 'MRU', name: 'pptpd_mru', type: 'text', maxlen: 4, size: 6, value: (nvram.pptpd_mru ? nvram.pptpd_mru : 1450)},
						{ title: '<a href="http://poptop.sourceforge.net/" target="_new">Poptop</a><br>自定义配置', name: 'pptpd_custom', type: 'textarea', value: nvram.pptpd_custom, style: 'width: 100%; height: 80px;' },
						{ title: '自定义防火墙启动加载规则', name: 'pptpd_ipup_script', type: 'textarea', value: nvram.pptpd_ipup_script, style: 'width: 100%; height: 80px;' },
						{ title: '自定义防火墙关闭加载规则', name: 'pptpd_ipdown_script', type: 'textarea', value: nvram.pptpd_ipdown_script, style: 'width: 100%; height: 80px;' }
					]);
				</script>

				<h4>说明 <a href="javascript:toggleVisibility('notes');"><span id="sesdiv_notes_showhide"><i class="icon-chevron-up"></i></span></a></h4>
				<div class="section" id="sesdiv_notes" style="display:none">
					<ul>
						<li><b>本地 IP地址/子网掩码</b> - 用于在服务器和VPN客户机之间建立PPTP隧道连接.</li>
						<li><b>远程 IP 地址池</b> - 用于为 VPN客户机分配 IP. (最多允许6个IP).</li>
						<li><b>广播中继模式</b> - 允许 VPN客户端 和 本地 LAN 之间通讯.</li>
						<li><b>启用加密</b> - 启用该选项后将对VPN通道进行加密以提升安全性，但是会导致VPN通道宽带减少.</li>
						<li><b>DNS 服务</b> - 使用自定义 DNS服务器 (如果未设置，VPN客户端将使用路由器的本地IP地址).</li>
						<li><b>WINS 服务</b> - 设置 WINS服务器IP, 也可以在 <a href=basic-network.asp>基本网络设置</a>中进行设置.</li>
						<li><b>MTU</b> - 最大传输单元. 超过限制的包将会被拆分..</li>
						<li><b>MRU</b> - 最大接收单元. 超过限制的包将会被拆分.</li>
					</ul>

					<ul>
						<li><b>其他相关说明:</b>
							<ul>
								<li>尝试避免在本地网络上为DHCP和VPN客户端 配置/分配 的可用地址范围之间有任何的冲突或重叠。</li>
							</ul>
						</li>
					</ul>

				</div>
			</div>
		</div>

		<div class="box" data-box="pptp-userlist">
			<div class="heading">PPTP 用户列表</div>
			<div class="content" id="sesdiv_userlist">
				<table class="line-table" id="ul-grid"></table>
			</div>


		</div>

		<a class="pull-right btn" href="/#vpn-pptp-online.asp">&raquo; PPTP 在线</a>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>
	<script type="text/javascript">init();</script>
</content>
