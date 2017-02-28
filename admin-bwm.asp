<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>带宽监控</title>
<content>
	<script type="text/javascript">

		// <% nvram("at_update,tomatoanon_answer,rstats_enable,rstats_path,rstats_stime,rstats_offset,rstats_exclude,rstats_sshut,et0macaddr,cifs1,cifs2,jffs2_on,rstats_bak"); %>

		function backupNameChanged()
		{
			if (location.href.match(/^(http.+?\/.+\/)/)) {
				// E('backup-link').href = RegExp.$1 + 'bwm/' + fixFile(E('backup-name').value) + '.gz?_http_id=' + nvram.http_id;
			}
		}

		function backupButton()
		{
			var name;

			name = fixFile(E('backup-name').value);
			if (name.length <= 1) {
				alert('不正确的文件名');
				return false;
			}
			location.href = '/bwm/' + name + '.gz?_http_id=' + nvram.http_id;
		}

		function restoreButton()
		{
			var fom;
			var name;
			var i;

			name = fixFile(E('restore-name').value);
			name = name.toLowerCase();
			if ((name.length <= 3) || (name.substring(name.length - 3, name.length).toLowerCase() != '.gz')) {
				alert('不正确的文件名. 正确的扩展名为 ".gz" .');
				return false;
			}

			if (!confirm('是否从 ' + name + '恢复?')) return false;

			E('restore-button').disabled = 1;
			fields.disableAll(E('_fom'), 1);
			E('restore-form').submit();

		}

		function getPath()
		{
			var s = E('_f_loc').value;
			return (s == '*user') ? E('_f_user').value : s;
		}

		function verifyFields(focused, quiet)
		{
			var b, v;
			var path;
			var eLoc, eUser, eTime, eOfs;
			var bak;

			eLoc = E('_f_loc');
			eUser = E('_f_user');
			eTime = E('_rstats_stime');
			eOfs = E('_rstats_offset');

			b = !E('_f_rstats_enable').checked;
			eLoc.disabled = b;
			eUser.disabled = b;
			eTime.disabled = b;
			eOfs.disabled = b;
			E('_f_new').disabled = b;
			E('_f_sshut').disabled = b;
			E('backup-button').disabled = b;
			E('backup-name').disabled = b;
			E('restore-button').disabled = b;
			E('restore-name').disabled = b;
			ferror.clear(eLoc);
			ferror.clear(eUser);
			ferror.clear(eOfs);
			if (b) return 1;

			path = getPath();
			E('newmsg').style.visibility = ((nvram.rstats_path != path) && (path != '*nvram') && (path != '')) ? 'visible' : 'hidden';

			bak = 0;
			v = eLoc.value;
			b = (v == '*user');
			elem.display(eUser, b);
			if (b) {
				if (!v_path(eUser, quiet, 1)) return 0;
			}
			/* JFFS2-BEGIN */
			else if (v == '/jffs/') {
				if (nvram.jffs2_on != '1') {
					ferror.set(eLoc, 'JFFS2 未启用.', quiet);
					return 0;
				}
			}
			/* JFFS2-END */
			/* CIFS-BEGIN */
			else if (v.match(/^\/cifs(1|2)\/$/)) {
				if (nvram['cifs' + RegExp.$1].substr(0, 1) != '1') {
					ferror.set(eLoc, 'CIFS #' + RegExp.$1 + ' 未启用.', quiet);
					return 0;
				}
			}
			/* CIFS-END */
			else {
				bak = 1;
			}

			E('_f_bak').disabled = bak;

			return v_range(eOfs, quiet, 1, 31);
		}

		function save()
		{
			var fom, path, en, e, aj;

			if (!verifyFields(null, false)) return;

			aj = 1;
			en = E('_f_rstats_enable').checked;
			fom = E('_fom');
			fom._service.value = 'rstats-restart';
			if (en) {
				path = getPath();
				if (((E('_rstats_stime').value * 1) <= 48) &&
					((path == '*nvram') || (path == '/jffs/'))) {
					if (!confirm('不建议对 NVRAM 或 JFFS2 频繁的存取，是否继续?')) return;
				}
				if ((nvram.rstats_path != path) && (fom.rstats_path.value != path) && (path != '') && (path != '*nvram') &&
					(path.substr(path.length - 1, 1) != '/')) {
					if (!confirm('注意: ' + path + ' 将会被视为一个文件. 如果这是一个目录，请使用 /. 是否继续?')) return;
				}
				fom.rstats_path.value = path;

				if (E('_f_new').checked) {
					fom._service.value = 'rstatsnew-restart';
					aj = 0;
				}
			}

			fom.rstats_path.disabled = !en;
			fom.rstats_enable.value = en ? 1 : 0;
			fom.rstats_sshut.value = E('_f_sshut').checked ? 1 : 0;
			fom.rstats_bak.value = E('_f_bak').checked ? 1 : 0;

			e = E('_rstats_exclude');
			e.value = e.value.replace(/\s+/g, ',').replace(/,+/g, ',');

			fields.disableAll(E('backup-section'), 1);
			fields.disableAll(E('restore-section'), 1);
			form.submit(fom, aj);
			if (en) {
				fields.disableAll(E('backup-section'), 0);
				fields.disableAll(E('restore-section'), 0);
			}
		}

		function init()
		{
			backupNameChanged();
		}
	</script>

	<div class="box">
		<div class="heading">带宽监控设置</div>
		<div class="content">
			<form id="_fom" method="post" action="tomato.cgi" style="margin: 0;">
				<input type="hidden" name="_nextpage" value="/#admin-bwm.asp">
				<input type="hidden" name="_service" value="rstats-restart">
				<input type="hidden" name="rstats_enable">
				<input type="hidden" name="rstats_path">
				<input type="hidden" name="rstats_sshut">
				<input type="hidden" name="rstats_bak">
			</form><hr>

			<script type="text/javascript">
				switch (nvram.rstats_path) {
					case '':
					case '*nvram':
					case '/jffs/':
					case '/cifs1/':
					case '/cifs2/':
						loc = nvram.rstats_path;
						break;
					default:
						loc = '*user';
						break;
				}
				$('#_fom').forms([
					{ title: '启用', name: 'f_rstats_enable', type: 'checkbox', value: nvram.rstats_enable == '1' },
					{ title: '历史数据保存位置', multi: [
						{ name: 'f_loc', type: 'select', options: [['','RAM (临时的)'],['*nvram','NVRAM'],
							/* JFFS2-BEGIN */
							['/jffs/','JFFS2'],
							/* JFFS2-END */
							/* CIFS-BEGIN */
							['/cifs1/','CIFS 1'],['/cifs2/','CIFS 2'],
							/* CIFS-END */
							['*user','自定义路径']], value: loc },
						{ name: 'f_user', type: 'text', maxlen: 48, size: 50, value: nvram.rstats_path }
					] },
					{ title: '保存频率', indent: 2, name: 'rstats_stime', type: 'select', value: nvram.rstats_stime, options: [
						[1,'每小时'],[2,'每2小时'],[3,'每3小时'],[4,'每4小时'],[5,'每5小时'],[6,'每6小时'],
						[9,'每9小时'],[12,'每12小时'],[24,'每天'],[48,'每两天'],[72,'每三天'],[96,'每四天'],
						[120,'每五天'],[144,'每六天'],[168,'每周']] },
					{ title: '关机时保存', indent: 2, name: 'f_sshut', type: 'checkbox', value: nvram.rstats_sshut == '1' },
					{ title: '创建新文件<br><small>(清除数据)</small>', indent: 2, name: 'f_new', type: 'checkbox', value: 0,
						suffix: ' &nbsp;<small id="newmsg" style="visibility:hidden">注意：如果这是一个新文件，则启用之</small>' },
					{ title: '创建备份', indent: 2, name: 'f_bak', type: 'checkbox', value: nvram.rstats_bak == '1' },
					{ title: '每月第一天为', name: 'rstats_offset', type: 'text', value: nvram.rstats_offset, maxlen: 2, size: 4 },
					{ title: '排除的接口', name: 'rstats_exclude', type: 'text', value: nvram.rstats_exclude, maxlen: 64, size: 50, suffix: '<small>(多个请用逗号分隔)</small>' }
					], { align: 'left' });
			</script>

			<div class="row">

				<div class="col-sm-12">

					<h4>备份</h4>
					<div class="section" id="backup-section">
						<form>
							<div class="input-append">
								<script type="text/javascript">
									$('#backup-section .input-append').prepend('<input size="40" type="text" maxlength="64" id="backup-name" name="backup_name" onchange="backupNameChanged()" value="tomato_rstats_' + nvram.et0macaddr.replace(/:/g, '').toLowerCase() + '">');
								</script>
								<button name="f_backup_button" id="backup-button" onclick="backupButton(); return false;" value="备份" class="btn">备份 <i class="icon-download"></i></button>
							</div>
						</form>
					</div>

				</div>

				<div class="col-sm-12">
					<h4>恢复</h4>
					<div class="section" id="restore-section">
						<form id="restore-form" method="post" action="bwm/restore.cgi?_http_id=<% nv(http_id); %>" encType="multipart/form-data">
							<input class="uploadfile" type="file" size="40" id="restore-name" name="restore_name" accept="application/x-gzip">
							<button type="button" name="f_restore_button" id="restore-button" value="恢复" onclick="restoreButton(); return false;" class="btn">恢复 <i class="icon-upload"></i></button>
						</form><br>
					</div>
				</div>

			</div>
		</div>
	</div>

	<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
	<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
	<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span><br /><br />

	<script type="text/javascript">init(); verifyFields(null, 1);</script>
</content>