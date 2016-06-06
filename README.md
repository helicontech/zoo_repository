### Source repository for Helicon Zoo v4 ###

* Zoo homepage: [https://www.helicontech.com/zoo/](Link URL)
* Version 1.0b

### Usage ###

You will need Helicon Zoo v4+ to use this repository.
Although it is possible to use it in bare format, it is recommended to compile it first by calling:

```
#!cmd
zoocmd.exe --compile-repository source_dir target_dir
```

Then you can use repository in Zoo by setting

```
# zoo_home_dir/HeliconZoo/etc/settings.yaml

main_feed: path_to_repository_local_network_or_http
```

### Repository syntax ###

The repository consists of Yaml files, representing repository itself, and set of resource files, containing other downloadable data
that is required for installations. Directories and files with names starting with dot '.' are ignored and not copied during compilation.
The top level of each Yaml file is a list, containing elements of the repository. Elements can be of three types: products, applications, and engines.

* Product - is a generic entity that is installed on a target system globally. Examples of products are Perl interpreter, MySQL, JDK, some pack
with configurations, IIS web server, Zoo module, etc.
* Application - is a web application entity. Something that is installed on a web server and configured for a specific location, like URL, path etc.
Examples of applications are WordPress, Sample Python project, PHPbb, etc.
* Engine - set of configurations and dependencies plus settings for Zoo module that defines how web application of particular kind should be executed. 
A level of abstraction that allows web applications to list only engines as their dependencies. Engine examples are PHP 5.5 Engine, Java Tomcat Engine, 
Node.js Engine. If the engine is installed on a target system, the system is considered capable of running web applications of that kind.

Each product, application or engine in repository is uniquely identified by ID, that are set as:


```
#!Yaml

product: ProductId
# or
engine: engineId
#or
application: applicationId
```

There can be more than one element with the same ID in the repository. Elements are then filtered by various criteria, such as OS version, bitness,
target web server, etc., and merged into one by combining fields and overwriting existing.

Please see .example.yaml file in the root for some more syntax examples.

### Contact ###

Author: Yaroslav Govorunov, Helicon Tech
e-mail: support@helicontech.com