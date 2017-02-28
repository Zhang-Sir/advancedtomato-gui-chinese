<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>定时任务</title>
<content>
	<style type="text/css">
		textarea {
			width: 95%;
		}
		.empty {
			height: 2em;
		}
	</style>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,sch_rboot,sch_rcon,sch_c1,sch_c1_cmd,sch_c2,sch_c2_cmd,sch_c3,sch_c3_cmd,sch_c4,sch_c4_cmd,sch_c5,sch_c5_cmd"); %>

		var dowNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
		var dowLow = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
		var scheds = []

		tm = [];
		tm.push([0, timeString(0)]);
		tm.push([1, timeString(1)]);
		for (i = 15; i < 1440; i += 15) {
			tm.push([i, timeString(i)]);
		}
		tm.push([1439, timeString(1439)]);

		tm.push(
			[-1, '每分钟'], [-3, '每3分钟'], [-5, '每5分钟'], [-15, '每15分钟'], [-30, '每30分钟'],
			[-60, '每小时'], [-(12 * 60), '每12小时'], [-(24 * 60), '每24小时'],
			['e', '每隔...']);

		/* REMOVE-BEGIN

		sch_* = en,time,days

		REMOVE-END */

		function makeSched(key, custom)
		{
			var s, v, w, a, t, i;
			var oe;

			scheds.push(key);

			s = nvram['sch_' + key] || '';
			if ((v = s.match(/^(0|1),(-?\d+),(\d+)$/)) == null) {
				v = custom ? ['', 0, -30, 0] : ['', 0, 0, 0];
			}
			w = v[3] * 1;
			if (w <= 0) w = 0xFF;

			orgkey = key;
			key = key + '_';

			if (custom) {
				t = tm;
			}
			else {
				t = [];
				for (i = 0; i < tm.length; ++i) {
					if ((tm[i][0] >= 0) || (tm[i][0] <= -60) || (tm[i][0] == 'e')) t.push(tm[i]);
				}
			}

			oe = 1;
			for (i = 0; i < t.length; ++i) {
				if (v[2] == t[i][0]) {
					oe = 0;
					break;
				}
			}

			a = [
				{ title: '启用', name: key + 'enabled', type: 'checkbox', value: v[1] == '1' },
				{ title: '时间', multi: [
					{ name: key + 'time', type: 'select', options: t, value: oe ? 'e' : v[2] },
					{ name: key + 'every', type: 'text', maxlen: 10, size: 10, value: (v[2] < 0) ? -v[2] : 30,
						prefix: ' ', suffix: ' <small id="_' + key + 'mins"><i>分钟</i></small>' } ] },
				{ title: '天', multi: [
					{ name: key + 'sun', type: 'checkbox', suffix: ' 星期日 &nbsp; ', value: w & 1 },
					{ name: key + 'mon', type: 'checkbox', suffix: ' 星期一 &nbsp; ', value: w & 2 },
					{ name: key + 'tue', type: 'checkbox', suffix: ' 星期二 &nbsp; ', value: w & 4 },
					{ name: key + 'wed', type: 'checkbox', suffix: ' 星期三 &nbsp; ', value: w & 8 },
					{ name: key + 'thu', type: 'checkbox', suffix: ' 星期四 &nbsp; ', value: w & 16 },
					{ name: key + 'fri', type: 'checkbox', suffix: ' 星期五 &nbsp; ', value: w & 32 },
					{ name: key + 'sat', type: 'checkbox', suffix: ' 星期六 &nbsp; &nbsp;', value: w & 64 },
					{ name: key + 'everyday', type: 'checkbox', suffix: ' 每天', value: (w & 0x7F) == 0x7F } ] }
			];

			if (custom) {
				a.push({ title: '命令', name: 'sch_' + key + 'cmd', type: 'textarea', value: nvram['sch_' + key + 'cmd' ] });
			}

			$('.content.' + orgkey).forms(a);
		}

		function verifySched(focused, quiet, key)
		{
			var e, f, i, n, b;
			var eTime, eEvery, eEveryday, eCmd;

			key = '_' + key + '_';

			eTime = E(key + 'time');
			eEvery = E(key + 'every');
			eEvery.style.visibility = E(key + 'mins').style.visibility = (eTime.value == 'e') ? 'visible' : 'hidden';

			eCmd = E('_sch' + key + 'cmd');
			eEveryday = E(key + 'everyday');

			if (E(key + 'enabled').checked) {
				eEveryday.disabled = 0;
				eTime.disabled = 0;
				eEvery.disabled = 0;
				if (eCmd) eCmd.disabled = 0;

				if (focused == eEveryday) {
					for (i = 0; i < 7; ++i) {
						f = E(key + dowLow[i]);
						f.disabled = 0;
						f.checked = eEveryday.checked;
					}
				}
				else {
					n = 0;
					for (i = 0; i < 7; ++i) {
						f = E(key + dowLow[i]);
						f.disabled = 0;
						if (f.checked) ++n;
					}
					eEveryday.checked = (n == 7);
				}

				if ((eTime.value == 'e') && (!v_mins(eEvery, quiet, eCmd ? 1 : 60, 60 * 24 * 60))) return 0;

				if ((eCmd) && (!v_length(eCmd, quiet, quiet ? 0 : 1, 2048))) return 0;
			}
			else {
				eEveryday.disabled = 1;
				eTime.disabled = 1;
				eEvery.disabled = 1;
				for (i = 0; i < 7; ++i) {
					E(key + dowLow[i]).disabled = 1;
				}
				if (eCmd) eCmd.disabled = 1;
			}

			if (eCmd) {
				if ((eCmd.value.length) || (!eTime.disabled)) {
					elem.removeClass(eCmd, 'empty');
				}
				else {
					elem.addClass(eCmd, 'empty');
				}
			}

			return 1;
		}

		function verifyFields(focused, quiet)
		{
			for (var i = 0; i < scheds.length; ++i) {
				if (!verifySched(focused, quiet, scheds[i])) return 0;
			}
			return 1;
		}

		function saveSched(fom, key)
		{
			var s, i, n, k, en, e;

			k = '_' + key + '_';

			en = E(k + 'enabled').checked;
			s = en ? '1' : '0';
			s += ',';

			e = E(k + 'time').value;
			if (e == 'e') s += -(E(k + 'every').value * 1);
			else s += e;

			n = 0;
			for (i = 0; i < 7; ++i) {
				if (E(k + dowLow[i]).checked) n |= (1 << i);
			}
			if (n == 0) {
				n = 0x7F;
				e = E(k + 'everyday');
				e.checked = 1;
				verifySched(e, key);
			}

			e = fom['sch_' + key];
			e.value = s + ',' + n;
		}

		function save()
		{
			var fom, i

			if (!verifyFields(null, false)) return;

			fom = E('_fom');
			for (i = 0; i < scheds.length; ++i) {
				saveSched(fom, scheds[i]);
			}

			form.submit(fom, 1);
		}

		function init() {
			verifyFields(null, 1);
		}
	</script>

	<form name="_fom" id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#admin-sched.asp">
		<input type="hidden" name="_service" value="sched-restart">
		<input type="hidden" name="sch_rboot" value="">
		<input type="hidden" name="sch_rcon" value="">
		<input type="hidden" name="sch_c1" value="">
		<input type="hidden" name="sch_c2" value="">
		<input type="hidden" name="sch_c3" value="">
		<input type="hidden" name="sch_c4" value="">
		<input type="hidden" name="sch_c5" value="">

		<div class="box" data-box="sched-reboot">
			<div class="heading">重启路由器</div>
			<div class="content rboot"></div>
		</div>
		<script type="text/javascript">
			makeSched("rboot");
		</script>


		<div class="box" data-box="sched-reconnect">
			<div class="heading">重新连接</div>
			<div class="content rcon"></div>
			<script type="text/javascript">
				makeSched("rcon");
			</script>
		</div>

		<div class="box" data-box="sched-cust1">
			<div class="heading">自定义 1</div>
			<div class="content c1"></div>
			<script type="text/javascript">
				makeSched("c1", 1);
			</script>
		</div>

		<div class="box" data-box="sched-cust2">
			<div class="heading">自定义 2</div>
			<div class="content c2"></div>
			<script type="text/javascript">
				makeSched("c2", 1);
			</script>
		</div>

		<div class="box" data-box="sched-cust3">
			<div class="heading">自定义 3</div>
			<div class="content c3"></div>
			<script type="text/javascript">
				makeSched("c3", 1);
			</script>
		</div>

		<div class="box" data-box="sched-cust4">
			<div class="heading">自定义 4</div>
			<div class="content c4"></div>
			<script type="text/javascript">
				makeSched("c4", 1);
			</script>
		</div>

		<div class="box" data-box="sched-cust5">
			<div class="heading">自定义 5</div>
			<div class="content c5"></div>
			<script type="text/javascript">
				makeSched("c5", 1);
			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>
	<script type="text/javascript">init();</script>
</content>