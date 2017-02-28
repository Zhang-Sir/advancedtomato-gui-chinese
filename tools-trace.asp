<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>路由追踪</title>
<content>
	<style type="text/css">
		#ttr-grid .co1, #ttr-grid .co3 {
			text-align: right;
		}
		#ttr-grid .co1 {
			width: 30px;
		}
		#ttr-grid .co2 {
			width: 410px;
		}
		#ttr-grid .co4, #ttr-grid .co5, #ttr-grid .co6 {
			text-align: right;
			width: 70px;
		}
		#ttr-grid .header .co1 {
			text-align: left;
		}
	</style>
	<script type="text/javascript">
		var tracedata = '';

		var tg = new TomatoGrid();
		tg.setup = function() {
			this.init('ttr-grid');
			this.headerSet(['跃点', '地址', '最小 (ms)', '最大 (ms)', '平均 (ms)', '+/- (ms)']);
		}
		tg.populate = function() {
			var seq = 1;
			var buf = tracedata.split('\n');
			var i, j, k;
			var s, f;
			var addr, emsg, min, max, avg;
			var time;
			var last = -1;

			this.removeAllData();
			for (i = 0; i < buf.length; ++i) {
				if (!buf[i].match(/^\s*(\d+)\s+(.+)$/)) continue;
				if (RegExp.$1 != seq) continue;

				s = RegExp.$2;

				if (s.match(/^([\w\.:\-]+)\s+\(([\d\.:A-Fa-f]+)\)/)) {
					addr = RegExp.$1;
					if (addr != RegExp.$2) addr += ' (' + RegExp.$2 + ')';
				}
				else addr = '*';

				min = max = avg = '';
				change = '';
				if (time = s.match(/(\d+\.\d+) ms/g)) {		// odd: captures 'ms'
					min = 0xFFFF;
					avg = max = 0;
					k = 0;
					for (j = 0; j < time.length; ++j) {
						f = parseFloat(time[j]);
						if (isNaN(f)) continue;
						if (f < min) min = f;
						if (f > max) max = f;
						avg += f;
						++k
					}
					if (k) {
						avg /= k;
						if (last >= 0) {
							change = avg - last;
							change = change.toFixed(2);
						}
						last = avg;
						min = min.toFixed(2);
						max = max.toFixed(2);
						avg = avg.toFixed(2);
					}
					else {
						min = max = avg = '';
						last = -1;
					}
				}
				else last = -1;

				if (s.match(/ (![<>\w+-]+)/)) emsg = RegExp.$1;
				else emsg = null;

				this.insertData(-1, [seq, addr, min, max, avg, change])
				++seq;
			}

			E('debug').value = tracedata;
			tracedata = '';
			spin(0);
		}

		function verifyFields(focused, quiet)
		{
			var s;
			var e;

			e = E('_f_addr');
			s = e.value.trim();
			if (!s.match(/^[\w\-\.\:]+$/)) {
				ferror.set(e, '主机名/地址 无效', quiet);
				return 0;
			}
			ferror.clear(e);

			return v_range('_f_hops', quiet, 2, 40) && v_range('_f_wait', quiet, 2, 10);
		}

		var tracer = null;

		function spin(x)
		{
			E('traceb').disabled = x;
			E('_f_addr').disabled = x;
			E('_f_hops').disabled = x;
			E('_f_wait').disabled = x;
			E('wait').style.visibility = x ? 'visible' : 'hidden';
			if (!x) tracer = null;
		}

		function trace()
		{
			// Opera 8 sometimes sends 2 clicks
			if (tracer) return;

			if (!verifyFields(null, 0)) return;
			spin(1);
			E('trace-error').style.visibility = 'hidden';

			tracer = new XmlHttp();
			tracer.onCompleted = function(text, xml) {
				eval(text);
				tg.populate();
			}
			tracer.onError = function(x) {
				spin(0);
				E('trace-error').innerHTML = '错误: ' + E('_f_addr').value + ' - ' + x;
				E('trace-error').style.visibility = 'visible';
			}

			var addr = E('_f_addr').value;
			var hops = E('_f_hops').value;
			var wait = E('_f_wait').value;
			tracer.post('trace.cgi', 'addr=' + addr + '&hops=' + hops + '&wait=' + wait);

			cookie.set('traceaddr', addr);
			cookie.set('tracehops', hops);
			cookie.set('tracewait', wait);
		}

		function init() {
			var s;

			if ((s = cookie.get('traceaddr')) != null) E('_f_addr').value = s;
			if ((s = cookie.get('tracehops')) != null) E('_f_hops').value = s;
			if ((s = cookie.get('tracewait')) != null) E('_f_wait').value = s;

			tg.setup();
			E('_f_addr').onkeypress = function(ev) { if (checkEvent(ev).keyCode == 13) trace(); }
		}
	</script>

	<ul class="nav-tabs">
		<li><a class="ajaxload" href="tools-ping.asp"><i class="icon-ping"></i> Ping</a></li>
		<li><a class="active"><i class="icon-gauge"></i> 路由追踪</a></li>
		<li><a class="ajaxload" href="tools-shell.asp"><i class="icon-cmd"></i> 系统命令</a></li>
		<li><a class="ajaxload" href="tools-survey.asp"><i class="icon-signal"></i> 无线勘查</a></li>
		<li><a class="ajaxload" href="tools-wol.asp"><i class="icon-wake"></i> 网络唤醒</a></li>
	</ul>

	<div class="box">
		<div class="heading">路由追踪</div>
		<div class="content">

			<div id="tracert-form"></div><hr>
			<script type="text/javascript">
				$('#tracert-form').forms([
					{ title: '地址', name: 'f_addr', type: 'text', maxlen: 64, size: 32, value: '',
						suffix: ' <button type="submit" value="追踪" onclick="trace()" id="traceb" class="btn">追踪 <i class="icon-gauge"></i></button>' },
					{ title: '最大跃点数', name: 'f_hops', type: 'text', maxlen: 2, size: 4, value: '20' },
					{ title: '最大等待时间', name: 'f_wait', type: 'text', maxlen: 2, size: 4, value: '3', suffix: ' <small>(每跳秒数)</small>' }
				]);
			</script>

			<div style="visibility:hidden" id="trace-error"></div>
			<div style="visibility:hidden;text-align:right" id="wait">请稍等... <div class="spinner"></div></div>
			<table id="ttr-grid" class="line-table"></table>

			<div style="height:10px;" onclick="javascript:E('debug').style.display=''"></div>
			<textarea id="debug" style="width:99%;height:300px;display:none"></textarea>
		</div>
	</div>

	<script type="text/javascript">init();</script>
</content>