<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

IP Traffic enhancements
Copyright (C) 2011 Augusto Bott
http://code.google.com/p/tomato-sdhc-vlan/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>IP 流量监控:最近24小时</title>
<content>
	<style type="text/css">
		table tr td:nth-child(even) { width: 25%; }
		table tr td:nth-child(odd) { width: 5%; }
		hr { margin: 0 5px 8px; }
	</style>
	<script type="text/javascript" src="js/wireless.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript" src="js/bwm-common.js"></script>
	<script type="text/javascript" src="js/bwm-hist.js"></script>
	<script type="text/javascript" src="js/interfaces.js"></script>
	<script type="text/javascript">
		//	<% nvram("wan_ifname,wan_proto,wan_iface,wan2_ifname,wan2_proto,wan2_iface,wan3_ifname,wan3_proto,wan3_iface,wan4_ifname,wan4_proto,wan4_iface,lan_ifname,wl_ifname,web_svg,cstats_enable,cstats_colors,dhcpd_static,lan_ipaddr,lan_netmask,lan1_ipaddr,lan1_netmask,lan2_ipaddr,lan2_netmask,lan3_ipaddr,lan3_netmask,cstats_labels"); %>
		//	<% devlist(); %>

		var cprefix = 'ipt_';
		var updateInt = 120;
		var updateDiv = updateInt;
		var updateMaxL = 720;
		var updateReTotal = 1;
		var hours = 24;
		var lastHours = 0;
		var debugTime = 0;

		var ipt_addr_shown = [];
		var ipt_addr_hidden = [];

		hostnamecache = [];

		function showHours() {
			if (hours == lastHours) return;
			showSelectedOption('hr', lastHours, hours);
			lastHours = hours;
		}

		function switchHours(h) {
			if ((!svgReady) || (updating)) return;

			hours = h;
			updateMaxL = (720 / 24) * hours;
			showHours();
			loadData();
			cookie.set(cprefix + 'hrs', hours);
		}

		var ref = new TomatoRefresh('/update.cgi', 'exec=ipt_bandwidth&arg0=speed');

		ref.refresh = function(text) {
			++updating;
			try {
				this.refreshTime = 1500;
				speed_history = {};
				try {
					eval(text);

					var i;
					for (i in speed_history) {
						if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && (i != '_next')) {
							ipt_addr_shown.push(i);
							var option=document.createElement("option");
							option.value=i;
							if (hostnamecache[i] != null) {
								option.text = hostnamecache[i] + ' (' + i + ')';
							} else {
								option.text=i;
							}
							E('_f_ipt_addr_shown').add(option,null);
							speed_history[i].hide = 0;
						}

						if (ipt_addr_hidden.find(i) != -1) {
							speed_history[i].hide = 1;
						} else {
							speed_history[i].hide = 0;
						}
					}

					if (cstats_busy) {
						E('rbusy').style.display = 'none';
						cstats_busy = 0;
					}
					this.refreshTime = (fixInt(speed_history._next, 1, 120, 60) + 2) * 1000;
				} catch (ex) {
					speed_history = {};
					cstats_busy = 1;
					E('rbusy').style.display = '';
				}
				if (debugTime) E('dtime').innerHTML = (ymdText(new Date())) + ' ' + (this.refreshTime / 1000);

				loadData();
			}
			catch (ex) {
				/* REMOVE-BEGIN
				//		alert('ex=' + ex);
				REMOVE-END */
			}
			--updating;
		}

		ref.toggleX = function() {
			this.toggle();
			$('#refresh-but').html('<i class="icon-' + (this.running ? 'stop' : 'reboot') + '"></i>');
			cookie.set(cprefix + 'refresh', this.running ? 1 : 0);
		}

		ref.initX = function() {
			var a;

			a = fixInt(cookie.get(cprefix + 'refresh'), 0, 1, 1);
			if (a) {
				ref.refreshTime = 100;
				ref.toggleX();
			}
		}

		function init() {

			if (nvram.cstats_enable != '1') {
				$('.cstats').before('<div class="alert alert-info">IP 流量监控已禁用.</b> <a href="/#admin-iptraffic.asp">启用 &raquo;</a>');
				return;
			}

			populateCache();

			var c,i;
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

			try {
				//	<% ipt_bandwidth("speed"); %>

				for (i in speed_history) {
					if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && ( i != '_next') && (i.trim() != '')) {
						ipt_addr_shown.push(i);
						var option=document.createElement("option");
						var ii = i;
						if (hostnamecache[i] != null) {
							ii = hostnamecache[i] + ' (' + i + ')';
						}
						option.text=ii;
						option.value=i;
						E('_f_ipt_addr_shown').add(option,null);
						speed_history[i].hide = 0;
					}
					if (ipt_addr_hidden.find(i) != -1) {
						speed_history[i].hide = 1;
					} else {
						speed_history[i].hide = 0;
					}
				}
			}
			catch (ex) {
				/* REMOVE-BEGIN
				//		speed_history = {};
				REMOVE-END */
			}
			cstats_busy = 0;
			if (typeof(speed_history) == 'undefined') {
				speed_history = {};
				cstats_busy = 1;
				E('rbusy').style.display = '';
			}

			hours = fixInt(cookie.get(cprefix + 'hrs'), 1, 24, 24);
			updateMaxL = (720 / 24) * hours;
			showHours();

			initCommon(1, 0, 0);

			verifyFields(null,1);

			ref.initX();
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
					if (!ref.running) {
						ref.once = 1;
						ref.start();
					} else {
						ref.stop();
						ref.start();
					}
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
		<li><a class="ajaxload" href="bwm-ipt-realtime.asp"><i class="icon-hourglass"></i> 实时</a></li>
		<li><a class="active"><i class="icon-clock"></i> 最近24小时</a></li>
		<li><a class="ajaxload" href="bwm-ipt-graphs.asp"><i class="icon-graphs"></i> 查看图表</a></li>
		<li><a class="ajaxload" href="bwm-ipt-details.asp"><i class="icon-globe"></i> 传输速率</a></li>
		<li><a class="ajaxload" href="bwm-ipt-daily.asp"><i class="icon-clock"></i> 每天</a></li>
		<li><a class="ajaxload" href="bwm-ipt-monthly.asp"><i class="icon-month"></i> 每月</a></li>
	</ul>

	<div id="cstats" class="box">
		<div class="heading">
			24小时 IP 流量历史 &nbsp; <div class="spinner" id="refresh-spinner" style="visibility:hidden;" onclick="debugTime=1"></div>
			<a href="#" data-toggle="tooltip" onclick="ref.toggleX(); return false;" title="自动刷新图形" class="pull-right" id="refresh-but"><i class="icon-refresh"></i></a>
		</div>
		<div class="content">
			<div id="tab-area" class="btn-toolbar"></div>

			<script type="text/javascript">
				if ((nvram.web_svg != '0') && (nvram.cstats_enable == '1')) {
					// without a div, Opera 9 moves svgdoc several pixels outside of <embed> (?)
					$('#tab-area').after('<embed id="graph" type="image/svg+xml" src="img/bwm-graph.svg?<% version(); %>" style="height: 300px; width:100%;"></embed>');
				}
			</script>

			<div id="bwm-controls">
				<small>(2 分钟间隔)</small> -
				<b>单位(小时)</b>:
				<a href="javascript:switchHours(1);" id="hr1">1</a>,
				<a href="javascript:switchHours(2);" id="hr2">2</a>,
				<a href="javascript:switchHours(4);" id="hr4">4</a>,
				<a href="javascript:switchHours(6);" id="hr6">6</a>,
				<a href="javascript:switchHours(12);" id="hr12">12</a>,
				<a href="javascript:switchHours(18);" id="hr18">18</a>,
				<a href="javascript:switchHours(24);" id="hr24">24</a>
				| <b>平均值</b>:
				<a href="javascript:switchAvg(1)" id="avg1">Off</a>,
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
				<small><a href="javascript:switchColor(1)" id="drawrev">[反色]</a></small> |
				<a class="ajaxload" href="admin-iptraffic.asp"><b>配置</b></a>
			</div>

			<table id="txt" class="data-table bwm-info">
				<tr>
					<td><b style="border-bottom:blue 1px solid" id="rx-name">接收</b> <i class="icon-arrow-down"></i></td>
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
					<td><b style="border-bottom:blue 1px solid" id="tx-name">发送</b> <i class="icon-arrow-up"></i></td>
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

			<hr><div id="settings"></div>
			<script type="text/javascript">
				$('#settings').forms([
					{ title: '隐藏设备', name: 'f_ipt_addr_shown', type: 'select', options: [[0,'选择']], suffix: '&nbsp; <small>( (点击/选择 从该列表中隐藏设备))</small>' },
					{ title: '显示设置', name: 'f_ipt_addr_hidden', type: 'select', options: [[0,'选择']], suffix: '&nbsp; <small>((点击/选择 显示已隐藏的设备))</small>' }
				]);
			</script>

			<span id="dtime"></span>
			<div class="alert alert-warning" style="display:none" id="rbusy">程序忙或没有响应，几秒钟后重新加载.</div>
		</div>
	</div>

	<script type="text/javascript">init();</script>
</content>