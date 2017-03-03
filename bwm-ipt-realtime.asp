<!DOCTYPE html>
<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>IP 流量监控: 实时 IP 流量</title>
<content>
	<style type="text/css">
		table tr td:nth-child(even) { width: 25%; }
		table tr td:nth-child(odd) { width: 5%; }
		hr { margin: 0 5px 8px; }
	</style>
	<script type="text/javascript" src="js/wireless.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript" src="js/bwm-common.js"></script>
	<script type="text/javascript" src="js/interfaces.js"></script>
	<script type="text/javascript">
		//	<% nvram("wan_ifname,wan_proto,wan_iface,wan2_ifname,wan2_proto,wan2_iface,wan3_ifname,wan3_proto,wan3_iface,wan4_ifname,wan4_proto,wan4_iface,lan_ifname,wl_ifname,web_svg,cstats_enable,cstats_colors,dhcpd_static,lan_ipaddr,lan_netmask,lan1_ipaddr,lan1_netmask,lan2_ipaddr,lan2_netmask,lan3_ipaddr,lan3_netmask,cstats_labels"); %>
		//	<% devlist(); %>

		var cprefix = 'ipt_';
		var updateInt = 2;
		var updateDiv = updateInt;
		var updateMaxL = 300;
		var updateReTotal = 1;
		var prev = [];
		var debugTime = 0;
		var avgMode = 0;
		var wdog = null;
		var wdogWarn = null;
		var cstats_busy = 0;

		var ipt_addr_shown = [];
		var ipt_addr_hidden = [];

		hostnamecache = [];

		var ref = new TomatoRefresh('/update.cgi', 'exec=iptmon', updateInt);

		ref.stop = function() {
			this.timer.start(1000);
		}

		ref.refresh = function(text) {
			var c, i, h, n, j, k, l;

			watchdogReset();

			++updating;
			try {
				iptmon = null;
				eval(text);

				n = (new Date()).getTime();
				if (this.timeExpect) {
					if (debugTime) $('#dtime').show().html((this.timeExpect - n) + ' ' + ((this.timeExpect + 1000*updateInt) - n));
					this.timeExpect += 1000*updateInt;
					this.refreshTime = MAX(this.timeExpect - n, 500);
				}
				else {
					this.timeExpect = n + 1000*updateInt;
				}

				for (i in iptmon) {
					c = iptmon[i];
					if ((p = prev[i]) != null) {
						h = speed_history[i];

						h.rx.splice(0, 1);
						h.rx.push((c.rx < p.rx) ? (c.rx + (0xFFFFFFFF - p.rx)) : (c.rx - p.rx));

						h.tx.splice(0, 1);
						h.tx.push((c.tx < p.tx) ? (c.tx + (0xFFFFFFFF - p.tx)) : (c.tx - p.tx));
						h.count++;
						if (h.count > updateMaxL) h.count = updateMaxL;
					}
					else if (!speed_history[i]) {
						speed_history[i] = {};
						h = speed_history[i];
						h.rx = [];
						h.tx = [];
						for (j = updateMaxL; j > 0; --j) {
							h.rx.push(0);
							h.tx.push(0);
						}
						h.count = 0;
						h.hide = 0;
					}
					prev[i] = c;

					if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && (i.trim() != '')) {
						ipt_addr_shown.push(i);
						var option=document.createElement("option");
						option.value=i;
						if (hostnamecache[i] != null) {
							option.text = hostnamecache[i] + ' (' + i + ')';
						} else {
							option.text=i;
						}
						E('_f_ipt_addr_shown').add(option,null);
					}

					if (ipt_addr_hidden.find(i) != -1) {
						speed_history[i].hide = 1;
					} else {
						speed_history[i].hide = 0;
					}

					verifyFields(null,1);

				}
				loadData();
			}
			catch (ex) {
				/* REMOVE-BEGIN
				//			alert('ex=' + ex);
				REMOVE-END */
			}
			--updating;
		}

		function watchdog() {
			watchdogReset();
			ref.stop();
			wdogWarn.style.display = '';
		}

		function watchdogReset() {
			if (wdog) clearTimeout(wdog)
			wdog = setTimeout(watchdog, 5000*updateInt);
			wdogWarn.style.display = 'none';
		}

		function init() {

			if (nvram.cstats_enable != '1') {
				$('.cstats').before('<div class="alert alert-info">IP 流量监控已禁用.</b> <a href="/#admin-iptraffic.asp">启用 &raquo;</a>');
				return;
			}

			populateCache();

			speed_history = [];

			initCommon(2, 1, 1);

			wdogWarn = E('warnwd');
			watchdogReset();

			var c;
			if ((c = cookie.get('ipt_addr_hidden')) != null) {
				c = c.split(',');
				for (var i = 0; i < c.length; ++i) {
					if (c[i].trim() != '') {
						ipt_addr_hidden.push(c[i]);
						var option=document.createElement("option");
						option.value=c[i];
						if (hostnamecache[c[i]] != null) {
							option.text = hostnamecache[c[i]] + ' (' + c[i] + ')';
						} else {
							option.text = c[i];
						}
						E('_f_ipt_addr_hidden').add(option,null);
					}
				}
			}

			$('.updatetime').html(5*updateInt);
			$('.interval').html(updateInt);

			verifyFields(null,1);

			ref.start();
		}

		function verifyFields(focused, quiet) {
			var changed_addr_hidden = 0;
			if (focused != null) {
				if (focused.id == '_f_ipt_addr_shown') {
					ipt_addr_shown.remove(focused.options[focused.selectedIndex].value);
					ipt_addr_hidden.push(focused.options[focused.selectedIndex].value);
					var option=document.createElement("option");
					option.text=focused.options[focused.selectedIndex].text;
					option.value=focused.options[focused.selectedIndex].value;
					E('_f_ipt_addr_shown').remove(focused.selectedIndex);
					E('_f_ipt_addr_shown').selectedIndex=0;
					E('_f_ipt_addr_hidden').add(option,null);
					changed_addr_hidden = 1;
				}

				if (focused.id == '_f_ipt_addr_hidden') {
					ipt_addr_hidden.remove(focused.options[focused.selectedIndex].value);
					ipt_addr_shown.push(focused.options[focused.selectedIndex].value);
					var option=document.createElement("option");
					option.text=focused.options[focused.selectedIndex].text;
					option.value=focused.options[focused.selectedIndex].value;
					E('_f_ipt_addr_hidden').remove(focused.selectedIndex);
					E('_f_ipt_addr_hidden').selectedIndex=0;
					E('_f_ipt_addr_shown').add(option,null);
					changed_addr_hidden = 1;
				}
				if (changed_addr_hidden == 1) {
					cookie.set('ipt_addr_hidden', ipt_addr_hidden.join(','), 1);
				}
			}

			if (E('_f_ipt_addr_hidden').length < 2) {
				E('_f_ipt_addr_hidden').disabled = 1;
			} else {
				E('_f_ipt_addr_hidden').disabled = 0;
			}

			if (E('_f_ipt_addr_shown').length < 2) {
				E('_f_ipt_addr_shown').disabled = 1;
			} else {
				E('_f_ipt_addr_shown').disabled = 0;
			}

			return 1;
		}
	</script>

	<ul class="nav-tabs">
		<li><a class="active"><i class="icon-hourglass"></i> 实时</a></li>
		<li><a class="ajaxload" href="bwm-ipt-24.asp"><i class="icon-clock"></i> 最近24小时</a></li>
		<li><a class="ajaxload" href="bwm-ipt-graphs.asp"><i class="icon-graphs"></i> 查看图表</a></li>
		<li><a class="ajaxload" href="bwm-ipt-details.asp"><i class="icon-globe"></i> 传输速率</a></li>
		<li><a class="ajaxload" href="bwm-ipt-daily.asp"><i class="icon-clock"></i> 每天</a></li>
		<li><a class="ajaxload" href="bwm-ipt-monthly.asp"><i class="icon-month"></i> 每月</a></li>
	</ul>

	<div id="cstats" class="box">
		<div class="heading">实时 IP 流量监控 &nbsp; <div class="spinner" id="refresh-spinner" onclick="javascript:debugTime=1"></div></div>
		<div class="content">
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
				<a href="javascript:switchAvg(8)" id="avg8">8x</a> |
				<b>最大值</b>:
				<a href="javascript:switchScale(0)" id="scale0">统一</a> 或
				<a href="javascript:switchScale(1)" id="scale1">单独</a> |
				<b>显示方案</b>:
				<a href="javascript:switchDraw(0)" id="draw0">填充</a> 或
				<a href="javascript:switchDraw(1)" id="draw1">实线</a> |
				<b>颜色方案</b>: <a href="javascript:switchColor()" id="drawcolor">-</a> |
				<small><a href="javascript:switchColor(1)" id="drawrev">[反色]</a></small>
				| <a class="ajaxload" href="admin-iptraffic.asp"><b>配置</b></a>
			</div>

			<table id="txt" class="data-table bwm-info">
				<tr>
					<td><b style="border-bottom:blue 2px solid" id="rx-name">接收</b> <i class="icon-arrow-down"></i></td>
					<td><span id="rx-current"></span></td>
					<td><b>平均值</b></td>
					<td id="rx-avg"></td>
					<td><b>最大值</b></td>
					<td id="rx-max"></td>
					<td><b>合计</b></td>
					<td id="rx-total"></td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td><b style="border-bottom:blue 2px solid" id="tx-name">发送</b> <i class="icon-arrow-up"></i></td>
					<td><span id="tx-current"></span></td>
					<td><b>平均值</b></td>
					<td id="tx-avg"></td>
					<td><b>最大值</b></td>
					<td id="tx-max"></td>
					<td><b>合计</b></td>
					<td id="tx-total"></td>
					<td>&nbsp;</td>
				</tr>
			</table>

			

			<hr><div id="options"></div>
			<script type="text/javascript">
				$('#options').forms([
					{ title: '隐藏设备', name: 'f_ipt_addr_shown', type: 'select', options: [[0,'选择']], suffix: ' &nbsp; <small>(点击/选择 从该列表中隐藏设备)</small>' },
					{ title: '显示设备', name: 'f_ipt_addr_hidden', type: 'select', options: [[0,'选择']], suffix: ' &nbsp; <small>(点击/选择 显示已隐藏的设备)</small>' }
				]);
			</script>

			<span id="dtime" style="display:none;"></span>
			<div class="alert alert-warning" id="warnwd" style="display:none">警告：10秒超时，重新启动...&nbsp;</div>
		</div>
	</div>
	<script type="text/javascript">init();</script>
</content>
