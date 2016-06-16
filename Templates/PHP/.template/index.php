<?php
?>
<!DOCTYPE html>
<html>
<head>
  <title>Sample PHP application template powered by Helicon Zoo</title>
  <style type="text/css">
    body {
      font-family: Sans-Serif;
      font-size: 16px;
      line-height: 22px;
    }

    h1 {
      color: #f42;
      text-align: center;
      letter-spacing: -1px;
      line-height: 40px;
    }

    h2 {
      color: #666;
      margin-top: 1em;
    }

    pre {
      padding: .5em;
      background-color: #eee;
      word-break: break-all;
      white-space: pre-wrap;
    }

    code {
      color: #008;
      font-family: Consolas, monospace;
    }

    #container {
      max-width: 960px;
      margin: 0 auto;
    }

    #footer {
      clear: both;
      margin: 2em 0;
      text-align: center;
    }
  </style>
</head>
<body>
<div id="container">
  <div id="header">
    <h1>Welcome to&nbsp;sample PHP template powered by&nbsp;Helicon&nbsp;Zoo</h1>
  </div>

  <div id="content">
    <p>This is a sample project showing how to run PHP applications  on IIS over FastCGI with the help of Helicon Zoo.</p>
    <h3>Current PHP version is <?php echo phpversion(); ?></h3> 
    <p>To switch to another PHP version please open Helicon Zoo and select a different engine for this application. You will need to install this engine if it is not installed yet. </p>
    <p>It is possible to set custom<strong> php.ini</strong> for this application by setting <strong>PHP_INI</strong> environment variable. Currently active <strong>php.ini</strong> is  <strong><?php echo $_SERVER["PHP_INI"]; ?></strong></p>
    <p>Composer script is installed at <strong><?php echo $_SERVER["SITE_PHYSICAL_PATH"]; ?>\composer.php</strong> Use it from Zoo console as 'php composer.php'.</p>
    <p><a href="phpinfo.php">View phpinfo</a></p>
    <p>Please  replace this template with your own PHP application by simply copying files over.</p>

    <a href="http://www.helicontech.com/zoo/">Helicon&nbsp;Zoo</a>
    &middot;
    <a href="http://www.helicontech.com/articles/category/helicon-zoo/">Articles</a>&nbsp;
    &middot;
    <a href="http://www.helicontech.com/community/Helicon_Zoo-6.html">Community</a>
    &middot;
    <a href="http://support.helicontech.com/">Support</a>


  </div>
</div>
</body>
</html>