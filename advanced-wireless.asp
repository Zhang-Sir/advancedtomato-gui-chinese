<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>无线设置</title>
<content>
	<script type="text/javascript" src="js/wireless.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript">
		//	<% nvram("at_update,tomatoanon_answer,wl_security_mode,wl_afterburner,wl_antdiv,wl_ap_isolate,wl_auth,wl_bcn,wl_dtim,wl_frag,wl_frameburst,wl_gmode_protection,wl_plcphdr,wl_rate,wl_rateset,wl_rts,wl_txant,wl_wme,wl_wme_no_ack,wl_wme_apsd,wl_txpwr,wl_mrate,t_features,wl_distance,wl_maxassoc,wlx_hpamp,wlx_hperx,wl_reg_mode,wl_country_code,wl_country,wl_btc_mode,wl_mimo_preamble,wl_obss_coex,wl_mitigation,wl_interference_override,wl_wmf_bss_enable"); %>
		//	<% wlcountries(); %>

		hp = features('hpamp');
		nphy = features('11n');

		function verifyFields(focused, quiet)
		{
			for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
				//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
				if (wl_sunit(uidx)<0) {
					var u = wl_unit(uidx);

					if (!v_range('_f_wl'+u+'_distance', quiet, 0, 99999)) return 0;
					if (!v_range('_wl'+u+'_maxassoc', quiet, 0, 255)) return 0;
					if (!v_range('_wl'+u+'_bcn', quiet, 1, 65535)) return 0;
					if (!v_range('_wl'+u+'_dtim', quiet, 1, 255)) return 0;
					if (!v_range('_wl'+u+'_frag', quiet, 256, 2346)) return 0;
					if (!v_range('_wl'+u+'_rts', quiet, 0, 2347)) return 0;
					if (!v_range(E('_wl'+u+'_txpwr'), quiet, hp ? 1 : 0, hp ? 251 : 400)) return 0;

					var b = E('_wl'+u+'_wme').value == 'off';
					E('_wl'+u+'_wme_no_ack').disabled = b;
					E('_wl'+u+'_wme_apsd').disabled = b;
				}
			}

			return 1;
		}

		function save()
		{
			var fom;
			var n;

			if (!verifyFields(null, false)) return;

			fom = E('_fom');

			for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
				if (wl_sunit(uidx)<0) {
					var u = wl_unit(uidx);

					n = E('_f_wl'+u+'_distance').value * 1;
					E('_wl'+u+'_distance').value = n ? n : '';

					E('_wl'+u+'_country').value = E('_wl'+u+'_country_code').value;
					E('_wl'+u+'_nmode_protection').value = E('_wl'+u+'_gmode_protection').value;
				}
			}

			if (hp) {
				if ((E('_wlx_hpamp').value != nvram.wlx_hpamp) || (E('_wlx_hperx').value != nvram.wlx_hperx)) {
					fom._service.disabled = 1;
					fom._reboot.value = 1;
					form.submit(fom, 0);
					return;
				}
			}
			else {
				E('_wlx_hpamp').disabled = 1;
				E('_wlx_hperx').disabled = 1;
			}

			form.submit(fom, 1);
		}
	</script>

	<form id="_fom" method="post" action="tomato.cgi">
	<input type="hidden" name="_nextpage" value="/#advanced-wireless.asp">
	<input type="hidden" name="_nextwait" value="10">
	<input type="hidden" name="_service" value="*">
	<input type="hidden" name="_reboot" value="0">

	<div id="formfields"></div>
	<script type="text/javascript">
		var htmlOut = ''
		for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
			if (wl_sunit(uidx)<0) {
				var u = wl_unit(uidx);

				htmlOut += ('<input type=\'hidden\' id=\'_wl'+u+'_distance\' name=\'wl'+u+'_distance\'>');
				htmlOut += ('<input type=\'hidden\' id=\'_wl'+u+'_country\' name=\'wl'+u+'_country\'>');
				htmlOut += ('<input type=\'hidden\' id=\'_wl'+u+'_nmode_protection\' name=\'wl'+u+'_nmode_protection\'>');

				htmlOut += ('<div class="box"><div class="heading">无线网络设置 ');
				//if (wl_ifaces.length > 1)
				htmlOut += ('(' + wl_display_ifname(uidx) + ') ');
				//W('');
				htmlOut += ('</div><div class="content">');

				at = ((nvram['wl'+u+'_security_mode'] != "wep") && (nvram['wl'+u+'_security_mode'] != "radius") && (nvram['wl'+u+'_security_mode'] != "disabled"));
				htmlOut += createFormFields([
					{ title: 'Afterburner', name: 'wl'+u+'_afterburner', type: 'select', options: [['auto','自动'],['on','启用'],['off','禁用 *']],
						value: nvram['wl'+u+'_afterburner'] },
					{ title: 'AP 隔离', name: 'wl'+u+'_ap_isolate', type: 'select', options: [['0','禁用 *'],['1','启用']],
						value: nvram['wl'+u+'_ap_isolate'] },
					{ title: '认证类型', name: 'wl'+u+'_auth', type: 'select',
						options: [['0','自动 *'],['1','共享密钥']], attrib: at ? 'disabled' : '',
						value: at ? 0 : nvram['wl'+u+'_auth'] },
					{ title: '基本速率', name: 'wl'+u+'_rateset', type: 'select', options: [['default','默认 *'],['12','1-2 Mbps'],['all','全部']],
						value: nvram['wl'+u+'_rateset'] },
					{ title: '信标间隔', name: 'wl'+u+'_bcn', type: 'text', maxlen: 5, size: 7,
						suffix: ' <small>(范围: 1 - 65535; 默认: 100)</small>', value: nvram['wl'+u+'_bcn'] },
					{ title: 'CTS 保护模式', name: 'wl'+u+'_gmode_protection', type: 'select', options: [['off','禁用 *'],['auto','自动']],
						value: nvram['wl'+u+'_gmode_protection'] },
					{ title: 'Regulatory 模式', name: 'wl'+u+'_reg_mode', type: 'select',
						options: [['off', '禁用 *'],['d', '802.11d'],['h', '802.11h']],
						value: nvram['wl'+u+'_reg_mode'] },
					{ title: '国家 / 地区', name: 'wl'+u+'_country_code', type: 'select',
						options: wl_countries, value: nvram['wl'+u+'_country_code'] },
					{ title: '蓝牙共存', name: 'wl'+u+'_btc_mode', type: 'select',
						options: [['0', '禁用 *'],['1', '启用'],['2', '取代']],
						value: nvram['wl'+u+'_btc_mode'] },
					{ title: '距离 / ACK响应调整', name: 'f_wl'+u+'_distance', type: 'text', maxlen: 5, size: 7,
						suffix: ' <small>米</small>&nbsp;&nbsp;<small>(范围: 0 - 99999; 默认: 0)</small>',
						value: (nvram['wl'+u+'_distance'] == '') ? '0' : nvram['wl'+u+'_distance'] },
					{ title: 'DTIM 间隔', name: 'wl'+u+'_dtim', type: 'text', maxlen: 3, size: 5,
						suffix: ' <small>(范围: 1 - 255; 默认: 1)</small>', value: nvram['wl'+u+'_dtim'] },
					{ title: '分片阈值', name: 'wl'+u+'_frag', type: 'text', maxlen: 4, size: 6,
						suffix: ' <small>(范围: 256 - 2346; 默认: 2346)</small>', value: nvram['wl'+u+'_frag'] },
					{ title: '帧突发技术', name: 'wl'+u+'_frameburst', type: 'select', options: [['off','禁用 *'],['on','启用']],
						value: nvram['wl'+u+'_frameburst'] },
					{ title: '高功率', hidden: !hp || (uidx > 0) },
					{ title: '功率放大器', indent: 2, name: 'wlx_hpamp' + (uidx > 0 ? uidx + '' : ''), type: 'select', options: [['0','禁用'],['1','启用 *']],
						value: nvram.wlx_hpamp != '0', hidden: !hp || (uidx > 0) },
					{ title: '增强接收敏感度', indent: 2, name: 'wlx_hperx' + (uidx > 0 ? uidx + '' : ''), type: 'select', options: [['0','禁用 *'],['1','启用']],
						value: nvram.wlx_hperx != '0', hidden: !hp || (uidx > 0) },
					{ title: '最大无线客户端数量', name: 'wl'+u+'_maxassoc', type: 'text', maxlen: 3, size: 5,
						suffix: ' <small>(范围: 1 - 255; 默认: 128)</small>', value: nvram['wl'+u+'_maxassoc'] },
					{ title: '组播速率', name: 'wl'+u+'_mrate', type: 'select',
						options: [['0','自动 *'],['1000000','1 Mbps'],['2000000','2 Mbps'],['5500000','5.5 Mbps'],['6000000','6 Mbps'],['9000000','9 Mbps'],['11000000','11 Mbps'],['12000000','12 Mbps'],['18000000','18 Mbps'],['24000000','24 Mbps'],['36000000','36 Mbps'],['48000000','48 Mbps'],['54000000','54 Mbps']],
						value: nvram['wl'+u+'_mrate'] },
					{ title: '前导信号', name: 'wl'+u+'_plcphdr', type: 'select', options: [['long','长 *'],['short','短']],
						value: nvram['wl'+u+'_plcphdr'] },
					{ title: '802.11n 报头', name: 'wl'+u+'_mimo_preamble', type: 'select', options: [['auto','自动'],['mm','混合模式 *'],['gf','Green Field'],['gfbcm','GF-BRCM']],
						value: nvram['wl'+u+'_mimo_preamble'], hidden: !nphy },
					{ title: '重叠的 BSS 共存', name: 'wl'+u+'_obss_coex', type: 'select', options: [['0','禁用 *'],['1','启用']],
						value: nvram['wl'+u+'_obss_coex'], hidden: !nphy },
					{ title: 'RTS 阈值', name: 'wl'+u+'_rts', type: 'text', maxlen: 4, size: 6,
						suffix: ' <small>(范围: 0 - 2347; 默认: 2347)</small>', value: nvram['wl'+u+'_rts'] },
					{ title: '接收天线', name: 'wl'+u+'_antdiv', type: 'select', options: [['3','自动 *'],['1','A'],['0','B']],
						value: nvram['wl'+u+'_antdiv'] },
					{ title: '发射天线', name: 'wl'+u+'_txant', type: 'select', options: [['3','自动 *'],['1','A'],['0','B']],
						value: nvram['wl'+u+'_txant'] },
					{ title: '发射功率', name: 'wl'+u+'_txpwr', type: 'text', maxlen: 3, size: 5,
						suffix: hp ?
						' <small>mW (放大前功率)</small>&nbsp;&nbsp;<small>(范围: 1 - 251; 默认: 10)</small>' :
						' <small>mW</small>&nbsp;&nbsp;<small>(范围: 0 - 400, 实际最大量取决于所选国家；硬件默认则使用0)</small>',
						value: nvram['wl'+u+'_txpwr'] },
					{ title: '传输速率', name: 'wl'+u+'_rate', type: 'select',
						options: [['0','自动 *'],['1000000','1 Mbps'],['2000000','2 Mbps'],['5500000','5.5 Mbps'],['6000000','6 Mbps'],['9000000','9 Mbps'],['11000000','11 Mbps'],['12000000','12 Mbps'],['18000000','18 Mbps'],['24000000','24 Mbps'],['36000000','36 Mbps'],['48000000','48 Mbps'],['54000000','54 Mbps']],
						value: nvram['wl'+u+'_rate'] },
					{ title: '干扰消减', name: 'wl'+u+'_mitigation', type: 'select',
						options: [['0','None *'],['1','Non-WLAN'],['2','WLAN Manual'],['3','WLAN Auto'],['4','WLAN 自动降噪']],
						value: nvram['wl'+u+'_mitigation'] },
					{ title: '无线多媒体', name: 'wl'+u+'_wme', type: 'select', options: [['auto','自动 *'],['off','禁用'],['on','启用 *']], value: nvram['wl'+u+'_wme'] },
					{ title: '无 ACK', name: 'wl'+u+'_wme_no_ack', indent: 2, type: 'select', options: [['off','禁用 *'],['on','启用']],
						value: nvram['wl'+u+'_wme_no_ack'] },
					{ title: 'APSD 模式', name: 'wl'+u+'_wme_apsd', indent: 2, type: 'select', options: [['off','禁用 *'],['on','启用']],
						value: nvram['wl'+u+'_wme_apsd'] },
					{ title: '无线组播转发', name: 'wl'+u+'_wmf_bss_enable', type: 'select', options: [['0','禁用 *'],['1','启用']],
						value: nvram['wl'+u+'_wmf_bss_enable'] }
					]);
				htmlOut += ('<small>星号 <b style="font-size: 1.5em">*</b> 表示为默认值.</small></div></div>');
			}

		}

		$('#formfields').append(htmlOut);
	</script>

	<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
	<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
	<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	<script type="text/javascript">verifyFields(null, 1);</script>
</content>