<!DOCTYPE html>
<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>带宽监控:每月流量</title>
<content>
	<script type="text/javascript" src="js/bwm-hist.js"></script>
	<script type="text/javascript">
		//<% nvram("wan_ifname,wan2_ifname,wan3_ifname,wan4_ifname,lan_ifname,rstats_enable"); %>

		try {
			//	<% bandwidth("monthly"); %>
		}
		catch (ex) {
			monthly_history = [];
		}
		rstats_busy = 0;
		if (typeof(monthly_history) == 'undefined') {
			monthly_history = [];
			rstats_busy = 1;
		}

		function genData()
		{
			var w, i, h;

			w = window.open('', 'tomato_data_m');
			w.document.writeln('<pre>');
			for (i = 0; i < monthly_history.length; ++i) {
				h = monthly_history[i];
				w.document.writeln([(((h[0] >> 16) & 0xFF) + 1900), (((h[0] >>> 8) & 0xFF) + 1), h[1], h[2]].join(','));
			}
			w.document.writeln('</pre>');
			w.document.close();
		}

		function save()
		{
			cookie.set('monthly', scale, 31);
		}

		function redraw()
		{
			var h;
			var grid;
			var rows;
			var yr, mo, da;

			rows = 0;
			block = '';
			gn = 0;

			grid = '<table class="line-table td-large">';
			grid += '<tr><td><b>日期</b></td><td><b>下载</b></td><td><b>上传</b></th><td><b>合计</b></td></tr>';

			for (i = 0; i < monthly_history.length; ++i) {
				h = monthly_history[i];
				yr = (((h[0] >> 16) & 0xFF) + 1900);
				mo = ((h[0] >>> 8) & 0xFF);

				grid += makeRow(((rows & 1) ? 'odd' : 'even'), ymText(yr, mo), rescale(h[1]), rescale(h[2]), rescale(h[1] + h[2]));
				++rows;
			}

			E('bwm-monthly-grid').innerHTML = grid + '</table>';
		}

		function init()
		{
			var s;

			if (nvram.rstats_enable != '1') { $('#rstats').before('<div class="alert alert-warning">宽带监控已禁用.</b> <a href="/#admin-bwm.asp">启用 &raquo;</a></div>'); return; }

			if ((s = cookie.get('monthly')) != null) {
				if (s.match(/^([0-2])$/)) {
					E('scale').value = scale = RegExp.$1 * 1;
				}
			}

			initDate('ym');
			monthly_history.sort(cmpHist);
			redraw();
		}
	</script>

	<ul class="nav-tabs">
		<li><a class="ajaxload" href="bwm-realtime.asp"><i class="icon-hourglass"></i> 实时</a></li>
		<li><a class="ajaxload" href="bwm-24.asp"><i class="icon-graphs"></i> 最近24小时</a></li>
		<li><a class="ajaxload" href="bwm-daily.asp"><i class="icon-clock"></i> 每天</a></li>
		<li><a class="ajaxload" href="bwm-weekly.asp"><i class="icon-week"></i> 每周</a></li>
		<li><a class="active"><i class="icon-month"></i> 每月</a></li>
	</ul>

	<div id="rstats" class="box">
		<div class="heading">每月带宽 <a class="pull-right" href="#" data-toggle="tooltip" title="刷新信息" onclick="reloadPage(); return false;"><i class="icon-refresh"></i></a></div>
		<div class="content">
			<div id="bwm-monthly-grid"></div>
		</div>
	</div>

	<a href="javascript:genData()" class="btn btn-primary">数据 <i class="icon-drive"></i></a>
	<a href="admin-bwm.asp" class="btn btn-danger ajaxload">配置 <i class="icon-tools"></i></a>
	<span class="pull-right">
		<b>日期格式</b> <select onchange="changeDate(this, 'ym')" id="dafm"><option value="0">年-月</option><option value="1">月-年</option><option value="2">月 年</option><option value="3">月.年</option></select> &nbsp;
		<b>单位大小</b> <select onchange="changeScale(this)" id="scale"><option value="0">KB</option><option value="1">MB</option><option value="2" selected>GB</option></select>
	</span>
	<script type="text/javascript">init();</script>
</content>