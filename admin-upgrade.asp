<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/

For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>固件升级</title>
<content>
	<style>
		#afu-progress {
			display: block;
			position: fixed;
			top: 0;
			right: 0;
			left: 0;
			bottom: 0;
			z-index: 20;
			background: #fff;
			color: #5A5A5A;
			opacity: 0;
			transition: opacity 250ms ease-out;
		}

		#afu-progress .text-container {
			position: absolute;
			display: block;
			text-align: center;
			font-size: 14px;
			width: 100%;
			height: 150px;
			top: 30%;
			margin-top: -75px;
			transform: scale(0.2);
			transition: all 350ms ease-out;
		}

		#afu-progress.active {
			opacity: 1;
		}

		#afu-progress.active .text-container {
			transform: scale(1);
			top: 40%;
		}
		
		.line-table tr { background: transparent !important; }
		.line-table tr:last-child { border: 0; }
	</style>
	<script type="text/javascript">
		// <% nvram("jffs2_on"); %>

		function clock()
		{
			var t = ((new Date()).getTime() - startTime) / 1000;
			elem.setInnerHTML('afu-time', Math.floor(t / 60) + ':' + Number(Math.floor(t % 60)).pad(2));
		}
		function upgrade() {
			var name;
			var i;
			var fom = document.form_upgrade;
			var ext;
			name = fixFile(fom.file.value);

			if (name.search(/\.(bin|trx|chk)$/i) == -1) {
				alert('请上传 ".bin" 或 ".trx" 文件.');
				return false;
			}

			if (!confirm('确定要使用这个文件更新 ' + name + '?')) return;
			E('afu-upgrade-button').disabled = true;

			// Some cool things
			$('#wrapper > .content').css('position', 'static');
			$('#afu-progress').clone().prependTo('#wrapper').show().addClass('active');
			startTime = (new Date()).getTime();
			setInterval('clock()', 500);

			fom.action += '?_reset=' + (E('f_reset').checked ? "1" : "0");
			form.addIdAction(fom);
			fom.submit();
		}
	</script>
	<div id="afu-input">

		<div class="alert alert-warning icon">
			<h5>注意!</h5>下载过程中文件可能损坏，为避免出现问题，请验证 MD5 校验 (<a target="_blank" href="http://en.wikipedia.org/wiki/Checksum">阅读更多</a>) AdvancedTomato 固件，然后再尝试刷机。
			<a class="close"><i class="icon-cancel"></i></a>
		</div>

		<form name="form_upgrade" method="post" action="upgrade.cgi" encType="multipart/form-data">

			<div class="box">
				<div class="heading">路由器固件升级</div>
				<div class="content">

					<fieldset>
						<label class="control-left-label col-sm-3">选择新固件:</label>
						<div class="col-sm-9"><input class="uploadfile" type="file" name="file" size="50">
							<button type="button" value="升级" id="afu-upgrade-button" onclick="upgrade();" class="btn btn-danger">升级 <i class="icon-upload"></i></button>
						</div>
					</fieldset>

					<fieldset>
						<label class="control-left-label col-sm-3" for="f_reset">恢复默认值</label>
						<div class="col-sm-9">
							<div id="reset-input">
								<div class="checkbox c-checkbox"><label><input class="custom" type="checkbox" id="f_reset">
									<span class="icon-check"></span> &nbsp; 刷写后，擦除 NVRAM 内存中的所有数据</label>
								</div>
							</div>
						</div>
					</fieldset>

				</div>
			</div>

			<div class="box">
				<div class="heading">路由器信息</div>
				<div class="content">
					<table class="line-table" id="version-table">
						<tr><td>当前版本:</td><td>&nbsp; <% version(1); %></td></tr>
					</table>
				</div>
			</div>

			<div id="afu-progress" style="display:none;">
				<div class="text-container">
					<div class="spinner spinner-large"></div><br /><br />
					<b id="afu-time">0:00</b><br />
					正在上传和刷新新固件，请稍候...<br />
					<b>不要关闭 Web浏览器或路由器!</b>
				</div>
			</div>
		</form>
	</div>

	/* JFFS2-BEGIN */
	<div class="alert alert-error" style="display:none;" id="jwarn">
		<h5>禁止升级!</h5>
		升级将会覆盖当前使用的 JFFS 分区，升级前,
		请备份 JFFS 分区的内容，并禁用它，然后重新启动路由器.
		<a href="/#admin-jffs2.asp">关闭 &raquo;</a>
	</div>
	<script type="text/javascript">
		//	<% sysinfo(); %>
		$('#version-table').append('<tr><td>可用容量:</td><td>&nbsp; ' + scaleSize(sysinfo.totalfreeram) + ' &nbsp; <small>(剩余内存空间必须大于固件文件尺寸)</small></td></tr>');

		if (nvram.jffs2_on != '0') {
			E('jwarn').style.display = '';
			E('afu-input').style.display = 'none';
		}
	</script>
	/* JFFS2-END */
</content>