<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>带宽监控:实时带宽</title>
<content>
	<style type="text/css">
		table tr td:nth-child(even) { width: 25%; }
		table tr td:nth-child(odd) { width: 5%; }
	</style>
	<script type="text/javascript" src="js/wireless.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript" src="js/bwm-common.js"></script>
	<script type="text/javascript">
		//<% nvram("wan_ifname,wan_iface,wan2_ifname,wan2_iface,wan3_ifname,wan3_iface,wan4_ifname,wan4_iface,lan_ifname,wl_ifname,wan_proto,wan2_proto,wan3_proto,wan4_proto,web_svg,rstats_colors"); %>

		var cprefix = 'bw_r';
		var updateInt = 2;
		var updateDiv = updateInt;
		var updateMaxL = 300;
		var updateReTotal = 1;
		var prev = [];
		var debugTime = 0;
		var avgMode = 0;
		var wdog = null;
		var wdogWarn = null;


		var ref = new TomatoRefresh('update.cgi', 'exec=netdev', 1);

		ref.stop = function() {
			this.timer.start(1000);
		}

		ref.refresh = function(text) {
			var c, i, h, n, j, k;

			watchdogReset();

			++updating;
			try {
				netdev = null;
				eval(text);

				n = (new Date()).getTime();
				if (this.timeExpect) {
					if (debugTime) $('#dtime').show().html((this.timeExpect - n) + ' ' + ((this.timeExpect + 2000) - n));
					this.timeExpect += 2000;
					this.refreshTime = MAX(this.timeExpect - n, 500);
				}
				else {
					this.timeExpect = n + 2000;
				}

				for (i in netdev) {
					c = netdev[i];
					if ((p = prev[i]) != null) {
						h = speed_history[i];

						h.rx.splice(0, 1);
						h.rx.push((c.rx < p.rx) ? (c.rx + (0xFFFFFFFF - p.rx)) : (c.rx - p.rx));

						h.tx.splice(0, 1);
						h.tx.push((c.tx < p.tx) ? (c.tx + (0xFFFFFFFF - p.tx)) : (c.tx - p.tx));
					}
					else if (!speed_history[i]) {
						speed_history[i] = {};
						h = speed_history[i];
						h.rx = [];
						h.tx = [];
						for (j = 300; j > 0; --j) {
							h.rx.push(0);
							h.tx.push(0);
						}
						h.count = 0;
					}
					prev[i] = c;
				}
				loadData();
			}
			catch (ex) {
			}
			--updating;
		}

		function watchdog()
		{
			watchdogReset();
			ref.stop();
			wdogWarn.style.display = '';
		}

		function watchdogReset() {
			if (wdog) clearTimeout(wdog)
			wdog = setTimeout(watchdog, 5000*updateInt);
			wdogWarn.style.display = 'none';
		}

		function init()
		{
			speed_history = [];

			initCommon(2, 1, 1);

			wdogWarn = E('warnwd');
			watchdogReset();

			$('.updatetime').html(5*updateInt);
			$('.interval').html(updateInt);

			ref.start();
		}
	</script>

	<ul class="nav-tabs">
		<li><a class="active"><i class="icon-hourglass"></i> 实时</a></li>
		<li><a class="ajaxload" href="bwm-24.asp"><i class="icon-graphs"></i> 最近24小时</a></li>
		<li><a class="ajaxload" href="bwm-daily.asp"><i class="icon-clock"></i> 每天</a></li>
		<li><a class="ajaxload" href="bwm-weekly.asp"><i class="icon-week"></i> 每周</a></li>
		<li><a class="ajaxload" href="bwm-monthly.asp"><i class="icon-month"></i> 每月</a></li>
	</ul>

	<div class="box">
		<div class="heading">实时带宽 &nbsp;  <div class="spinner" id="refresh-spinner" onclick="javascript:debugTime=1"></div></div>
		<div class="content">
			<div id="rstats">
				<div id="tab-area" class="btn-toolbar"></div>

				<script type="text/javascript">
					if (nvram.web_svg != '0') {
						$('#tab-area').after('<embed id="graph" type="image/svg+xml" src="img/bwm-graph.svg?<% version(); %>" style="height: 300px; width:100%;"></embed>');
					}
				</script>

				<div id="bwm-controls">
					<small>(<span class="updatetime"></span> 分钟统计绘图窗口, <span class="interval"></span> 秒统计间隔)</small> -
					<b>平均值</b>:
					<a href="javascript:switchAvg(1)" id="avg1">关闭</a>,
					<a href="javascript:switchAvg(2)" id="avg2">2x</a>,
					<a href="javascript:switchAvg(4)" id="avg4">4x</a>,
					<a href="javascript:switchAvg(6)" id="avg6">6x</a>,
					<a href="javascript:switchAvg(8)" id="avg8">8x</a>
					| <b>最大值</b>:
					<a href="javascript:switchScale(0)" id="scale0">统一</a> 或
					<a href="javascript:switchScale(1)" id="scale1">单独</a>
					| <b>显示方案</b>:
					<a href="javascript:switchDraw(0)" id="draw0">填充</a> 或
					<a href="javascript:switchDraw(1)" id="draw1">实线</a>
					| <b>颜色方案</b>: <a href="javascript:switchColor()" id="drawcolor">-</a>
					<small><a href="javascript:switchColor(1)" id="drawrev">[反色]</a></small>
					| <a class="ajaxload" href="admin-bwm.asp"><b>配置</b></a>
				</div><br />

				<table id="txt" class="data-table bwm-info">
					<tr>
						<td><b style="border-bottom:blue 1px solid" id="rx-name">接收</b> <i class="icon-arrow-down"></i></td>
						<td><span id="rx-current"></span></td>
						<td><b>平均</b></td>
						<td id="rx-avg"></td>
						<td><b>最大</b></td>
						<td id="rx-max"></td>
						<td><b>合计</b></td>
						<td id="rx-total"></td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td><b style="border-bottom:blue 1px solid" id="tx-name">发送</b> <i class="icon-arrow-up"></i></td>
						<td><span id="tx-current"></span></td>
						<td><b>平均</b></td>
						<td id="tx-avg"></td>
						<td><b>最大</b></td>
						<td id="tx-max"></td>
						<td><b>合计</b></td>
						<td id="tx-total"></td>
						<td>&nbsp;</td>
					</tr>
				</table>
			</div>

			<span id="dtime" style="display:none;"></span>
			<div id="warnwd" class="alert alert-warning" style="display:none">警告: 超时 10 秒钟, 重新绘图中...&nbsp;</div>
		</div>
	</div>
	<script type="text/javascript">init();</script>
</content>