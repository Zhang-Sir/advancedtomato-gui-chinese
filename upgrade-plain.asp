<html>
    <head><title>固件升级</title>
    <script type="text/javascript">
    function upgrade() {
        document.form_upgrade.submit();
    }
    </script>
    </head>
    <body>
        <h1>固件升级</h1>
        <b>警告:</b>
        <ul>
            <li>这个页面没有上传状态信息，并且在升级按钮被按下后，页面将不会变化。
            <li>升级可能需要3分钟才能完成，在此期间不要中断开路由器或浏览器。
        </ul>
        <br>
        <form name="form_upgrade" method="post" action="upgrade.cgi?_http_id=<% nv(http_id); %>" encType="multipart/form-data">
            <label>选择要使用的文件:</label>
            <input type="file" name="file" size="50"> <button type="button" value="升级" id="afu-upgrade-button" onclick="upgrade()" class="btn btn-danger">升级</button>
        </form>
    </body>
</html>