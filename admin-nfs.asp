<!--
Tomato GUI
Copyright (C) 2007-2011 Shibby
http://openlinksys.info
For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>NFS 服务</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,nfs_enable,nfs_exports"); %>

		var access = [['rw', '读/写'], ['ro', '只读']];
		var sync = [['sync', '是'], ['async', '否']];
		var subtree = [['subtree_check', '是'], ['no_subtree_check', '否']];
		var nfsg = new TomatoGrid();
		nfsg.exist = function(f, v)
		{
			var data = this.getAllData();
			for (var i = 0; i < data.length; ++i) {
				if (data[i][f] == v) return true;
			}
			return false;
		}
		nfsg.dataToView = function(data) {
			return [data[0], data[1], data[2],data[3], data[4], data[5]];
		}
		nfsg.verifyFields = function(row, quiet)
		{
			var ok = 1;
			return ok;
		}
		nfsg.resetNewEditor = function() {
			var f;
			f = fields.getAll(this.newEditor);
			ferror.clearAll(f);
			f[0].value = '';
			f[1].value = '';
			f[2].selectedIndex = 0;
			f[3].selectedIndex = 0;
			f[4].selectedIndex = 1;
			f[5].value = 'no_root_squash';
		}
		nfsg.setup = function()
		{
			this.init('nfsg-grid', '', 50, [
				{ type: 'text', maxlen: 50 },
				{ type: 'text', maxlen: 30 },
				{ type: 'select', options: access },
				{ type: 'select', options: sync },
				{ type: 'select', options: subtree },
				{ type: 'text', maxlen: 50 }
			]);
			this.headerSet(['目录','IP 地址/子网', '访问权限', '同步', '子目录树检查', '其它选项']);
			var s = nvram.nfs_exports.split('>');
			for (var i = 0; i < s.length; ++i) {
				var t = s[i].split('<');
				if (t.length == 6) this.insertData(-1, t);
			}
			this.showNewEditor();
			this.resetNewEditor();
		}
		function save()
		{
			var data = nfsg.getAllData();
			var exports = '';
			var i;
			if (data.length != 0) exports += data[0].join('<');
			for (i = 1; i < data.length; ++i) {
				exports += '>' + data[i].join('<');
			}
			var fom = E('_fom');
			fom.nfs_enable.value = E('_f_nfs_enable').checked ? 1 : 0;
			fom.nfs_exports.value = exports;
			form.submit(fom, 1);
		}
		function init()
		{
			nfsg.recolor();
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#admin-nfs.asp">
		<input type="hidden" name="_service" value="nfs-start">
		<input type="hidden" name="nfs_enable">
		<input type="hidden" name="nfs_exports">

		<div class="box">
			<div class="heading">NFS 服务设置</div>
			<div class="content">
				<div id="nfs-server"></div><hr><br />
				<script type="text/javascript">
					$('#nfs-server').forms([
						{ title: '启用 NFS 服务', name: 'f_nfs_enable', type: 'checkbox', value: nvram.nfs_enable != '0' }
					]);
				</script>

				<h4>NFS 客户端</h4>
				<table class="line-table" id="nfsg-grid"></table><br><hr>

				<h4>说明</h4>
				<ul>
					<li>您可以在以下网站找到有关正确配置 NFS 的更多信息: <a href="http://nfs.sourceforge.net/nfs-howto/" target="_blanc"><b>http://nfs.sourceforge.net</b></a>.
					<li>如果要从其他 NFS 服务器装载 NFS 共享，可以通过 telnet / ssh 使用 mount.nfs 工具。
				</ul>
			</div>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">nfsg.setup(); init();</script>
</content>