<title>日志查看</title>
<content>
<script type="text/javascript">
	//<% nvram("at_update,tomatoanon_answer,log_file"); %>

	function find()
	{
		var s = E('find-text').value;
		if (s.length) document.location = 'logs/view.cgi?find=' + escapeCGI(s) + '&_http_id=' + nvram.http_id;
	}

	function init()
	{
		var e = E('find-text');
		if (e) e.onkeypress = function(ev) {
			if (checkEvent(ev).keyCode == 13) find();
			}
	}
</script>

<div class="box">
	<div class="heading">查看路由器日志 
		<a class="ajaxload pull-right" data-toggle="tooltip" title="配置日志记录" href="#admin-log.asp"><i class="icon-system"></i></a>
	</div>
	<div class="content">

		<div id="logging">
			<div class="section">
				<a href="logs/view.cgi?which=25&_http_id=<% nv(http_id) %>">查看最后  25 行</a><br />
				<a href="logs/view.cgi?which=50&_http_id=<% nv(http_id) %>">查看最后  50 行</a><br />
				<a href="logs/view.cgi?which=100&_http_id=<% nv(http_id) %>">查看最后  100 行</a><br />
				<a href="logs/view.cgi?which=all&_http_id=<% nv(http_id) %>">显示全部</a><br /><br />
				<div class="input-append"><input class="span3" type="text" maxsize="32" id="find-text"> <button value="搜索" onclick="find()" class="btn">搜索 <i class="icon-search"></i></button></div>
				<i>搜索并显示可用日志文件中匹配的内容</i>
				<br><br /><hr>
				<a class="btn btn-primary" href="logs/syslog.txt?_http_id=<% nv(http_id) %>">下载日志记录文件 <i class="icon-download"></i></a>
			</div>
		</div>

	</div>
</div>

<script type="text/javascript">
	if (nvram.log_file != '1') {
		$('#logging').before('<div class="alert alert-info">内部日志已禁用。</b><br><br><a href="admin-log.asp">启用 &raquo;</a></div>');
		E('logging').style.display = 'none';
	}
</script>
<script type="text/javascript">init()</script>