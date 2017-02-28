<!--
Tomato GUI
Copyright (C) 2006-2009 Jonathan Zarate
http://www.polarcloud.com/tomato/

Portions Copyright (C) 2010-2011 Jean-Yves Avenard, jean-yves@avenard.org

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>PPTP 客户端</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,pptp_client_enable,pptp_client_peerdns,pptp_client_mtuenable,pptp_client_mtu,pptp_client_mruenable,pptp_client_mru,pptp_client_nat,pptp_client_srvip,pptp_client_srvsub,pptp_client_srvsubmsk,pptp_client_username,pptp_client_passwd,pptp_client_mppeopt,pptp_client_crypt,pptp_client_custom,pptp_client_dfltroute,pptp_client_stateless"); %>

		pptpup = parseInt('<% psup("pptpclient"); %>');

		var changed = 0;

		function toggle(service, isup)
		{
			if (changed) {
				if (!confirm("未保存的更改将丢失，继续吗?")) return;
			}
			$('#_' + service + '_button').html('<div class="spinner spinner-small"></div>');
			form.submitHidden('/service.cgi', {
				_redirect: '/#vpn-pptp.asp',
				_service: service + (isup ? '-stop' : '-start')
			});
		}

		function verifyFields(focused, quiet)
		{
			var ret = 1;

			elem.display(PR('_pptp_client_srvsub'), PR('_pptp_client_srvsubmsk'), !E('_f_pptp_client_dfltroute').checked);

			var f = E('_pptp_client_mtuenable').value == '0';
			if (f) {
				E('_pptp_client_mtu').value = '1450';
			}
			E('_pptp_client_mtu').disabled = f;
			f = E('_pptp_client_mruenable').value == '0';
			if (f) {
				E('_pptp_client_mru').value = '1450';
			}
			E('_pptp_client_mru').disabled = f;

			if (!v_range('_pptp_client_mtu', quiet, 576, 1500)) ret = 0;
			if (!v_range('_pptp_client_mru', quiet, 576, 1500)) ret = 0;
			if (!v_ip('_pptp_client_srvip', true) && !v_domain('_pptp_client_srvip', true)) { ferror.set(E('_pptp_client_srvip'), "服务器地址错误.", quiet); ret = 0; }
			if (!E('_f_pptp_client_dfltroute').checked && !v_ip('_pptp_client_srvsub', true)) { ferror.set(E('_pptp_client_srvsub'), "子网地址无效.", quiet); ret = 0; }
			if (!E('_f_pptp_client_dfltroute').checked && !v_ip('_pptp_client_srvsubmsk', true)) { ferror.set(E('_pptp_client_srvsubmsk'), "子网掩码无效.", quiet); ret = 0; }

			changed |= ret;
			return ret;
		}

		function save()
		{
			if (!verifyFields(null, false)) return;

			var fom = E('_fom');

			E('pptp_client_enable').value = E('_f_pptp_client_enable').checked ? 1 : 0;
			E('pptp_client_nat').value = E('_f_pptp_client_nat').checked ? 1 : 0;
			E('pptp_client_dfltroute').value = E('_f_pptp_client_dfltroute').checked ? 1 : 0;
			E('pptp_client_stateless').value = E('_f_pptp_client_stateless').checked ? 1 : 0;

			form.submit(fom, 1);

			changed = 0;
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#vpn-pptp.asp">
		<input type="hidden" name="_service" value="">
		<input type="hidden" name="_nextwait" value="5">

		<input type="hidden" id="pptp_client_enable" name="pptp_client_enable">
		<input type="hidden" id="pptp_client_peerdns" name="pptp_client_peerdns">
		<input type="hidden" id="pptp_client_nat" name="pptp_client_nat">
		<input type="hidden" id="pptp_client_dfltroute" name="pptp_client_dfltroute">
		<input type="hidden" id="pptp_client_stateless" name="pptp_client_stateless">

		<div class="box" id="pptp-client">
			<div class="heading">PPTP 客户端设置 <span class="pptp-client-status"></span></div>
			<div class="content"></div>
			<script type="text/javascript">
				$('#pptp-client .content').forms([
					{ title: '同 WAN 一起启动', name: 'f_pptp_client_enable', type: 'checkbox', value: nvram.pptp_client_enable != 0 },
					{ title: '服务器地址', name: 'pptp_client_srvip', type: 'text', size: 17, value: nvram.pptp_client_srvip },
					{ title: '用户名: ', name: 'pptp_client_username', type: 'text', maxlen: 50, size: 54, value: nvram.pptp_client_username },
					{ title: '密码: ', name: 'pptp_client_passwd', type: 'password', maxlen: 50, size: 54, value: nvram.pptp_client_passwd },
					{ title: '加密方式', name: 'pptp_client_crypt', type: 'select', value: nvram.pptp_client_crypt,
						options: [['0', '自动'],['1', '无'],['2','最大（仅128位）'],['3','要求（128或40位）']] },
					{ title: '无状态 MPPE 连接', name: 'f_pptp_client_stateless', type: 'checkbox', value: nvram.pptp_client_stateless != 0 },
					{ title: '接受 DNS 配置', name: 'pptp_client_peerdns', type: 'select', options: [[0, '禁用'],[1, '启用'],[2, '独占']], value: nvram.pptp_client_peerdns },
					{ title: '重定向 Internet 流量', name: 'f_pptp_client_dfltroute', type: 'checkbox', value: nvram.pptp_client_dfltroute != 0 },
					{ title: '远程 子网 / 掩码', multi: [
						{ name: 'pptp_client_srvsub', type: 'text', maxlen: 15, size: 17, value: nvram.pptp_client_srvsub },
						{ name: 'pptp_client_srvsubmsk', type: 'text', maxlen: 15, size: 17, prefix: ' /&nbsp', value: nvram.pptp_client_srvsubmsk } ] },
					{ title: '创建 NAT 隧道', name: 'f_pptp_client_nat', type: 'checkbox', value: nvram.pptp_client_nat != 0 },
					{ title: 'MTU', multi: [
						{ name: 'pptp_client_mtuenable', type: 'select', options: [['0', '默认'],['1','手动']], value: nvram.pptp_client_mtuenable },
						{ name: 'pptp_client_mtu', type: 'text', maxlen: 4, size: 6, value: nvram.pptp_client_mtu } ] },
					{ title: 'MRU', multi: [
						{ name: 'pptp_client_mruenable', type: 'select', options: [['0', '默认'],['1','手动']], value: nvram.pptp_client_mruenable },
						{ name: 'pptp_client_mru', type: 'text', maxlen: 4, size: 6, value: nvram.pptp_client_mru } ] },
					{ title: '自定义配置', name: 'pptp_client_custom', type: 'textarea', value: nvram.pptp_client_custom, style: "width: 100%; height: 80px;" }
				]);

				$('#pptp-client .pptp-client-status').html((!pptpup ? '<small style="color: red;">(停止)</small>' : '<small style="color: green;">(运行中)</small>'));
				$('#pptp-client .pptp-client-status').after('<a href="#" data-toggle="tooltip" class="pull-right pptp-client-control" title="' +
					(pptpup ? '停止 PPTP 客户端' : '启动 PPTP 客户端') + '" onclick="toggle(\'pptpclient\', pptpup); return false;" id="_pptpclient_button">' + (pptpup ? '<i class="icon-stop"></i>' : '<i class="icon-play"></i>') + '</a>');

			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>
	</form>

	<script type="text/javascript">verifyFields(null, 1);</script>
</content>