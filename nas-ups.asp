<!--
Tomato GUI
For use with Tomato Firmware only.
No part of this file may be used without permission.
--><title>UPS 管理</title>
<content>
	<script type="text/javascript">
		//      <% nvram("at_update,tomatoanon_answer"); %>

		function init() {
			clientSideInclude('ups-status', '/ext/cgi-bin/tomatoups.cgi');
			clientSideInclude('ups-data', '/ext/cgi-bin/tomatodata.cgi');
		}

		function clientSideInclude(id, url) {
			var req = false;
			// For Safari, Firefox, and other non-MS browsers
			if (window.XMLHttpRequest) {
				try {
					req = new XMLHttpRequest();
				} catch (e) {
					req = false;
				}
			} else if (window.ActiveXObject) {
				// For Internet Explorer on Windows
				try {
					req = new ActiveXObject("Msxml2.XMLHTTP");
				} catch (e) {
					try {
						req = new ActiveXObject("Microsoft.XMLHTTP");
					} catch (e) {
						req = false;
					}
				}
			}

			var element = document.getElementById(id);
			if (!element) {
				alert("错误的 id " + id +
					"传递给 Client Side Include." +
					"你需要一个 div 或 span 元素 " +
					"在您的网页中使用此 id.");
				return;
			}
			if (req) {
				// Synchronous request, wait till we have it all
				req.open('GET', url, false);
				req.send(null);
				element.innerHTML = req.responseText;
				$('.tomato-grid').addClass('line-table');
			} else {
				element.innerHTML =
				"很抱歉，您的浏览器不支持 " +
				"此页需要，XML HTTP Request objects. " +
				"适用于 Windows 的 Internet Explorer 5 或更高版本, " +
				"或 Firefox 与 Safari. 其他 " +
				"兼容的浏览器也可能存在.";
			}
		}
	</script>

	<input type="hidden" name="_nextpage" value="/#nas-ups.asp">
	<div class="box">
		<div class="heading">APC UPS 状态</div>
		<div class="content">
			<span id="ups-status"></span>
		</div>
	</div>

	<div class="box">
		<div class="heading">UPS 状态</div>
		<div class="content">
			<span id="ups-data"></span>
		</div>
	</div>

	<script type="text/javascript">init();</script>
</content>