
<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>日志管理</title>
<content><style>
		table.fields-table tr td:first-child {
			width: 30%;
			min-width: 250px;
		}
	</style><script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,log_remote,log_remoteip,log_remoteport,log_file,log_file_custom,log_file_path,log_limit,log_in,log_out,log_mark,log_events,log_wm,log_wmtype,log_wmip,log_wmdmax,log_wmsmax,log_file_size,log_file_keep,webmon_bkp,webmon_dir,webmon_shrink"); %>

		function verifyFields(focused, quiet)
		{
			var a, b, c;

			a = E('_f_log_file').checked;
			b = E('_f_log_remote').checked;
			c = E('_f_log_file_custom').checked;

			a = !(a || b);
			E('_log_in').disabled = a;
			E('_log_out').disabled = a;
			E('_log_limit').disabled = a;
			E('_log_mark').disabled = a;
			E('_f_log_acre').disabled = a;
			E('_f_log_crond').disabled = a;
			E('_f_log_dhcpc').disabled = a;
			E('_f_log_ntp').disabled = a;
			E('_f_log_sched').disabled = a;

			elem.display(PR('_log_remoteip'), b);
			E('_log_remoteip').disabled = !b;
			E('_log_remoteport').disabled = !b;

			E('_f_log_file_custom').disabled = !E('_f_log_file').checked;
			E('_log_file_path').disabled = !c || !E('_f_log_file').checked;

			if (!a) {
				if (!v_range('_log_limit', quiet, 0, 2400)) return 0;
				if (!v_range('_log_mark', quiet, 0, 99999)) return 0;
				if (b) {
					c = E('_log_remoteip');
					if (!v_ip(c, 1) && !v_domain(c, 1)) {
						if (!quiet) ferror.show(c);
						return 0;
					}
					if (!v_port('_log_remoteport', quiet)) return 0;
				}
			}

			if (E('_f_log_file').checked) {
				E('_log_file_size').disabled = 0;
				if (!v_range('_log_file_size', quiet, 0, 99999)) return 0;
				if (parseInt(E('_log_file_size').value) > 0) {
					E('_log_file_keep').disabled = 0;
					if (!v_range('_log_file_keep', quiet, 0, 99)) return 0;
				} else {
					E('_log_file_keep').disabled = 1;
				}
			} else {
				E('_log_file_size').disabled = 1;
				E('_log_file_keep').disabled = 1;
			}

			a = E('_f_log_wm').checked;
			b = E('_log_wmtype').value != 0;
			c = E('_f_webmon_bkp').checked;
			E('_log_wmtype').disabled = !a;
			E('_f_log_wmip').disabled = !a;
			E('_log_wmdmax').disabled = !a;
			E('_log_wmsmax').disabled = !a;
			E('_f_webmon_bkp').disabled = !a;
			E('_f_webmon_shrink').disabled = !a || !c;
			E('_webmon_dir').disabled = !a || !c;
			elem.display(PR('_f_log_wmip'), b);

			if (a) {
				if (b) {
					if (!_v_iptaddr('_f_log_wmip', quiet, 15, 1, 1)) return 0;
				}
				if (!v_range('_log_wmdmax', quiet, 0, 9999)) return 0;
				if (!v_range('_log_wmsmax', quiet, 0, 9999)) return 0;
			}

			return 1;
		}

		function save()
		{
			var a, fom;

			if (!verifyFields(null, false)) return;

			fom = E('_fom');
			fom.log_remote.value = E('_f_log_remote').checked ? 1 : 0;
			fom.log_file.value = E('_f_log_file').checked ? 1 : 0;
			fom.log_file_custom.value = E('_f_log_file_custom').checked ? 1 : 0;

			a = [];
			if (E('_f_log_acre').checked) a.push('acre');
			if (E('_f_log_crond').checked) a.push('crond');
			if (E('_f_log_dhcpc').checked) a.push('dhcpc');
			if (E('_f_log_ntp').checked) a.push('ntp');
			if (E('_f_log_sched').checked) a.push('sched');
			fom.log_events.value = a.join(',');

			fom.log_wm.value = E('_f_log_wm').checked ? 1 : 0;
			fom.log_wmip.value = fom.f_log_wmip.value.split(/\s*,\s*/).join(',');
			fom.webmon_bkp.value = E('_f_webmon_bkp').checked ? 1 : 0;
			fom.webmon_shrink.value = E('_f_webmon_shrink').checked ? 1 : 0;

			form.submit(fom, 1);
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#admin-log.asp">
		<input type="hidden" name="_service" value="logging-restart">

		<input type="hidden" name="log_remote">
		<input type="hidden" name="log_file">
		<input type="hidden" name="log_file_custom">
		<input type="hidden" name="log_events">

		<input type="hidden" name="log_wm">
		<input type="hidden" name="log_wmip">
		<input type="hidden" name="webmon_bkp">
		<input type="hidden" name="webmon_shrink">

		<div class="box" data-box="router-log">
			<div class="heading">系统日志</div>
			<div class="content" id="router-log"></div>
			<script type="text/javascript">

				/* REMOVE-BEGIN
				// adjust (>=1.22)
				nvram.log_mark *= 1;
				if (nvram.log_mark >= 120) nvram.log_mark = 120;
				else if (nvram.log_mark >= 60) nvram.log_mark = 60;
				else if (nvram.log_mark > 0) nvram.log_mark = 30;
				else nvram.log_mark = 0;
				REMOVE-END */

				$('#router-log').forms([
					{ title: '记录到本地系统', name: 'f_log_file', type: 'checkbox', value: nvram.log_file == 1 },
					{ title: '日志大小限制', name: 'log_file_size', type: 'text', maxlen: 5, size: 6, value: nvram.log_file_size || 50, suffix: ' <small>KB</small>' },
					{ title: '日志条数限制', name: 'log_file_keep', type: 'text', maxlen: 2, size: 3, value: nvram.log_file_keep || 1 },
					{ title: '自定义保存路径', multi: [
						{ name: 'f_log_file_custom', type: 'checkbox', value: nvram.log_file_custom == 1, suffix: '  ' },
						{ name: 'log_file_path', type: 'text', maxlen: 50, size: 30, value: nvram.log_file_path, suffix: ' <small>(确保该目录存在并可写)</small>' }
					] },
					{ title: '记录到远端系统', name: 'f_log_remote', type: 'checkbox', value: nvram.log_remote == 1 },
					{ title: '主机或者 IP地址 / 端口', indent: 2, multi: [
						{ name: 'log_remoteip', type: 'text', maxlen: 32, size: 35, value: nvram.log_remoteip, suffix: ':' },
						{ name: 'log_remoteport', type: 'text', maxlen: 5, size: 7, value: nvram.log_remoteport } ]},
					{ title: '生成间隔', name: 'log_mark', type: 'select', options: [[0,'关闭'],[30,'每隔30分钟'],[60,'每隔1小时'],[120,'每隔2小时'],[360,'每隔6小时'],[720,'每隔12小时'],[1440,'每隔1天'],[10080,'每隔7天']], value: nvram.log_mark },
					{ title: '事件记录', text: '<small>(某些改动在重启后生效)</small>' },
					{ title: '记录访问限制事件', indent: 2, name: 'f_log_acre', type: 'checkbox', value: (nvram.log_events.indexOf('acre') != -1) },
					{ title: '记录 Cron 事件', indent: 2, name: 'f_log_crond', type: 'checkbox', value: (nvram.log_events.indexOf('crond') != -1) },
					{ title: '记录 DHCP 客户端事件', indent: 2, name: 'f_log_dhcpc', type: 'checkbox', value: (nvram.log_events.indexOf('dhcpc') != -1) },
					{ title: '记录 NTP 事件', indent: 2, name: 'f_log_ntp', type: 'checkbox', value: (nvram.log_events.indexOf('ntp') != -1) },
					{ title: '记录定时事件', indent: 2, name: 'f_log_sched', type: 'checkbox', value: (nvram.log_events.indexOf('sched') != -1) },
					{ title: '连接日志' },
					{ title: '记录下行连接', indent: 2, name: 'log_in', type: 'select', options: [[0,'从不记录 (推荐)'],[1,'被防火墙阻止的'],[2,'被防火墙允许的'],[3,'两者都有']], value: nvram.log_in },
					{ title: '记录上行连接', indent: 2, name: 'log_out', type: 'select', options: [[0,'从不记录 (推荐)'],[1,'被防火墙阻止的'],[2,'被防火墙允许的'],[3,'两者都有']], value: nvram.log_out },
					{ title: '日志记录限制', indent: 2, name: 'log_limit', type: 'text', maxlen: 4, size: 5, value: nvram.log_limit, suffix: ' <small>(每分钟消息数 / 0 表示不限制)</small>' }
				]);
			</script>
		</div>

		<div class="box" data-box="webmon-settings">
			<div class="heading">网站访问历史</div>
			<div class="content" id="webmon"></div>
			<script type='text/javascript'>
				$('#webmon').forms([
					{ title: '启用网站访问历史', name: 'f_log_wm', type: 'checkbox', value: nvram.log_wm == 1 },
					{ title: '监测范围(局域网电脑)', name: 'log_wmtype', type: 'select', options: [[0,'所有电脑/设备'],[1,'下列电脑/设备...'],[2,'除下列电脑/设备之外...']], value: nvram.log_wmtype },
					{ title: 'IP 地址(es)', indent: 2,  name: 'f_log_wmip', type: 'text', maxlen: 512, size: 64, value: nvram.log_wmip,
						suffix: '<small>(例如: "1.1.1.1", "1.1.1.0/24" 或者 "1.1.1.1 - 2.2.2.2")</small>' },
					{ title: '保留记录数量' },
					{ title: '域名', indent: 2,  name: 'log_wmdmax', type: 'text', maxlen: 4, size: 6, value: nvram.log_wmdmax, suffix: ' <small>(0 表示禁用)</small>' },
					{ title: '搜索关键字', indent: 2, name: 'log_wmsmax', type: 'text', maxlen: 4, size: 6, value: nvram.log_wmsmax, suffix: ' <small>(0 表示禁用)</small>' },
					{ title: '每日备份', name: 'f_webmon_bkp', type: 'checkbox', value: nvram.webmon_bkp == 1, suffix: ' <small>(每天午夜)</small>' },
					{ title: '备份后清除数据', indent: 2, name: 'f_webmon_shrink', type: 'checkbox', value: nvram.webmon_shrink == 1 },
					{ title: '备份保存目录', indent: 2,  name: 'webmon_dir', type: 'text', maxlen: 128, size: 30, value: nvram.webmon_dir, suffix: ' <small>(确保该目录存在并可写)</small>' }
				]);
			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>
	</form>

	<script type="text/javascript">verifyFields(null, 1);</script>
</content>