<!--
Tomato GUI
Samba Server - !!TB

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>Samba 文件共享</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,smbd_enable,smbd_user,smbd_passwd,smbd_wgroup,smbd_cpage,smbd_custom,smbd_master,smbd_wins,smbd_shares,smbd_autoshare,wan_wins"); %>

		var ssg = new TomatoGrid();

		ssg.exist = function(f, v)
		{
			var data = this.getAllData();
			for (var i = 0; i < data.length; ++i) {
				if (data[i][f] == v) return true;
			}
			return false;
		}

		ssg.existName = function(name)
		{
			return this.exist(0, name);
		}

		ssg.sortCompare = function(a, b) {
			var col = this.sortColumn;
			var da = a.getRowData();
			var db = b.getRowData();
			var r = cmpText(da[col], db[col]);
			return this.sortAscending ? r : -r;
		}

		ssg.dataToView = function(data) {
			return [data[0], data[1], data[2], ['只读', '读 / 写'][data[3]], ['否', '是'][data[4]]];
		}

		ssg.fieldValuesToData = function(row) {
			var f = fields.getAll(row);
			return [f[0].value, f[1].value, f[2].value, f[3].value, f[4].value];
		}

		ssg.verifyFields = function(row, quiet)
		{
			var f, s;

			f = fields.getAll(row);

			s = f[0].value.trim().replace(/\s+/g, ' ');
			if (s.length > 0) {
				if (s.search(/^[ a-zA-Z0-9_\-\$]+$/) == -1) {
					ferror.set(f[0], '无效的共享名.仅字符"$ A-Z 0-9 - _"和空格可用..', quiet);
					return 0;
				}
				if (this.existName(s)) {
					ferror.set(f[0], '重复的共享名.', quiet);
					return 0;
				}
				f[0].value = s;
			}
			else {
				ferror.set(f[0], '共享名不能为空.', quiet);
				return 0;
			}

			if (!v_nodelim(f[1], quiet, '目录', 1) || !v_path(f[1], quiet, 1)) return 0;
			if (!v_nodelim(f[2], quiet, '描述', 1)) return 0;

			return 1;
		}

		ssg.resetNewEditor = function()
		{
			var f;

			f = fields.getAll(this.newEditor);
			ferror.clearAll(f);

			f[0].value = '';
			f[1].value = '';
			f[2].value = '';
			f[3].selectedIndex = 0;
			f[4].selectedIndex = 0;
		}

		ssg.setup = function()
		{
			this.init('ss-grid', 'sort', 50, [
				{ type: 'text', maxlen: 32 },
				{ type: 'text', maxlen: 256 },
				{ type: 'text', maxlen: 64 },
				{ type: 'select', options: [[0, '只读'],[1, '读 / 写']] },
				{ type: 'select', options: [[0, '否'],[1, '是']] }
			]);
			this.headerSet(['共享名', '目录', '描述', '访问权限', '隐藏']);

			var s = nvram.smbd_shares.split('>');
			for (var i = 0; i < s.length; ++i) {
				var t = s[i].split('<');
				if (t.length == 5) {
					this.insertData(-1, t);
				}
			}

			this.sort(0);
			this.showNewEditor();
			this.resetNewEditor();
		}

		function verifyFields(focused, quiet)
		{
			var a, b;

			a = E('_smbd_enable').value;

			elem.display(PR('_smbd_user'), PR('_smbd_passwd'), (a == 2));

			E('_smbd_wgroup').disabled = (a == 0);
			E('_smbd_cpage').disabled = (a == 0);
			E('_smbd_custom').disabled = (a == 0);
			E('_smbd_autoshare').disabled = (a == 0);
			E('_f_smbd_master').disabled = (a == 0);
			E('_f_smbd_wins').disabled = (a == 0 || (nvram.wan_wins != '' && nvram.wan_wins != '0.0.0.0'));

			if (a != 0 && !v_length('_smbd_custom', quiet, 0, 2048)) return 0;

			if (a == 2) {
				if (!v_length('_smbd_user', quiet, 1)) return 0;
				if (!v_length('_smbd_passwd', quiet, 1)) return 0;

				b = E('_smbd_user');
				if (b.value == 'root') {
					ferror.set(b, '不允许使用\"root\"作为用户名.', quiet);
					return 0;
				}
				ferror.clear(b);
			}

			return 1;
		}

		function save()
		{
			if (ssg.isEditing()) return;
			if (!verifyFields(null, 0)) return;

			var fom = E('_fom');

			var data = ssg.getAllData();
			var r = [];
			for (var i = 0; i < data.length; ++i) r.push(data[i].join('<'));
			fom.smbd_shares.value = r.join('>');
			fom.smbd_master.value = E('_f_smbd_master').checked ? 1 : 0;
			if (nvram.wan_wins == '' || nvram.wan_wins == '0.0.0.0')
				fom.smbd_wins.value = E('_f_smbd_wins').checked ? 1 : 0;
			else
				fom.smbd_wins.value = nvram.smbd_wins;

			form.submit(fom, 1);
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#nas-samba.asp">
		<input type="hidden" name="_service" value="samba-restart">

		<input type="hidden" name="smbd_master">
		<input type="hidden" name="smbd_wins">
		<input type="hidden" name="smbd_shares">

		<div class="box">
			<div class="heading">Samba 文件共享</div>
			<div class="content fileshare"></div>
			<script type="text/javascript">
				$('.content.fileshare').forms([
					{ title: '启用文件共享', name: 'smbd_enable', type: 'select',
						options: [['0', '否'],['1', '是(不需要身份验证)'],['2', '是(需要身份验证)']],
						value: nvram.smbd_enable },
					{ title: '用户名', indent: 2, name: 'smbd_user', type: 'text', maxlen: 50, size: 32,
						value: nvram.smbd_user },
					{ title: '密码', indent: 2, name: 'smbd_passwd', type: 'password', maxlen: 50, size: 32, peekaboo: 1,
						value: nvram.smbd_passwd },
					{ title: '工作组名称', name: 'smbd_wgroup', type: 'text', maxlen: 20, size: 32,
						value: nvram.smbd_wgroup },
					{ title: '客户端代码页', name: 'smbd_cpage', type: 'select',
						options: [['', '未定义'],['437', '437 (美国,加拿大)'],['850', '850 (西欧)'],['852', '852 (中欧 / 东欧)'],['866', '866 (斯拉夫 / 俄语)']
							/* LINUX26-BEGIN */
							,['932', '932 (日语)'],['936', '936 (简体中文)'],['949', '949 (朝鲜语)'],['950', '950 (繁体中文 / Big5)']
							/* LINUX26-END */
						],
						suffix: ' <small> (Windows 中运行 cmd,输入 chcp 命令可查看系统代码页)</small>',
						value: nvram.smbd_cpage },
					{ title: 'Samba 自定义配置', name: 'smbd_custom', type: 'textarea', value: nvram.smbd_custom, style: 'width: 100%; height: 80px;' },
					{ title: '自动共享 USB 设备分区', name: 'smbd_autoshare', type: 'select',
						options: [['0', '禁用'],['1', '只读'],['2', '读 / 写'],['3', '隐藏式 读 / 写']],
						value: nvram.smbd_autoshare },
					{ title: '可选', multi: [
						{ suffix: '&nbsp; Master Browser &nbsp;&nbsp;&nbsp;', name: 'f_smbd_master', type: 'checkbox', value: nvram.smbd_master == 1 },
						{ suffix: '&nbsp; WINS 服务 (if not defined on Basic/Network page) &nbsp;',	name: 'f_smbd_wins', type: 'checkbox', value: (nvram.smbd_wins == 1) && (nvram.wan_wins == '' || nvram.wan_wins == '0.0.0.0') }
					] }
				]);
			</script>
		</div>

		<div class="box">
			<div class="heading">附加的共享列表</div>
			<div class="content">
				<table class="line-table" id="ss-grid"></table><br />
				<small>如果没有指定共享目录并且自动共享关闭时, <i>/mnt</i> 目录将会被以只读模式共享.</small>
			</div>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">ssg.setup(); verifyFields(null, 1);</script>
</content>