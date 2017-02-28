<title>清除 Cookies</title>
<content>

	<div class="box">
		<div class="heading">清除 Cookies</div>
		<div class="content clearcookies"></div>
	</div>
	<script type="text/javascript">
		b = [];
		c = document.cookie.split(';');
		for (i = 0; i < c.length; ++i) {
			if (c[i].match(/^\s*tomato_(.+?)=/)) {
				b.push(c[i]);
				cookie.unset(RegExp.$1);
			}
		}
		if (b.length == 0) b.push('<b>No cookie found!</b>');
		$('.content.clearcookies').append(b.join('<br>'));
	</script>

</content>