<title>状态概览</title>
<content>
	<script type="text/javascript" src="js/wireless.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript" src="js/interfaces.js?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript" src="js/status-data.jsx?_http_id=<% nv(http_id); %>"></script>
	<script type="text/javascript">
		//    <% nvstat(); %>
		//    <% etherstates(); %>
		wmo = {'ap':'接入点','sta':'无线客户端','wet':'无线桥接','wds':'WDS'};
		auth = {'disabled':'禁用','wep':'WEP','wpa_personal':'WPA 个人 (PSK)','wpa_enterprise':'WPA 企业','wpa2_personal':'WPA2 个人 (PSK)','wpa2_enterprise':'WPA2 企业','wpaX_personal':'WPA / WPA2 个人','wpaX_enterprise':'WPA / WPA2 企业','radius':'Radius'};
		enc = {'tkip':'TKIP','aes':'AES','tkip+aes':'TKIP / AES'};
		bgmo = {'disabled':'-','mixed':'自动','b-only':'仅 802.11b','g-only':'仅 802.11g','bg-mixed':'802.11 b/g','lrs':'LRS','n-only':'仅 802.11n'};
	</script>
	<script type="text/javascript">
		show_dhcpc = [];
		show_codi = [];
		for ( var uidx = 1; uidx <= nvram.mwan_num; ++uidx ) {
			var u;
			u     = (uidx > 1) ? uidx : '';
			proto = nvram[ 'wan' + u + '_proto' ];
			if ( proto != 'disabled' ) show_langateway = 0;
			show_dhcpc[ uidx - 1 ] = ((proto == 'dhcp') || (proto == 'lte') || (((proto == 'l2tp') || (proto == 'pptp')) && (nvram.pptp_dhcp == '1')));
			show_codi[ uidx - 1 ]  = ((proto == 'pppoe') || (proto == 'l2tp') || (proto == 'pptp') || (proto == 'ppp3g'));
		}

		show_radio = [];
		for ( var uidx = 0; uidx < wl_ifaces.length; ++uidx ) {
			/* REMOVE-BEGIN
			 //	show_radio.push((nvram['wl'+wl_unit(uidx)+'_radio'] == '1'));
			 REMOVE-END */
			if ( wl_sunit( uidx ) < 0 )
				show_radio.push( (nvram[ 'wl' + wl_fface( uidx ) + '_radio' ] == '1') );
		}

		nphy = features( '11n' );

		function dhcpc( what, wan_prefix ) {
			form.submitHidden( 'dhcpc.cgi', { exec: what, prefix: wan_prefix, _redirect: '/#status-home.asp' } );
		}

		function serv( service, sleep ) {
			form.submitHidden( 'service.cgi', { _service: service, _redirect: '/#status-home.asp', _sleep: sleep } );
		}

		function wan_connect( uidx ) {
			serv( 'wan' + uidx + '-restart', 5 );
		}

		function wan_disconnect( uidx ) {
			serv( 'wan' + uidx + '-stop', 2 );
		}

		function wlenable( uidx, n ) {
			form.submitHidden( 'wlradio.cgi', { enable: '' + n, _nextpage: 'status-overview.asp', _nextwait: n ? 6 : 3, _wl_unit: wl_unit( uidx ) } );
		}

		var ref = new TomatoRefresh( 'js/status-data.jsx', '', 0, 'status_overview_refresh' );

		ref.refresh = function( text ) {
			stats = {};
			try {
				eval( text );
			}
			catch ( ex ) {
				stats = {};
			}
			show();
		}


		function c( id, htm ) {
			E( id ).cells[ 1 ].innerHTML = htm;
		}

		function ethstates() {

			var ports = [], names = {}, v = 0;

			// Fail safe (check if minimum 5 ports exist (bit lame since not all routers have 5 ports???)
			if ( etherstates.port0 == "disable" || typeof (etherstates.port0) == 'undefined' || typeof (etherstates.port1) == 'undefined' || typeof (etherstates.port2) == 'undefined' || typeof (etherstates.port3) == 'undefined' || typeof (etherstates.port4) == 'undefined' ) {

				$( '#ethernetPorts' ).remove();
				return false;

			}

			// Name ports (MultiWAN thing)
			for ( uidx = 1; uidx <= nvram.mwan_num; ++uidx ) {
				u = (uidx > 1) ? uidx : '';
				if ( (nvram[ 'wan' + u + '_sta' ] == '') && (nvram[ 'wan' + u + '_proto' ] != 'lte') && (nvram[ 'wan' + u + '_proto' ] != 'ppp3g') ) {
					names[ 'port' + v ] = 'WAN' + u;
					++v;
				}
			}

			for ( uidx = v; uidx <= 4; ++uidx ) { names[ 'port' + uidx ] = 'LAN' + uidx; }

			// F*** standard approach writing down port by port, lets just loop through array....
			$.each( etherstates, function( $k, $v ) {

				var speed, status;

				// Replace status/speed based on port status
				if ( $v == 'DOWN' ) {

					status = 'off';
					speed  = etherstates[ $k ].replace( "DOWN", "断开" );

				} else {

					status = 'on';
					speed  = etherstates[ $k ].replace( 'HD', 'M半双工' );
					speed  = speed.replace( "FD", "M全双工" );

				}

				ports.push( '<div class="eth ' + status + ' ' + ( ( $k == 'port0' ) ? 'wan' : '' ) + '"><div class="title">' + names[$k] + '</div><div class="speed">' + speed + '</div></div>' );

			});

			$( "#ethernetPorts .content" ).html( '<div id="ethPorts">' + ports.join( '' ) + '</div>' );

		}

		function show() {

			c( 'cpu', stats.cpuload );
			c( 'cpupercent', stats.cpupercent );
			c( 'wlsense', stats.wlsense );
			c( 'uptime', stats.uptime );
			c( 'time', stats.time );
			c( 'memory', stats.memory + '<div class="progress small"><div class="bar" style="width: ' + stats.memoryperc + ';"></div></div>' );
			c( 'swap', stats.swap + '<div class="progress small"><div class="bar" style="width: ' + stats.swapperc + ';"></div></div>' );
			elem.display( 'swap', stats.swap != '' );

/* IPV6-BEGIN */
			c( 'ip6_wan', stats.ip6_wan );
			elem.display( 'ip6_wan', stats.ip6_wan != '' );
			c( 'ip6_lan', stats.ip6_lan );
			elem.display( 'ip6_lan', stats.ip6_lan != '' );
			c( 'ip6_lan_ll', stats.ip6_lan_ll );
			elem.display( 'ip6_lan_ll', stats.ip6_lan_ll != '' );
/* IPV6-END */

			for ( uidx = 1; uidx <= nvram.mwan_num; ++uidx ) {

				var u = (uidx > 1) ? uidx : '';

				c( 'wan' + u + 'ip', stats.wanip[ uidx - 1 ] );
				c( 'wan' + u + 'netmask', stats.wannetmask[ uidx - 1 ] );
				c( 'wan' + u + 'gateway', stats.wangateway[ uidx - 1 ] );
				c( 'wan' + u + 'dns', stats.dns[ uidx - 1 ] );
				c( 'wan' + u + 'uptime', stats.wanuptime[ uidx - 1 ] );
				c( 'wan' + u + 'status', ( ( stats.wanstatus[ uidx - 1 ] == 'Connected') ? '<span class="text-green">已连接</span>' : '<span class="text-red">' + stats.wanstatus[ uidx - 1 ] + '</span>') );
				if ( show_dhcpc[ uidx - 1 ] ) c( 'wan' + u + 'lease', stats.wanlease[ uidx - 1 ] );
				if ( show_dhcpc[ uidx - 1 ] ) c( 'wan' + u + 'lease', stats.wanlease[ uidx - 1 ] );
				if ( show_codi ) {

					if ( stats.wanup[ uidx - 1 ] ) {

						$( '#b' + u + '_connect_').hide();
						$( '#b' + u + '_disconnect' ).show();

					} else {

						$( '#b' + u + '_connect' + u ).show();
						$( '#b' + u + '_disconnect' + u ).hide();

					}
				}
			}

			for ( uidx = 0; uidx < wl_ifaces.length; ++uidx ) {

				if ( wl_sunit( uidx ) < 0 ) {
					c( 'radio' + uidx, wlstats[ uidx ].radio ? '启用 <i class="icon-check"></i>' : '禁用 <i class="icon-cancel"></i>' );
					c( 'rate' + uidx, wlstats[ uidx ].rate );

					if ( show_radio[ uidx ] ) {

						if ( wlstats[ uidx ].radio ) {

							$( '#b_wl' + uidx + '_enable' ).hide();
							$( '#b_wl' + uidx + '_disable' ).show();

						} else {

							$( '#b_wl' + uidx + '_enable' ).show();
							$( '#b_wl' + uidx + '_disable' ).hide();

						}

					} else {

						// Interface disabled, hide enable/disable
						$( '#b_wl' + uidx + '_enable' ).hide();
						$( '#b_wl' + uidx + '_disable' ).hide();

					}

					c( 'channel' + uidx, stats.channel[ uidx ] );
					if ( nphy ) {
						c( 'nbw' + uidx, wlstats[ uidx ].nbw );
					}
					c( 'interference' + uidx, stats.interference[ uidx ] );
					elem.display( 'interference' + uidx, stats.interference[ uidx ] != '' );

					if ( wlstats[ uidx ].client ) {
						c( 'rssi' + uidx, wlstats[ uidx ].rssi || '' );
						c( 'noise' + uidx, wlstats[ uidx ].noise || '' );
						c( 'qual' + uidx, stats.qual[ uidx ] || '' );
					}
				}
				c( 'ifstatus' + uidx, wlstats[ uidx ].ifstatus || '' );
			}
		}

		function earlyInit() {

			var uidx;
			for ( uidx = 1; uidx <= nvram.mwan_num; ++uidx ) {
				var u = (uidx > 1) ? uidx : '';
				elem.display( 'b' + u + '_dhcpc', show_dhcpc[ uidx - 1 ] );
				elem.display( 'b' + u + '_connect', 'b' + u + '_disconnect', show_codi[ uidx - 1 ] );
				// elem.display( 'wan' + u + '-title', 'sesdiv_wan' + u, (nvram[ 'wan' + u + '_proto' ] != 'disabled') );
			}
			for ( uidx = 0; uidx < wl_ifaces.length; ++uidx ) {
				if ( wl_sunit( uidx ) < 0 )
					elem.display( 'b_wl' + uidx + '_enable', 'b_wl' + uidx + '_disable', show_radio[ uidx ] );
			}

			ethstates();
			show();
			init();
		}

		function init() {

			$( '.refresher' ).after( genStdRefresh( 1, 1, 'ref.toggle()' ) );
			ref.initPage( 3000, 3 );

		}

	</script>

	<div class="fluid-grid">

		<div class="box" data-box="home_systembox">
			<div class="heading">系统</div>
			<div class="content" id="sesdiv_system">
				<div class="section"></div>
				<script type="text/javascript">
					var a = (nvstat.size - nvstat.free) / nvstat.size * 100.0;
					createFieldTable('', [
						{ title: '名称', text: nvram.router_name },
						{ title: '型号', text: nvram.t_model_name },
						{ title: 'CPU 芯片', text: stats.systemtype, suffix: ' <small>(dual-core)</small>' },
						{ title: 'CPU 频率', text: stats.cpumhz },
						{ title: 'Flash 容量', text: stats.flashsize },
						null,
						{ title: '时间', rid: 'time', text: stats.time },
						{ title: '运行时间', rid: 'uptime', text: stats.uptime },
						{ title: 'CPU 使用率', rid: 'cpupercent', text: stats.cpupercent },
						{ title: 'CPU 负载 <small>(1 / 5 / 15 mins)</small>', rid: 'cpu', text: stats.cpuload },
						{ title: '内存使用率', rid: 'memory', text: stats.memory + '<div class="progress small"><div class="bar" style="width: ' + stats.memoryperc + ';"></div></div>' },
						{ title: 'Swap 使用率', rid: 'swap', text: stats.swap + '<div class="progress small"><div class="bar" style="width: ' + stats.swapperc + ';"></div></div>', hidden: (stats.swap == '') },
						{ title: 'NVRAM 使用率', text: scaleSize(nvstat.size - nvstat.free) + ' <small>/</small> ' + scaleSize(nvstat.size) + ' (' + (a).toFixed(2) + '%) <div class="progress small"><div class="bar" style="width: ' + (a).toFixed(2) + '%;"></div></div>' },
						null,
						{ title: 'CPU 温度', rid: 'temps', text: stats.cputemp + 'C'},
						{ title: '无线网卡温度', rid: 'wlsense', text: stats.wlsense }
						], '#sesdiv_system', 'data-table dataonly');
				</script>
			</div>
		</div>

		<div class="MultiWAN"></div>
		<script type="text/javascript">

			for ( uidx = 1; uidx <= nvram.mwan_num; ++uidx ) {

				var u = (uidx > 1) ? uidx : '';
				$( '.MultiWAN' ).append( '<div class="box" id="wan-title' + u + '" data-box="home_wanbox' + u + '"><div class="heading">WAN ' + u + '</div>' +
				                         '<div class="content" id="sesdiv_wan' + u + '"></div></div>' );

				createFieldTable( '', [
					{ title: 'MAC 地址', text: nvram[ 'wan' + u + '_hwaddr' ] },
					{ title: '连接类型', text: { 'dhcp': 'DHCP', 'static': 'Static IP', 'pppoe': 'PPPoE', 'pptp': 'PPTP', 'l2tp': 'L2TP', 'ppp3g': '3G Modem', 'lte': '4G/LTE' }[ nvram[ 'wan' + u + '_proto' ] ] || '-' },
					{ title: 'IP 地址', rid: 'wan' + u + 'ip', text: stats.wanip[ uidx - 1 ] },
					{ title: '子网掩码', rid: 'wan' + u + 'netmask', text: stats.wannetmask[ uidx - 1 ] },
					{ title: '网关', rid: 'wan' + u + 'gateway', text: stats.wangateway[ uidx - 1 ] },
					/* IPV6-BEGIN */
					{ title: 'IPv6 地址', rid: 'ip6_wan', text: stats.ip6_wan, hidden: (stats.ip6_wan == '') },
					/* IPV6-END */
					{ title: 'DNS', rid: 'wan' + u + 'dns', text: stats.dns[ uidx - 1 ] },
					{ title: 'MTU', text: nvram[ 'wan' + u + '_run_mtu' ] },
					null,
					{ title: '状态', rid: 'wan' + u + 'status', text: stats.wanstatus[ uidx - 1 ] },
					{ title: '连接运行时间', rid: 'wan' + u + 'uptime', text: stats.wanuptime[ uidx - 1 ] },
					{ title: '剩余租约时间', rid: 'wan' + u + 'lease', text: stats.wanlease[ uidx - 1 ], ignore: !show_dhcpc[ uidx - 1 ] }
				], '#sesdiv_wan' + u, 'data-table dataonly' );

				$( '#sesdiv_wan' + u ).append(
						'<br><button type="button" class="btn btn-primary pull-left" onclick="wan_connect(' + uidx + ')" value="连接" id="b' + u + '_connect" style="display:none;margin-right: 5px;">连接 <i class="icon-reboot"></i></button>' +
						'<button type="button" class="btn btn-danger pull-left" onclick="wan_disconnect(' + uidx + ')" value="断开" id="b' + u + '_disconnect" style="display:none;margin-right: 5px;">断开 <i class="icon-cancel"></i></button>' +
						'<div id="b' + u + '_dhcpc" class="btn-group pull-left" style="display:none;"><button type="button" class="btn" onclick="dhcpc(\'renew\', \'wan' + u + '\')" value="更新">更新</button>' +
						'<button type="button" class="btn" onclick="dhcpc(\'release\', \'wan' + u + '\')" value="释放">释放</button><div class="clearfix"></div></div>'
				);

			}

		</script>

		<div class="box" id="ethernetPorts" data-box="home_ethports">
			<div class="heading">以太网端口状态
				<a class="ajaxload pull-right" data-toggle="tooltip" title="配置设置" href="#basic-network.asp"><i class="icon-system"></i></a>
			</div>
			<div class="content" id="sesdiv_lan-ports"></div>
		</div>


		<div class="box" id="LAN-settings" data-box="home_lanbox">
			<div class="heading">LAN </div>
			<div class="content" id="sesdiv_lan">
				<script type="text/javascript">

					function h_countbitsfromleft(num) {
						if (num == 255 ){
							return(8);
						}
						var i = 0;
						var bitpat=0xff00;
						while (i < 8){
							if (num == (bitpat & 0xff)){
								return(i);
							}
							bitpat=bitpat >> 1;
							i++;
						}
						return(Number.NaN);
					}

					function numberOfBitsOnNetMask(netmask) {
						var total = 0;
						var t = netmask.split('.');
						for (var i = 0; i<= 3 ; i++) {
							total += h_countbitsfromleft(t[i]);
						}
						return total;
					}

					var s='';
					var t='';
					for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
						var j = (i == 0) ? '' : i.toString();
						if (nvram['lan' + j + '_ifname'].length > 0) {
							if (nvram['lan' + j + '_proto'] == 'dhcp') {
								if ((!fixIP(nvram.dhcpd_startip)) || (!fixIP(nvram.dhcpd_endip))) {
									var x = nvram['lan' + j + '_ipaddr'].split('.').splice(0, 3).join('.') + '.';
									nvram['dhcpd' + j + '_startip'] = x + nvram['dhcp' + j + '_start'];
									nvram['dhcpd' + j + '_endip'] = x + ((nvram['dhcp' + j + '_start'] * 1) + (nvram['dhcp' + j + '_num'] * 1) - 1);
								}
								s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? '<br>' : '';
								s += '<b>br' + i + '</b> (LAN' + j + ') - ' + nvram['dhcpd' + j + '_startip'] + ' - ' + nvram['dhcpd' + j + '_endip'];
							} else {
								s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? '<br>' : '';
								s += '<b>br' + i + '</b> (LAN' + j + ') - Disabled';
							}
							t += ((t.length>0)&&(t.charAt(t.length-1) != ' ')) ? '<br>' : '';
							t += '<b>br' + i + '</b> (LAN' + j + ') - ' + nvram['lan' + j + '_ipaddr'] + '/' + numberOfBitsOnNetMask(nvram['lan' + j + '_netmask']);

						}
					}

					createFieldTable('', [
						{ title: '路由器 MAC 地址', text: nvram.et0macaddr },
						{ title: '路由器 IP 地址', text: t },
						{ title: '网关', text: nvram.lan_gateway, ignore: nvram.wan_proto != 'disabled' },
						/* IPV6-BEGIN */
						{ title: '路由器 IPv6 地址', rid: 'ip6_lan', text: stats.ip6_lan, hidden: (stats.ip6_lan == '') },
						{ title: 'IPv6 本地链路地址', rid: 'ip6_lan_ll', text: stats.ip6_lan_ll, hidden: (stats.ip6_lan_ll == '') },
						/* IPV6-END */
						{ title: 'DNS', rid: 'dns', text: stats.dns, ignore: nvram.wan_proto != 'disabled' },
						{ title: 'DHCP', text: s }
						], '#sesdiv_lan', 'data-table dataonly' );

				</script>
			</div>
		</div>

		<script type="text/javascript">

			for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {

				var data = "";

				/* REMOVE-BEGIN
				//	u = wl_unit(uidx);
				REMOVE-END */
				u = wl_fface(uidx);
				data += '<div class="box" data-box="home_wl' + u +'"><div class="heading" id="wl'+u+'-title">无线';
				if (wl_ifaces.length > 0)
					data += ' (' + wl_display_ifname(uidx) + ')';
				data += '</div>';
				data += '<div class="content" id="sesdiv_wl_'+u+'">';
				sec = auth[nvram['wl'+u+'_security_mode']] + '';
				if (sec.indexOf('WPA') != -1) sec += ' + ' + enc[nvram['wl'+u+'_crypto']];

				wmode = wmo[nvram['wl'+u+'_mode']] + '';
				if ((nvram['wl'+u+'_mode'] == 'ap') && (nvram['wl'+u+'_wds_enable'] * 1)) wmode += ' + WDS';

				data += createFieldTable('', [
					{ title: 'MAC 地址', text: nvram['wl'+u+'_hwaddr'] },
					{ title: '无线模式', text: wmode },
					{ title: '工作模式', text: bgmo[nvram['wl'+u+'_net_mode']], ignore: (wl_sunit(uidx)>=0) },
					{ title: '连接状态', rid: 'ifstatus'+uidx, text: wlstats[uidx].ifstatus },
					{ title: '无线网络', rid: 'radio'+uidx, text: (wlstats[uidx].radio == 0) ? '禁用 <i class="icon-cancel"></i>' : '启用 <i class="icon-check"></i>', ignore: (wl_sunit(uidx)>=0) },
					/* REMOVE-BEGIN */
					//	{ title: 'SSID', text: (nvram['wl'+u+'_ssid'] + ' <small><i>' + ((nvram['wl'+u+'_mode'] != 'ap') ? '' : ((nvram['wl'+u+'_closed'] == 0) ? '(Broadcast Enabled)' : '(Broadcast Disabled)')) + '</i></small>') },
					/* REMOVE-END */
					{ title: 'SSID 名称', text: nvram['wl'+u+'_ssid'] },
					{ title: 'SSID 广播', text: (nvram['wl'+u+'_closed'] == 0) ? '<span class="text-green">启用 <i class="icon-check"></i></span>' : '<span class="text-red">禁用 <i class="icon-cancel"></i></span>', ignore: (nvram['wl'+u+'_mode'] != 'ap') },
					{ title: '安全设置', text: sec },
					{ title: '无线信道', rid: 'channel'+uidx, text: stats.channel[uidx], ignore: (wl_sunit(uidx)>=0) },
					{ title: '无线频宽', rid: 'nbw'+uidx, text: wlstats[uidx].nbw, ignore: ((!nphy) || (wl_sunit(uidx)>=0)) },
					{ title: '干扰水平', rid: 'interference'+uidx, text: stats.interference[uidx], hidden: ((stats.interference[uidx] == '') || (wl_sunit(uidx)>=0)) },
					{ title: '无线速率', rid: 'rate'+uidx, text: wlstats[uidx].rate, ignore: (wl_sunit(uidx)>=0) },
					{ title: '信号强度', rid: 'rssi'+uidx, text: wlstats[uidx].rssi || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
					{ title: '本底噪声', rid: 'noise'+uidx, text: wlstats[uidx].noise || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
					{ title: '信号质量', rid: 'qual'+uidx, text: stats.qual[uidx] || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) }
					], null, 'data-table dataonly');

				data += '<div class="btn-control-group"><br>';
				data += '<button type="button" class="btn btn-primary" onclick="wlenable('+uidx+', 1)" id="b_wl'+uidx+'_enable" value="启用" style="display:none;">启用 <i class="icon-check"></i></button>';
				data += '<button type="button" class="btn btn-danger" onclick="wlenable('+uidx+', 0)" id="b_wl'+uidx+'_disable" value="禁用" style="display:none;">禁用 <i class="icon-disable"></i></button>';
				data += '</div></div></div>';
				$('#LAN-settings').after(data);
			}
		</script>
	</div>

	<div class="clearfix refresher"></div>
	<script type="text/javascript">earlyInit();</script>
</content>
