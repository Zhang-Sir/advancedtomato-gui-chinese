<!--
Tomato GUI
Copyright (C) 2012 Shibby
http://openlinksys.info
For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>TomatoAnon 项目</title>
<content>
	<script type="text/javascript">
		//	<% nvram("tomatoanon_enable,tomatoanon_answer,tomatoanon_id"); %>
		$('.anonlink').append('<a title="检查我的路由器" class="pull-right" href="http://anon.groov.pl/?search=9&routerid=<% nv('tomatoanon_id'); %>" target="_blank"><i class="icon-forward"></i></a>');
		function verifyFields(focused, quiet)
		{
			var o = (E('_tomatoanon_answer').value == '1');
			E('_tomatoanon_enable').disabled = !o;
			var s = (E('_tomatoanon_enable').value == '1');
			return 1;
		}
		function save()
		{
			if (verifyFields(null, 0)==0) return;
			var fom = E('_fom');
			fom._service.value = 'tomatoanon-restart';
			form.submit('_fom', 1);
		}
		function init()
		{
			var anon = true;
		}

		function submit_complete()
		{
			document.location.reload();
		}
	</script>


	<form id="_fom" method="post" action="tomato.cgi">
		<input type="hidden" name="_nextpage" value="/#admin-tomatoanon.asp">
		<input type="hidden" name="_service" value="tomatoanon-restart">

		<div class="box">
			<div class="heading">TomatoAnon 项目</div>
			<div class="content">
				<p>我想向您介绍一个我正在开发的新项目，名为 TomatoAnon。
					TomatoAnon 脚本将向在线数据库发送有关您的路由器型号和已安装的 Tomato 版本的信息.
					提交的信息是100％匿名的，只用于统计目的.
					<b>此脚本不会收集或传输任何私人或个人信息（例如 MAC 地址，IP 地址等）!</b>
					TomatoAnon 脚本是完全开放的，并且用 bash 编写。 每个人都可以自由地查看所收集并传输到数据库的信息..
				</p>

				<p>收集的数据可以这查看 <a href="http://anon.groov.pl/" target="_blank"><b>TomatoAnon 统计</b></a> 页面.<br>
					这些信息可以帮助您选择您所在国家或地区可用的最佳和最受欢迎的路由器.
					您可以在此找到每个路由器最常用和最稳定的 Tomato 版本.
					如果您不希望提供数据或对正在收集的数据不舒服的情况下，可以禁用 TomatoAnon 脚本..
					当然您也可以随时重新启用它.
				</p>

				<p>以下数据由 TomatoAnon 收集和传输:</p>
				<ul>
					<li>MD5SUM of WAN+LAN MAC addresses - this provides a unique identifier for each router, e.g: 1c1dbd4202d794251ec1acf1211bb2c8</li>
					<li>Model of router, e.g: Asus RT-N66U</li>
					<li>Installed version of Tomato, e.g: 102 K26 USB</li>
					<li>Build Type, e.g: Mega-VPN-64K</li>
					<li>Country, e.g: POLAND</li>
					<li>ISO Country Code, e.g: PL</li>
					<li>Router uptime, e.g: 3 days</li>
					<li>That`s it!!</li>
				</ul>

				<p>感谢您的阅读，请做出正确的选择来帮助这个项目.</p><br />

				<h3>Tomato 更新通知</h3>
				<p>
					AdvancedTomato 此次更新包括对 TomatoAnon 脚本的修复与添加，以提供在线自动更新检查机制。
					由于 TomatoAnon 脚本将收集的数据传输回 TomatoAnon 项目，此脚本还将检查安装的 AdvancedTomato 版本，并提供最新版本.
					就像 TomatoAnon, 该代码可以免费查看，以确保没有收集其他敏感信息.
				</p><br />

				<h4>它是如何工作的?</h4>
				<p>AdvancedTomato 会检索您的路由器的当前 Tomato 版本，并在页面上创建一个小链接，看起来像这样: <b><a target="_blank" href="http://advancedtomato.com/update.php?v=1.06.08">http://advancedtomato.com/update.php?v=1.06.08</a></b>.
					您的 Web 浏览器将跟随链接跳转，并且 AdvancedTomato 服务器发送一个响应，指示是否有较新的版本可用.<br>
					仅此而已!
				</p><br />

				<h5>AdvancedTomato 固件汉化说明</h5>
				<p>
					<li>AdvancedTomato 固件由网友 ZhangSir 独立汉化。</li>			
					<li>转发与转载请保留汉化作者信息，请勿打击作者积极性。</li>
					<li>汉化作者博客地址 <b><a target="_blank" href="https://www.getlinux.cn">GetLinux.cn</a></b></li>
					<li>汉化项目 GitHub 链接：<b><a target="_blank" href="https://github.com/Zhang-Sir/advancedtomato-gui-Chinese-localization">https://github.com/Zhang-Sir/advancedtomato-gui-Chinese-localization</a></b></li>
				</p>
			</div>
		</div>

		<div class="box anon">
			<div class="heading anonlink">TomatoAnon 设置</div>
			<div class="content"></div>
			<script type="text/javascript">
				$('.box.anon .content').forms([
					{ title: '你明白什么 TomatoAnon 吗?', name: 'tomatoanon_answer', type: 'select', options: [ ['0','不, 我不清楚. 我需要阅读上述信息并作出明智的决定.'], ['1','是的, 我已了解并作出决定.'] ], value: nvram.tomatoanon_answer, suffix: ' '},
					{ title: '是否要启用 TomatoAnon ?', name: 'tomatoanon_enable', type: 'select', options: [ ['-1','我现在不确定.'], ['1','是的, 我确定启用它.'], ['0','不, 我不想启用它.'] ], value: nvram.tomatoanon_enable, suffix: ' '}
				]);
			</script>
		</div>

		<button type="button" value="保存设置" id="save-button" onclick="save()" class="btn btn-primary">保存设置 <i class="icon-check"></i></button>
		<button type="button" value="取消设置" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消设置 <i class="icon-cancel"></i></button>
		<span id="footer-msg" class="alert alert-warning" style="visibility: hidden;"></span>

	</form>

	<script type="text/javascript">verifyFields(null, 1); init();</script>
</content>
