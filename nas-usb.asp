<!--
Tomato GUI
USB Support - !!TB

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>USB 基本设置</title>
<content>
	<style>textarea { width: 100%; }</style>
	<script type="text/javascript">

		//	<% nvram("usb_enable,usb_uhci,usb_ohci,usb_usb2,usb_mmc,usb_storage,usb_printer,usb_printer_bidirect,usb_automount,usb_fs_ext3,usb_fs_fat,usb_fs_ntfs,usb_fs_hfs,script_usbmount,script_usbumount,script_usbhotplug,idle_enable,usb_3g"); %>
		//	<% usbdevices(); %>

		list = [];

		var xob = null;

		function _umountHost(host)
		{
			form.submitHidden('usbcmd.cgi', { remove: host });
		}

		function _mountHost(host)
		{
			form.submitHidden('usbcmd.cgi', { mount: host });
		}

		function _forceRefresh()
		{
			if (!ref.running) ref.once = 1;
			ref.start();
		}

		function umountHost(a, host)
		{
			if (xob) return;

			if ((xob = new XmlHttp()) == null) {
				_umountHost(host);
				return;
			}

			a = E(a);
			a.innerHTML = '请稍等...';

			xob.onCompleted = function(text, xml) {
				eval(text);
				if (usb.length == 1) {
					if (usb[0] != 0)
						ferror.set(a, '设备正忙，请确保没有应用程序正在使用它，然后重试.', 0);
				}
				xob = null;
				_forceRefresh();
			}

			xob.onError = function() {
				xob = null;
				_forceRefresh();
			}

			xob.post('usbcmd.cgi', 'remove=' + host);
		}

		function mountHost(a, host)
		{
			if (xob) return;

			if ((xob = new XmlHttp()) == null) {
				_mountHost(host);
				return;
			}

			a = E(a);
			a.innerHTML = '请稍等...';

			xob.onCompleted = function(text, xml) {
				eval(text);
				if (usb.length == 1) {
					if (usb[0] == 0)
						ferror.set(a, '无法挂载，验证设备是否已插入，然后重试.', 0);
				}
				xob = null;
				_forceRefresh();
			}

			xob.onError = function() {
				xob = null;
				_forceRefresh();
			}

			xob.post('usbcmd.cgi', 'mount=' + host);
		}

		var ref = new TomatoRefresh('update.cgi', 'exec=usbdevices', 0, 'nas_usb_refresh');

		ref.refresh = function(text)
		{
			try {
				eval(text);
			}
			catch (ex) {
				return;
			}
			dg.removeAllData();
			dg.populate();
			dg.resort();
		}

		var dg = new TomatoGrid();

		dg.sortCompare = function(a, b) {
			var col = this.sortColumn;
			var ra = a.getRowData();
			var rb = b.getRowData();
			var r;

			switch (col) {
				case 1:
					if (ra.type == '存储设备' && ra.type == rb.type)
						r = cmpInt(ra.host, rb.host);
					else
						r = cmpText(ra.host, rb.host);
					break;
				default:
					r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML);
			}
			return this.sortAscending ? r : -r;
		}

		dg.populate = function()
		{
			var i, j, k, a, b, c, e, s, desc, d, parts, p;

			list = [];

			for (i = 0; i < list.length; ++i) {
				list[i].type = '';
				list[i].host = '';
				list[i].vendor = '';
				list[i].product = '';
				list[i].serial = '';
				list[i].discs = [];
				list[i].is_mounted = 0;
			}

			for (i = usbdev.length - 1; i >= 0; --i) {
				a = usbdev[i];
				e = {
					type: a[0],
					host: a[1],
					vendor: a[2],
					product: a[3],
					serial: a[4],
					discs: a[5],
					is_mounted: a[6]
				};
				list.push(e);
			}

			for (i = list.length - 1; i >= 0; --i) {
				e = list[i];

				if (e.type != '存储设备')
					s = '&nbsp<br><small>&nbsp</small>';
				else {
					if (xob)
						s = ((e.is_mounted == 0) ? 'No' : 'Yes') + '<br><small>请稍等...</small>';
					else if (e.is_mounted == 0)
						s = 'No<br><small><a href="javascript:mountHost(\'L' + i + '\',\'' + e.host + '\')" title="挂载存储设备的所有分区" id="L' + i + '">[ Mount ]</a></small>';
						else
							s = 'Yes<br><small><a href="javascript:umountHost(\'L' + i + '\',\'' + e.host + '\')" title="安全删除存储设备" id="L' + i + '">[ Unmount ]</a></small>';
				}
				desc = (e.vendor + ' ' + e.product).trim() + '<small>'; // + (e.serial == '' ? '' : '<br>Serial No: ' + e.serial);
				if (e.discs) {
					for (j = 0; j <= e.discs.length - 1; ++j) {
						d = e.discs[j];
						parts = d[1];
						for (k = 0; k <= parts.length - 1; ++k) {
							p = parts[k];
							if (p) {
								desc = desc + '<br>分区 \'' + p[0] + '\'' + (p[3] != '' ? ' ' + p[3] : '') +
								((p[5] != 0) ? ' (' + doScaleSize((p[5] - p[6]), 0) + 
									((p[1] == 1) ? ' / ' + doScaleSize(p[5], 0) + ' 已使用' : '') +
									')' : '') + '  ' +
								((p[1] != 0) ? '' : '未知 ') + ((p[3] == 'swap') ? '活跃' : '已挂载') +
								((p[2] != '') ? ' 于 ' + p[2] : '');
							}
						}
					}
				}
				desc = desc + '</small>';
				this.insert(-1, e, ['<i class="icon-drive icon-medium icon-middle"></i> ' + e.type, e.host, desc, s], false);
			}

			list = [];
		}

		dg.setup = function()
		{
			this.init('dev-grid', 'sort');
			this.headerSet(['类型', 'Host', '描述', '状态']);
			this.populate();
			this.sort(1);
		}

		function earlyInit() {
			$('#last-box').after(genStdRefresh(1,0,'ref.toggle()'));
			dg.setup();
			init();
		}

		function init() {
			dg.recolor();
			ref.initPage();
		}

		function verifyFields(focused, quiet)
		{
			var b = !E('_f_usb').checked;
			var a = !E('_f_storage').checked;

			E('_f_uhci').disabled = b || nvram.usb_uhci == -1;
			E('_f_ohci').disabled = b || nvram.usb_ohci == -1;
			E('_f_usb2').disabled = b;
			E('_f_print').disabled = b;
			E('_f_storage').disabled = b;

			/* LINUX26-BEGIN */
			/* MICROSD-BEGIN */
			E('_f_mmc').disabled = a || b || nvram.usb_mmc == -1;
			elem.display(PR('_f_mmc'), nvram.usb_mmc != -1);
			/* MICROSD-END */
			/* LINUX26-END */

			E('_f_ext3').disabled = b || a;
			E('_f_fat').disabled = b || a;
			/* LINUX26-BEGIN */
			E('_f_idle_enable').disabled = b || a;
			E('_f_usb_3g').disabled = b;
			/* LINUX26-END */
			/* NTFS-BEGIN */
			E('_f_ntfs').disabled = b || a;
			/* NTFS-END */
			/* HFS-BEGIN */
			E('_f_hfs').disabled = b || a; //!Victek
			/* HFS-END */
			E('_f_automount').disabled = b || a;
			E('_f_bprint').disabled = b || !E('_f_print').checked;

			elem.display(PR('_f_automount'), !b && !a);
			elem.display(PR('_script_usbmount'), PR('_script_usbumount'), !b && !a && E('_f_automount').checked);
			elem.display(PR('_script_usbhotplug'), !b && (!a || E('_f_print').checked));

			if (!v_length('_script_usbmount', quiet, 0, 2048)) return 0;
			if (!v_length('_script_usbumount', quiet, 0, 2048)) return 0;
			if (!v_length('_script_usbhotplug', quiet, 0, 2048)) return 0;

			return 1;
		}

		function save()
		{
			var fom;

			if (!verifyFields(null, 0)) return;

			fom = E('_fom');
			fom.usb_enable.value = E('_f_usb').checked ? 1 : 0;
			fom.usb_uhci.value = nvram.usb_uhci == -1 ? -1 : (E('_f_uhci').checked ? 1 : 0);
			fom.usb_ohci.value = nvram.usb_ohci == -1 ? -1 : (E('_f_ohci').checked ? 1 : 0);
			fom.usb_usb2.value = E('_f_usb2').checked ? 1 : 0;
			fom.usb_storage.value = E('_f_storage').checked ? 1 : 0;
			fom.usb_printer.value = E('_f_print').checked ? 1 : 0;
			fom.usb_printer_bidirect.value = E('_f_bprint').checked ? 1 : 0;

			/* LINUX26-BEGIN */
			/* MICROSD-BEGIN */
			fom.usb_mmc.value = nvram.usb_mmc == -1 ? -1 : (E('_f_mmc').checked ? 1 : 0);
			/* MICROSD-END */
			/* LINUX26-END */

			fom.usb_fs_ext3.value = E('_f_ext3').checked ? 1 : 0;
			fom.usb_fs_fat.value = E('_f_fat').checked ? 1 : 0;
			/* NTFS-BEGIN */
			fom.usb_fs_ntfs.value = E('_f_ntfs').checked ? 1 : 0;
			/* NTFS-END */
			/* HFS-BEGIN */
			fom.usb_fs_hfs.value = E('_f_hfs').checked ? 1 : 0; //!Victek
			/* HFS-END */
			fom.usb_automount.value = E('_f_automount').checked ? 1 : 0;
			/* LINUX26-BEGIN */
			fom.idle_enable.value = E('_f_idle_enable').checked ? 1 : 0;
			fom.usb_3g.value = E('_f_usb_3g').checked ? 1 : 0;
			/* LINUX26-END */

			form.submit(fom, 1);
		}

		function submit_complete()
		{
			reloadPage();
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#nas-usb.asp">
		<input type="hidden" name="_service" value="usb-restart">

		<input type="hidden" name="usb_enable">
		<input type="hidden" name="usb_uhci">
		<input type="hidden" name="usb_ohci">
		<input type="hidden" name="usb_usb2">
		<input type="hidden" name="usb_mmc">
		<input type="hidden" name="usb_storage">
		<input type="hidden" name="usb_printer">
		<input type="hidden" name="usb_printer_bidirect">
		<input type="hidden" name="usb_fs_ext3">
		<input type="hidden" name="usb_fs_fat">
		/* NTFS-BEGIN */
		<input type="hidden" name="usb_fs_ntfs">
		/* NTFS-END */
		/* HFS-BEGIN */
		<input type="hidden" name="usb_fs_hfs">
		/* HFS-END */
		<input type="hidden" name="usb_automount">
		/* LINUX26-BEGIN */
		<input type="hidden" name="idle_enable">
		<input type="hidden" name="usb_3g">
		/* LINUX26-END */

		<div class="box" data-box="usb-supp">
			<div class="heading">USB 设备支持</div>
			<div class="content">
				<div id="usbfields"></div>
				<script type="text/javascript">

					$('#usbfields').forms([
						{ title: '开启 USB 设备', name: 'f_usb', type: 'checkbox', value: nvram.usb_enable == 1 },
						{ title: '支持 USB 2.0', indent: 2, name: 'f_usb2', type: 'checkbox', value: nvram.usb_usb2 == 1 },
						{ title: '支持 USB 1.1', indent: 2, multi: [
							{ suffix: '&nbsp; OHCI &nbsp;&nbsp;&nbsp;', name: 'f_ohci', type: 'checkbox', value: nvram.usb_ohci == 1 },
							{ suffix: '&nbsp; UHCI &nbsp;',	name: 'f_uhci', type: 'checkbox', value: nvram.usb_uhci == 1 }
						] },
						null,
						{ title: '支持 USB 打印机', name: 'f_print', type: 'checkbox', value: nvram.usb_printer == 1 },
						{ title: '双向复制', indent: 2, name: 'f_bprint', type: 'checkbox', value: nvram.usb_printer_bidirect == 1 },
						null,
						{ title: '支持 USB 存储设备', name: 'f_storage', type: 'checkbox', value: nvram.usb_storage == 1 },
						{ title: '支持文件系统', indent: 2, multi: [
							{ suffix: '&nbsp; Ext2 / Ext3 &nbsp;&nbsp;&nbsp;', name: 'f_ext3', type: 'checkbox', value: nvram.usb_fs_ext3 == 1 },
							/* NTFS-BEGIN */
							{ suffix: '&nbsp; NTFS &nbsp;&nbsp;&nbsp;', name: 'f_ntfs', type: 'checkbox', value: nvram.usb_fs_ntfs == 1 },
							/* NTFS-END */
							{ suffix: '&nbsp; FAT &nbsp;', name: 'f_fat', type: 'checkbox', value: nvram.usb_fs_fat == 1 }
							/* HFS-BEGIN */
							,{ suffix: '&nbsp; HFS / HFS+ &nbsp;', name: 'f_hfs', type: 'checkbox', value: nvram.usb_fs_hfs == 1 }
							/* HFS-END */
						] },
						/* LINUX26-BEGIN */
						/* MICROSD-BEGIN */
						{ title: '支持 SD/MMC 卡', indent: 2, name: 'f_mmc', type: 'checkbox', value: nvram.usb_mmc == 1 },
						/* MICROSD-END */
						/* LINUX26-END */
						{ title: '自动挂载', indent: 2, name: 'f_automount', type: 'checkbox',
							suffix: ' <small>自动将所有分区挂载于 <i>/mnt</i> 子目录中.</small>', value: nvram.usb_automount == 1 },
						{ title: '安装后执行', indent: 2, name: 'script_usbmount', type: 'textarea', value: nvram.script_usbmount },
						{ title: '卸载前执行', indent: 2, name: 'script_usbumount', type: 'textarea', value: nvram.script_usbumount },
						null,
						/* LINUX26-BEGIN */
						{ title: 'HDD 休眠', name: 'f_idle_enable', type: 'checkbox',
							suffix: ' <small>空闲时自动休眠硬盘，对闪存设备无效.</small>', value: nvram.idle_enable == 1 },
						null,
						{ title: '支持 USB 3G Modem', name: 'f_usb_3g', type: 'checkbox',
							suffix: ' <small>在从 USB 端口断开 3G 调制解调器之前，请记住取消选中复选框。如果调制解调器使用 usbserial 模块，您必须重新启动路由器，然后再拔下调制解调器.</small>', value: nvram.usb_3g == 1 },
						null,
						/* LINUX26-END */
						{ title: '热插拔脚本<br><small>(当任何 USB 设备连接或删除时调用)</small>', name: 'script_usbhotplug', type: 'textarea', value: nvram.script_usbhotplug },
						null,
						{ text: '<small>某些更改将在重新启动后生效.</small>' }
					]);
				</script>
			</div>
		</div>

		<div class="box" id="last-box" data-box="attached-devices">
			<div class="heading">设备列表</div>
			<div class="content">
				<table id="dev-grid" class="line-table"></table>
			</div>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">earlyInit(); verifyFields(null, 1);</script>
</content>