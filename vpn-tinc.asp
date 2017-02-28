<title>Tinc 配置</title>
<content>
	<style type='text/css'>

		#th-grid .co1 {
			width: 10%;
			text-align: center;
		}
		#th-grid .co2 {
			width: 17%;
		}
		#th-grid .co3 {
			width: 29%;
		}
		#th-grid .co4 {
			width: 10%;
		}
		#th-grid .co5 {
			width: 14%;
		}
		#th-grid .co6 {
			width: 20%;
		}

		.editor td:first-child {
			text-align: center;
		}

		textarea {
			width: 100%;
			height: 10em;
		}
	</style>
	<script type="text/javascript">

		//	<% nvram("tinc_wanup,tinc_name,tinc_devicetype,tinc_mode,tinc_vpn_netmask,tinc_private_rsa,tinc_private_ed25519,tinc_custom,tinc_hosts,tinc_firewall,tinc_manual_firewall,tinc_manual_tinc_up,tinc_tinc_up,tinc_tinc_down,tinc_host_up,tinc_host_down,tinc_subnet_up,tinc_subnet_down"); %>

		var tinc_compression = [['0','0 - 无'],['1','1 - Fast zlib'],['2','2'],['3','3'],['4','4'],['5','5'],['6','6'],['7','7'],['8','8'],['9','9 - Best zlib'],['10','10 - Fast lzo'],['11','11 - Best lzo']];
		var th = new TomatoGrid();
		var cmd = null;
		var cmdresult = '';

		tabs = [['config', '<i class="icon-system"></i> 基本设置'],['hosts', '<i class="icon-globe"></i> 主机设置'],['scripts', '<i class="icon-hammer"></i> 脚本设置'],['keys', '<i class="icon-lock"></i> 秘钥设置'],['status', '<i class="icon-info"></i> 运行状态']];
		changed = 0;
		tincup = parseInt ('<% psup("tincd"); %>');

		th.setup = function() {
			this.init('th-grid', '', 50, [
				{ type: 'checkbox' },
				{ type: 'text', maxlen: 30 },
				{ type: 'text', maxlen: 100 },
				{ type: 'text', maxlen: 5 },
				{ type: 'select', options: tinc_compression },
				{ type: 'text', maxlen: 20 },
				{ type: 'textarea', proxy: "_host_rsa_key" },
				{ type: 'textarea', proxy: "_host_ed25519_key" },
				{ type: 'textarea', proxy: "_host_custom" }
			]);
			this.headerSet(['连接', '名称', '地址', '端口', '压缩', '子网']);
			var nv = nvram.tinc_hosts.split('>');
			for (var i = 0; i < nv.length; ++i) {
				var t = nv[i].split('<');
				if (t.length == 9){
					t[0] *= 1;
					this.insertData(-1, t);
				}
			}
			th.showNewEditor();
		}

		th.dataToView = function(data) {
			return [(data[0] != '0') ? 'On' : '', data[1], data[2], data[3], data[4] ,data[5] ];
		}

		th.fieldValuesToData = function(row) {
			var f = fields.getAll(row);
			return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value, E('_host_rsa_key').value, E('_host_ed25519_key').value, E('_host_custom').value ];
		}


		th.resetNewEditor = function() {
			var f = fields.getAll(this.newEditor);
			f[0].checked = 0;
			f[1].value = '';
			f[2].value = '';
			f[3].value = '';
			f[4].selectedIndex = 0;
			f[5].value = '';
			E('_host_rsa_key').value = '';
			E('_host_ed25519_key').value = '';
			E('_host_custom').value = '';
			ferror.clearAll(fields.getAll(this.newEditor));
			ferror.clear(E('_host_ed25519_key'));
		}

		th.verifyFields = function(row, quiet) {

			var f = fields.getAll(row);

			if (f[1].value == "") {
				ferror.set(f[1], "主机名不能为空.", quiet); return 0 ; }
			else {  ferror.clear(f[1]) }

			if (f[0].checked && f[2].value == "") {
				ferror.set(f[2], "选中 连接 时必须提供地址.", quiet); return 0 ; }
			else {  ferror.clear(f[2]) }

			if (!f[3].value == "" ) {
				if (!v_port(f[3], quiet)) return 0 ;
			}

			if(E('_tinc_devicetype').value == 'tun'){
				if ((!v_subnet(f[5], 1)) && (!v_ip(f[5], 1))) {
					ferror.set(f[5], "子网或 IP 地址无效.", quiet); return 0 ; }
				else {  ferror.clear(f[5]) }
			}
			else if (E('_tinc_devicetype').value == 'tap'){
				if (f[5].value != '') {
					ferror.set(f[5], "子网使用 TAP 接口类型时留空.", quiet); return 0 ; }
				else {  ferror.clear(f[5]) }
			}

			if (E('_host_ed25519_key').value == "") {
				ferror.set(E('_host_ed25519_key'), "Ed25519 公钥不能为空.", quiet); return 0 ; }
			else {  ferror.clear(E('_host_ed25519_key')) }

			return 1;
		}

		function verifyFields(focused, quiet)
		{
			if (focused)
			{
				changed = 1;
			}

			// Visibility Changes
			var vis = {
				_tinc_mode: 1,
				_tinc_vpn_netmask: 1,
			};

			switch (E('_tinc_devicetype').value) {
				case 'tun':
					vis._tinc_mode = 0;
					vis._tinc_vpn_netmask = 1 ;
					break;
				case 'tap':
				vis._tinc_mode = 1;
				vis._tinc_vpn_netmask = 0 ;
				break;
			}

			switch(E('_tinc_manual_tinc_up').value) {
				case '0' :
					E('_tinc_tinc_up').disabled = 1 ;
					break;
				case '1' :
				E('_tinc_tinc_up').disabled = 0 ;
				break;
			}

			switch(E('_tinc_manual_firewall').value) {
				case '0' :
					E('_tinc_firewall').disabled = 1 ;
					break;
				default :
					E('_tinc_firewall').disabled = 0 ;
					break;
			}

			for (a in vis) {
				b = E(a);
				c = vis[a];
				b.disabled = (c != 1);
				PR(b).style.display = c ? '' : 'none';
			}

			E('edges').disabled = !tincup;
			E('connections').disabled = !tincup;
			E('subnets').disabled = !tincup;
			E('nodes').disabled = !tincup;
			E('info').disabled = !tincup;
			E('hostselect').disabled = !tincup;

			// Element Verification
			if (E('_tinc_name').value == "" && E('_f_tinc_wanup').checked) {
				ferror.set(E('_tinc_name'), "选中“同 WAN 一起启动”时需要使用主机名.", quiet); return 0 ; }
			else {  ferror.clear(E('_tinc_name')) }

			if (E('_tinc_private_ed25519').value == "" && E('_tinc_custom').value == "" && E('_f_tinc_wanup').checked) {
				ferror.set(E('_tinc_private_ed25519'), "Ed25519 选中“同 WAN 一起启动”时需要私钥.", quiet); return 0 ; }
			else {  ferror.clear(E('_tinc_private_ed25519')) }

			if (!v_netmask('_tinc_vpn_netmask', quiet)) return 0;

			if (!E('_host_ed25519_key').value == "") {
				ferror.clear(E('_host_ed25519_key')) }

			var hostdefined = false;
			var hosts = th.getAllData();
			for (var i = 0; i < hosts.length; ++i) {
				if(hosts[i][1] == E('_tinc_name').value){
					hostdefined = true;
					break;
				}
			}

			if (!hostdefined && E('_f_tinc_wanup').checked) {
				ferror.set(E('_tinc_name'), "主机名称 \"" + E('_tinc_name').value + "\" 主机区域被定义时，“同 WAN 一起启动”必须被选中.", quiet); return 0 ; }
			else {  ferror.clear(E('_tinc_name')) };

			return 1;
		}

		function escapeText(s)
		{
			function esc(c) {
				return '&#' + c.charCodeAt(0) + ';';
			}
			return s.replace(/[&"'<>]/g, esc).replace(/\n/g, ' <br>').replace(/ /g, '&nbsp;');
		}

		function spin(x,which)
		{
			E(which).style.visibility = x ? 'visible' : 'hidden';
			if (!x) cmd = null;
		}

		// Borrowed from http://snipplr.com/view/14074/
		String.prototype.between = function(prefix, suffix) {
			s = this;
			var i = s.indexOf(prefix);
			if (i >= 0) {
				s = s.substring(i + prefix.length);
			}
			else {
				return '';
			}
			if (suffix) {
				i = s.indexOf(suffix);
				if (i >= 0) {
					s = s.substring(0, i);
				}
				else {
					return '';
				}
			}
			return s;
		}

		function displayKeys()
		{
			E('_rsa_private_key').value = "-----BEGIN RSA PRIVATE KEY-----\n" + cmdresult. between('-----BEGIN RSA PRIVATE KEY-----\n','\n-----END RSA PRIVATE KEY-----') + "\n-----END RSA PRIVATE KEY-----";
			E('_rsa_public_key').value = "-----BEGIN RSA PUBLIC KEY-----\n" + cmdresult. between('-----BEGIN RSA PUBLIC KEY-----\n','\n-----END RSA PUBLIC KEY-----') + "\n-----END RSA PUBLIC KEY-----";
			E('_ed25519_private_key').value = "-----BEGIN ED25519 PRIVATE KEY-----\n" + cmdresult. between('-----BEGIN ED25519 PRIVATE KEY-----\n','\n-----END ED25519 PRIVATE KEY-----') + "\n-----END ED25519 PRIVATE KEY-----";
			E('_ed25519_public_key').value = cmdresult. between('-----END ED25519 PRIVATE KEY-----\n','\n');

			cmdresult = '';
			spin(0,'generateWait');
			E('execb').disabled = 0;
		}

		function generateKeys()
		{
			E('execb').disabled = 1;
			spin(1,'generateWait');

			E('_rsa_private_key').value = "";
			E('_rsa_public_key').value = "";
			E('_ed25519_private_key').value = "";
			E('_ed25519_public_key').value = "";

			cmd = new XmlHttp();
			cmd.onCompleted = function(text, xml) {
				eval(text);
				displayKeys();
			}
			cmd.onError = function(x) {
				cmdresult = '错误: ' + x;
				displayKeys();
			}

			var commands = "/bin/rm -rf /etc/keys \n\
			/bin/mkdir /etc/keys \n\
			/bin/echo -e '\n\n\n\n' | /usr/sbin/tinc -c /etc/keys generate-keys \n\
			/bin/cat /etc/keys/rsa_key.priv \n\
			/bin/cat /etc/keys/rsa_key.pub \n\
			/bin/cat /etc/keys/ed25519_key.priv \n\
			/bin/cat /etc/keys/ed25519_key.pub";

			cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));

		}

		function displayStatus()
		{
			E('result').innerHTML = '<tt>' + escapeText(cmdresult) + '</tt>';
			cmdresult = '';
			spin(0,'statusWait');
		}

		function updateStatus(type)
		{
			E('result').innerHTML = '';
			spin(1,'statusWait');

			cmd = new XmlHttp();
			cmd.onCompleted = function(text, xml) {
				eval(text);
				displayStatus();
			}
			cmd.onError = function(x) {
				cmdresult = '错误: ' + x;
				displayStatus();
			}

			if(type != "info"){
				var commands = "/usr/sbin/tinc dump " + type + "\n";
			}
			else
			{
				var selects = document.getElementById("hostselect");
				var commands = "/usr/sbin/tinc " + type + " " + selects.options[selects.selectedIndex].text + "\n";
			}

			cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
			updateNodes();
		}

		function displayNodes()
		{

			var hostselect=document.getElementById("hostselect")
			var selected = hostselect.value;

			while(hostselect.firstChild){
				hostselect.removeChild(hostselect.firstChild);
			}

			var hosts = cmdresult.split("\n");

			for (var i = 0; i < hosts.length; ++i)
			{
				if (hosts[i] != ''){
					hostselect.options[hostselect.options.length]=new Option(hosts[i],hosts[i]);
					if(hosts[i] == selected){
						hostselect.value = selected;
					}
				}
			}

			cmdresult = '';
		}

		function updateNodes()
		{

			if (tincup)
			{
				cmd = new XmlHttp();
				cmd.onCompleted = function(text, xml) {
					eval(text);
					displayNodes();
				}
				cmd.onError = function(x) {
					cmdresult = '错误: ' + x;
					displayNodes();
				}

				var commands = "/usr/sbin/tinc dump nodes | /bin/busybox awk '{print $1}'";
				cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
			}
		}

		function displayVersion()
		{
			E('version').innerHTML = "<small>Tinc (" + escapeText(cmdresult).replace('<br>', '').replace('&nbsp;','') + ")</small>";
			cmdresult = '';
		}

		function getVersion()
		{
			cmd = new XmlHttp();
			cmd.onCompleted = function(text, xml) {
				eval(text);
				displayVersion();
			}
			cmd.onError = function(x) {
				cmdresult = '错误: ' + x;
				displayVersion();
			}

			var commands = "/usr/sbin/tinc --version | /bin/busybox awk 'NR==1  {print $3}'";
			cmd.post('shell.cgi', 'action=execute&command=' + escapeCGI(commands.replace(/\r/g, '')));
		}

		function tabSelect(name)
		{
			tgHideIcons();
			cookie.set('vpn_tinc_tab', name);
			tabHigh(name);

			for (var i = 0; i < tabs.length; ++i)
			{
				var on = (name == tabs[i][0]);
				elem.display(tabs[i][0] + '-tab', on);
			}
		}


		function toggle(service, isup)
		{

			var data = th.getAllData();
			var s = '';
			for (var i = 0; i < data.length; ++i) {
				s += data[i].join('<') + '>';
			}

			if (nvram.tinc_hosts != s)
				changed = 1;

			if (changed) {
				if (!confirm("未保存的更改将丢失，仍然继续吗?")) return;
			}

			E('_' + service + '_button').disabled = true;
			
			form.submitHidden('/service.cgi', {
				_redirect: '/#vpn-tinc.asp',
				_sleep: ((service == 'tinc') && (!isup)) ? '3' : '3',
				_service: service + (isup ? '-stop' : '-start')
			});
		}

		function save()
		{
			if (!verifyFields(null, false)) return;
			if (th.isEditing()) return;

			var data = th.getAllData();
			var s = '';
			for (var i = 0; i < data.length; ++i) {
				s += data[i].join('<') + '>';
			}
			var fom = E('_fom');
			fom.tinc_hosts.value = s;
			fom.tinc_wanup.value = fom.f_tinc_wanup.checked ? 1 : 0;

			if ( tincup )
			{
				fom._service.value = 'tinc-restart';
			}

			changed = 0;

			form.submit(fom, 1);
		}

		function init()
		{
			verifyFields(null, true);
			th.recolor();
			th.resetNewEditor();
			var c;
			if (((c = cookie.get('vpn_tinc_hosts_vis')) != null) && (c == '1')) toggleVisibility("hosts");
			getVersion();
			updateNodes();
		}

		function earlyInit()
		{
			tabSelect(cookie.get('vpn_tinc_tab') || 'config');
		}

		function toggleVisibility(whichone) {
			if (E('sesdiv_' + whichone).style.display == '') {
				E('sesdiv_' + whichone).style.display = 'none';
				E('sesdiv_' + whichone + '_showhide').innerHTML = '<i class="icon-chevron-up"></i>';
				cookie.set('vpn_tinc_' + whichone + '_vis', 0);
			} else {
				E('sesdiv_' + whichone).style.display='';
				E('sesdiv_' + whichone + '_showhide').innerHTML = '<i class="icon-chevron-down"></i>';
				cookie.set('vpn_tinc_' + whichone + '_vis', 1);
			}
		}

	</script>

	<form id="_fom" method="post" action="tomato.cgi">

		<input type="hidden" name="_nextpage" value="/#vpn-tinc.asp">
		<input type="hidden" name="_service" value="">

		<div id="vpn-tinc">
			<script type="text/javascript">

				// -------- BEGIN CONFIG TAB -----------
				var html = '<ul id="tabs" class="nav nav-tabs">';
				for (j = 0; j < tabs.length; j++) {
					html += '<li><a href="javascript:tabSelect(\''+tabs[j][0]+'\')" id="'+tabs[j][0]+'">'+tabs[j][1]+'</a></li>';
				}

				var action = ((tincup) ? 'title="立即停止"><i class="icon-stop"></i>' : 'title="立即启动"><i class="icon-play"></i>');
				var status = ((!tincup) ? '<small style="color: red">(停止)</small>' : '<small style="color: green;">(运行中)</small>');

				html += '</ul>\
				<div class="box">\
				<div class="heading">Tinc 配置 <span id="version"></span> ' + status + '\
				<a id="_tinc_button" class="pull-right" href="#" data-toggle="tooltip" onclick="toggle(\'tinc\', tincup); return false;"' + action + '</a></div>\
				<div class="content">'

				var t = "config";
				html +='<div id="'+t+'-tab">';
				html +='<input type="hidden" name="tinc_wanup">';

				html += createFormFields([
					{ title: '同 WAN 一起启动 ', name: 'f_tinc_wanup', type: 'checkbox', value: (nvram.tinc_wanup == 1) },
					{ title: '接口类型', name: 'tinc_devicetype', type: 'select', options: [['tun','TUN'],['tap','TAP']], value: nvram.tinc_devicetype },
					{ title: '模式', name: 'tinc_mode', type: 'select', options: [['switch','Switch'],['hub','Hub']], value: nvram.tinc_mode },
					{ title: 'VPN 网络掩码', name: 'tinc_vpn_netmask', type: 'text', maxlen: 15, size: 25, value: nvram.tinc_vpn_netmask,  suffix: ' <small>整个VPN网络的网络掩码.</small>' },
					{ title: '主机名称', name: 'tinc_name', type: 'text', maxlen: 30, size: 25, value: nvram.tinc_name, suffix: ' <small>还必须在 \'主机设置\' 区域中定义.</small>' },
					{ title: 'Ed25519 私钥', name: 'tinc_private_ed25519', type: 'textarea', value: nvram.tinc_private_ed25519 },
					{ title: 'RSA 私钥 *', name: 'tinc_private_rsa', type: 'textarea', value: nvram.tinc_private_rsa },
					{ title: '自定义', name: 'tinc_custom', type: 'textarea', value: nvram.tinc_custom }
				]);

				html +='</div>';
				// -------- END CONFIG TAB -----------


				// -------- BEGIN HOSTS TAB -----------
				t = "hosts";
				html +='<div id="'+t+'-tab">';
				html +='<input type="hidden" name="tinc_hosts">';
				html +='<table class="line-table" id="th-grid"></table>';

				html += createFormFields([
					{ title: 'Ed25519 公钥', name: 'host_ed25519_key', type: 'textarea' },
					{ title: 'RSA 公钥 *', name: 'host_rsa_key', type: 'textarea' },
					{ title: '自定义', name: 'host_custom', type: 'textarea' }
				]);

				html +='<br /><h4>说明 <a href="javascript:toggleVisibility(\'hosts\');"><span id="sesdiv_hosts_showhide"><i class="icon-chevron-up"></i></span></a></h4>';
				html +='<div class="section" id="sesdiv_hosts" style="display:none">';
				html +='<ul>';
				html +='<li><b>连接</b> - Tinc 将尝试建立到主机的元连接. 需要填写地址字段';
				html +='<li><b>名称</b> - 主机名称. 此主机必须填的一个条目.';
				html +='<li><b>地址</b> <i>(可选)</i> - 必须解析到可以访问主机的外部IP地址.';
				html +='<li><b>端口</b> <i>(可选)</i> - 主机监听的端口. 如果为空，则使用默认值（655）.';
				html +='<li><b>压缩</b> - 用于UDP数据包的压缩级别，可选值 ';
				html +='0 (关闭), 1 (fast zlib) 和任意整数到 9 (best zlib), 10 (fast lzo) and 11 (best lzo).';
				html +='<li><b>子网</b> - 主机将服务的子网.';
				html +='</ul>';
				html +='</div>';

				html +='</div>';

				// ---------- END HOSTS TAB ------------


				// -------- BEGIN SCRIPTS TAB -----------
				t = "scripts";
				html +='<div id="'+t+'-tab">';

				html += createFormFields([
					{ title: '防火墙规则', name: 'tinc_manual_firewall', type: 'select', options: [['0','自动 '],['1','附加'],['2','手动']], value: nvram.tinc_manual_firewall },
					{ title: '防火墙', name: 'tinc_firewall', type: 'textarea', value: nvram.tinc_firewall },
					{ title: 'tinc-up 建立', name: 'tinc_manual_tinc_up', type: 'select', options: [['0','自动'],['1','手动']], value: nvram.tinc_manual_tinc_up },
					{ title: 'tinc-up', name: 'tinc_tinc_up', type: 'textarea', value: nvram.tinc_tinc_up },
					{ title: 'tinc-down', name: 'tinc_tinc_down', type: 'textarea', value: nvram.tinc_tinc_down },
					{ title: 'host-up', name: 'tinc_host_up', type: 'textarea', value: nvram.tinc_host_up },
					{ title: 'host-down', name: 'tinc_host_down', type: 'textarea', value: nvram.tinc_host_down },
					{ title: 'subnet-up', name: 'tinc_subnet_up', type: 'textarea', value: nvram.tinc_subnet_up },
					{ title: 'subnet-down', name: 'tinc_subnet_down', type: 'textarea', value: nvram.tinc_subnet_down }
				]);

				html +='</div>';
				// -------- END SCRIPTS TAB -----------

				// -------- BEGIN KEYS TAB -----------
				t = "keys";
				html +='<div id="'+t+'-tab">';

				html += createFormFields([
					{ title: 'Ed25519 私钥', name: 'ed25519_private_key', type: 'textarea', value: "" },
					{ title: 'Ed25519 公钥', name: 'ed25519_public_key', type: 'textarea', value: "" },
					{ title: 'RSA 私钥', name: 'rsa_private_key', type: 'textarea', value: "" },
					{ title: 'RSA 公钥', name: 'rsa_public_key', type: 'textarea', value: "" }
				]);

				html +='<button class="btn btn-primary" type="button" value="gen" onclick="generateKeys()" id="execb"><i class="icon-lock"></i> 生成密钥</button>';
				html +='<div style="visibility:hidden;text-align:right" id="generateWait">请稍等... <div class="spinner"></div></div>';
				html +='</div>';

				// -------- END KEY TAB -----------

				// -------- BEGIN STATUS TAB -----------
				t = "status";

				html +='<div id="'+t+'-tab">';

				html += '<div class="btn-group">';
				html += '<a class="btn btn-success" onclick="updateStatus(\'edges\')" id="edges">边缘</a>';
				html += '<a class="btn" onclick="updateStatus(\'subnets\')" id="subnets">子网</a>';
				html += '<a class="btn" onclick="updateStatus(\'connections\')" id="connections">连接</a>';
				html += '<a class="btn" onclick="updateStatus(\'nodes\')" id="nodes">节点</a>';
				html += '</div>'
				html += '<div style="visibility:hidden;text-align:right" id="statusWait">请稍等... <div class="spinner"></div></div>';

				html +='<input class="btn btn-primary" type="button" value="信息" onclick="updateStatus(\'info\')" id="info">';
				html +='<select id="hostselect" style="width:170px"></select>';

				html +='<pre id="result"></pre>';

				html +='</div></div>';
				// -------- END KEY TAB -----------

				$('#vpn-tinc').html(html);
				th.setup();

			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">
		earlyInit();
		init();
	</script>
</content>
