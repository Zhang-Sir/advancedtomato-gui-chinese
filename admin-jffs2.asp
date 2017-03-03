<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>JFFS 设置</title>
<content>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,jffs2_on,jffs2_exec,t_fix1"); %>

		fmtwait = (nvram.t_fix1 == 'RT-N16' ? 120 : 60);

		function verifyFields(focused, quiet) {
			var b = !E('_f_jffs2_on').checked;
			E('format').disabled = b;
			E('_jffs2_exec').disabled = b;
			return 1;
		}

		function formatClicked()
		{
			if (!verifyFields(null, 0)) return;
			if (!confirm("确认要格式化 JFFS 分区?")) return;
			save(1);
		}

		function formatClock()
		{
			if (ftime == 0) {
				$('.fclock').html('请稍等');
			}
			else {
				$('.fclock').html(((ftime > 0) ? '剩余 ' : '') + ftime + ' 秒' + ((ftime == 1) ? '' : ''));
			}
			if (--ftime >= 0) setTimeout(formatClock, 1000);
		}

		function save(format)
		{
			if (!verifyFields(null, 0)) return;

			E('format').disabled = 1;
			if (format) $('.ajaxwrap').prepend('<div class="alert alert-warning icon"><h5>警告!</h5>格式化分区 JFFS，请稍候 <span class="fclock">剩余60秒</span>...</div>');

			var fom = E('_fom');
			var on = E('_f_jffs2_on').checked ? 1 : 0;
			fom.jffs2_on.value = on;
			if (format) {
				fom.jffs2_format.value = 1;
				fom._commit.value = 0;
				fom._nextwait.value = fmtwait;
			}
			else {
				fom.jffs2_format.value = 0;
				fom._commit.value = 1;
				fom._nextwait.value = on ? 15 : 3;
			}
			form.submit(fom, 1);

			if (format) {
				ftime = fmtwait;
				formatClock();
			}
		}

		function submit_complete()
		{
			reloadPage();
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#admin-jffs2.asp">
		<input type="hidden" name="_nextwait" value="10">
		<input type="hidden" name="_service" value="jffs2-restart">
		<input type="hidden" name="_commit" value="1">

		<input type="hidden" name="jffs2_on">
		<input type="hidden" name="jffs2_format" value="0">

		<div class="box">
			<div class="heading">JFFS 分区</div>
			<div class="content" id="jffsdata"></div>
			<script type="text/javascript">
				// <% statfs("/jffs", "jffs2"); %>

				show_notice1('<% notice("jffs"); %>');

				jfon = (nvram.jffs2_on == 1);
				$('#jffsdata').forms([
					{ title: '启用', name: 'f_jffs2_on', type: 'checkbox', value: jfon },
					{ title: '挂载后执行', name: 'jffs2_exec', type: 'text', maxlen: 64, size: 34, value: nvram.jffs2_exec },
					null,
					{ title: 'JFFS 使用率 ', text: (((jffs2.mnt) || (jffs2.size > 0)) ? scaleSize(jffs2.size - jffs2.free) : '') + ((jffs2.mnt) ? ' / ' + scaleSize(jffs2.size) + ' (<span class="percentage"></span>)\
					<div class="progress small jffs2"><div class="bar"></div></div>' : ' (未挂载)') },
					{ title: '', custom: '<button type="button" value="格式化 / 擦除..." onclick="formatClicked()" id="format" class="btn">格式化 / 擦除...</button>' }
				]);

				// Progress BAR
				if (jffs2.size) {

					var calc = (Math.round(((jffs2.size - jffs2.free) / jffs2.size) * 100)) + '%';
					$('.percentage').html(calc);
					$('.progress.jffs2 .bar').css('width', calc);

				}
			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>
	</form>

	<script type="text/javascript">verifyFields(null, 1);</script>
</content>
